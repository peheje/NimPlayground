import random
import math

const bounds = -1.0..1.0

type
    Neuron* = ref object
        weights*: seq[float]
        bias*: float

proc newNeuron*(n: Neuron): Neuron =
    new result
    result.bias = n.bias
    for weight in n.weights:
        result.weights.add(weight)

proc newNeuron*(weights: int): Neuron =
    new result
    for i in 0..<weights:
        result.weights.add(rand(bounds))
    result.bias = rand(bounds)

func invoke*(x: Neuron, input: seq[float], lastLayer: bool): float =
    result = x.bias
    for i in 0..<input.len:
        result += x.weights[i] * input[i]
    if not lastLayer:
        result = max(result, 0.0) # Relu
        #result = tanh(result) # Tanh
        #result = 1.0 / (1.0 + exp(-result)) # Sigmoid

proc mutate*(x: Neuron, power, frequency: float) =
    for i in 0..<x.weights.len:
        if rand(0.0..1.0) < frequency:
            x.weights[i] += rand(-power..power)
    if rand(0.0..1.0) < frequency:
        x.bias += rand(-power..power)