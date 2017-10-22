import algorithm
import random
import marshal

# Globals
const N_GENERATIONS = 1000
const POPULATION_SIZE = 10000
const NUM_CHARACTERS = 11
const TARGET = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const MUTATE_P = 0.1

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

method `>`(this: Agent, other: Agent): bool {.base.} =
    result = this.fitness > other.fitness

method print(this: Agent) {.base.} = 
    echo(this.fitness, " -> ", $$this.data)

method calcFitness(this: Agent) {.base.} =
    this.fitness = 0.0
    for i in 0..<TARGET.len:
        if this.data[i] == TARGET[i]:
            this.fitness += 1.0
    this.fitness *= this.fitness

method mutate(this: Agent) {.base.} =
    for i in 0..<this.data.len:
        if random(1.0) < MUTATE_P:
            this.data[i] = random(NUM_CHARACTERS)

# Procedures
proc createWheel(pool: seq[Agent]): seq[float] =
    var s = 0.0
    result = newSeq[float](POPULATION_SIZE)
    for i in 0..<POPULATION_SIZE:
        s += pool[i].fitness
        result[i] = s

proc pick(pool: seq[Agent], wheel: seq[float]): Agent =
    let r = random(wheel[^1])
    let idx = min(wheel.lowerBound(r), POPULATION_SIZE-1)
    deepCopy(result, pool[idx])

proc createPool(pool: seq[Agent]): seq[Agent] =
    let wheel = createWheel(pool)
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

# Run generations

for gen in 0..<N_GENERATIONS:
    for i in 0..<POPULATION_SIZE:
        pool[i].mutate()
        # pool[i].crossover(pool)
        pool[i].calcFitness()
    pool = createPool(pool)
    if gen mod 100 == 0:
        echo("Generation, ", gen, "/", N_GENERATIONS)
        stdout.write("best: ")
        maxAgent(pool).print()