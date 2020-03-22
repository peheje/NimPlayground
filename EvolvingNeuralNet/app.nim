import math
import random
import streams
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
        weights: int

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

proc newNet(setup: seq[int]): Net =
    new result
    let lastLayerIdx = setup.len - 2
    for i in 0..<setup.len-1:
        result.layers.add(newLayer(setup[i], setup[i+1], i == lastLayerIdx))

func invoke(x: Net, input: seq[float]): seq[float] =
    result = input
    for layer in x.layers:
        result = layer.invoke(result)

proc writeJsonDebug(o: any) =
    const path = "/Users/phj/Desktop/nim_write.txt"
    let file = newFileStream(path, FileMode.fmWrite)
    if file != nil:
        file.writeLine(pretty(%o))

proc main() =
    randomize()
    let dataInputs = 3
    let dataOutputs = 4
    let n1 = newNet(@[dataInputs, 100, 1000, 10000, 1000, 100, dataOutputs])
    
    var result = n1.invoke(@[1.0, 2.0, 3.0])
    
    #writeJsonDebug(n1)
    #echo result

main()