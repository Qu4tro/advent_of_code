#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) readFile length split elem getAttr attrNames;
    inherit (lib.lists) head last remove findFirst reverseList tail;
    inherit (lib.strings) splitString;
    inherit (lib.attrsets) genAttrs zipAttrsWith;

    inherit (import ../string-extra.nix) trim splitAndMap;
    inherit (import ../math-extra.nix) sum;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) takeWhile;
    inherit (import ../advent-utils.nix) splitAndMapFromTrimmedFile;

    orbits =
      let
        orbitPairsList =
          splitAndMapFromTrimmedFile ./input "\n" (line:
            remove [] (split "[[:punct:]]" line)
          );
        orbitPairsAttrSetsList =
          map
            (pair: genAttrs [(last pair)] (_: head pair))
            orbitPairsList;
        orbitPairsAttrSet =
          zipAttrsWith
            (name: values: head values)
            orbitPairsAttrSetsList;
      in
        orbitPairsAttrSet;

    countOrbitsOf = (allOrbits: object:
      if object == "COM" then 0 else

      1 + countOrbitsOf allOrbits (getAttr object allOrbits)
    );

    orbitalTransfersTo = (from: to:
      let
        orbitPath = (allOrbits: object:
          if object == "COM" then ["COM"] else

          [object] ++ (orbitPath allOrbits (getAttr object allOrbits))
        );

        orbitIntersection = (orbitPath1: orbitPath2:
          findFirst (x: elem x orbitPath2) (abort "Not found") orbitPath1
        );

        orbitPathFromToCom = orbitPath orbits from;
        orbitPathToToCom = orbitPath orbits to;
        intersectionObject = orbitIntersection orbitPathFromToCom orbitPathToToCom;
        fromPath = takeWhile (x: x != intersectionObject) orbitPathFromToCom;
        toPath = takeWhile (x: x != intersectionObject) orbitPathToToCom;
      in
        tail (fromPath) ++ [intersectionObject] ++ (reverseList (tail toPath))
    );

    part1 = sum (map (countOrbitsOf orbits) (attrNames orbits));
    part2 = length (orbitalTransfersTo "YOU" "SAN") - 1;

in strict { inherit part1 part2; }
