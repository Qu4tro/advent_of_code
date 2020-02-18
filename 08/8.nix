#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) readFile trace;
    inherit (lib.strings) stringToCharacters concatStrings intersperse;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../string-extra.nix) trim;
    inherit (import ../lists-extra.nix) chunks minimumBy countEqual zipManyListsWith;

    width = 25;
    height = 6;
    area = width * height;
    layers = chunks area (stringToCharacters (trim (readFile ./input)));

    checksum = layersToChecksum: (
      let layer = minimumBy (countEqual "0") layersToChecksum;
      in (countEqual "1" layer) * (countEqual "2" layer)
    );
    part1 = checksum layers;

    black = "0";
    white = "1";
    transparent = "2";

    visiblePixel = topPixel: bottomPixel: (
      if topPixel != transparent then topPixel else bottomPixel
    );

    decode = imageLayers: (
      let decodedLayer = zipManyListsWith visiblePixel imageLayers;
          paintedLayer = map (c: if c == white then "█" else " ") decodedLayer;
          chunkedLayer = (chunks width paintedLayer);
          splitedLayer = intersperse "\n" (map concatStrings chunkedLayer);
      in concatStrings (["\n"] ++ splitedLayer)
    );

    part2 = trace (decode layers) (decode layers);

in strict {inherit part1 part2;}
