import
    os, 
    threadpool,
    random,
    marshal

const TARGET = @[0, 0, 1, 1, 2, 2]
const NUM_CHARACTERS = 10

type
    Agent* = ref object
        data*: seq[int]
        fitness*: float

proc new_agent(): Agent =
    result = Agent()
    result.fitness = -1.0
    result.data = newSeq[int](TARGET.len)
    for i in 0..<TARGET.len:
        result.data[i] = random(NUM_CHARACTERS)

# Override deep_copy(type: ref Agent): Agent
proc deep_copy(a: Agent): Agent =
    echo " -> OVERRIDED deep_copy called!!"
    return new_agent()

var chan: Channel[Agent]
open(chan)
proc mutate() =
    var a = chan.recv()
    a.data[0] = 100
    chan.send(a)

var pool = new_seq[Agent](10)
for i in 0..<10:
    pool[i] = new_agent()
    chan.send(pool[i])
 
for i in 0..<10:
    spawn mutate()

for i in 0..<10:
    var r: Agent = chan.recv()
    echo $$(r)


var r = new_agent()
echo "    -> TESTING DEEP COPY OVERRIDE"
var r_copy = deep_copy(r)
echo $$(r_copy)