import random
import sugar
import helpers
import datasets
import json
import net
import sequtils

import algorithm

proc main() =

    randomize()
    let iris = newIris()
    const print = false
    const
        size = 100
        generations = 10000
        parentInheritance = 0.0
        regularization = 0.0
        crossoverProbability = 0.1
        crossoverRate = 0.1
        crossoverPower = 0.1..1.0
        mutateProbability = 0.1
        mutatePower = 0.1
        mutateFrequency = 0.1

    
    let setup = @[iris.inputs, 10, 100, 10, iris.outputs]
    let batch = iris.train  # todo take batch first time?

    var pool = newSeq[Net]()
    for i in 0..<size:
        let net = newNet(setup)
        pool.add(net)
        net.computeFitness(batch, parentInheritance, regularization)
    
    for j in 0..<generations:
        let wheel = computeWheel(pool)
        var nexts = newSeq[Net]()

        let bestIdx = pool.argMaxBy(x => x.fitness)
        let best = pool[bestIdx].deepCopy()

        for i in 1..<size:
            var next = pick(pool, wheel)
            if rand(0.0..1.0) < crossoverProbability:
                next.crossover(pool, crossoverRate, crossoverPower, wheel)
            if rand(0.0..1.0) < mutateProbability:
                next.mutate(mutatePower, mutateFrequency)

            let batch = iris.train # todo take batch
            next.computeFitness(batch, parentInheritance, regularization)
            nexts.add(next)
        
        nexts.add(best)
        pool = nexts
    
        if j mod 10 == 0:
            let bestIdx = pool.argMaxBy(x => x.fitness)
            let bestNet = pool[bestIdx]

            let testPredictions = bestNet.correctPredictions(iris.test)
            let testPercentage = testPredictions.toFloat / iris.test.xs.len.toFloat
            echo "test percentage " & $testPercentage

main()
