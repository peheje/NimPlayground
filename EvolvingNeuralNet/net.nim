import layer
import neuron
import datasets
import helpers
import algorithm
import random
import math
import sequtils
import sugar

type
    Net* = ref object
        layers*: seq[Layer]
        fitness*: float
        correct*, weights*: int

proc newNet*(setup: seq[int]): Net =
    new result
    let lastLayerIdx = setup.len-2
    for i in 0..<setup.len-1:
        result.layers.add(newLayer(setup[i], setup[i+1], i == lastLayerIdx))
        result.weights += (1+setup[i]) * setup[i+1]

func invoke*(x: Net, input: seq[float]): seq[float] =
    result = input
    for layer in x.layers:
        result = layer.invoke(result)

proc correctPredictions*(n: Net, series: Series): int =
    result = 0
    for i, x in series.xs:
        let correct = series.ys[i]
        let neuralGuess = n.invoke(x)
        let bestGuess = argMax(neuralGuess)
        if bestGuess == correct:
            result += 1

proc correctPredictions*(nets: seq[Net], series: Series): int =
    result = 0
    for i, x in series.xs:
        let correct = series.ys[i]
        let bestGuessIdx = nets
            .map(n => n.invoke(x))
            .transpose()    # so we can find the max across nets 
            .map(x => max(x))
            .argMax()
        if bestGuessIdx == correct:
            result += 1

proc computeFitness*(n: Net, series: Series, parentInheritance, regularization: float) = 

    var regularizationSum = 0.0
    for layer in n.layers:
        for neuron in layer.neurons:
            for weight in neuron.weights:
                regularizationSum += weight * weight

    let correct = n.correctPredictions(series)
    let batchfitness = pow(correct.toFloat, 3.0)
    let regularizationLoss = (regularizationSum * regularization) / n.weights.toFloat
    let parentFitness = n.fitness * parentInheritance

    n.fitness = max(parentFitness + batchfitness - regularizationLoss, 0.0)
    n.correct = correct

proc mutate*(x: Net, power, frequency: float) =
    for layer in x.layers:
        for neuron in layer.neurons:
            neuron.mutate(power, frequency)

proc pick*(pool: seq[Net], wheel: seq[float]): Net =
    let sum = wheel[^1]
    let ran = rand(0.0..sum)
    let idx = wheel.lowerBound(ran, system.cmp[float])
    return pool[idx].deepCopy()

proc crossover*(a: Net, pool: seq[Net], frequency, power: float, wheel: seq[float]) =
    let mate = pick(pool, wheel)
    let crossoverCount = (frequency * a.weights.toFloat).toInt-1

    for i in 0..<crossOverCount:
        let rLayer = rand(0..<a.layers.len)
        let rNeuron = rand(0..<a.layers[rLayer].neurons.len)
        let rWeigt = rand(0..<a.layers[rLayer].neurons[rNeuron].weights.len)

        let crossoverPower = rand(power)
        a.layers[rLayer].neurons[rNeuron].weights[rWeigt] = 
            lerp(a.layers[rLayer].neurons[rNeuron].weights[rWeigt],
                 mate.layers[rLayer].neurons[rNeuron].weights[rWeigt],
                 crossoverPower)

proc computeWheel*(pool: seq[Net]): seq[float] =
    var sum = 0.0
    result = newSeq[float]()
    for net in pool:
        sum += net.fitness
        result.add(sum)