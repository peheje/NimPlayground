import random

var state = initRand(100)

# A biased random
proc f_rand*(min, max: float): float =
    let r = float(next(state))
    # pow(2, 64) = 1.844674407E19
    let rr = r / 1.844674407E19
    let rrr = rr * (max - min) + min
    return rrr

# A biased random
proc i_rand*(min, max: uint64): int =
    result = int((next(state) + min) mod max)