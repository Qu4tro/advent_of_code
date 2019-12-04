#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    math = import ../math-extra.nix;
    lazy = import ../lazy-extra.nix;
    llists = import ../lists-extra.nix;

    min = lib.trivial.min;
    max = lib.trivial.max;

    lists = lib.lists;
    str = lib.strings;

    inputFile = str.removeSuffix "\n" (builtins.readFile ./input);
    inputList = str.splitString "\n" inputFile;
    wires = map (str.splitString ",") inputList;


    manhattanDistance = (fst: snd: math.abs (snd.x - fst.x) + math.abs (snd.y - fst.y));

    applyStep = ({x, y}: step:
      let direction = str.substring 0 1 step;
          distance = str.toInt (str.removePrefix direction step);

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

    findIntersections = (allWires:
      let 
          crossingPoint = ({fst, snd}:
          lists.filter (p: segmentContainsPoint fst p && segmentContainsPoint snd p) 
            (if fst.fst.x == fst.snd.x then 
              [ {x = fst.fst.x; y = snd.fst.y;}]
             else
              [ {x = snd.fst.x; y = fst.fst.y;}]
            )
          );

          segments = map (ps: (lists.zipLists ps (lists.tail ps))) allWires;
          wire1 = lists.head segments;
          wire2 = lists.last segments;

          rawIntersections = map crossingPoint (llists.cartesianProduct wire1 wire2);
          intersections = lists.remove [] rawIntersections;

      in llists.concat intersections
    );


    pathOf = llists.scanl applyStep;

    centralPortPosition = {x = 0; y = 0;};
    wiresPathEdges = map (pathOf centralPortPosition) wires;
    intersections = findIntersections wiresPathEdges;

    part1 = manhattanDistance centralPortPosition
            (llists.minimumBy 
              (manhattanDistance centralPortPosition)
              (lists.remove centralPortPosition intersections)
            );


    stepDistance = manhattanDistance;
    walkingDistance = (path: targetPosition:
      if path == [] then abort "Aaaaaahhhh!" else
      let startingPosition = lists.head path;
          nextPosition = lists.head (lists.tail path);
          remainingPath = lists.tail path;
       in if segmentContainsPoint {fst = startingPosition; snd = nextPosition;} targetPosition then
            stepDistance startingPosition targetPosition
          else
            stepDistance startingPosition nextPosition + walkingDistance remainingPath targetPosition
    );

    summedWalkingDistance = (path1: path2: targetPosition: 
      walkingDistance path1 targetPosition + walkingDistance path2 targetPosition
    );

    wire1PathEdge = lists.head wiresPathEdges;
    wire2PathEdge = lists.last wiresPathEdges;
    part2 = (summedWalkingDistance wire1PathEdge wire2PathEdge)
            (llists.minimumBy 
              (summedWalkingDistance wire1PathEdge wire2PathEdge)
              (lists.remove centralPortPosition intersections)
            );

in lazy.strict {part1 = part1; part2 = part2; }
