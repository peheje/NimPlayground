import strutils
import marshal
import math
import random

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
    elif node.op == Operation.add:
        return node.left.eval() + node.right.eval()
    elif node.op == Operation.subtract:
        return node.left.eval() - node.right.eval()
    elif node.op == Operation.multiply:
        return node.left.eval() * node.right.eval()
    elif node.op == Operation.divide:
        var right = node.right.eval()
        if right == 0.0:
            right = 1.0
        return node.left.eval() / right
    elif node.op == Operation.cos:
        return math.cos(node.left.eval())
    elif node.op == Operation.sin:
        return math.sin(node.left.eval())
    elif node.op == Operation.value:
        return node.value
    else:
        raise newException(Exception, "Operation not supported")

proc randomOperator(): Operation =
    let r = rand(1..Operation.high.ord())   # Don't allow value
    return Operation(r)

proc randomNode(leaf: bool = false): Node =
    if leaf:
        result = Node(op: value, value: rand(-100.0..100.0))
    else:
        result = Node(op: randomOperator())

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

proc main() = 
    randomize()
    # let data = read_xy("data.txt")

    # Example data for (2.2 − (2/11)) + (7*cos(0.5))
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

    var gen = Node()
    for _ in 0..<10:
        generate(gen, 2)
        gen.print()
        echo "===="
        echo gen.eval()

main()