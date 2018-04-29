import math
# import random
# import nimprof

# randomize()

# Constants
const params = 2
const print = 10000
const generations = 1000
const popsize = 100
const mutate = 0.5

# Optimization problems
proc booth(x: array[params, float32]): float32 =
    # (1.0, 3.0) = 0
    let t1 = pow(x[0] + 2*x[1] - 7.0, 2.0)
    let t2 = pow(2*x[0] + x[1] - 5.0, 2.0)
    return t1 + t2  
    
const optimizer = booth

# Helpers
proc min_index(x: array[popsize, float32]): int =
    var smallest = float32.high
    for i in 0..<x.len:
        if x[i] < smallest:
            smallest = x[i]
            result = i

# Biased fast random
var
    x: uint32 = 123456789
    y: uint32 = 362436069
    z: uint32 = 521288629
    w: uint32 = 88675123
    
proc xor128(): uint32 = 
    var t: uint32
    t = x xor (x shl 11)
    x = y
    y = z
    z = w
    w = w xor (w shr 19) xor t xor (t shr 8)
    return w

proc f_rand(min, max: float32): float32 =
    # A biased random!
    let r = float32(xor128())
    # pow(2, 32) - 1 == 4294967295
    let rr = r / 4294967295.0
    let rrr = rr * (max - min) + min
    return rrr

proc i_rand(min, max: uint32): int =
    # A biased random
    result = int((xor128() + min) mod max)

var crossover = 0.9
var scores: array[popsize, float32]
var others: array[3, int]
var donor: array[params, float32]
var trial: array[params, float32]

# Init population
var pop: array[popsize, array[params, float32]]
for i in 0..<popsize:
    for j in 0..<params:
        pop[i][j] = f_rand(-100, 100)
    scores[i] = optimizer(pop[i])

# For each generation
for g in 0..<generations:
    crossover = f_rand(0.5, 1.0)
    
    for i in 0..<popsize:
        # Get three others
        for j in 0..<3:
            var idx = i_rand(0, popsize)
            while idx == i:
                idx = i_rand(0, popsize)
            others[j] = idx
        
        let x0 = pop[others[0]]
        let x1 = pop[others[1]]
        let x2 = pop[others[2]]
        let xt = pop[i]

        # Create donor
        for j in 0..<params:
            donor[j] = x0[j] + (x1[j] - x2[j]) * mutate
        
        # Todo: EnsureBounds

        # Create trial
        for j in 0..<params:
            if f_rand(0, 1.0) < crossover:
                trial[j] = donor[j]
            else:
                trial[j] = xt[j]
        
        # Greedy pick best
        let score_trial = optimizer(trial)
        let score_target = scores[i]

        if score_trial < score_target:
            for j in 0..<params:
                pop[i][j] = trial[j]
            scores[i] = score_trial
        
    if g mod print == 0:
        let mean = scores.sum() / scores.len().toFloat
        echo "generation mean ", mean
    if g == generations-1:
        let best_idx = scores.min_index()
        echo "best ", pop[best_idx]
