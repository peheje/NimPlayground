import layer
import neuron
import datasets
import helpers
import algorithm
import random
import math
import deques

type
    Net* = ref object
        layers*: seq[Layer]
        fitness*: float
        correct*, weights*: int
        mates: Deque[Net]

proc newNet*(setup: seq[int]): Net =
    new result
    result.mates = initDeque[Net](8)
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

        var guesses = newSeq[seq[float]]()
        guesses.add(neuralGuess)
        for mate in n.mates:
            guesses.add(mate.invoke(x))

        var combined = newSeq[float]()
        for i in 0..<neuralGuess.len:
            var temp = newSeq[float]()
            for guess in guesses:
                temp.add(guess[i])
            combined.add(max(temp))

        #if n.mates.len > 1:
        #    echo repr(guesses)
        #    echo repr(combined)

        let bestGuess = argMax(combined)
        if bestGuess == correct:
            result += 1

proc computeFitness*(n: Net, series: Series, parentInheritance: float) = 
    let correct = n.correctPredictions(series)
    let batchfitness = pow(correct.toFloat, 3.0)
    n.fitness = max(parentInheritance * n.fitness + batchfitness, 0.0)
    n.correct = correct

proc mutate*(x: Net, power, frequency: float) =
    for layer in x.layers:
        for neuron in layer.neurons:
            neuron.mutate(power, frequency)

proc pick*(pool: seq[Net], wheel: seq[float], copy: bool = true): Net =
    let sum = wheel[^1]
    let ran = rand(0.0..sum)
    let idx = wheel.lowerBound(ran, system.cmp[float])
    if copy:
        return pool[idx].deepCopy()
    else:
        return pool[idx]

proc crossover*(a: Net, pool: seq[Net], frequency, power: float, wheel: seq[float]) =
    let mate = pick(pool, wheel, false)
    if a.mates.len > 4:
        a.mates.popLast()
    a.mates.addFirst(mate)

proc crossover2*(a: Net, pool: seq[Net], frequency, power: float, wheel: seq[float]) =
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