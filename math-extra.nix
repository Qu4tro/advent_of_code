#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    abs = x: if x < 0 then -x else x;
    sum = lib.lists.foldr (a: b: a + b) 0;
in { inherit abs sum; }
