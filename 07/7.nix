#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) head last length tail range elemAt;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) maximumBy permutations;
    inherit (import ../advent-icpc.nix) readMemory compute;

    memory = readMemory ./input;

    thrusterSignal = inputSignal: memory: phaseSettingSequence: (
      let
          amplifierA = compute memory [(elemAt phaseSettingSequence 0) inputSignal];
          amplifierB = compute memory [(elemAt phaseSettingSequence 1) (last amplifierA.outQ)];
          amplifierC = compute memory [(elemAt phaseSettingSequence 2) (last amplifierB.outQ)];
          amplifierD = compute memory [(elemAt phaseSettingSequence 3) (last amplifierC.outQ)];
          amplifierE = compute memory [(elemAt phaseSettingSequence 4) (last amplifierD.outQ)];

      in last (amplifierE.outQ)
    );

    inputSignal = 0;
    thruster1 = thrusterSignal inputSignal memory;
    phaseSettingPossibilities1 = permutations (range 0 4);
    part1 = thruster1 (maximumBy thruster1 phaseSettingPossibilities1);

in strict {inherit part1;}
