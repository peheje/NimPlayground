import random

type
    Series* = ref object
        xs*: seq[seq[float]]
        ys*: seq[int]

    Dataset* = ref object of RootObj
        inputs*, outputs*: int
        test*, train*: Series

proc newSeries*(): Series =
    new result
    result.xs = newSeq[seq[float]]()
    result.ys = newSeq[int]()

proc computeBatch*(dataset: Dataset, size: int): Series =
    let clipped = min(dataset.train.xs.len, size)
    result = newSeries()
    for i in 0..<clipped:
        let r = rand(0..<dataset.train.xs.len)
        result.xs.add(dataset.train.xs[r])
        result.ys.add(dataset.train.ys[r])