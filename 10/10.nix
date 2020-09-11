#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) readFile length split elem getAttr attrNames filter;
    inherit (lib.lists) head last remove findFirst reverseList tail concatLists;
    inherit (lib.strings) splitString stringToCharacters;
    inherit (lib.attrsets) mapAttrs' genAttrs filterAttrs;

    inherit (import ../string-extra.nix) trim splitAndMap;
    inherit (import ../math-extra.nix) sum manhattanDistance slope;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) takeWhile enumerate;
    inherit (import ../advent-utils.nix) splitStringAndMapFromTrimmedFile;

    input = splitStringAndMapFromTrimmedFile ./input "\n" stringToCharacters;
    coordinateGrid = (
      let enumeratedLines = enumerate input;
          coordinateGrid =
              map (elines:
                map (ecolumns:
                  genAttrs ["x" "y" "obj"] (name:
                  if name == "x" then
                    ecolumns.fst
                  else if name == "y" then
                    elines.fst
                  else
                    ecolumns.snd
                  )
              ) (enumerate elines.snd)
          ) enumeratedLines;
      in concatLists coordinateGrid
    );
    asteroidCoordinates =
        map (filterAttrs (n: v: n != "obj"))
          (filter (grid: grid.obj == "#") coordinateGrid);

    preprocessAsteroids = (originAsteroid: targetAsteroid:
      genAttrs ["dx" "dy" "slope" "manhattanDistance"] (attr_name:
        if attr_name == "dx" then
          targetAsteroid.x - originAsteroid.x
        else if attr_name == "dy" then
          targetAsteroid.y - originAsteroid.y
        else if attr_name == "slope" then
          slope originAsteroid targetAsteroid
        else if attr_name == "manhattanDistance" then
          manhattanDistance originAsteroid targetAsteroid
        else
          abort "Aaaaaahhhh"
        )
    );

    isVisibleFrom = (allAsteroids: originAsteroid: targetAsteroid:
      0
    );

    countVisibleAsteroid =
      allAsteroidCoordinates:
      initialAsteroidCoordinate: (
        let
          asteroids = remove initialAsteroidCoordinate allAsteroidCoordinates;
          preprocessedAsteroids = map (preprocessAsteroids initialAsteroidCoordinate) asteroids;
        in preprocessedAsteroids
    );


    part1 = map (countVisibleAsteroid asteroidCoordinates) asteroidCoordinates;
in strict { inherit part1; }
