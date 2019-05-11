import math
import random
import problems
import helpers
import streams
# import nimprof

# should compile with -flto enabled e.g., -d:release is not enough
# nim c -r -d:release -l:-flto <path>

proc main() =

    const
        optimizer = f1
        params = 100
        bounds = -100.0..100.0
        print = 200
        generations = 10000
        popsize = 150
        mutate_range = 0.2..0.9
        crossover_range = 0.1..1.0
        log_csv = false

    when log_csv:
        # Open file for writing
        const path = "/Users/phj/Desktop/nim_write.txt"
        let file = newFileStream(path, FileMode.fmWrite)
        if file != nil:
            file.writeLine("step,mean")
        else:
            quit("could not open file", 100)

    var
        crossover = 0.9
        mutate = 0.4
        scores: array[popsize, float]
        others: array[3, int]
        donor: array[params, float]
        trial: array[params, float]
        pop: array[popsize, array[params, float]]

    let scores_len = len(scores).toFloat

    # Init population
    for i in 0..<popsize:
        for j in 0..<params:
            pop[i][j] = rand(bounds)
        scores[i] = optimizer(pop[i])

    # For each generation
    for g in 0..<generations:
        crossover = rand(crossover_range)
        mutate = rand(mutate_range)

        for i in 0..<popsize:
            # Get three others
            for j in 0..<3:
                var idx = rand(popsize-1)
                while idx == i:
                    idx = rand(popsize-1)
                others[j] = idx

            let
                x0 = pop[others[0]]
                x1 = pop[others[1]]
                x2 = pop[others[2]]
                xt = pop[i]

            # Create donor
            for j in 0..<params:
                donor[j] = x0[j] + (x1[j] - x2[j]) * mutate

            # Limit bounds
            for j in 0..<params:
                if donor[j] < bounds.a: donor[j] = bounds.a
                elif donor[j] > bounds.b: donor[j] = bounds.b

            # Create trial
            for j in 0..<params:
                if rand(0.0..1.0) < crossover:
                    trial[j] = donor[j]
                else:
                    trial[j] = xt[j]

            # Greedy pick best
            let
                score_trial = optimizer(trial)
                score_target = scores[i]

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
