#!/usr/bin/nix-instantiate --eval

let not = bool: if bool then false else true;

in { inherit not; }
