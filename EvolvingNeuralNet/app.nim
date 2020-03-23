import math
import random
import sugar
import helpers
import datasets
import json

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

proc mutate(x: Neuron, power, frequency: float) =
    for i in 0..<x.weights.len:
        if rand(0.0..1.0) < frequency:
            x.weights[i] += rand(-power..power)
    if rand(0.0..1.0) < frequency:
        x.bias += rand(-power..power)

proc newLayer(previousInputSize, size: int, last: bool): Layer =
    new result
    for i in 0..<size:
        result.neurons.add(newNeuron(previousInputSize))
    result.last = last

func invoke(x: Layer, input: seq[float]): seq[float] =
    for neuron in x.neurons:
        result.add(neuron.invoke(input, x.last))

proc newNet(setup: seq[int]): Net =
    new result
    let lastLayerIdx = setup.len-2
    for i in 0..<setup.len-1:
        result.layers.add(newLayer(setup[i], setup[i+1], i == lastLayerIdx))
        result.weights += (1+setup[i]) * setup[i+1]

func invoke(x: Net, input: seq[float]): seq[float] =
    result = input
    for layer in x.layers:
        result = layer.invoke(result)

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

proc mutate(x: Net, power, frequency: float) =
    for layer in x.layers:
        for neuron in layer.neurons:
            neuron.mutate(power, frequency)

proc main() =
    randomize()
    let iris = newIris()
    const print = false

    var avg = 0.0
    const size = 20000;
    var nets = newSeq[Net]()
    for i in 0..<size:
        let net = newNet(@[iris.inputs, 10, 10, 10, iris.outputs])
        nets.add(net)
        net.computeFitness(iris.train, 0.0, 0.0)
        let percentage = net.correct / iris.train.xs.len
        avg += percentage / size
        when print:
            writeJsonDebug(net)
            echo "fitness " & $net.fitness
            echo "percentage correct " & $percentage
            echo "______"

    echo "average " & $avg
    let bestIdx = nets.argMaxBy(x => x.fitness)
    let bestNet = nets[bestIdx]
    echoJsonDebug(bestNet)

    let testPredictions = bestNet.correctPredictions(iris.test)
    let testPercentage = testPredictions.toFloat / iris.test.xs.len.toFloat
    echo "test percentage " & $testPercentage

main()
