#!/usr/bin/nix-instantiate --eval

let while = pred: func: x: if pred x then while pred func (func x) else x;
    minBy = func: x: y: if (func x <= func y) then x else y;
in { inherit while minBy; }
