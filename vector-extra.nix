#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (import ./math-extra.nix) sqrt;

    mkVector2 = (fst: snd:
      { x1 = fst.x - snd.x ; x2 = fst.y - snd.y; }
    );

    unit2 = (vector:
      let magnitude = magnitude2 vector.x1 vector.x2;
      in
        { x1 = vector.x1 / magnitude; x2 = vector.x2 / magnitude; }
    );

    magnitude2 = (x1: x2:
      sqrt (x1 * x1 + x2 * x2)
    );


in { inherit mkVector2 unit2; }
