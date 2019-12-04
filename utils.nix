#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) readFile;
    inherit (lib.strings) splitString stringToCharacters concatStrings;
    inherit (import ./string-extra.nix) splitAndMap trim;

    splitAndMapFromTrimmedFile = (path: delimiter: func:
      splitAndMap delimiter func
            (trim (readFile path))
    );

in { inherit splitAndMapFromTrimmedFile; }
