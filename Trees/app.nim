import random
import marshal

const n_nodes = 100
const n_columns = 3

type
    Node = ref object
        threshold: float
        column: int
        index: int

proc newNode(index: int): Node =
    result = Node()
    result.column = rand(n_columns)
    result.threshold = rand(-100.0..100.0)
    result.index = index

type
    Tree = ref object
        data: array[n_nodes + 1, Node]

proc newTree(): Tree =
    result = Tree()
    for i in 1..<n_nodes + 1:
        result.data[i] = newNode(i)

proc left(n: Tree, i: int): Node =
    result = n.data[i*2]

proc right(n: Tree, i: int): Node =
    result = n.data[i*2 + 1]

proc parent(n: Tree, i: int): Node =
    result = n.data[i div 2];

proc main() =
    let t = newTree()
    echo $$t.data

    echo $$t.parent(1)
    echo $$t.parent(2)
    echo $$t.left(1)
    echo $$t.right(1)
    echo $$t.right(40)
    
main()
