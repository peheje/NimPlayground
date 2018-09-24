proc min_index*(x: openarray[float]): int =
    var smallest = float.high
    for i in 0..<len(x):
        if x[i] < smallest:
            smallest = x[i]
            result = i

proc limit_bounds*(x: var openarray[float], bound_from, bound_to: float) =
    for i in 0..<len(x):
        if x[i] < bound_from: x[i] = bound_from
        elif x[i] > bound_to: x[i] = bound_to