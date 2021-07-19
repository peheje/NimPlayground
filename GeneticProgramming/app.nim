import strutils
import math
import random
import sugar
import strformat

# Fast math gives some weird behavior, try: nim c -r -d=danger -l=-flto app.nim

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
        call: proc(x: Node): float

proc eval(node: Node): float =
    result = case node.kind:
        of nkValue: node.value
        of nkBinary: node.binaryOperation.call(node.left, node.right)
        of nkUnary: node.unaryOperation.call(node.child)

proc print(node: Node, indent: int = 0) =
    if node.kind == nkBinary:
        print(node.right, indent + 6)
    echo ""
    for i in 0..<indent:
        stdout.write(" ")
    case node.kind:
        of nkValue:
            echo node.value.formatFloat(ffDecimal, 3)
        of nkBinary:
            echo node.binaryOperation.sign
            print(node.left, indent + 6)
        of nkUnary:
            echo node.unaryOperation.sign
            print(node.child, indent + 6)

proc randomNode(binaryOps: seq[BinaryOperation], unaryOps: seq[UnaryOperation], depth, max: int): Node =
    let leaf = depth == max
    if leaf:
        result = Node(kind: nkValue, value: round(rand(-10.0..10.0)))
    else:
        if rand(1.0) < 0.25:
            result = Node(kind: nkUnary, unaryOperation: unaryOps.sample())
        else:
            result = Node(kind: nkBinary, binaryOperation: binaryOps.sample())

proc randomTree(binaryOps: seq[BinaryOperation], unaryOps: seq[UnaryOperation], node: var Node, max, counter: int = 0) =
    node = randomNode(binaryOps, unaryOps, counter, max)
    if counter >= max:
        return
    case node.kind:
        of nkValue:
            assert(false, "randomTree should not get here on value-nodes")
        of nkBinary:
            randomTree(binaryOps, unaryOps, node.left, max, counter + 1)
            randomTree(binaryOps, unaryOps, node.right, max, counter + 1)
        of nkUnary:
            randomTree(binaryOps, unaryOps, node.child, max, counter + 1)

proc parenthesis(x: float): string =
    if x < 0.0:
        return fmt"({x})"
    else:
        return $x

proc toEquation(node: Node, eq: var string, depth: int = 0) =
    case node.kind:
        of nkValue:
            assert(false, "toEquation should not be called on value-nodes")
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
        of nkUnary:
            let sign = node.unaryOperation.sign
            eq &= fmt"{sign}("
            if node.child.kind == nkValue:
                eq &= fmt"{node.child.value}"
            else:
                node.child.toEquation(eq, depth + 1)
            eq &= ")"

proc main() =
    randomize()
    var binaryOps = newSeq[BinaryOperation]()
    binaryOps.add(BinaryOperation(sign: "+", call: (a, b) => a.eval() + b.eval()))
    binaryOps.add(BinaryOperation(sign: "-", call: (a, b) => a.eval() - b.eval()))
    binaryOps.add(BinaryOperation(sign: "*", call: (a, b) => a.eval() * b.eval()))
    binaryOps.add(BinaryOperation(sign: "^", call: (a, b) => pow(a.eval(), b.eval())))
    binaryOps.add(BinaryOperation(sign: "/", call: (a, b) => a.eval() / b.eval()))

    var unaryOps = newSeq[UnaryOperation]()
    unaryOps.add(UnaryOperation(sign: "abs", call: (x) => abs(x.eval())))
    unaryOps.add(UnaryOperation(sign: "sqrt", call: (x) => sqrt(x.eval())))
    unaryOps.add(UnaryOperation(sign: "cos", call: (x) => cos(x.eval())))
    unaryOps.add(UnaryOperation(sign: "sin", call: (x) => sin(x.eval())))

    for i in 0..<10_000_000:
        var tree: Node = nil
        randomTree(binaryOps, unaryOps, tree, 6)

        #if tree.eval() == 42.0:
        tree.print()
        var equation = ""
        tree.toEquation(equation)
        echo equation
        echo tree.eval()
        echo "_____"

main()
