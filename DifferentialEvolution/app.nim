import math
import random
# import nimprof

# randomize()

# Optimization problems
proc booth(x: openarray[float]): float =
    # f(1.0,3.0)=0
    let t1 = pow(x[0] + 2*x[1] - 7.0, 2.0)
    let t2 = pow(2*x[0] + x[1] - 5.0, 2.0)
    return t1 + t2

proc beale(x: openarray[float]): float =
    # f(3,0.5)=0
    let
        term1 = pow(1.500 - x[0] + x[0]*x[1], 2.0)
        term2 = pow(2.250 - x[0] + x[0]*x[1]*x[1], 2.0)
        term3 = pow(2.625 - x[0] + x[0]*x[1]*x[1]*x[1], 2.0)
    return term1 + term2 + term3

proc matyas(x: openarray[float]): float =
    # f(0,0)=0
    let
        t1 = 0.26*(x[0]*x[0] + x[1]*x[1])
        t2 = 0.48*x[0]*x[1]
    return t1 - t2

proc f1(x: openarray[float]): float =
    # f(0) = 0
    var s = 0.0
    for i in 0..<len(x):
        s += x[i]*x[i]
    return abs(s)

proc f2(x: openarray[float]): float =
    var
        s = 0.0
        p = 1.0
    for i in 0..<len(x):
        s += abs(x[i])
        p *= x[i]
    return abs(s) + abs(p)

# In League of Legends, a player's Effective Health when defending against physical damage is given by E=H(100+A)/100, where H is health and A is armor. Health costs 2.5 gold per unit, and Armor costs 18 gold per unit. You have 3600 gold, and you need to optimize the effectiveness E of your health and armor to survive as long as possible against the enemy team's attacks. How much of each should you buy?  
# You do not spend equal money on A and H: E=3H−1720H2 so the maximum is at H=1080, plug back in for A=50.
proc lol1(x: openarray[float]): float =
    let
        health = x[0]
        armor = x[1]
        effective_hp = (health*(100.0+armor))/100.0
    if (health*2.5 + armor*18) > 3600:
        return 1.0
    return 1.0/effective_hp

# Ten minutes into the game, you have 1080 health and 10 armor. You have only 720 gold to spend, and again Health costs 2.5 gold per unit while Armor costs 18 gold per unit. Again the goal is to maximize the effectiveness E. Notice that you don't want to maximize the effectiveness of what you purchase -- you want to maximize the effectiveness E of your resulting health and armor. How much of each should you buy?   
# One way to do this is to realize from number 1 that we know an optimal configuration is H=1080 and A=50, so right now we have way too much health and not enough armor. The answer to this is that we should spend all the money on 40 armor, to get exactly back to the optimized answer to #1.
proc lol2(x: openarray[float]): float =
    let
        health = x[0]
        armor = x[1]
        current_health = health + 1080
        current_armor = armor + 10
        effective_health = (current_health*(100.0 + current_armor))/100
    if (health*2.5 + armor*18) > 720:
        return 1.0
    return 1.0/effective_health

# Thirty minutes into the game, you have 2000 health and 50 armor. You have 1800 gold to spend, and again Health costs approximately 2.5 gold per unit while Armor costs approximately 18 gold per unit. Again the goal is to maximize the effectiveness E of your resulting health and armor. How much of each should you buy?
    
# If H and A are the amount they plan to buy, the effectiveness is E=(H+2000)(100+(50+A))100 since they started with 2000 and 50 respectively. The critical point appears at H = -100, so the maximum actually occurs at one of the endpoints, not at the critical point at all. Again the player should spend all the money on armor.
proc lol3(x: openarray[float]): float =
    let
        health = x[0]
        armor = x[1]
        current_health = health + 2000
        current_armor = armor + 50
        effective_health = (current_health*(100.0 + current_armor))/100.0
    if (health*2.5 + armor*18) > 1800:
        return 1.0
    return 1.0/effective_health

proc find_sqrt(x: openarray[float]): float =
    # sqrt(2): x*x == 2 => x*x-2 = 0
    let
        c = x[0]
        t = c*c - 2
    return abs(t)

# There is 36 heads and 100 legs, how many horses and jockeys are there?
# 14 and 22
proc horses_and_jockeys(x: openarray[float]): float =
    let
        horses = x[0]
        jockeys = x[1]
        legs = horses*4 + jockeys*2
        heads = horses + jockeys
    result = abs(36-heads) + abs(100-legs)
    
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

var state = initRand(100)

# A biased random
proc f_rand(min, max: float): float =
    let r = float(next(state))
    # pow(2, 64) = 1.844674407E19
    let rr = r / 1.844674407E19
    let rrr = rr * (max - min) + min
    return rrr

# A biased random
proc i_rand(min, max: uint64): int =
    result = int((next(state) + min) mod max)

proc main() =
    # Constants
    const optimizer = horses_and_jockeys
    const params = 2
    const bound_from = 0
    const bound_to = 1000

    const print = 1000
    const generations = 1000
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