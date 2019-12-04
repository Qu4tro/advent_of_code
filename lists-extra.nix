#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) head tail take drop range length foldl elemAt;
    inherit (import ./func-extra.nix) minBy;

    replace = (xs: i: v: (take i xs) ++ [v] ++ (drop (i + 1) xs));

    scanl = (op: accum: list: 
      [accum] ++ (
        if list == [] then [] else

        let h = head list;
            t = tail list;
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

      let h = head xs;
          t = tail xs;
       in if p h then [h] ++ (takeWhile p t)
                 else []
    );

    dropWhile = (p: xs: 
      if xs == [] then [] else

      let h = head xs;
          t = tail xs;
       in if p h then (dropWhile p t)
                 else xs
    );

    upTo = n: range 0 n;

    concat = foldl (a: b: a ++ b) [];

    minimumBy = op: xs: 
      let h = head xs;
          t = tail xs;
      in if length xs == 1 then h else
         minBy op h (minimumBy op t);

    anyBy2 = pred: xs: (
      if length xs < 2 then false else

      let fst = elemAt xs 0;
          snd = elemAt xs 1;
      in pred fst snd || anyBy2 pred (tail xs)
    );

    allBy2 = pred: xs: (
      if length xs < 2 then true else

      let fst = elemAt xs 0;
          snd = elemAt xs 1;
      in pred fst snd && allBy2 pred (tail xs)
    );

    findFirst2 = pred: default: xs: (
      if length xs < 0 then default else

      let fst = elemAt xs 0;
          snd = elemAt xs 1;
      in if pred fst snd then {fst = fst; snd = snd;}
                         else findFirst2 pred default (tail xs)
    );

    span = pred: xs: (
      if xs == [] then {fst = []; snd = [];} else

      let h = head xs;
          t = tail xs;
      in if pred h then let spanRec = span pred t;
                        in {fst = [h] ++ spanRec.fst; snd = spanRec.snd;}
         else {fst = []; snd = xs;}
    );

    groupIntoListBy = pred: xs: (
      if xs == [] then [] else

      let h = head xs;
          conditionSpan = span (pred h) xs;

      in [conditionSpan.fst] ++ (groupIntoListBy pred conditionSpan.snd)
    );

    groupIntoList = groupIntoListBy (x: y: x == y);

in { inherit allBy2 anyBy2 cartesianProduct concat dropWhile groupIntoList groupIntoListBy minimumBy replace scanl takeWhile upTo ; }
