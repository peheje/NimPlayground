import strutils
import math
import random
import sugar
import strformat

type
    Node[T] = ref object
        left, right: Node[T]
        op: Operation[T]
        value: float
    
    Operation[T] = ref object
        sign: string
        unary: bool
        eval: proc(a, b: Node[T]): T

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

proc randomNode[T](ops: seq[Operation[T]], parent: Operation[T], depth, max: int): Node[T] =
    let leaf = depth == max

    if leaf:
        if parent.sign == "sqrt":
            result = Node[T](op: ops[0], value: rand(0.0..10.0))
        else:
            result = Node[T](op: ops[0], value: rand(-10.0..10.0))
    else:
        result = Node[T](op: ops[rand(1..<ops.len)])

proc randomTree[T](ops: seq[Operation[T]], node: var Node[T], max: int, counter: int = 0, parent: Operation[T] = nil) =
    node = randomNode[T](ops, parent, counter, max)
    if counter >= max:
        return
    randomTree(ops, node.left, max, counter + 1, node.op)
    if not node.op.unary:
        randomTree(ops, node.right, max, counter + 1, node.op)

proc toEquation(node: Node, eq: var string, depth: int = 0) =
    let sign = node.op.sign
    let right = node.right
    let left = node.left
    
    if right != nil and right.op.sign == "val":
        eq &= fmt"({left.value} {sign} {right.value})"
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

proc main[T]() =
    randomize()
    var operations = newSeq[Operation[T]]()

    operations.add(Operation[T](sign: "val", unary: false, eval: (a, b) => a.value))
    operations.add(Operation[T](sign: "+", unary: false, eval: (a, b) => a.eval() + b.eval()))
    operations.add(Operation[T](sign: "-", unary: false, eval: (a, b) => a.eval() - b.eval()))
    operations.add(Operation[T](sign:"*", unary: false, eval: (a, b) => a.eval() * b.eval()))
    operations.add(Operation[T](sign:"/", unary: false, eval: (a, b) => a.eval() / b.eval()))
    
    operations.add(Operation[T](sign:"abs", unary: true, eval: (a, b) => abs(a.eval())))

    operations.add(Operation[T](sign:"cos", unary: true, eval: (a, b) => cos(a.eval())))
    operations.add(Operation[T](sign:"sin", unary: true, eval: (a, b) => sin(a.eval())))

    #operations.add(Operation(sign:"sqrt", unary: true, eval: (a, b) => sqrt(a.eval())))

    for i in 0..<1000:
        var tree = Node[T]()
        randomTree(operations, tree, 4)
        #tree.print()

        echo tree.eval
        var equation = ""
        tree.toEquation(equation)
        echo equation
        echo "_____"

main[float]()