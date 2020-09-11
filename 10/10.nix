#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) readFile length split elem getAttr attrNames filter;
    inherit (lib.lists) head last remove findFirst reverseList tail concatLists unique;
    inherit (lib.strings) splitString stringToCharacters;
    inherit (lib.attrsets) mapAttrs' genAttrs filterAttrs;

    inherit (import ../string-extra.nix) trim splitAndMap;
    inherit (import ../math-extra.nix) maximum;
    inherit (import ../vector-extra.nix) mkVector2 unit2;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) enumerate;
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
      let unit = unit2 (mkVector2 originAsteroid targetAsteroid);
      in {x1 = toString unit.x1; x2 = toString unit.x2;}
    );

    countVisibleAsteroid =
      allAsteroidCoordinates:
      initialAsteroidCoordinate: (
        let
          asteroids = remove initialAsteroidCoordinate allAsteroidCoordinates;
          preprocessedAsteroids = map (preprocessAsteroids initialAsteroidCoordinate) asteroids;
          nVisibleAsteroids = length (unique preprocessedAsteroids);
        in nVisibleAsteroids
    );


    part1 = maximum (map (countVisibleAsteroid asteroidCoordinates) asteroidCoordinates);

in strict { inherit part1; }
