{.experimental.}
import os
import marshal
import strutils, math, threadpool
import times

proc go(i: int): int =
    sleep(1000)
    return i

proc main() =
    const size = 10
    var a = newSeq[int](size)
    echo getClockStr()
    parallel:
        for i in 0..a.high:
            a[i] = spawn go(i)
    echo $$a
    echo getClockStr()

main()