#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) readFile length split elem getAttr attrNames filter trace;
    inherit (lib.lists) head last remove findFirst reverseList tail concatLists unique elemAt sort;
    inherit (lib.strings) splitString stringToCharacters;
    inherit (lib.attrsets) mapAttrs' genAttrs filterAttrs;

    inherit (import ../string-extra.nix) trim splitAndMap;
    inherit (import ../math-extra.nix) maximum maximumBy manhattanDistance atan2 pseudoangle rad2def;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) enumerate uniqueBy removeMany rotateUntil;
    inherit (import ../advent-utils.nix) splitStringAndMapFromTrimmedFile;
    vector = import ../vector2.nix;

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
      let unit = vector.unit (vector.fromPoints originAsteroid targetAsteroid);
      in {x1 = toString unit.x1; x2 = toString unit.x2;}
    );

    countVisibleAsteroid =
      allAsteroids:
      initialAsteroid: (
        let
          asteroids = remove initialAsteroid allAsteroids;
          preprocessedAsteroids = map (preprocessAsteroids initialAsteroid) asteroids;
          nVisibleAsteroids = length (unique preprocessedAsteroids);
        in nVisibleAsteroids
    );


    idealPosition = maximumBy (countVisibleAsteroid asteroidCoordinates) asteroidCoordinates;
    part1 = countVisibleAsteroid asteroidCoordinates idealPosition;

    listVisibleAsteroid =
      allAsteroids:
      initialAsteroid: (
        let
          asteroids = remove initialAsteroid allAsteroids;
          visibleAsteroids = uniqueBy (preprocessAsteroids initialAsteroid) (sort (a: b: manhattanDistance initialAsteroid a < manhattanDistance initialAsteroid b) asteroids);
        in visibleAsteroids
    );

    laserFullRotation = (originAsteroid: allAsteroids:
      removeMany (listVisibleAsteroid allAsteroids originAsteroid) allAsteroids
    );

    laserOrderedRotation = (originAsteroid: allAsteroids:
      let rotateF = rotateUntil (a: a.x >= originAsteroid.x && a.y < originAsteroid.y);
          sortF = sort (fst: snd:
                          let v1 = vector.unit (vector.fromPoints originAsteroid fst);
                              v2 = vector.unit (vector.fromPoints originAsteroid snd);
                          in atan2 v1.x1 v1.x2 > atan2 v2.x1 v2.x2
                       );
          visibleAsteroids = listVisibleAsteroid allAsteroids originAsteroid;
      in
          rotateF (sortF visibleAsteroids)
    );

    nthAsteroidVaporized = (originAsteroid: allAsteroids: n:
    let
        nInitialAsteroids = length allAsteroids;
        remainingAsteroids = laserFullRotation originAsteroid allAsteroids;
        nRemainingAsteroids = length remainingAsteroids;
        nVaporizedAsteroids = trace (nInitialAsteroids - nRemainingAsteroids) (nInitialAsteroids - nRemainingAsteroids);
    in if nVaporizedAsteroids == 0 then
      abort "Never got to n."
    else if nVaporizedAsteroids >= n then
      # laserOrderedRotation originAsteroid allAsteroids
      elemAt (laserOrderedRotation originAsteroid allAsteroids) n
    # else if nVaporizedAsteroids != countVisibleAsteroid allAsteroids originAsteroid then
    #   abort "Wrong"
    else
      nthAsteroidVaporized originAsteroid remainingAsteroids (n - nVaporizedAsteroids)
    );

    # pos = {x = 4; y = 4;};
    # bet = nthAsteroidVaporized pos asteroidCoordinates 9;
    bet = nthAsteroidVaporized idealPosition asteroidCoordinates 200;
    part2 = bet.x * 100 + bet.y;

    # abc = listVisibleAsteroid asteroidCoordinates pos;

# in strict { inherit abc; }
in strict { inherit part1 part2; }
