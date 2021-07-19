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
    case node.kind
        of nkValue: return node.value
        of nkBinary: return node.binaryOperation.call(node.left, node.right)
        of nkUnary: return node.unaryOperation.call(node.child)

proc print(node: Node, indent: int = 0) =
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
            print(node.left, indent + 6)
        of nkUnary: 
            echo node.unaryOperation.sign
            print(node.child, indent + 6)

proc randomNode(ops: seq[BinaryOperation], unaryOps: seq[UnaryOperation], depth, max: int): Node =
    let leaf = depth == max
    if leaf:
        result = Node(kind: nkValue, value: round(rand(-10.0..10.0)))
    else:
        if rand(1.0) < 0.25:
            result = Node(kind: nkUnary, unaryOperation: unaryOps[rand(0..<unaryOps.len)])
        else:
            result = Node(kind: nkBinary, binaryOperation: ops[rand(0..<ops.len)])

proc randomTree(ops: seq[BinaryOperation], unaryOps: seq[UnaryOperation], node: var Node, max, counter: int = 0) =
    node = randomNode(ops, unaryOps, counter, max)
    if counter >= max:
        return

    case node.kind
        of nkBinary:
            randomTree(ops, unaryOps, node.left, max, counter + 1)
            randomTree(ops, unaryOps, node.right, max, counter + 1)
        of nkUnary:
            randomTree(ops, unaryOps, node.child, max, counter + 1)
        of nkValue:
            assert(false, "value node should not end up in random tree")

proc parenthesis(x: float): string =
    if x < 0.0:
        return fmt"({x})"
    else:
        return $x

proc toEquation(node: Node, eq: var string, depth: int = 0) =
    case node.kind
        of nkValue:
            assert(false, "nkValue or nkUnary kind should not end up here")
        of nkUnary:
            # Untested code:
            let sign = node.unaryOperation.sign
            eq &= fmt"{sign}("
            if node.child.kind == nkValue:
                eq &= fmt"{node.child.value}"
            else:
                node.child.toEquation(eq, depth + 1)
            eq &= ")"
        of nkBinary:
            let sign = node.binaryOperation.sign
            if node.left.kind == nkValue and node.right.kind == nkValue:
                eq &= fmt"({parenthesis(node.left.value)} {sign} {parenthesis(node.right.value)})"
            else:
                if depth != 0:
                    eq &= "("
                node.left.toEquation(eq, depth + 1)
                eq &= fmt" {sign} "
                node.right.toEquation(eq, depth + 1)
                if depth != 0:
                    eq &= ")"

proc main() =
    randomize()
    var ops = newSeq[BinaryOperation]()

    ops.add(BinaryOperation(sign: "+", call: (a, b) => a.eval() + b.eval()))
    ops.add(BinaryOperation(sign: "-", call: (a, b) => a.eval() - b.eval()))
    #ops.add(BinaryOperation(sign: "*", call: (a, b) => a.eval() * b.eval()))
    #ops.add(BinaryOperation(sign: "^", call: (a, b) => pow(a.eval(), b.eval())))
    #ops.add(Operation(sign: "/", call: (a, b) => a.eval() / b.eval()))

    var unaryOps = newSeq[UnaryOperation]()
    unaryOps.add(UnaryOperation(sign: "abs", call: (x) => abs(x.eval())))
    unaryOps.add(UnaryOperation(sign:"sqrt", call: (x) => sqrt(x.eval())))
    #ops.add(Operation(sign: "cos", call: (a, b) => cos(a.eval()), unary: true))
    #ops.add(Operation(sign: "sin", call: (a, b) => sin(a.eval()), unary: true))

    for i in 0..<1_000_000:
        var tree: Node = nil
        randomTree(ops, unaryOps, tree, 2)

        #if tree.eval() == 42.0:
        tree.print()
        var equation = ""
        tree.toEquation(equation)
        echo equation
        echo tree.eval()
        echo "_____"


main()
