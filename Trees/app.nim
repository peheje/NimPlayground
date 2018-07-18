import random
import marshal
import math

const n_nodes = int(pow(2.0, 16.0))
const n_columns = 3
const n_categories = 3

type
    Row = array[n_columns, float]

type
    Node = ref object
        threshold: float
        column: int
        index: int
        prediction: int
        
proc isLeaf(n: Node): bool =
    return n.index*2 + 1 > n_nodes

proc newNode(index: int): Node =
    result = Node()
    result.column = rand(n_columns)
    result.threshold = rand(-100.0..100.0)
    result.index = index
    if result.isLeaf():
        result.prediction = rand(n_categories)
        
type
    Tree = ref object
        data: array[n_nodes + 1, Node]

proc newTree(): Tree =
    result = Tree()
    for i in 1..<n_nodes + 1:
        result.data[i] = newNode(i)

proc left_idx(i: int): int =
    result = i*2

proc right_idx(i: int): int =
    result = i*2 + 1

proc parent_idx(i: int): int =
    result = i div 2;

proc predict(t: Tree, data: openarray[Row]): int =
    var tree_idx = 1
    for row in data:
        let node = t.data[tree_idx]
        if node.isLeaf():
            return node.prediction
        if row[node.column] < node.threshold:
            tree_idx = left_idx(tree_idx)
        else:
            tree_idx = right_idx(tree_idx)

proc main() =
    let t = newTree()
    echo $$t.data

    var training = newSeq[array[n_columns, float]]()
    for i in 0..<100:
        var column = array[n_columns, float]()
        for j in 0..n_columns:

    
        training.add()

    
main()
