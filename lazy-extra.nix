#!/usr/bin/nix-instantiate --eval

let strict = x: builtins.deepSeq x x;
in { inherit strict; }
