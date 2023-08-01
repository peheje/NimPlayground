import random
import problems
import streams
import times
import sequtils
import stats
# import nimprof

# nim c -r -d=danger --passC:-flto --passC:-ffast-math app.nim

proc main() =

  let start = cpuTime()
  const
    log_csv = true
    print = 1000
    optimizer = f1
    params = 300
    bounds = -10.0..10.0
    generations = 200000
    popsize = 200
    mutate_range = 0.2..0.95
    crossover_range = 0.1..1.0

  when log_csv:
    # Open file for writing
    const path = "nim_write.txt"
    let file = newFileStream(path, FileMode.fmWrite)
    if file != nil:
      file.writeLine("step,mean")
    else:
      quit("could not open file", 100)

  var
    trial = newSeq[float](params)
    pop = newSeqWith(popsize, newSeqWith(params, rand(bounds)))
    scores = pop.mapIt(optimizer(it))

  # For each generation
  for g in 0..<generations:
    var
      crossover = rand(crossover_range)
      mutate = rand(mutate_range)

    for i in 0..<popsize:
      # Get three others, fast than .sample
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
      let mean = scores.mean()
      echo "generation ", g
      echo "generation mean ", mean
      echo "generation best ", scores.min()
      when log_csv:
        file.writeLine($g & "," & $mean)

  when log_csv:
    file.close()

  echo "best ", pop[scores.minIndex()]
  echo "time taken: ", cpuTime() - start

main()
