let lib = import <nixpkgs/lib>;
    lists = lib.lists;
    str = lib.strings;
    listsExtra = import ./lists-extra.nix;

    splitAndMap = (delimiter: func: xs: 
      map func (str.splitString delimiter xs)
    );
    trim = (xs: 
      let isWhitespace = 
            s: s == "\n" || s == "\r" || s == "\t" || s == " ";
            
          chars = str.stringToCharacters xs;
          trimFront = listsExtra.dropWhile isWhitespace;
          trimBack = xs: lists.reverseList (trimFront (lists.reverseList xs));

      in str.concatStrings (trimBack (trimFront chars))
    );
in { inherit splitAndMap trim; }
