import math
import random
import problems
import helpers
import streams
import times
# import nimprof

# nim c -r -d:release -d:danger -l:-flto app.nim

proc main() =

  let start = cpuTime()
  const
    log_csv = false
    print = 1000
    optimizer = f1
    params = 300
    bounds = -10.0..10.0
    generations = 10000
    popsize = 200
    mutate_range = 0.2..0.95
    crossover_range = 0.1..1.0
    popsize_float = popsize.toFloat

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
    trial = newSeq[float](params)
    pop = newSeq[seq[float]](popsize)

  # Init population
  for i in 0..<popsize:
    pop[i] = newSeq[float](params)
    for j in 0..<params:
      pop[i][j] = rand(bounds)
    scores[i] = optimizer(pop[i])

  # For each generation
  for g in 0..<generations:
    crossover = rand(crossover_range)
    mutate = rand(mutate_range)

    for i in 0..<popsize:
      # Get three others
      let
        x0 = pop[rand(popsize-1)]
        x1 = pop[rand(popsize-1)]
        x2 = pop[rand(popsize-1)]
        xt = pop[i]

      # Create trial
      for j in 0..<params:
        if rand(1.0) < crossover:
          trial[j] = (x0[j] + (x1[j] - x2[j]) * mutate).clamp(bounds.a, bounds.b)
        else:
          trial[j] = xt[j]
      let score_trial = optimizer(trial)

      # Replace current if better
      if score_trial < scores[i]:
        pop[i] = trial
        scores[i] = score_trial

    if g mod print == 0 or g == generations-1:
      let mean = scores.sum() / popsize_float
      echo "generation mean ", mean
      echo "generation best ", scores.min()
      echo "generation ", g

      when log_csv:
        file.writeLine($g & "," & $mean)

  #let best_idx = scores.arg_min()
  #echo "best ", pop[best_idx]

  when log_csv:
    file.close()

  echo "time taken: ", cpuTime() - start

main()
