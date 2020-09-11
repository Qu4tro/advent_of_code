#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) head last tail filter remove zipLists;
    inherit (lib.strings) toInt splitString substring removePrefix;
    inherit (lib.trivial) min max;

    inherit (import ../math-extra.nix) manhattanDistance;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) concat minimumBy cartesianProduct scanl;
    inherit (import ../advent-utils.nix) splitStringAndMapFromTrimmedFile;

    wires = splitStringAndMapFromTrimmedFile ./input "\n" (splitString ",");
    wire1 = head wires;
    wire2 = last wires;

    applyStep = ({x, y}: step:
      let direction = substring 0 1 step;
          distance = toInt (removePrefix direction step);

      in if direction == "R" then
        { x = x + distance; y = y; }
      else if direction == "L" then
        { x = x - distance; y = y; }
      else if direction == "U" then
        { x = x; y = y + distance; }
      else if direction == "D" then
        { x = x; y = y - distance; }
      else abort "Aaaaaahhhh!"
    );

    segmentContainsPoint = ({fst, snd}: {x, y}:
      (fst.x == x && (min fst.y snd.y) <= y && (max fst.y snd.y) >= y) ||
      (fst.y == y && (min fst.x snd.x) <= x && (max fst.x snd.x) >= x)
    );

    findIntersections = (wire1: wire2:
      let
        crossingPoint = ({fst, snd}:
          filter (p: segmentContainsPoint fst p && segmentContainsPoint snd p)
            (if fst.fst.x == fst.snd.x then
              [ {x = fst.fst.x; y = snd.fst.y;}]
             else
              [ {x = snd.fst.x; y = fst.fst.y;}]
            )
        );

        segments1 = zipLists wire1 (tail wire1);
        segments2 = zipLists wire2 (tail wire2);

        intersections =
          remove [] (
            map crossingPoint
            (cartesianProduct segments1 segments2)
          );

      in concat intersections
    );


    centralPortPosition = {x = 0; y = 0;};
    pathOf = scanl applyStep centralPortPosition;
    wire1Path = pathOf wire1;
    wire2Path = pathOf wire2;

    intersections =
      remove centralPortPosition
        (findIntersections wire1Path wire2Path);

    part1 =
      manhattanDistance centralPortPosition
        (minimumBy
          (manhattanDistance centralPortPosition)
          intersections
        );


    stepDistance = manhattanDistance;
    walkingDistance = (path: targetPosition:
      if path == [] then abort "Aaaaaahhhh!" else

      let startingPosition = head path;
          nextPosition = head (tail path);
          remainingPath = tail path;
          nextPathContainsTarget =
            segmentContainsPoint
                {fst = startingPosition; snd = nextPosition;} targetPosition;
       in if nextPathContainsTarget then
            stepDistance startingPosition targetPosition
          else
            stepDistance startingPosition nextPosition
            + walkingDistance remainingPath targetPosition
    );

    summedWalkingDistance = (path1: path2: targetPosition:
      walkingDistance path1 targetPosition
      + walkingDistance path2 targetPosition
    );

    part2 =
      (summedWalkingDistance wire1Path wire2Path)
        (minimumBy
          (summedWalkingDistance wire1Path wire2Path)
          intersections
        );

in strict { inherit part1 part2 ; }
