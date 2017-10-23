{.experimental.}
import random
import os
import strutils, math, threadpool
import times

const NUM_CHARACTERS = 10
const TARGET = @[0, 0, 1, 1, 2, 2]


type
    Agent* = ref object
        data*: seq[int]
        fitness*: float

proc newAgent(): Agent =
    result = Agent()
    result.fitness = -1.0
    result.data = newSeq[int](TARGET.len)
    for i in 0..<TARGET.len:
        result.data[i] = random(NUM_CHARACTERS)

proc mutate(s: seq[Agent]) =
    s[0].fitness = 100

proc main() =
    const SIZE = 10
    var s = newSeq[Agent](SIZE)
    for i in 0..<s.len:
        s[i] = newAgent()
    
    echo $s[0]
    mutate(s)
    echo $s[0]
  
main()