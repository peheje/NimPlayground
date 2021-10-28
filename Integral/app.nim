import std/sugar
import std/strformat
import std/math

type
    F = proc(x: float): float
    Rule = proc(f: F, x, h: float): float

    Test = ref object
        name: string
        f: F
        start, to, answer: float

    Experiment = ref object
        name: string
        rule: Rule
        test: Test

proc integral(
    start, to: float,
    columns: int,
    rule: Rule,
    f: F): float =
    let h = (to - start) / columns.toFloat()
    var sum = 0.0
    for i in 0..<columns:
        let x = start + i.toFloat() * h
        sum += rule(f, x, h)
    sum * h

proc leftRectangle(f: F, x, h: float): float = f(x)

proc rightRectangle(f: F, x, h: float): float = f(x + h)

proc midRectangle(f: F, x, h: float): float = f(x + h / 2.0)

proc trapezium(f: F, x, h: float): float = (f(x) + f(x + h)) / 2.0

proc simpson(f: F, x, h: float): float = (f(x) + 4.0 * f(x + h / 2.0) + f(x + h)) / 6.0

proc main() =

    const
        columns = 100

    let
        fs = @[
            Test(name: "x^2", f: (x: float) => x * x, start: 0.0, to: 1.0, answer: 1.0/3.0),
            Test(name: "1/x", f: (x: float) => 1.0 / x, start: 1.0, to: 100.0, answer: ln(100.0)),
            Test(name: "x^3+x^2+x+1", f: (x: float) => x*x*x+x*x+x+1, start: -2.0, to: 2.5, answer: 19.2656),
        ]

    var exs: seq[Experiment]
    for f in fs:
        exs.add(Experiment(name: "Left", rule: leftRectangle, test: f))
        exs.add(Experiment(name: "Right", rule: rightRectangle, test: f))
        exs.add(Experiment(name: "Mid", rule: midRectangle, test: f))
        exs.add(Experiment(name: "Trapezium", rule: trapezium, test: f))
        exs.add(Experiment(name: "Simpson", rule: simpson, test: f))

    echo fmt"Columns: {columns}"

    for ex in exs:
        let
            test = ex.test
            guess = integral(test.start, test.to, columns, ex.rule, test.f)
            error = abs(test.answer - guess)
        echo ex.name & " " & test.name
        echo fmt"{guess} error: {error} ?"
        echo ""

main()
