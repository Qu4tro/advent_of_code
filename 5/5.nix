#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) last;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../advent-icpc.nix) readMemory compute;

    memory = readMemory ./input;

    part1 = last ((compute memory [1]).outQ);
    part2 = last ((compute memory [5]).outQ);

in strict { inherit part1 part2; }
