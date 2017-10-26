import locks, random, marshal

const N_THREADS = 4
const POOLSIZE = N_THREADS * 1
const NUM_CHARACTERS = 10
const TARGET = @[0, 0, 1, 1, 2, 2, 3, 3]
const MUTATE_RATE = 1.0

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

# Initialize global vars (need to be global as pr nim threading model)
var pool: seq[Agent]

# Initialize pool
pool = newSeq[Agent](POOLSIZE)
for i in 0..<POOLSIZE:
    pool[i] = newAgent()

# Partition pool
if POOLSIZE mod N_THREADS != 0:
    raise newException(ValueError, "POOLSIZE % N_THREADS must equal 0")
const CHUNKSIZE = (POOLSIZE / N_THREADS).toInt
var chunks = newSeq[seq[Agent]](N_THREADS)
var idx = 0
for i in 0..<N_THREADS:
    chunks[i] = newSeq[Agent](CHUNKSIZE)
    for j in 0..<CHUNKSIZE:
        chunks[i][j] = pool[idx]
        idx += 1

# Spawn threads
var lock: Lock
initLock(lock)
var threads: array[0..N_THREADS-1, Thread[seq[Agent]]]

randomize()

proc mutate(chunk: seq[Agent]) {.thread.} =
    # acquire(lock)
    echo "before mutate", $$(chunk)
    for agent in chunk:
        for i in 0..<agent.data.len:
            if random(1.0) < MUTATE_RATE:
                agent.data[i] = random(NUM_CHARACTERS)
    echo "after  mutate", $$(chunk)
    # release(lock)

echo $$(pool)

for i in 0..<threads.len:
    createThread(threads[i], mutate, chunks[i])
joinThreads(threads)

echo $$(pool)