#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.trivial) mod;

    sum = lib.lists.foldr (a: b: a + b) 0;

    abs = n: if n < 0 then -n else n;
    odd = n: mod n 2 == 1;
    even = n: mod n 2 == 0;

    slope = (fst: snd:
      let
        rise = snd.y - fst.y;
        run = snd.x - fst.x;
      in
        if run != 0 then rise / run
                    else null
    );
    manhattanDistance = (fst: snd: abs (snd.x - fst.x) + abs (snd.y - fst.y));

    quadrant = (vec:
      if vec.x > 0 && vec.y > 0 then
        1
      else if vec.x < 0 && vec.y > 0 then
        2
      else if vec.x < 0 && vec.y < 0 then
        3
      else if vec.x > 0 && vec.y < 0 then
        4
      # not really quadrant anymore
      else if vec.x == 0 && vec.y == 0 then
        0
      else if vec.y == 0 && vec.x > 0 then
        -1
      else if vec.x == 0 && vec.y > 0 then
        -2
      else if vec.y == 0 && vec.x < 0 then
        -3
      else if vec.x == 0 && vec.y < 0 then
        -4
      else
        abort "Aaaaaahhhh"
    );

    semiaxis = (vec:
      if vec.x == 0 && vec.y == 0 then
        0
      else if vec.y == 0 && vec.x > 0 then
        1
      else if vec.x == 0 && vec.y > 0 then
        2
      else if vec.y == 0 && vec.x < 0 then
        3
      else if vec.x == 0 && vec.y < 0 then
        4
      else
        null
    );

in { inherit abs even mod odd sum slope manhattanDistance; }
