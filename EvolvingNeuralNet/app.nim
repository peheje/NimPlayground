import random
import sugar
import helpers
import datasets
import json
import net

import algorithm

proc main() =

    randomize()
    let iris = newIris()
    const print = false

    var avg = 0.0
    const size = 5;
    var nets = newSeq[Net]()
    for i in 0..<size:
        let net = newNet(@[iris.inputs, 10, 10, 10, iris.outputs])
        nets.add(net)
        net.computeFitness(iris.train, 0.0, 0.0)

    var sum = 0.0
    for i in 0..<size:
        let val = nets[i].fitness
        echo val
        sum += val

    let wheel = computeWheel(nets)
    echoJsonDebug(wheel)
    for i in 0..<1000000:
        nets[0].crossover(nets, 0.5, wheel)

        # let percentage = net.correct / iris.train.xs.len
        # avg += percentage / size
        # when print:
        #     writeJsonDebug(net)
        #     echo "fitness " & $net.fitness
        #     echo "percentage correct " & $percentage
        #     echo "______"
            
    when print:
        echoJsonDebug(bestNet)
    
    echo "average " & $avg
    let bestIdx = nets.argMaxBy(x => x.fitness)
    let bestNet = nets[bestIdx]

    let testPredictions = bestNet.correctPredictions(iris.test)
    let testPercentage = testPredictions.toFloat / iris.test.xs.len.toFloat
    echo "test percentage " & $testPercentage

main()
