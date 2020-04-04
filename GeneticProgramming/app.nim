import strutils
import math
import random
import sugar

type
    Node = ref object
        left, right: Node
        op: Operation
        value: float
    
    Operation = ref object
        sign: string
        unary: bool
        eval: proc(a, b: Node): float

proc add(ops: var seq[Operation], sign: string, unary: bool, eval: proc(a, b: Node): float): Operation =
    result = Operation(sign: sign, unary: unary, eval: eval)
    ops.add(result)

proc eval(node: Node): float =
    if node == nil:
        return
    elif node.op.sign == "val":
        return node.value
    return node.op.eval(node.left, node.right)

proc print(node: Node, s: int = 0) =
    if node == nil:
        return
    print(node.right, s + 6)
    echo ""
    for i in 0..<s:
        stdout.write(" ")
    if node.op.sign == "val":
        echo node.value.formatFloat(ffDecimal, 3)
    else:
        echo node.op.sign
    print(node.left, s + 6)

proc randomNode(ops: seq[Operation], leaf: bool = false, valueRange: HSlice[float, float]): Node =
    if leaf:
        result = Node(op: ops.sample(), value: rand(valueRange))
    else:
        result = Node(op: ops[rand(1..<ops.len)])

proc randomTree(ops: seq[Operation], node: var Node, max: int, counter: int = 0) =
    node = randomNode(ops, max == counter, -10.0..10.0)
    if counter >= max:
        return
    randomTree(ops, node.left, max, counter + 1)
    if not node.op.unary:
        randomTree(ops, node.right, max, counter + 1)

randomize()

var operations = newSeq[Operation]()
let valOp = operations.add("val", false, (a, b) => a.value)
let addOp = operations.add("+", false, (a, b) => a.eval() + b.eval())
let subOp = operations.add("-", false, (a, b) => a.eval() - b.eval())
let mulOp = operations.add("*", false, (a, b) => a.eval() * b.eval())
let divOp = operations.add("/", false, (a, b) => a.eval() / b.eval())
let cosOp = operations.add("cos", true, (a, b) => cos(a.eval()))

# Example data for (2.2 − (2/11)) + (7*cos(0.5)) = 8.16125975141442719463
let root = Node(op: addOp)
root.right = Node(op: mulOp)
root.right.left = Node(op: valOp, value: 7.0)
root.right.right = Node(op: cosOp)
root.right.right.left = Node(op: valOp, value: 0.5)
root.left = Node(op: subOp)
root.left.left = Node(op: valOp, value: 2.2)
root.left.right = Node(op: divOp)
root.left.right.left = Node(op: valOp, value: 2.0)
root.left.right.right = Node(op: valOp, value: 11.0)
root.print()
echo root.eval()