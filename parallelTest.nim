{.experimental.}
import os
import marshal
import strutils, math, threadpool
import times
import random

proc go(i: int): int =
    sleep(1000)
    return i

proc main() =
    const size = 10
    var a = newSeq[int](size)
    echo getClockStr()
    parallel:
        for i in 0..<a.len:
            if random(1.0) < 0.5:
                a[i] = spawn go(i)
    echo $$a
    echo getClockStr()

main()