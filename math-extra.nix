#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.trivial) mod;
    inherit (lib.lists) head foldr;

    min = a: b: if a > b then b else a;
    max = a: b: if a > b then a else b;
    minBy = f: a: b: if f a > f b then b else a;
    maxBy = f: a: b: if f a > f b then a else b;

    abs = n: if n < 0 then -n else n;
    odd = n: mod n 2 == 1;
    even = n: mod n 2 == 0;

    sum = foldr (a: b: a + b) 0;
    minimum = list: foldr min (head list) list;
    maximum = list: foldr max (head list) list;

    minimumBy = f: list: foldr (minBy f) (head list) list;
    maximumBy = f: list: foldr (maxBy f) (head list) list;

    slope = (fst: snd:
      let
        rise = snd.y - fst.y;
        run = snd.x - fst.x;
      in
        if run != 0 then rise * 1.0 / run
                    else null
    );
    manhattanDistance = (fst: snd: abs (snd.x - fst.x) + abs (snd.y - fst.y));

    unitVector = (fst: snd:
      { x = 0; y = 0; }
    );


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

    sqrt = sqrtNewton 0.00001 4.0;

    sqrtNewton = (epsilon: prev: num:
      let next = (prev + (num * 1.0) / prev) / 2;
      in
        if abs (next - prev) < (epsilon * next) then next else

        sqrtNewton epsilon next num
    );


in { inherit abs even mod odd sum slope manhattanDistance min max minBy maxBy minimum maximum minimumBy maximumBy sqrt; }
