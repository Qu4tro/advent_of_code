#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    lists = lib.lists;

    replace = (xs: i: v: (lists.take i xs) ++ [v] ++ (lists.drop (i + 1) xs));

    scanl = (op: accum: list: 
      [accum] ++ (
        if list == [] then 
          [] 
        else let h = lists.head list;
                 t = lists.tail list;
        in scanl op (op accum h) t
        )
    );

    cartesianProduct = (xs: ys:
      if xs == [] || ys == [] then
        [] 
      else 
        (map (y: { fst = builtins.head xs; snd = y; }) ys)
        ++ 
        (cartesianProduct (builtins.tail xs) ys)
    );

    takeWhile = (p: xs: 
      if xs == [] then []
      else let h = lists.head xs;
               t = lists.tail xs;
            in if p h then [h] ++ (takeWhile p t)
                      else []
    );

    dropWhile = (p: xs: 
      if xs == [] then []
      else let h = lists.head xs;
               t = lists.tail xs;
            in if p h then (dropWhile p t)
                      else xs
    );

    upTo = n: lists.range 0 n;

    concat = lists.foldl (a: b: a ++ b) [];

    minimumBy = op: xs: 
      let h = lists.head xs;
          t = lists.tail xs;
          minBy = op: x: y: if (op x <= op y) then x else y;

      in if lists.length xs == 1 then h  
                                 else minBy op h (minimumBy op t);

in { inherit cartesianProduct concat dropWhile minimumBy replace scanl takeWhile upTo ; }
