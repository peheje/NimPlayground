import os, threadpool

var chan: Channel[string]
open(chan)

proc say_hello() =
    chan.send("Hello!")

spawn say_hello()
echo chan.recv()