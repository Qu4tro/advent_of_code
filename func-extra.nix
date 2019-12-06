#!/usr/bin/nix-instantiate --eval

let while = pred: func: x: if pred x then while pred func (func x) else x;
    minBy = func: x: y: if (func x <= func y) then x else y;

    repeat = n: func: x:
      let finalIteration = while (iter: iter.i < n)
                             (iter: {i = iter.i + 1; value = func iter.value;})
                             {i = 0; value = x;};
      in finalIteration.value;

    repeatEnumerating = n: func: x:
    let finalIteration =
            while (iter: iter.i < n)
              (iter: {i = iter.i + 1; value = func iter.i iter.value; })
              {i = 0; value = x;};
      in finalIteration.value;

in { inherit while minBy repeat repeatEnumerating; }
