#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    lazy = import ../lazy-extra.nix;
    math = import ../math-extra.nix;
    func = import ../func-extra.nix;

    max = lib.trivial.max;
    str = lib.strings;

    inputFile = str.removeSuffix "\n" (builtins.readFile ./input);
    inputList = str.splitString "\n" inputFile;
    moduleMassList = builtins.map str.toInt inputList;

    fuelPerMass = x: 
      let result = x / 3 - 2;
      in max 0 result;

    part1 = math.sum (map fuelPerMass moduleMassList);

    rocketEquationStep = {totalFuel, lastIncrement}:
        let increment = fuelPerMass lastIncrement;
        in {totalFuel = totalFuel + increment; lastIncrement = increment; };

    rocketEquationSteps = func.while
      ({totalFuel, lastIncrement}: lastIncrement > 0)
      rocketEquationStep;

    rocketEquation = moduleMass: 
      (rocketEquationSteps {totalFuel = 0; lastIncrement = moduleMass;}).totalFuel;

    part2 = math.sum (map rocketEquation moduleMassList);

in lazy.strict {part1 = part1; part2 = part2; }
