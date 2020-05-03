import math
import random
import problems
import streams
import times
import sequtils
# import nimprof

# nim c -r -d=danger -l=-flto --passC:-ffast-math app.nim

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
    trial = newSeq[float](params)
    scores: array[popsize, float]
    pop = newSeqWith(popsize, newSeqWith(params, rand(bounds)))

  # Init scores
  for i in 0..<popsize:
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

  echo "best ", pop[scores.minIndex()]

  when log_csv:
    file.close()

  echo "time taken: ", cpuTime() - start

main()
