#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) add mul div;
    inherit (lib.lists) head last elemAt any reverseList;
    inherit (lib.strings) toInt fixedWidthString concatStrings stringToCharacters;
    inherit (lib.trivial) mod;

    inherit (import ../queue.nix) emptyQueue dequeue enqueue;
    inherit (import ../string-extra.nix) stringToDigits;
    inherit (import ../func-extra.nix) while repeat;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) replace;
    inherit (import ../utils.nix) splitAndMapFromTrimmedFile;

    memory = splitAndMapFromTrimmedFile ./input "," toInt;
    immediateMode = "1";
    positionMode = "0";

    op1 = p1: p2: p3: context: (
      context // (
        with context;
        { mem = replace mem p3 (add p1 p2);
          iPointer = iPointer + 4; 
        }
      )
    );

    op2 = p1: p2: p3: context: (
      context // (
        with context;
        { mem = replace mem p3 (mul p1 p2);
          iPointer = iPointer + 4;
        }
      )
    );

    op3 = p1: context: (
      context // (
        with context;
        let dequeueResult = dequeue inQ;
        in { mem = replace mem p1 dequeueResult.value;
             inQ = dequeueResult.updatedQueue;
             iPointer = iPointer + 2;
           }
      )
    );

    op4 = p1: context: (
      context // (
        with context;
        { outQ = enqueue outQ p1;
          iPointer = iPointer + 2;
        }
      )
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

    decodeOp = context: (
      with context;
      let opInt = elemAt mem iPointer;
          opV = mod opInt 100;
          modes = decodeOpModes opInt;

          readRef = i: elemAt mem (iPointer + i + 1);
          readValue = i: (
            if (elemAt modes i) == immediateMode
                then elemAt mem (iPointer + i + 1)
                else elemAt mem (elemAt mem (iPointer + i + 1))
          );


          op = { opV = opV;
           opF = (
             if opV == 1 then
               op1 (readValue 0) (readValue 1) (readRef 2)
             else if opV == 2 then
               op2 (readValue 0) (readValue 1) (readRef 2)
             else if opV == 3 then
               op3 (readRef 0)
             else if opV == 4 then
               op4 (readValue 0)
             else if opV == 99 then
               null
             else
               null
           );
           modes = modes;
         };

         halted = if op.opF == null then true else false;

      in context // { op = op; halted = halted; }
    );

    computeStep = inContext: (
      let context = decodeOp inContext;
          haltConditionTrue = context.op.opV == 99;

      in if context.halted then context
                           else context.op.opF context
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
    part1 = (compute memory inputQueue);

in strict { inherit part1; }
