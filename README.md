A mix of different genetic inspired algorithms and experiments in Nim.

[To run these you need to install Nim](https://nim-lang.org/install.html) 

**Differential evolution**

You got a problem and it sounds like an optimization problem, you don't want to juggle many equations with many unknowns in a real math sense. You want to know if there is a solution.

*There are 36 heads and 100 legs, how many horses and jockeys are there?*

If you can express this in code you can run this algorithm to find an answer. You express this by a function that takes an array of parameters you want to find (two in this case), and you implement the function so that it returns a small number if the solution is good, and a big number if the solution is bad.

```nim
proc horses_and_jockeys*(x: openarray[float]): float =
  let
    horses = x[0]
    jockeys = x[1]
    legs = horses*4 + jockeys*2
    heads = horses + jockeys
  result = abs(36-heads) + abs(100-legs)
```
Set the hyperparams to something sensible, i.e. 2 params, positive bounds

```nim
const
  log_csv = false
  print = 1000
  optimizer = horses_and_jockeys
  params = 2
  bounds = 0.0..1000.0
  generations = 10000
  popsize = 1000
  mutate_range = 0.2..0.95
  crossover_range = 0.1..1.0
```

[14.0, 22.0]

It also works if you have constraints.

*In League of Legends, a player's Effective Health when defending against physical damage is given by E=H(100+A)/100, where H is health and A is armor. Health costs 2.5 gold per unit, and Armor costs 18 gold per unit. You have 3600 gold, and you need to optimize the effectiveness E of your health and armor to survive as long as possible against the enemy team's attacks. How much of each should you buy?*
```nim
proc lol1*(x: openarray[float]): float =
  let
    health = x[0]
    armor = x[1]
    effective_hp = (health*(100.0+armor))/100.0
  if (health*2.5 + armor*18) > 3600:
    return 1.0
  return 1.0/effective_hp
```

```nim
const
  log_csv = false
  print = 1000
  optimizer = lol1
  params = 2
  bounds = 0.0..10000.0
  generations = 10000
  popsize = 1000
```

[1079.999993591275, 50.00000089010068]
You do not spend equal money on A and H: E=3H−1720H2 so the maximum is at H=1080, plug back in for A=50.

The algorithm by no means guarantees that this is the best solution

**Evolving neural nets**

**Genetic programming**

**Genetic algorithm**
