#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (builtins) add mul div;
    inherit (lib.lists) head foldr elemAt any reverseList;
    inherit (lib.strings) toInt;
    inherit (lib.trivial) mod;

    inherit (import ../queue.nix) emptyQueue dequeue enqueue;
    inherit (import ../string-extra.nix) stringToDigits;
    inherit (import ../func-extra.nix) while;
    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) replace;
    inherit (import ../utils.nix) splitAndMapFromTrimmedFile;

    memory = splitAndMapFromTrimmedFile ./input "," toInt;

    op1 = {mem, inQ, outQ, op, iPointer, halted}: (
      let p1 = elemAt mem (iPointer + 0);
          p2 = elemAt mem (iPointer + 1);
          p3 = elemAt mem (iPointer + 2);

          v1 = elemAt mem p1;
          v2 = elemAt mem p2;

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

          v1 = elemAt mem p1;
          v2 = elemAt mem p2;

      in { 
        inherit inQ outQ op halted;
        mem = replace mem p3 (mul v1 v2);
        iPointer = iPointer + 3;
      }
    );

    op3 = {mem, inQ, outQ, op, iPointer, halted}: (
      let dequeueResult = dequeue inQ;
          p1 = elemAt mem (iPointer + 1);
          
      in { 
        inherit outQ op halted;
        mem = replace mem p1 dequeueResult.value;
        inQ = dequeueResult.updatedQueue;
        iPointer = iPointer + 1;
      }
    );

    op4 = {mem, inQ, outQ, op, iPointer, halted}: (
      let p1 = elemAt mem (iPointer + 1);
          newOutQ = enqueue outQ (elemAt mem p1);
          
      in { 
        inherit mem inQ op halted;
        outQ = newOutQ;
        iPointer = iPointer + 1;
      }
    );

    decodeOp = {mem, inQ, outQ, op, iPointer, halted}: (
      let opInt = elemAt mem iPointer;
          opV = mod opInt 100;
          opM = reverseList (stringToDigits (div opInt 100));
      in { 
           inherit mem inQ outQ halted;
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
                 abort "Aaaaaahhhh!"
             );
             modes = opM;
           };

           iPointer = iPointer + 1;
         }
    );

    computeStepTest = context: (
      let newContext = decodeOp context;

          haltConditionTrue =
            newContext.op.opV == 99
            || any (x: x != 0) newContext.outQ; # TODO: RemoveTHIS

      in if haltConditionTrue then newContext // { halted = true; }
                              else newContext.op.call newContext
      );

    compute = mem: inQ: (
      while (c: !c.halted) computeStepTest
        { inherit mem inQ; 
          iPointer = 0;
          outQ = emptyQueue;
          halted = false;
          op = null;
        }
    );


    # We'll always start at 0, so let's create a helper function for that
    # We'll also always want to grab the head and return it
    compute_and_return = (mem: compute mem emptyQueue);


    # Inputs noun and verb into memory to fix the gravity assistance
    restoreGravityAssist = (mem: noun: verb: 
      replace (replace mem 1 noun) 2 verb
    );

    magicParam1 = 12;
    magicParam2 = 02;

    # What's the return value of a computation with the magic parameters?
    part1 = compute_and_return 
              (restoreGravityAssist memory magicParam1 magicParam2);


in strict { inherit part1 ; }
# in strict (computeStepTest
#         { mem = memory;
#           inQ = emptyQueue;
#           outQ = emptyQueue;
#           iPointer = 0;
#           halted = false;
#           op = null;
#         }
#         )
