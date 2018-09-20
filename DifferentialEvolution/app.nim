# should compile with -flto enabled e.g., -d:release is not enough
# nim c -r -d:release -l:-flto <path>

import math
import random
import problems
import fastrandom
# import nimprof

# Helpers
proc min_index(x: openarray[float]): int =
    var smallest = float.high
    for i in 0..<len(x):
        if x[i] < smallest:
            smallest = x[i]
            result = i

proc limit_bounds(x: var openarray[float], bound_from, bound_to: float) =
    for i in 0..<len(x):
        if x[i] < bound_from: x[i] = bound_from
        elif x[i] > bound_to: x[i] = bound_to

proc main() =
    # Constants
    const optimizer = constraints1
    const params = 2
    const bound_from = -1000
    const bound_to = 1000

    const print = 500
    const generations = 100
    const popsize = 200
    const mutate = 0.5
    const dither_from = 0.5
    const dither_to = 1.0

    var crossover = 0.9
    var scores: array[popsize, float]
    var others: array[3, int]
    var donor: array[params, float]
    var trial: array[params, float]

    let scores_len = len(scores).toFloat

    # Init population
    var pop: array[popsize, array[params, float]]
    for i in 0..<popsize:
        for j in 0..<params:
            pop[i][j] = f_rand(boundFrom, boundTo)
        scores[i] = optimizer(pop[i])

    # For each generation
    for g in 0..<generations:
        crossover = f_rand(dither_from, dither_to)
        
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
            
            limit_bounds(donor, bound_from, bound_to)

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
            let mean = scores.sum() / scores_len
            echo "generation mean ", mean
            echo "generation ", g
        
    let best_idx = scores.min_index()
    echo "best ", pop[best_idx]

main()