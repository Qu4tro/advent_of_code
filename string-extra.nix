#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    lists = lib.lists;
    str = lib.strings;
    listsExtra = import ./lists-extra.nix;

    splitAndMap = (delimiter: func: xs: 
      func (str.splitString delimiter xs)
    );
    trim = (xs: 
      let isWhitespace = 
            s: s == "\n" || s == "\r" || s == "\t" || s == " ";
            
          chars = str.stringToCharacters xs;
          trimFront = listsExtra.dropWhile isWhitespace;
          trimBack = listsExtra.takeWhile (x: isWhitespace x == false);

      in str.concatStrings (trimBack (trimFront chars))
    );
in { inherit splitAndMap trim; }
