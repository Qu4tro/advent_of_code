#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.trivial) mod;

    sum = lib.lists.foldr (a: b: a + b) 0;

    abs = n: if n < 0 then -n else n;
    odd = n: mod n 2 == 1;
    even = n: mod n 2 == 0;

in { inherit abs even mod odd sum; }
