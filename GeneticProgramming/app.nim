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

proc randomNode(ops: seq[Operation], parent: Operation, depth, max: int): Node =
    let leaf = depth == max

    if leaf:
        result = Node(op: ops[0], value: rand(-10.0..10.0))
    else:
        result = Node(op: ops[rand(1..<ops.len)])

proc randomTree(ops: seq[Operation], node: var Node, max: int, counter: int = 0, parent: Operation = nil) =
    node = randomNode(ops, parent, counter, max)
    if counter >= max:
        return
    randomTree(ops, node.left, max, counter + 1, node.op)
    if not node.op.unary:
        randomTree(ops, node.right, max, counter + 1, node.op)

proc toEquation(n: Node, s: var string, depth: int = 0) =
    let sign = n.op.sign
    if n.right != nil and n.right.op.sign == "val":
        s &= fmt"({n.left.value} {sign} {n.right.value})"
    elif not n.op.unary:
        if n.right != nil and n.left != nil:
            if depth != 0:
                s &= "("
            if n.left != nil:
                n.left.toEquation(s, depth + 1)
            s &= fmt" {sign} "
            if n.right != nil:
                n.right.toEquation(s, depth + 1)
            if depth != 0:
                s &= ")"
    else:
        s &= fmt"{sign}("
        if n.right == nil and n.left != nil and n.left.op.sign == "val":
            s &= fmt"{n.left.value}"
        else:
            n.left.toEquation(s, depth + 1)
        s &= ")"

proc main() =
    randomize()
    var operations = newSeq[Operation]()

    operations.add(Operation(sign: "val", unary: false, eval: (a, b) => a.value))
    operations.add(Operation(sign: "+", unary: false, eval: (a, b) => a.eval() + b.eval()))
    operations.add(Operation(sign: "-", unary: false, eval: (a, b) => a.eval() - b.eval()))
    operations.add(Operation(sign:"*", unary: false, eval: (a, b) => a.eval() * b.eval()))
    operations.add(Operation(sign:"/", unary: false, eval: (a, b) => a.eval() / b.eval()))

    #operations.add(Operation(sign:"cos", unary: true, eval: (a, b) => cos(a.eval())))
    #operations.add(Operation(sign:"sin", unary: true, eval: (a, b) => sin(a.eval())))
    #operations.add(Operation(sign:"sqrt", unary: true, eval: (a, b) => sqrt(a.eval())))
    #operations.add(Operation(sign:"abs", unary: true, eval: (a, b) => abs(a.eval())))

    for i in 0..<1:
        var tree = Node()
        randomTree(operations, tree, 4)
        var equation = ""
        tree.toEquation(equation)

        tree.print()
        echo equation
        echo tree.eval()

main()