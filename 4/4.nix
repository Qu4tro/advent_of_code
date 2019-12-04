#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) head last length any range filter;
    inherit (lib.strings) toInt stringToCharacters;

    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) groupIntoList allBy2 anyBy2;
    inherit (import ../utils.nix) splitAndMapFromTrimmedFile;


    intToDigits = n: stringToCharacters (toString n);
    isIncrementing = allBy2 (x: y: x <= y);


    inputList = splitAndMapFromTrimmedFile ./input "-" toInt;
    intRange = map intToDigits (range (head inputList) (last inputList));


    isValid = digits: (
      let hasSequence = anyBy2 (x: y: x == y);
       in hasSequence digits && isIncrementing digits
    );
    validValues1 = filter isValid intRange;
    part1 = length validValues1;

    isValid2 = digits: (
      let hasOnlyEvenSequences = digits:
            any (xs: length xs == 2) (groupIntoList digits);

        in hasOnlyEvenSequences digits && isIncrementing digits
    );
    validValues2 = filter isValid2 validValues1;
    part2 = length validValues2;

in strict { inherit part1 part2 ; }
