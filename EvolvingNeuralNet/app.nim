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
    const 
         parentInheritance = 0.1
         regularization = 0.0

    var avg = 0.0
    const size = 5;
    var nets = newSeq[Net]()
    for i in 0..<size:
        let net = newNet(@[iris.inputs, 2, iris.outputs])
        nets.add(net)
        net.computeFitness(iris.train, 0.0, 0.0)

    var sum = 0.0
    for i in 0..<size:
        let val = nets[i].fitness
        echo val
        sum += val

    for i in 0..<10000:
        let wheel = computeWheel(nets)

        # DEBUG START
        nets[0].fitness = 10000.0
        nets[0].layers[0].neurons[0].weights[0] = 111.11
        
        nets[1].fitness = 0.0
        nets[1].layers[0].neurons[0].weights[0] = 999.99

        # DEBUG END
        for j in 0..<nets.len:
            nets[j].crossover(nets, 0.5, wheel)
            nets[j].computeFitness(iris.train, parentInheritance, regularization)

    
    echoJsonDebug(nets)

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
