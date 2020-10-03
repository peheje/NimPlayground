import random
import sequtils
import marshal
import algorithm
import json

const
    knapsackCapacity = 200
    boxWeightRange = 1..10
    boxWorthRange = 50..100
    boxCount = 100

    generations = 10
    populationSize = 200
    initialPickRate = 0.01
    mutateRate = 0.05
    crossoverRate = 0.5

type
    Box = ref object
        weight: int
        worth: int
    
    Choice = ref object
        selections: seq[bool]
        score: int

proc newRandomBox(): Box =
    return Box(weight: rand(boxWeightRange), worth: rand(boxWorthRange))

proc assignScore(choice: Choice, boxes: seq[Box]) =
    var worth = 0
    var weight = 0

    for i in 0..<choice.selections.len:
        if (choice.selections[i]):
            weight += boxes[i].weight
            worth += boxes[i].worth
    
    if weight > knapsackCapacity:
        choice.score = 0
    else:
        choice.score = worth

proc newRandomChoice(boxes: seq[Box]): Choice = 
    result = Choice()
    result.selections = newSeqWith(boxes.len, rand(1.0) < initialPickRate)
    result.assignScore(boxes)

proc pick(population: seq[Choice]): Choice =
    
    # Tournament
    let p1 = population[rand(populationSize-1)]
    let p2 = population[rand(populationSize-1)]

    if p1.score > p2.score:
        return p1.deepCopy()
    else:
        return p2.deepCopy()

proc crossover(choice: Choice, population: seq[Choice]) =
    if rand(1.0) < crossoverRate:
        let mate = population[rand(populationSize-1)]

        let fromMate = choice.selections.len div 2
        let fromSelf = choice.selections.len - fromMate

        assert fromMate + fromSelf == choice.selections.len

        for i in 0..<fromMate:
            choice.selections[i] = mate.selections[i]
        for i in fromMate..<mate.selections.len:
            mate.selections[i] = choice.selections[i]


proc mutate(choice: Choice) =
    for i in 0..<choice.selections.len:
        if rand(1.0) < mutateRate:
            choice.selections[i] = not choice.selections[i]

proc main() =
    
    let boxes = newSeqWith(boxCount, newRandomBox())

    # Create population
    var population = newSeqWith(populationSize, newRandomChoice(boxes))

    # Which boxes do we put into knapsack to maximize worth?
    for g in 0..<generations:

        let newPopulation = newSeqWith(populationSize, pick(population))

        for choice in newPopulation:
            choice.crossover(newPopulation)
            choice.mutate()

        echo newPopulation.mapIt(it.score).max()
        population = newPopulation
    


    let best = population.mapIt(it.score).minIndex()
    echo "boxes: ", pretty(%boxes)
    echo "best: ", pretty(%population[best])



main()