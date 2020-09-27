#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (import ./math-extra.nix) sqrt;

    new = x1: x2: (
      { x1 = x1; x2 = x2; }
    );

    zero = (fst: snd:
      new 0 0
    );

    fromPoints = (fst: snd:
      new (fst.x - snd.x) (fst.y - snd.y)
    );

    unit = (vector:
      let mag = magnitude vector;
      in
        new (vector.x1 / mag) (vector.x2 / mag)
    );

    magnitude = (v:
      sqrt (v.x1 * v.x1 + v.x2 * v.x2)
    );

    crossProduct = v1: v2: (
      (v1.x1*v2.x2) - (v1.x2*v2.x1)
    );

in { inherit new zero fromPoints unit magnitude crossProduct; }
