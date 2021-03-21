import strutils
import math
import random
import sugar
import strformat

type
    Node = ref object
        left, right: Node
        op: Operation
        value: float

    Operation = ref object
        sign: string
        unary: bool
        eval: proc(a, b: Node): float

proc eval(node: Node): float =
    if node == nil:
        return
    elif node.op.sign == "val":
        return node.value
    elif node.op.unary:
        return node.op.eval(node.left, nil)
    return node.op.eval(node.left, node.right)

proc print(node: Node, indent: int = 0) =
    if node == nil:
        return
    print(node.right, indent + 6)
    echo ""
    for i in 0..<indent:
        stdout.write(" ")
    if node.op.sign == "val":
        echo node.value.formatFloat(ffDecimal, 3)
    else:
        echo node.op.sign
    print(node.left, indent + 6)

proc randomNode(ops: seq[Operation], depth, max: int): Node =
    let leaf = depth == max

    if leaf:
        result = Node(op: ops[0], value: round(rand(-10.0..10.0)))
    else:
        result = Node(op: ops[rand(1..<ops.len)])

proc randomTree(ops: seq[Operation], node: var Node, max, counter: int = 0) =
    node = randomNode(ops, counter, max)
    if counter >= max:
        return
    randomTree(ops, node.left, max, counter + 1)
    if not node.op.unary:
        randomTree(ops, node.right, max, counter + 1)

proc parenthesis(x: float): string =
    if x < 0.0:
        return fmt"({x})"
    else:
        return $x

proc toEquation(node: Node, eq: var string, depth: int = 0) =
    let sign = node.op.sign
    let right = node.right
    let left = node.left

    if right != nil and right.op.sign == "val":
        eq &= fmt"({parenthesis(left.value)} {sign} {parenthesis(right.value)})"
    elif not node.op.unary:
        if depth != 0:
            eq &= "("
        left.toEquation(eq, depth + 1)
        eq &= fmt" {sign} "
        right.toEquation(eq, depth + 1)
        if depth != 0:
            eq &= ")"
    else:
        eq &= fmt"{sign}("
        if left.op.sign == "val":
            eq &= fmt"{left.value}"
        else:
            left.toEquation(eq, depth + 1)
        eq &= ")"

proc main() =
    randomize()
    var ops = newSeq[Operation]()

    ops.add(Operation(sign: "val", eval: (a, b) => a.value))
    ops.add(Operation(sign: "+", eval: (a, b) => a.eval() + b.eval()))
    ops.add(Operation(sign: "-", eval: (a, b) => a.eval() - b.eval()))
    ops.add(Operation(sign: "*", eval: (a, b) => a.eval() * b.eval()))
    ops.add(Operation(sign: "^", eval: (a, b) => pow(a.eval(), b.eval())))
    #ops.add(Operation(sign: "/", eval: (a, b) => a.eval() / b.eval()))
    #ops.add(Operation(sign: "abs", eval: (a, b) => abs(a.eval()), unary: true))
    #ops.add(Operation(sign: "cos", eval: (a, b) => cos(a.eval()), unary: true))
    #ops.add(Operation(sign: "sin", eval: (a, b) => sin(a.eval()), unary: true))
    #ops.add(Operation(sign:"sqrt", eval: (a, b) => sqrt(a.eval()), unary: true))

    for i in 0..<1_000_000:
        var tree: Node = nil
        randomTree(ops, tree, 5)
        #tree.print()

        if tree.eval() == 42.0:
            var equation = ""
            tree.toEquation(equation)
            echo equation
            echo tree.eval()
            echo "_____"


main()
