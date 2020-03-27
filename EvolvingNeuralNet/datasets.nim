import tables
import random
import strutils

type
    Series* = ref object
        xs*: seq[seq[float]]
        ys*: seq[int]

    Dataset* = ref object of RootObj
        inputs*, outputs*: int
        test*, train*: Series

    Iris* = ref object of Dataset

proc newSeries(): Series =
    new result
    result.xs = newSeq[seq[float]]()
    result.ys = newSeq[int]()

proc newIris*(): Iris =
    new result
    result.inputs = 4
    result.outputs = 3
    result.test = newSeries()
    result.train = newSeries()

    let map = {
        "Iris-virginica": 0,
        "Iris-versicolor": 1,
        "Iris-setosa": 2
    }.toTable()

    const path = "/Users/phj/GitRepos/nim_genetic/EvolvingNeuralNet/iris.data"

    var rows = newSeq[string]()
    for line in lines(path):
        rows.add(line)
    shuffle(rows)

    var xss = newSeq[seq[float]]()
    var ys = newSeq[int]()
    for row in rows:
        let dims = row.split(",")
        var xs = newSeq[float]()
        for i in 0..<dims.len - 1:
            xs.add(parseFloat(dims[i]))
        let last = map[dims[dims.len - 1]]
        xss.add(xs)
        ys.add(last)

    let ratioOfTraining = 0.8
    let numberOfTraining = toInt(ratioOfTraining * ys.len.toFloat)

    for i in 0..<ys.len:
        if i < numberOfTraining:
            result.train.xs.add(xss[i])
            result.train.ys.add(ys[i])
        else:
            result.test.xs.add(xss[i])
            result.test.ys.add(ys[i])