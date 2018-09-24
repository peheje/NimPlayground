# should compile with -flto enabled e.g., -d:release is not enough
# nim c -r -d:release -l:-flto <path>

import math
import random
import problems
import fastrandom
import helpers
import streams
# import nimprof

proc main() =

    # Open file for writing
    let file = newFileStream("/Users/phj/Desktop/nim_write.txt", FileMode.fmWrite)
    if file != nil:
        file.writeLine("step,mean")
    else:
        quit("could not open file", 100)

    # Constants
    const optimizer = f1
    const params = 1000
    const bound_from = -10
    const bound_to = 10

    const print = 200
    const generations = 20000
    const popsize = 100
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
            echo "generation  mean ", mean
            echo "generation ", g
            file.writeLine($g & "," & $mean)
        
    let best_idx = scores.min_index()
    echo "best ", pop[best_idx]
    file.close()

main()