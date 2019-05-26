import strutils
import marshal
import math
import random
import tables
import sets

type
    Point* = object
        x*, y*: float

    Operation = enum
        value, cos, sin, add, sub, mul, divi, sqrt

    Node = ref object
        left: Node
        right: Node
        op: Operation
        value: float

var UNARY = initSet[Operation]()
var OPERATIONS = initTable[Operation, proc (l, r: Node): float]()
var RANGE = -100.0..100.0
var SKIP = 0

proc print(node: Node, s: int = 0) =
    if node.isNil:
        return
    print(node.right, s + 6)
    echo ""
    for i in 0..<s:
        stdout.write(" ")
    if node.op == Operation.value:
        echo node.value.formatFloat(ffDecimal, 3)
    else:
        echo node.op
    print(node.left, s + 6)

proc eval(node: Node): float =
    if node.isNil:
        return
    elif node.op == Operation.value:
        return node.value
    let op = OPERATIONS[node.op]
    return op(node.left, node.right)

proc randomNode(leaf: bool = false): Node =
    if leaf:
        result = Node(op: Operation.value, value: rand(RANGE))
    else:
        result = Node(op: Operation(rand(1 + SKIP..Operation.high.ord())))

proc randomTree(node: var Node, max: int, counter: int = 0) =
    node = randomNode(max == counter)
    if counter >= max:
        return
    randomTree(node.left, max, counter + 1)
    if not UNARY.contains(node.op):
        randomTree(node.right, max, counter + 1)

proc read_xy*(path: string): seq[Point] =
    let lines = readFile(path).split("\n")
    result = newSeq[Point]()
    for line in lines:
        var s = line.split(" ")
        var x = s[0].parseFloat
        var y = s[1].parseFloat
        result.add(Point(x: x, y: y))

# Fitting the data.txt for 2. order poly:
# f(x) =  1.6484391286220554 + 0.99555711903272903 * x^1 + -0.085717636022514102 * x^2

proc runExample() =
    # Example data for (2.2 − (2/11)) + (7*cos(0.5)) = 8.16125975141442719463
    let root = Node(op: Operation.add)
    root.right = Node(op: Operation.mul)
    root.right.left = Node(op: Operation.value, value: 7.0)
    root.right.right = Node(op: Operation.cos)
    root.right.right.left = Node(op: Operation.value, value: 0.5)
    root.left = Node(op: Operation.sub)
    root.left.left = Node(op: Operation.value, value: 2.2)
    root.left.right = Node(op: Operation.divi)
    root.left.right.left = Node(op: Operation.value, value: 2.0)
    root.left.right.right = Node(op: Operation.value, value: 11.0)
    root.print()
    echo root.eval()

proc main() =
    randomize()
    # let data = read_xy("data.txt")
    # runExample

    # Setup
    SKIP = 2
    RANGE = 0.0..10.0

    OPERATIONS[Operation.add] = proc (l, r: Node): float = l.eval() + r.eval()
    OPERATIONS[Operation.sub] = proc (l, r: Node): float = l.eval() - r.eval()
    OPERATIONS[Operation.mul] = proc (l, r: Node): float = l.eval() * r.eval()
    OPERATIONS[Operation.divi] = proc (l, r: Node): float = l.eval() / r.eval()
    OPERATIONS[Operation.sqrt] = proc (l, r: Node): float = sqrt(l.eval())
    OPERATIONS[Operation.cos] = proc (l, r: Node): float = cos(l.eval())
    OPERATIONS[Operation.sin] = proc (l, r: Node): float = sin(l.eval())

    UNARY.incl(Operation.sqrt)
    UNARY.incl(Operation.cos)
    UNARY.incl(Operation.sin)

    for _ in 0..<1000:
        var gen = Node()
        randomTree(gen, 3)
        gen.print()
        echo gen.eval()
        echo "===="

main()
