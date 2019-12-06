#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) head findFirst range;
    inherit (lib.strings) toInt;

    inherit (import ../lazy-extra.nix) strict;
    inherit (import ../lists-extra.nix) replace cartesianProduct;
    inherit (import ../utils.nix) splitAndMapFromTrimmedFile;

    memory = splitAndMapFromTrimmedFile ./input "," toInt;

    # Our compute function
    # Params:
    #    - iPointer : int
    #       Parameter that indicates where in the memory does
    #       it start to execute the instructions
    #    - memory : [int]
    #       A list of integers, representing the memory of our computer
    #       It contains the instructions it's running plus additional data
    # Returns:
    #    - memory : [int]
    #       An updated state of the memory when halting
    computeInstructionsF = (iPointer: mem:
      let op = builtins.elemAt mem iPointer;
      in
        # We start by checking for stop conditions.
        # In this case, we know we should stop when we encounter a 99
        if op == 99 then mem else

        # Otherwise, let's figure out the instruction and prepare the execution
        let
          opF =
            if op == 1 then
              builtins.add
            else if op == 2 then
              builtins.mul
            else
              # This should not happen according to spec
              builtins.abort "something went wrong.";

          # Let's define all the parameters: p1, p2, p3
          # Each parameter is a pointer for a location in memory
          p1 = builtins.elemAt mem (iPointer + 1);
          p2 = builtins.elemAt mem (iPointer + 2);
          p3 = builtins.elemAt mem (iPointer + 3);

          # And finally fetch the values of the first and second
          # parameter from memory
          v1 = builtins.elemAt mem p1;
          v2 = builtins.elemAt mem p2;

        in
          let updatedMemory = replace mem p3 (opF v1 v2);
          in computeInstructionsF (iPointer + 4) updatedMemory
    );

    # We'll always start at 0, so let's create a helper function for that
    # We'll also always want to grab the head and return it
    compute_and_return = (mem: head (computeInstructionsF 0 mem));

    # Inputs noun and verb into memory to fix the gravity assistance
    restoreGravityAssist = (mem: noun: verb:
      replace (replace mem 1 noun) 2 verb
    );

    magicParam1 = 12;
    magicParam2 = 02;

    # What's the return value of a computation with the magic parameters?
    part1 = compute_and_return
              (restoreGravityAssist memory magicParam1 magicParam2);

    # What are the the magic parameters, to get magicNumber as the return value?
    magicNumber = 19690720;

    # Helper to return the pair of noun and verb as a number
    fixToNum = ({fst, snd}: 100 * fst + snd);

    # Let's try them all
    findRightFix = findFirst 
        ({fst, snd}: compute_and_return
                       (restoreGravityAssist memory fst snd) == magicNumber)
        (builtins.abort "No solution found. We need to abort!!")
        (cartesianProduct (range 1 99) (range 1 99));

    part2 = fixToNum findRightFix;

in strict { inherit part1 part2 ; }
