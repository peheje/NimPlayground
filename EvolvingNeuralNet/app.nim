import math
import random
import streams
import json
import os
import strutils
import tables
import sequtils

const bounds = -1.0..1.0

type
    Neuron* = ref object
        weights: seq[float]
        bias: float

    Layer* = ref object
        neurons: seq[Neuron]
        last: bool

    Net* = ref object
        layers: seq[Layer]
        fitness: float
        correct, weights: int

    Series* = ref object
        xs: seq[seq[float]]
        ys: seq[int]

    Dataset* = ref object of RootObj
        inputs, outputs: int
        test, train: Series

    Iris* = ref object of Dataset

proc echoJsonDebug(o: any) =
    echo pretty(%o)

proc writeJsonDebug(o: any) =
    const path = "/Users/phj/Desktop/nim_write.txt"
    let file = newFileStream(path, FileMode.fmWrite)
    if file != nil:
        file.writeLine(pretty(%o))

proc newSeries(): Series =
    new result
    result.xs = newSeq[seq[float]]()
    result.ys = newSeq[int]()

proc newIris(): Iris =
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

    let ratioOfTraining = 0.5
    let numberOfTraining = toInt(ratioOfTraining * ys.len.toFloat)

    for i in 0..<ys.len:
        if i < numberOfTraining:
            result.train.xs.add(xss[i])
            result.train.ys.add(ys[i])
        else:
            result.test.xs.add(xss[i])
            result.test.ys.add(ys[i])

func lerp(a, b, p: float): float =
    return a + (b - a) * p

proc newNeuron(weights: int): Neuron =
    new result
    for i in 0..<weights:
        result.weights.add(rand(bounds))
    result.bias = rand(bounds)

func invoke(x: Neuron, input: seq[float], lastLayer: bool): float =
    result = x.bias
    for i in 0..<input.len:
        result += x.weights[i] * input[i]
    if not lastLayer:
        result = tanh(result) # Tanh
        #result = max(result, 0.0) # Relu
        #result = 1.0 / (1.0 + exp(-result)) # Sigmoid

proc newLayer(previousInputSize, size: int, last: bool): Layer =
    new result
    for i in 0..<size:
        result.neurons.add(newNeuron(previousInputSize))
    result.last = last

func invoke(x: Layer, input: seq[float]): seq[float] =
    for neuron in x.neurons:
        result.add(neuron.invoke(input, x.last))

func invoke(x: Net, input: seq[float]): seq[float] =
    result = input
    for layer in x.layers:
        result = layer.invoke(result)

proc argMax(x: seq[float]): int =
    var max = low(float)
    result = -1
    for i in 0..<x.len:
        if x[i] > max:
            max = x[i]
            result = i

proc correctPredictions(n: Net, series: Series): int =
    result = 0
    for i, x in series.xs:
        let correct = series.ys[i]
        let neuralGuess = n.invoke(x)
        let bestGuess = argMax(neuralGuess)
        if bestGuess == correct:
            result += 1

proc computeFitness(n: Net, series: Series, parentInheritance, regularization: float) = 
    n.correct = n.correctPredictions(series)
    let correctFitness = n.correct.toFloat / series.ys.len.toFloat

    var regularizationLoss = 0.0
    if regularization != 0:
        for layer in n.layers:
            for neuron in layer.neurons:
                for weight in neuron.weights:
                    regularizationLoss += weight * weight
    regularizationLoss = (regularizationLoss / n.weights.toFloat) * regularization

    let dataloss = 0.0 # todo

    let batchFitness = correctFitness - regularizationLoss - dataloss
    let parentFitness = n.fitness
    n.fitness = parentInheritance * parentFitness + batchFitness

proc newNet(setup: seq[int]): Net =
    new result
    let lastLayerIdx = setup.len-2
    for i in 0..<setup.len-1:
        result.layers.add(newLayer(setup[i], setup[i+1], i == lastLayerIdx))
        result.weights += (1+setup[i]) * setup[i+1]

proc mutate(x: Neuron, power, frequency: float) =
    for i in 0..<x.weights.len:
        if rand(0.0..1.0) < frequency:
            x.weights[i] += rand(-power..power)
    if rand(0.0..1.0) < frequency:
        x.bias += rand(-power..power)

proc mutate(x: Net, power, frequency: float) =
    for layer in x.layers:
        for neuron in layer.neurons:
            neuron.mutate(power, frequency)

proc main() =
    randomize()
    let iris = newIris()

    var avg = 0.0
    const size = 10;
    for i in 0..<size:
        let net = newNet(@[iris.inputs, 10, 10, 10, iris.outputs])
        writeJsonDebug(net)
        net.computeFitness(iris.train, 0.0, 0.0)
        let percentage = net.correct / iris.train.xs.len
        echo "fitness " & $net.fitness
        echo "percentage correct " & $percentage
        echo "______"
        avg += percentage / size
    echo "average " & $avg

main()
