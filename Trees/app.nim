import random
import marshal
import math
import json
import bignum

const n_nodes = int(pow(2.0, 6.0))
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
    return n.index*2 + 1 >= n_nodes

proc newNode(index: int): Node =
    result = Node()
    result.column = rand(n_columns)
    result.threshold = rand(-100.0..100.0)
    result.index = index
    if result.isLeaf():
        let prediction = rand(n_categories)
        echo "node is leaf with category " & $prediction
        result.prediction = prediction
        
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

proc predict(t: Tree, row: Row, tree_idx: int = 1): int =
    let node = t.data[tree_idx]
    if node.isLeaf():
        echo "was leaf: " & $$node & " node.prediction = " & $node.prediction
        return node.prediction
    if row[node.column] < node.threshold:
        echo $row[node.column] & "<" & $node.threshold
        let _ = t.predict(row, left_idx(tree_idx))
    else:
        echo $row[node.column] & ">" & $node.threshold
        let _ = t.predict(row, right_idx(tree_idx))

proc pretty_print(o: any) =
    let s = $$o
    let json = parseJson(s)
    echo json.pretty

proc fib(n: Rat): Rat =
    var
        i = newRat(0)
        t = newRat(0)
        a = newRat(0)
        b = newRat(1)
    while i < n:
        t = a + b
        a = b
        b = t
        i += 1
    return a

proc main() =
    # let limit = newRat(1402)
    let limit = newRat(10 ^ 7)
    # let limit = newRat(10) # 55
    echo fib(limit)

proc main1() =
    let t = newTree()
    # echo $$t.data

    var training = newSeq[Row]()
    for i in 0..<10:
        let row: Row = [rand(-100.0..100.0), rand(-100.0..100.0), rand(-100.0..100.0)]
        training.add(row)

    pretty_print(training)
    let res = t.predict(training[1])    # should not always be 0
    echo res

main()