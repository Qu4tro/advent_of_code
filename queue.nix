#!/usr/bin/nix-instantiate --eval

let lib = import <nixpkgs/lib>;
    inherit (lib.lists) head tail;

    emptyQueue = [];

    dequeue = queue: (
      { value = head queue; updatedQueue = tail queue; }
    );

    enqueue = queue: v: (
      queue ++ [v]
    );

in { inherit emptyQueue dequeue enqueue ; }
