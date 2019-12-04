#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    math = import ../math-extra.nix;
    lazy = import ../lazy-extra.nix;
    llists = import ../lists-extra.nix;
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

    findIntersections = (allWires:
        let slope = x: 0;
            closestIntersection = ({fst, snd}:
            # Pararel
            if slope fst == slope snd then
              # Vertical
              if fst.fst.x == snd.fst.x then
                0
              # Horizontal
              else if fst.fst.y == snd.fst.y then
                0
            # Certainly not colinear
            else
                null
           # Prependicular
           else
             0
           );

           paintLine = {fst, snd}:
            if fst.x == snd.x then 
              map (n: {x = fst.x; y = n;}) (lists.range fst.y snd.y)
            else
              map (n: {x = n; y = fst.y;}) (lists.range fst.x snd.x);


           closestIntersection2 = ({fst, snd}: lists.intersectLists (paintLine fst) (paintLine snd));

           segments = map (ps: (lists.zipLists ps (lists.tail ps))) allWires;
           segments1 = lists.head segments;
           segments2 = lists.last segments;

           rawIntersections = map closestIntersection2 (llists.cartesianProduct segments1 segments2);
           intersections = lists.remove [] rawIntersections;
       in llists.concat intersections
    );

    pathOf = llists.scanl applyStep;

    centralPortPosition = {x = 0; y = 0;};
    paths = map (pathOf centralPortPosition) wires;

    part1 = manhattanDistance centralPortPosition
            (llists.minimumBy 
              (manhattanDistance centralPortPosition)
              (lists.remove centralPortPosition (findIntersections paths))
            );

# in lazy.strict (llists.intersectionMany paths)
# in lazy.strict (builtins.elemAt paths 1)
in lazy.strict part1
