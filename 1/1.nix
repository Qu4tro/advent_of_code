#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    strings = lib.strings;
    lists = lib.lists;
    strict = (x: builtins.deepSeq x x);

    sum = lists.foldr (a: b: a + b) 0;
    while = (p: f:
      let go = (x: if p x then go (f x) else x);
      in go
    );

    inputFile = builtins.readFile ./input;
    rawList = lists.remove "" (strings.splitString "\n" inputFile);
    moduleMassList = builtins.map strings.toInt rawList;

    fuelPerMass = x: x / 3 - 2;

    part1 = sum (map fuelPerMass moduleMassList);

    rocketEquationSteps = (initialMass: (
      while (x: builtins.head x > 0) (x: 
        let fuelForFuel = fuelPerMass (builtins.head x);
        in [fuelForFuel] ++ x
      ) [initialMass]
    ));
    rocketEquation = (m: sum (lists.tail (lists.init (rocketEquationSteps m))));

    part2 = sum (map rocketEquation moduleMassList);

in strict {part1 = part1; part2 = part2; }
