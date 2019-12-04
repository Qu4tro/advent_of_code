#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    minBy = (import ./func-extra.nix).minBy;

    lists = lib.lists;

    replace = (xs: i: v: (lists.take i xs) ++ [v] ++ (lists.drop (i + 1) xs));

    scanl = (op: accum: list: 
      [accum] ++ (
        if list == [] then [] else

        let h = lists.head list;
            t = lists.tail list;
        in scanl op (op accum h) t
        )
    );

    cartesianProduct = (xs: ys:
      if xs == [] || ys == [] then [] else

      (map (y: { fst = builtins.head xs; snd = y; }) ys)
      ++
      (cartesianProduct (builtins.tail xs) ys)
    );

    takeWhile = (p: xs: 
      if xs == [] then [] else

      let h = lists.head xs;
          t = lists.tail xs;
       in if p h then [h] ++ (takeWhile p t)
                 else []
    );

    dropWhile = (p: xs: 
      if xs == [] then [] else

      let h = lists.head xs;
          t = lists.tail xs;
       in if p h then (dropWhile p t)
                 else xs
    );

    upTo = n: lists.range 0 n;

    concat = lists.foldl (a: b: a ++ b) [];

    minimumBy = op: xs: 
      let h = lists.head xs;
          t = lists.tail xs;
      in if lists.length xs == 1 then h else
         minBy op h (minimumBy op t);

    anyBy2 = pred: xs: (
      if lists.length xs < 2 then false else

      let fst = lists.head xs;
          tail = lists.tail xs;
          snd = lists.head tail;
      in pred fst snd || anyBy2 pred tail
    );

    allBy2 = pred: xs: (
      if lists.length xs < 2 then true else

      let fst = lists.head xs;
          tail = lists.tail xs;
          snd = lists.head tail;
      in pred fst snd && allBy2 pred tail
    );

    findFirst2 = pred: default: xs: (
      if lists.length xs < 0 then default else

      let fst = lists.elemAt xs 0;
          snd = lists.elemAt xs 1;
          tail = lists.tail xs;
      in if pred fst snd then {fst = fst; snd = snd;}
                         else findFirst2 pred default tail
    );

    span = pred: xs: (
      if xs == [] then {fst = []; snd = [];} else

      let h = lists.head xs;
          t = lists.tail xs;
      in if pred h then let spanRec = span pred t;
                        in {fst = [h] ++ spanRec.fst; snd = spanRec.snd;}
         else {fst = []; snd = xs;}
    );

    groupIntoListBy = pred: xs: (
      if xs == [] then [] else

      let h = lists.head xs;
          conditionSpan = span (pred h) xs;

      in [conditionSpan.fst] ++ (groupIntoListBy pred conditionSpan.snd)
    );

    groupIntoList = groupIntoListBy (x: y: x == y);

in { inherit allBy2 anyBy2 cartesianProduct concat dropWhile groupIntoList groupIntoListBy minimumBy replace scanl takeWhile upTo ; }
