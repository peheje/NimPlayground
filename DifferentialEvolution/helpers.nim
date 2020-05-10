import strutils

type
  Point* = object
    x*, y*: float

proc read_xy*(path: string): seq[Point] =
  let lines = readFile(path).split("\n")
  result = newSeq[Point]()
  for line in lines:
    var s = line.split(" ")
    var x = s[0].parseFloat
    var y = s[1].parseFloat
    result.add(Point(x: x, y: y))

proc horner*(coeffs: openArray[float], x: float): float =
  # coeffs[0] is for highest order
  # [2.0, 5.0, -1.0, 5.0] equals 2*x^3 + 5*x^2 - 1*x + 5
  for c in coeffs:
    result = result * x + c
