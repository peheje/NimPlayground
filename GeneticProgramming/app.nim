import strutils
import marshal
import math
import random
import tables

type
    Point* = object
        x*, y*: float

    Operation = enum
        value, add, subtract, multiply, divide, cos, sin

    Node = ref object
        left: Node
        right: Node
        op: Operation
        value: float

var OPS = initTable[Operation, proc (l, r: Node): float]()

proc print(op: Operation) =
    if op == Operation.add:
        echo "+"
    elif op == Operation.subtract:
        echo "-"
    elif op == Operation.multiply:
        echo "*"
    elif op == Operation.divide:
        echo "/"
    elif op == Operation.cos:
        echo "cos"
    elif op == Operation.sin:
        echo "sin"
    else:
        raise newException(Exception, "Could not print that operator")

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
        node.op.print()
    print(node.left, s + 6)

proc eval(node: Node): float =
    if node.isNil:
        return

    if node.op == Operation.value:
        return node.value

    let op = OPS[node.op]
    return op(node.left, node.right)

proc randomNode(leaf: bool = false): Node =
    if leaf:
        result = Node(op: Operation.value, value: rand(-100.0..100.0))
    else:
        result = Node(op: Operation(rand(1..Operation.high.ord())))

proc generate(node: var Node, max: int, counter: int = 0) =
    node = randomNode(max == counter)
    if counter >= max:
        return
    generate(node.left, max, counter + 1)
    generate(node.right, max, counter + 1)

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
    root.right = Node(op: Operation.multiply)
    root.right.left = Node(op: Operation.value, value: 7.0)
    root.right.right = Node(op: Operation.cos)
    root.right.right.left = Node(op: Operation.value, value: 0.5)
    root.left = Node(op: Operation.subtract)
    root.left.left = Node(op: Operation.value, value: 2.2)
    root.left.right = Node(op: Operation.divide)
    root.left.right.left = Node(op: Operation.value, value: 2.0)
    root.left.right.right = Node(op: Operation.value, value: 11.0)
    root.print()
    echo root.eval()

proc main() =
    randomize()
    # let data = read_xy("data.txt")

    OPS[Operation.add] = proc (l, r: Node): float = l.eval() + r.eval()
    OPS[Operation.subtract] = proc (l, r: Node): float = l.eval() - r.eval()
    OPS[Operation.multiply] = proc (l, r: Node): float = l.eval() * r.eval()
    OPS[Operation.divide] = proc (l, r: Node): float = l.eval() / r.eval()
    OPS[Operation.cos] = proc (l, r: Node): float = cos(l.eval())
    OPS[Operation.sin] = proc (l, r: Node): float = sin(l.eval())

    runExample()

    var gen = Node()
    for _ in 0..<0:
        generate(gen, 2)
        gen.print()
        echo "===="
        echo gen.eval()

main()
