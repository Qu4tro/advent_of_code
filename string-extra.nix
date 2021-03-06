let lib = import <nixpkgs/lib>;
    inherit (lib.lists) reverseList remove;
    inherit (lib.strings) splitString stringToCharacters concatStrings;
    inherit (import ./lists-extra.nix) dropWhile;

    splitAndMap = (delimiter: func: xs:
      map func (remove [] (builtins.split delimiter xs))
    );

    splitStringAndMap = (delimiter: func: xs:
      map func (splitString delimiter xs)
    );

    trim = (xs:
      let isWhitespace =
            s: s == "\n" || s == "\r" || s == "\t" || s == " ";

          chars = stringToCharacters xs;
          trimFront = dropWhile isWhitespace;
          trimBack = xs: reverseList (trimFront (reverseList xs));

      in concatStrings (trimBack (trimFront chars))
    );

    stringToDigits = str: stringToCharacters (toString str);

in { inherit splitAndMap splitStringAndMap trim stringToDigits; }
