#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.trivial) mod;
    inherit (lib.lists) head foldr;

    abs = n: if n < 0 then -n else n;

    odd = n: mod n 2 == 1;
    even = n: mod n 2 == 0;

    sum = foldr (a: b: a + b) 0;

    min = a: b: if a > b then b else a;
    max = a: b: if a > b then a else b;

    minBy = f: a: b: if f a > f b then b else a;
    maxBy = f: a: b: if f a > f b then a else b;

    minimum = list: foldr min (head list) list;
    maximum = list: foldr max (head list) list;

    minimumBy = f: list: foldr (minBy f) (head list) list;
    maximumBy = f: list: foldr (maxBy f) (head list) list;

    slope = fst: snd: (
      let
        rise = snd.y - fst.y;
        run = snd.x - fst.x;
      in
        if run != 0 then rise * 1.0 / run
                    else null
    );

    manhattanDistance = fst: snd: (
      abs (snd.x - fst.x) + abs (snd.y - fst.y)
    );

    sqrt = sqrtNewton 0.00001 4.0;

    sqrtNewton = epsilon: prev: num: (
      let next = (prev + (num * 1.0) / prev) / 2;
      in
        if abs (next - prev) < (epsilon * next) then next else

        sqrtNewton epsilon next num
    );

    pi = 3.14156;

    atan = z: (
      let n1 = 0.97239411;
          n2 = -0.19194795;
      in (n1 + n2 * z * z) * z
    );

    atan2 = x: y: (
      if x == 0 && y == 0 then 0 else
      if x == 0 && y > 0 then pi / 2 else
      if x == 0 && y < 0 then -pi / 2 else

      if abs x > abs y then
        let z = 1.0 * y / x;
        in
          if x > 0 then
            atan(z)
          else if y >= 0 then
            atan(z) + pi
          else
            atan(z) - pi
      else
        let z = 1.0 * x / y;
        in
          if y > 0 then
            (-atan(z)) + pi / 2
          else
            (-atan(z)) - pi / 2
    );

    rad2def = rad: rad * (180 / pi);


    copysign = (x: y:
      if y >= 0 then abs(x) else -abs(x)
    );

    pseudoangle = (x: y:
      copysign (1.0 - 1.0 * x / (abs x + abs y)) y
    );


in { inherit abs even mod odd sum slope manhattanDistance min max minBy maxBy minimum maximum minimumBy maximumBy sqrt atan atan2 pi rad2def; }
