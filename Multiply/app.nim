import std/times
import std/strutils

template benchmark(benchmarkName: string, code: untyped) =
    block:
        let t0 = epochTime()
        code
        let elapsed = epochTime() - t0
        let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
        echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

proc multiply(a, b: int): int =
    var
        left = a
        right = b
    while left != 0:
        if left mod 2 != 0: # Check rightmost bit
            result += right
        left = left div 2   # Bitshift right
        right = right * 2   # Bitshift left

const size = 100_000_000
var y = 0.0
benchmark "multiply":
    for i in 0..<size:
        y += (float)multiply(4678, 231452)
echo y

y = 0.0
benchmark "*":
    for i in 0..size:
        y += 4678*231452
echo y
