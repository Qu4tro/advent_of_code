#!/usr/bin/nix-instantiate --eval

let while = (p: f: x: if p x then while p f (f x) else x);
in { inherit while; }
