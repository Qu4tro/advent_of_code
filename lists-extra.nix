#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    lists = lib.lists;

    replace = (xs: i: v: (lists.take i xs) ++ [v] ++ (lists.drop (i + 1) xs));

    listIntersection = (xs: ys: 
      if xs == [] || ys == [] then
        []
      else let h = lists.head xs;
               t = lists.tail xs;
      in if lists.elem h ys then 
        [h] ++ listIntersection t ys
      else 
        listIntersection t ys
    );
    listIntersectionMany = (xss: lists.foldl listIntersection (lists.head xss) xss);

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


in { inherit cartesianProduct dropWhile listIntersection listIntersectionMany replace scanl takeWhile ; }
