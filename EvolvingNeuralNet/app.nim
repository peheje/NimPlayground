import random
import helpers
import datasets
import net
import algorithm
import sugar

proc main() =

    #randomize()
    const
        print = false
        size = 20
        generations = 10_000
        batchsize = 20
        trainRatio = 0.5
        parentInheritance = 0.40
        regularization = 1.0
        crossoverProbability = 0.1
        crossoverRate = 0.05
        crossoverPower = 0.1..1.0
        mutatePower = 0.5
        mutateFrequency = 0.1
        mutateProbabilityDecay = 0.999

    var
        mutateProbability = 0.8

    let iris = newIris(trainRatio)
    let setup = @[iris.inputs, 10, 10, 10, iris.outputs]
    let batch = iris.computeBatch(batchsize)

    var pool = newSeq[Net]()
    for i in 0..<size:
        let net = newNet(setup)
        pool.add(net)
        net.computeFitness(batch, parentInheritance, regularization)
    
    #var copy = pool.deepCopy()
    #copy.sort((a, b) => cmp(a.fitness, b.fitness), SortOrder.Descending)
    #echo repr(copy)

    for j in 0..<generations:
        let wheel = computeWheel(pool)
        var nexts = newSeq[Net]()

        for i in 0..<size:
            var next = pick(pool, wheel)
            if rand(0.0..1.0) < crossoverProbability:
                next.crossover(pool, crossoverRate, crossoverPower, wheel)
            if rand(0.0..1.0) < mutateProbability:
                next.mutate(mutatePower, mutateFrequency)

            let batch = iris.computeBatch(batchsize)
            next.computeFitness(batch, parentInheritance, regularization)
            nexts.add(next)
        
        pool = nexts

        if mutateProbability > 0.1:
            # echo "mutateProbability" & $mutateProbability
            mutateProbability *= mutateProbabilityDecay
    
        if j mod 10 == 0:
            let bestIdx = pool.argMaxBy(x => x.fitness)
            let bestNet = pool[bestIdx]

            let testPredictions = bestNet.correctPredictions(iris.test)
            let testPercentage = testPredictions.toFloat / iris.test.xs.len.toFloat
            echo "test percentage " & $testPercentage

main()
