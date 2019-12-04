#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    str = lib.strings;
    stringsExtra = import ./string-extra.nix;

    splitAndMapFromTrimmedFile = (path: delimiter: func:
      stringsExtra.splitAndMap delimiter func
            (stringsExtra.trim (builtins.readFile path))
    );

in { inherit splitAndMapFromTrimmedFile; }
