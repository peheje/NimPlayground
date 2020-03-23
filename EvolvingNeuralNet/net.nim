import layer
import neuron
import datasets
import helpers

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

proc computeFitness*(n: Net, series: Series, parentInheritance, regularization: float) = 
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

proc mutate*(x: Net, power, frequency: float) =
    for layer in x.layers:
        for neuron in layer.neurons:
            neuron.mutate(power, frequency)