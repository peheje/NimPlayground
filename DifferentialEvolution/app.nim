# should compile with -flto enabled e.g., -d:release is not enough
# nim c -r -d:release -l:-flto <path>

import math
import random
import problems
import helpers
import streams
# import nimprof

const log_csv = false

proc main() =

    when log_csv:
        # Open file for writing
        let file = newFileStream("/Users/phj/Desktop/nim_write.txt", FileMode.fmWrite)
        if file != nil:
            file.writeLine("step,mean")
        else:
            quit("could not open file", 100)

    # Adjustable parameters
    const optimizer = f1
    const params = 1000
    const bound_from = -100.0
    const bound_to = 100.0

    const print = 200
    const generations = 40000
    const popsize = 150
    
    var mutate = 0.4
    const mutate_range = 0.2..0.9

    var crossover = 0.9
    const crossover_range = 0.1..1.0

    var scores: array[popsize, float]
    var others: array[3, int]
    var donor: array[params, float]
    var trial: array[params, float]

    let scores_len = len(scores).toFloat

    # Init population
    var pop: array[popsize, array[params, float]]
    for i in 0..<popsize:
        for j in 0..<params:
            pop[i][j] = rand(bound_from..bound_to)
        scores[i] = optimizer(pop[i])

    # For each generation
    for g in 0..<generations:
        crossover = rand(crossover_range)
        mutate = rand(mutate_range)
        
        for i in 0..<popsize:
            # Get three others
            for j in 0..<3:
                var idx = rand(popsize)
                while idx == i:
                    idx = rand(popsize)
                others[j] = idx
            
            let x0 = pop[others[0]]
            let x1 = pop[others[1]]
            let x2 = pop[others[2]]
            let xt = pop[i]

            # Create donor
            for j in 0..<params:
                donor[j] = x0[j] + (x1[j] - x2[j]) * mutate
            
            # Limit bounds
            for j in 0..<params:
                if donor[j] < bound_from: donor[j] = bound_from
                elif donor[j] > bound_to: donor[j] = bound_to

            # Create trial
            for j in 0..<params:
                if rand(0.0..1.0) < crossover:
                    trial[j] = donor[j]
                else:
                    trial[j] = xt[j]
            
            # Greedy pick best
            let score_trial = optimizer(trial)
            let score_target = scores[i]

            if score_trial < score_target:
                pop[i] = trial
                scores[i] = score_trial
            
        if g mod print == 0:
            echo "generation mean ", scores.sum() / scores_len
            echo "generation best ", scores.min()
            echo "generation ", g

            when log_csv:
                file.writeLine($g & "," & $mean)
        
    let best_idx = scores.arg_min()
    echo "best ", pop[best_idx]

    when log_csv:
        file.close()

main()