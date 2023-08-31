import std/random
import std/times
import std/sequtils
import std/stats
import problems
# import std/nimprof

# nim c -r -d=danger --passC:-flto --passC:-ffast-math app.nim

let start = cpuTime()
const
  log_csv = false
  print = 1000
  optimizer = f1
  params = 1000
  bounds = -10.0..10.0
  generations = 10_000
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
  pop = newSeqWith(popsize, newSeqWith(params, rand(bounds)))
  scores = pop.mapIt(optimizer(it))

proc mate(pool: seq[seq[float]], crossover: float, mutate: float, xt: seq[float], xtScore: float): tuple[a: seq[float], b: float] =
  let
    x0 = pop.sample
    x1 = pop.sample
    x2 = pop.sample

  # Create trial
  var trial = newSeq[float](params)
  for j in 0..<params:
    if rand(1.0) < crossover:
      trial[j] = (x0[j] + (x1[j] - x2[j]) * mutate).clamp(bounds.a, bounds.b)
    else:
      trial[j] = xt[j]
  let trialScore = optimizer(trial)

  # Replace current if better
  if trialScore < xtScore:
    result = (trial, trialScore)
  else:
    result = (xt, xtScore)

# For each generation
for g in 0..<generations:
  var
    crossover = rand(crossover_range)
    mutate = rand(mutate_range)

  for i in 0..<popsize:
    let (next, nextScore) = mate(pop, crossover, mutate, pop[i], scores[i])
    pop[i] = next
    scores[i] = nextScore
      
  if g mod print == 0 or g == generations-1:
    let mean = scores.mean()
    echo "generation ", g
    echo "generation mean ", mean
    echo "generation best ", scores.min()
    when log_csv:
      file.writeLine($g & "," & $mean)

when log_csv:
  file.close()

let best = pop[scores.minIndex()]
echo "best ", best
echo "score ", scores.min()
echo "time taken: ", cpuTime() - start