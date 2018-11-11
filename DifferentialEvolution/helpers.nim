proc arg_min*(x: openarray[float]): int =
    var smallest = float.high
    for i in 0..<len(x):
        if x[i] < smallest:
            smallest = x[i]
            result = i