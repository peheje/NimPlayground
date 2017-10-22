import algorithm
import random

# Setup
const POPULATION_SIZE: int = 10000
randomize()

echo "Tests 1"
type
    Coordinate* = ref object
        x*, y*: int

var coordinates = newSeq[Coordinate](POPULATION_SIZE)

for i in 0..<POPULATION_SIZE:
    coordinates[i] = Coordinate(x: random(10), y: random(10))

for coord in reversed(coordinates.sortedByIt(it.y)):
    echo "(", coord.x, ";", coord.y, ")"

echo "End tests1"


proc printArray(a: seq) =
    for i in 0..<a.len:
        echo a[i]

proc createWheel(a: seq[float]): seq[float] =
    var s = 0.0
    var w = newSeq[float](POPULATION_SIZE)
    for i in 0..<POPULATION_SIZE:
        s += a[i]
        w[i] = s
    return w

proc pick(a: seq[float], wheel: seq[float]): float =
    let r = random(wheel[POPULATION_SIZE - 1])
    let idx = wheel.lowerBound(r)
    return a[idx]

# Main
var pool = newSeq[float](POPULATION_SIZE)
for i in 0..<POPULATION_SIZE:
    pool[i] = random(1.0)

# pool[0] = 10.0

let wheel = createWheel(pool)
var picks = newSeq[float](POPULATION_SIZE)
for i in 0..<POPULATION_SIZE:
    picks[i] = pick(pool, wheel)

# echo "wheel"
# printArray(wheel)
# echo "picks"
# printArray(picks)
# echo "pool"
# printArray(pool)
# echo "done"

