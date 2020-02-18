#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) readFile;
    inherit (lib.strings) splitString stringToCharacters concatStrings;
    inherit (import ./string-extra.nix) splitAndMap splitStringAndMap trim;

    splitAndMapFromTrimmedFile = (path: delimiter: func:
      splitAndMap delimiter func
            (trim (readFile path))
    );
    splitStringAndMapFromTrimmedFile = (path: delimiter: func:
      splitStringAndMap delimiter func
            (trim (readFile path))
    );

in { inherit splitAndMapFromTrimmedFile splitStringAndMapFromTrimmedFile; }
