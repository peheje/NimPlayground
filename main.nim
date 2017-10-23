import algorithm
import random
import math
import marshal

randomize()

# Globals
const N_GENERATIONS = 10000
const POPULATION_SIZE = 10000
const NUM_CHARACTERS = 1000
const TARGET = @[0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9]
const MUTATE_PROP = 0.10
const MUTATE_RATE = 0.05
const CROSSOVER_PROP = 0.10
const CROSSOVER_RATE = 0.05

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

# Initialize pool first time
var pool = newSeq[Agent](POPULATION_SIZE)
for i in 0..<POPULATION_SIZE:
    pool[i] = newAgent()
    pool[i].calcFitness()

# Run generations
for gen in 0..<N_GENERATIONS:
    let wheel = createWheel(pool)
    for i in 0..<POPULATION_SIZE:
        if random(1.0) < CROSSOVER_PROP:
            pool[i].crossover(pool, wheel)
        if random(1.0) < MUTATE_PROP:
            pool[i].mutate()
        pool[i].calcFitness()
    pool = createPool(pool, wheel)

    if gen mod 100 == 0:
        echo("Generation, ", gen, "/", N_GENERATIONS)
        let best = maxAgent(pool)        
        stdout.write("best: ")
        best.print()
