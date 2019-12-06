#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) add mul div;
    inherit (lib.lists) head last elemAt any reverseList;
    inherit (lib.strings) toInt fixedWidthString concatStrings stringToCharacters;
    inherit (lib.trivial) mod;

    inherit (import ../queue.nix) emptyQueue dequeue enqueue;
    inherit (import ../string-extra.nix) stringToDigits;
    inherit (import ../func-extra.nix) while;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) replace;
    inherit (import ../utils.nix) splitAndMapFromTrimmedFile;

    memory = splitAndMapFromTrimmedFile ./input "," toInt;
    immediateMode = "1";
    positionMode = "0";

    op1 = {mem, inQ, outQ, op, iPointer, halted}: (
      let p1 = elemAt mem (iPointer + 0);
          p2 = elemAt mem (iPointer + 1);
          p3 = elemAt mem (iPointer + 2);

          v1 = if elemAt (op.modes) 0 == immediateMode
                then p1
                else elemAt mem p1;

          v2 = if elemAt (op.modes) 1 == immediateMode
                then p2
                else elemAt mem p2;
      in { 
        inherit inQ outQ op halted;
        mem = replace mem p3 (add v1 v2);
        iPointer = iPointer + 3;
      }
    );

    op2 = {mem, inQ, outQ, op, iPointer, halted}: (
      let p1 = elemAt mem (iPointer + 0);
          p2 = elemAt mem (iPointer + 1);
          p3 = elemAt mem (iPointer + 2);

          v1 = if elemAt (op.modes) 0 == immediateMode
                then p1
                else elemAt mem p1;

          v2 = if elemAt (op.modes) 1 == immediateMode
                then p2
                else elemAt mem p2;
      in { 
        inherit inQ outQ op halted;
        mem = replace mem p3 (mul v1 v2);
        iPointer = iPointer + 3;
      }
    );

    op3 = {mem, inQ, outQ, op, iPointer, halted}: (
      let dequeueResult = dequeue inQ;
          x = builtins.trace (toString mem) mem;
          p1 = elemAt mem iPointer;
          
      in { 
        inherit outQ op halted;
        mem = replace mem p1 dequeueResult.value;
        inQ = dequeueResult.updatedQueue;
        iPointer = iPointer + 1;
      }
    );

    op4 = {mem, inQ, outQ, op, iPointer, halted}: (
      let p1 = elemAt mem iPointer;
          v1 = if elemAt (op.modes) 0 == immediateMode
                then p1
                else elemAt mem p1;

          newOutQ = enqueue outQ v1;
          
      in { 
        inherit mem inQ op halted;
        outQ = newOutQ;
        iPointer = iPointer + 1;
      }
    );

    decodeOpModes = opInt: (
      let opM = div opInt 100;
      in
        reverseList (
          (stringToCharacters 
          (fixedWidthString 10 "0"
          (concatStrings 
          (stringToDigits opM)))))
    );

    decodeOp = {mem, inQ, outQ, op, iPointer, halted}: (
      let opInt = elemAt mem iPointer;
          opV = mod opInt 100;
          modes = decodeOpModes opInt;

          op = {
             opV = opV;
             call = (
               if opV == 1 then
                 op1
               else if opV == 2 then
                 op2
               else if opV == 3 then
                 op3
               else if opV == 4 then
                 op4
               else if opV == 99 then
                 null
               else
               abort (concatStrings [
                 "Aaaaaahhhh! Unknown opcode: "
                 (toString opV)
               ])
             );
             modes = modes;
           };

      in {
           inherit mem inQ outQ op halted;
           iPointer = iPointer + 1;
         }
    );

    computeStep = context: (
      let newContext = decodeOp context;

          haltConditionTrue =
            newContext.op.opV == 99
            || any (x: x != 0) newContext.outQ; # TODO: RemoveTHIS

      in if haltConditionTrue then newContext // { halted = true; }
                              else newContext.op.call newContext
      );

    computeStepTest = context: (
      let newContext = decodeOp context;
          haltConditionTrue = newContext.op.opV == 99;

      in if haltConditionTrue then newContext // { halted = true; }
                              else newContext.op.call newContext
      );

    initialComputationState = mem: inQ:
      { inherit mem inQ; 
        iPointer = 0;
        outQ = emptyQueue;
        halted = false;
        op = null;
      };

    compute = mem: inQ:
      while (c: !c.halted) computeStep
        (initialComputationState mem inQ);

    inputQueue = enqueue emptyQueue 1;
    part1 = last ((compute memory inputQueue).outQ);

in strict { inherit part1; }
