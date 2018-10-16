# import nimprof
import algorithm
import random
import sitmo
import math
import marshal
import times
import strutils, math, threadpool

randomize()
# some comment here
# Globals
const N_THREADS = 4
const POPULATION_SIZE = 100_000
const N_GENERATIONS = 100_000
const NUM_CHARACTERS = 10
const TARGET = @[0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9]
const MUTATE_PROP = 0.10
const MUTATE_RATE = 0.05
const CROSSOVER_PROP = 0.10
const CROSSOVER_RATE = 0.05

import sitmo
var r = newsitmo()
r.seed(0x7FFFFFFFu32)
echo r.random
r.skip(0xFFFFFFFFFFFFFFFFu64)
echo r.random

# Agent type
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

proc pick(pool: seq[Agent], wheel: seq[float]): Agent =
    let r = random(wheel[^1])
    let idx = min(wheel.lowerBound(r), POPULATION_SIZE-1)
    deepCopy(result, pool[idx])

proc `>`(this: Agent, other: Agent): bool =
    result = this.fitness > other.fitness

proc print(this: Agent) = 
    echo(sqrt(this.fitness), " -> ", $$this.data)

proc calcFitness(this: Agent) =
    this.fitness = 0.0
    for i in 0..<TARGET.len:
        if this.data[i] == TARGET[i]:
            this.fitness += 1.0
    this.fitness *= this.fitness

proc mutate(this: Agent) =
    for i in 0..<this.data.len:
        if random(1.0) < MUTATE_RATE:
            this.data[i] = random(NUM_CHARACTERS)

proc crossover(this: Agent, pool: seq[Agent], wheel: seq[float]) =
    let mate = pick(pool, wheel)
    for i in 0..<this.data.len:
        if random(1.0) < CROSSOVER_RATE:
            swap(mate.data[i], this.data[i])

# Procedures
proc createWheel(pool: seq[Agent]): seq[float] =
    var s = 0.0
    result = newSeq[float](POPULATION_SIZE)
    for i in 0..<POPULATION_SIZE:
        s += pool[i].fitness
        result[i] = s

proc createPool(pool: seq[Agent], wheel: seq[float]): seq[Agent] =
    result = newSeq[Agent](POPULATION_SIZE)
    for i in 0..<pool.len:
        result[i] = pick(pool, wheel)

proc maxAgent(pool: seq[Agent]): Agent =
    result = pool[0]
    for i in 1..<pool.len:
        if pool[i] > result: result = pool[i]

proc newAgents(n: int): seq[Agent] =
    result = newSeq[Agent](n)
    for i in 0..<n:
        result[i] = newAgent()

{.experimental.}        
proc newAgentsParallel(n: int): seq[Agent] =
    echo getClockStr()
    # Initialize pool first time
    const populationPrThread = (POPULATION_SIZE/N_THREADS).toInt
    var flowPool = newSeq[FlowVar[seq[Agent]]](N_THREADS)
    parallel:
        for i in 0..<flowPool.len:
            flowPool[i] = spawn newAgents(populationPrThread)
    result = newSeq[Agent](POPULATION_SIZE)
    # check https://github.com/aboisvert/nimskiis/blob/master/tests/test_iteratorskiis.nim
    var idx = 0
    for i in 0..<flowPool.len:
        var s: seq[Agent] = ^flowPool[i]
        for j in 0..<s.len:
            result[idx] = s[j]
            result[idx].calcFitness()
            idx += 1
        
    echo getClockStr()
    echo "parallelNewAgents finished"

proc partition(pool: seq[Agent], n: int): seq[seq[Agent]] =
    # Partition for parallel
    const populationPrThread = (POPULATION_SIZE/N_THREADS).toInt    
    var idx = 0
    result = newSeq[seq[Agent]](N_THREADS)
    for i in 0..<result.len:
        result[i] = newSeq[Agent](populationPrThread)
        for j in 0..<result[i].len:
            result[i][j] = pool[idx]
            idx += 1
    # echo($$ result)

proc life(part: var seq[Agent], pool: var seq[Agent], wheel: var seq[float]) =
    for a in part:
        if random(1.0) < CROSSOVER_PROP:
            a.crossover(pool, wheel)
        if random(1.0) < MUTATE_PROP:
            a.mutate()
        a.calcFitness()
    # echo "life done"

proc execute() =
    if (POPULATION_SIZE mod N_THREADS != 0):
        raise newException(ValueError, "POPULATION_SIZE must be divisable with N_THREADS")

    var pool: seq[Agent] = newAgentsParallel(POPULATION_SIZE) # Works
    # Run generations
    for gen in 0..<N_GENERATIONS:
        var wheel = createWheel(pool)
        let partitions: seq[seq[Agent]] = partition(pool, N_THREADS)
        for i in 0..<partitions.len:
            var part = partitions[i]
            life(part, pool, wheel)
        pool = createPool(pool, wheel)
        
        if gen mod 100 == 0:
            echo("Generation, ", gen, "/", N_GENERATIONS)
            let best = maxAgent(pool)        
            stdout.write("best: ")
            best.print()
    
    
            
execute()