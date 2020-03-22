import math
import random
import streams
import json
import os

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

func lerp(a, b, p: float): float =
    return a + (b - a) * p

proc newNeuron(nWeights: int): Neuron =
    new result
    for i in 0..<nWeights:
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

proc correctPredictions(n: Net, xs: seq[seq[float]], ys: seq[int]): int =
    result = 0
    for i, x in xs:
        let correct = ys[i]
        let neuralGuess = n.invoke(x)
        let bestGuess = argMax(neuralGuess)
        if bestGuess == correct:
            result += 1

proc computeFitness(n: Net, xs: seq[seq[float]], ys: seq[int], parentInheritance: float, gamma: float) =
    let correct = n.correctPredictions(xs, ys)
    let correctFitness = float(correct) / float(xs.len)

    var regularizationLoss = 0.0
    if gamma != 0:
        for layer in n.layers:
            for neuron in layer.neurons:
                for weight in neuron.weights:
                    regularizationLoss += weight * weight
    
    let dataloss = 0.0 # todo

    let batchFitness = correctFitness - regularizationLoss - dataloss
    let parentFitness = n.fitness
    n.fitness = parentInheritance * parentFitness + batchFitness

proc newNet(setup: seq[int]): Net =
    new result
    let lastLayerIdx = setup.len - 2
    for i in 0..<setup.len-1:
        result.layers.add(newLayer(setup[i], setup[i+1], i == lastLayerIdx))
    
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

proc writeJsonDebug(o: any) =
    const path = "/Users/phj/Desktop/nim_write.txt"
    let file = newFileStream(path, FileMode.fmWrite)
    if file != nil:
        file.writeLine(pretty(%o))

proc main() =
    randomize()
    let dataInputs = 3
    let dataOutputs = 4
    let n1 = newNet(
        @[dataInputs, 100, 100, 100, 100, 100, dataOutputs])
    
    var result = n1.invoke(@[1.0, 2.0, 3.0])
    #writeJsonDebug(n1)
    #sleep(2000)
    for i in 0..<10:
        n1.mutate(1.0, 0.25)
    #writeJsonDebug(n1)
    #echo result

main()