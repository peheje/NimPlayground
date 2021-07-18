import strutils
import math
import random
import sugar
import strformat

type
    NodeKind = enum
        nkValue,
        nkBinary
        nkUnary

    Node = ref object
        case kind: NodeKind
        of nkValue: 
            value: float
        of nkBinary: 
            binaryOperation: BinaryOperation
            left, right: Node
        of nkUnary:
            unaryOperation: UnaryOperation
            child: Node

    BinaryOperation = ref object
        sign: string
        call: proc(a, b: Node): float

    UnaryOperation = ref object
        sign: string
        call: proc(a: Node): float

proc eval(node: Node): float =
    if node == nil:
        return
    elif node.kind == nkValue:
        return node.value
    elif node.kind == nkUnary:
        return node.unaryOperation.call(node.child)
    return node.binaryOperation.call(node.left, node.right)

proc print(node: Node, indent: int = 0) =
    if node == nil:
        return
    if node.kind == nkBinary:
        print(node.right, indent + 6)
    echo ""
    for i in 0..<indent:
        stdout.write(" ")
    case node.kind
        of nkValue:
            echo node.value.formatFloat(ffDecimal, 3)
        of nkBinary:
            echo node.binaryOperation.sign
        of nkUnary:
            echo node.unaryOperation.sign
    if node.kind == nkBinary:
        print(node.left, indent + 6)

proc randomNode(ops: seq[BinaryOperation], depth, max: int): Node =
    let leaf = depth == max
    if leaf:
        result = Node(kind: nkValue, value: round(rand(-10.0..10.0)))
    else:
        result = Node(kind: nkBinary, binaryOperation: ops[rand(0..<ops.len)])

proc randomTree(ops: seq[BinaryOperation], node: var Node, max, counter: int = 0) =
    node = randomNode(ops, counter, max)
    if counter >= max:
        return
    randomTree(ops, node.left, max, counter + 1)
    if node.kind != nkUnary:
        randomTree(ops, node.right, max, counter + 1)

proc parenthesis(x: float): string =
    if x < 0.0:
        return fmt"({x})"
    else:
        return $x

proc toEquation(node: Node, eq: var string, depth: int = 0) =
    let right = node.right
    let left = node.left

    var sign = "UNINITIALIZED"
    if node.kind == nkBinary:
            sign = node.binaryOperation.sign
    else:
        assert(false)

    if right != nil and right.kind == nkValue:
        eq &= fmt"({parenthesis(left.value)} {sign} {parenthesis(right.value)})"
    elif node.kind != nkUnary:
        if depth != 0:
            eq &= "("
        left.toEquation(eq, depth + 1)
        eq &= fmt" {sign} "
        right.toEquation(eq, depth + 1)
        if depth != 0:
            eq &= ")"
    else:
        eq &= fmt"{sign}("
        if left.kind == nkValue:
            eq &= fmt"{left.value}"
        else:
            left.toEquation(eq, depth + 1)
        eq &= ")"

proc main() =
    randomize()
    var ops = newSeq[BinaryOperation]()

    ops.add(BinaryOperation(sign: "+", call: (a, b) => a.eval() + b.eval()))
    ops.add(BinaryOperation(sign: "-", call: (a, b) => a.eval() - b.eval()))
    ops.add(BinaryOperation(sign: "*", call: (a, b) => a.eval() * b.eval()))
    ops.add(BinaryOperation(sign: "^", call: (a, b) => pow(a.eval(), b.eval())))
    #ops.add(Operation(sign: "/", call: (a, b) => a.eval() / b.eval()))
    #ops.add(Operation(sign: "abs", call: (a, b) => abs(a.eval()), unary: true))
    #ops.add(Operation(sign: "cos", call: (a, b) => cos(a.eval()), unary: true))
    #ops.add(Operation(sign: "sin", call: (a, b) => sin(a.eval()), unary: true))
    #ops.add(Operation(sign:"sqrt", call: (a, b) => sqrt(a.eval()), unary: true))

    for i in 0..<100_000:
        var tree: Node = nil
        randomTree(ops, tree, 2)

        if tree.eval() == 42.0:
            tree.print()
            var equation = ""
            tree.toEquation(equation)
            echo equation
            echo tree.eval()
            echo "_____"


main()
