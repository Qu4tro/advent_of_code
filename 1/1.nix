#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) head findFirst range;
    inherit (lib.strings) toInt;
    inherit (lib.trivial) max;

    inherit (import ../math-extra.nix) sum;
    inherit (import ../func-extra.nix) while;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) replace cartesianProduct;
    inherit (import ../utils.nix) splitAndMapFromTrimmedFile;

    moduleMassList = splitAndMapFromTrimmedFile ./input "\n" toInt;

    fuelPerMass = x: 
      let result = x / 3 - 2;
      in max 0 result;

    part1 = sum (map fuelPerMass moduleMassList);

    rocketEquationStep = {totalFuel, lastIncrement}:
        let increment = fuelPerMass lastIncrement;
        in {totalFuel = totalFuel + increment; lastIncrement = increment; };

    rocketEquationSteps = while
      ({totalFuel, lastIncrement}: lastIncrement > 0)
      rocketEquationStep;

    rocketEquation = moduleMass: 
      (rocketEquationSteps {totalFuel = 0; lastIncrement = moduleMass;}).totalFuel;

    part2 = sum (map rocketEquation moduleMassList);

in strict { inherit part1 part2 ; }
