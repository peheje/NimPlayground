import neuron

type
    Layer* = ref object
        neurons*: seq[Neuron]
        last*: bool

proc newLayer*(l: Layer): Layer =
    new result
    result.last = l.last
    for neuron in l.neurons:
        result.neurons.add(newNeuron(neuron))

proc newLayer*(previousInputSize, size: int, last: bool): Layer =
    new result
    for i in 0..<size:
        result.neurons.add(newNeuron(previousInputSize))
    result.last = last

func invoke*(x: Layer, input: seq[float]): seq[float] =
    for neuron in x.neurons:
        result.add(neuron.invoke(input, x.last))