#import nimprof
import random
import helpers
import datasets
import iris
import abalone
import net
import sequtils
import sugar
import math

proc main() =

    #randomize()
    const
        size = 200
        batchsize = 20
        generations = 2000
        print = 100
        trainRatio = 0.75
        parentInheritance = 0.9
        regularization = 0.8
        testWithTop = 0
        mutateProbability = 0.20
        mutateRate = 0.01
        mutatePower = 2.0
        crossoverProbability = 0.0
        crossoverRate = 0.02
        crossoverPower = 0.5
    
    let data = newAbalone(trainRatio)
    let setup = @[data.inputs, 10, 10, 10, data.outputs]
    let batch = data.computeBatch(batchsize)

    var pool = newSeq[Net]()
    for i in 0..<size:
        let net = newNet(setup)
        pool.add(net)
        net.computeFitness(batch, parentInheritance, regularization)
    
    for j in 0..<generations:
        let wheel = computeWheel(pool)
        var nexts = newSeq[Net]()

        for i in 0..<size:
            var next = pick(pool, wheel)
            if rand(0.0..1.0) < crossoverProbability:
                next.crossover(pool, crossoverRate, crossoverPower, wheel)
            if rand(0.0..1.0) < mutateProbability:
                next.mutate(mutatePower, mutateRate)

            let batch = data.computeBatch(batchsize)
            next.computeFitness(batch, parentInheritance, regularization)
            nexts.add(next)
        
        pool = nexts

        if j mod print == 0:
            var topText = ""
            when testWithTop != 0:
                let topn = pool.orderBy(x => x.fitness).take(testWithTop)
                let topnCorrections = topn.correctPredictions(data.test)
                let topPercentage = topnCorrections.toFloat / data.test.xs.len.toFloat
                topText = " top percentage " & $topPercentage

            let averageFitness = pool.map(x => x.fitness).sum() / size
            let bestIdx = pool.argMaxBy(x => x.fitness)
            let bestNet = pool[bestIdx]
            let testPredictions = bestNet.correctPredictions(data.test)
            let testPercentage = testPredictions.toFloat / data.test.xs.len.toFloat
            echo "test percentage t" & $testPercentage & " average fitness " & $averageFitness & topText
main()
