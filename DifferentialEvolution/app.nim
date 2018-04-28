import math
import random

# randomize()

# Optimization problems
proc booth(x: seq[float]): float =
    # (1.0, 3.0) = 0
    let t1 = pow(x[0] + 2*x[1] - 7.0, 2.0)
    let t2 = pow(2*x[0] + x[1] - 5.0, 2.0)
    return t1 + t2    

# Constants
const generations = 100
const popsize = 100
const params_range = -5.0..5.0
const dither_range = 0.5..1.0
const mutate = 0.5
const print = 50
const optimizer = booth
const params = 2

var crossover = 0.5
var scores = newSeq[float](popsize)
var others = newSeq[int](3)
var donor = newSeq[float](params)
var trial = newSeq[float](params)

# Init population
var pop = newSeq[seq[float]](popsize)
for i in 0..<popsize:
    pop[i] = newSeq[float](params)
    for j in 0..<params:
        pop[i][j] = rand(params_range)

# Initial scores
for i in 0..<popsize:
    scores[i] = optimizer(pop[i])

# For each generation
for g in 0..<generations:
    crossover = rand(dither_range)
    
    for i in 0..<popsize:
        # Get three others
        for j in 0..<3:
            var idx = rand(0..<popsize)
            while idx == i:
                idx = rand(0..<popsize)
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
            if rand(1.0) < crossover:
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
        let minimum = min(scores)
        let best_idx = scores.find(minimum)
        echo "best ", pop[best_idx]

            
