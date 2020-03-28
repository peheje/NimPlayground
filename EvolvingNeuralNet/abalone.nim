import random
import tables
import datasets
import strutils

type
    Abalone* = ref object of Dataset

proc newAbalone*(ratioOfTraining: float): Abalone =
    new result
    result.inputs = 8
    #result.outputs = 28
    result.outputs = 3
    result.test = newSeries()
    result.train = newSeries()

    let map = {
        "M": -1.0,
        "F": 0.0,
        "I": 1.0
    }.toTable()

    const path = "/Users/phj/GitRepos/nim_genetic/EvolvingNeuralNet/abalone.data"

    var rows = newSeq[string]()
    for line in lines(path):
        rows.add(line)
    shuffle(rows)

    var xss = newSeq[seq[float]]()
    var ys = newSeq[int]()
    for row in rows:
        let dims = row.split(",")
        var xs = newSeq[float]()
        xs.add(map[dims[0]])
        for i in 1..<dims.len-1:
            xs.add(parseFloat(dims[i]))
        let last = dims[^1].parseInt

        var class = -1
        if last < 9:
            class = 0
        elif last < 11:
            class = 1
        else:
            class = 2

        xss.add(xs)
        ys.add(class)

    let numberOfTraining = toInt(ratioOfTraining * ys.len.toFloat)

    for i in 0..<ys.len:
        if i < numberOfTraining:
            result.train.xs.add(xss[i])
            result.train.ys.add(ys[i])
        else:
            result.test.xs.add(xss[i])
            result.test.ys.add(ys[i])