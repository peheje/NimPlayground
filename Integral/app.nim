import std/sugar
import std/strformat
import std/math

type
    F = proc(x: float): float
    Rule = proc(f: F, x, h: float): float

    Experiment = ref object
        name: string
        f: F
        start, to, answer: float
        rule: Rule

proc integral(
    start, to: float,
    cols: int,
    rule: Rule,
    f: F): float =
    let h = (to - start) / cols.toFloat()
    var sum = 0.0
    for i in 0..<cols:
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
        cols = 100
        powerOfTwo = (x: float) => x * x
        oneOver = (x: float) => 1.0 / x

    echo fmt"Columns: {cols}"

    for ex in @[
        Experiment(name: "Left-Rectangle x^2", f: powerOfTwo, start: 0.0, to: 1.0, answer: 1.0/3.0, rule: leftRectangle),
        Experiment(name: "Simpson, x^2", f: powerOfTwo, start: 0.0, to: 1.0, answer: 1.0/3.0, rule: simpson),
        Experiment(name: "Left-Rectangle 1/x", f: oneOver, start: 1.0, to: 100.0, answer: ln(100.0), rule: leftRectangle),
        Experiment(name: "Simpson 1/x", f: oneOver, start: 1.0, to: 100.0, answer: ln(100.0), rule: simpson)
        ]:
        stdout.write ex.name & ": "
        echo fmt"{integral(ex.start, ex.to, cols, ex.rule, ex.f)} == {ex.answer} ?"

main()
