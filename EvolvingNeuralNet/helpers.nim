import json
import streams
import sugar
import algorithm

proc argMax*[T](x: seq[T]): int =
    var max = x[0]
    result = 0
    for i in 1..<x.len:
        let value = x[i]
        if value > max:
            max = value
            result = i

proc argMaxBy*[T, V](s: openArray[T], call: T -> V): int =
    var max = call(s[0])
    result = 0
    for i in 1..<s.len:
        let value = call(s[i])
        if value > max:
            max = value
            result = i

proc echoJsonDebug*(o: any) =
    echo pretty(%o)

proc writeJsonDebug*(o: any) =
    const path = "/Users/phj/Desktop/nim_write.txt"
    let file = newFileStream(path, FileMode.fmWrite)
    if file != nil:
        file.writeLine(pretty(%o))

func lerp*(a, b, p: float): float =
    return a + (b - a) * p

proc take*[T](s: openArray[T], limit: int): seq[T] =
    result = newSeq[T]()
    for i in 0..<limit:
        result.add(s[i])

proc orderBy*[T, V](s: seq[T], call: T -> V, order: SortOrder = SortOrder.Descending): seq[T] =
    var copy = s.deepCopy()
    copy.sort((a, b) => cmp(call(a), call(b)), order)
    result = copy

proc transpose*[T](s: seq[seq[T]]): seq[seq[T]] =
    result = newSeq[seq[T]](s[0].len)
    for i in 0..<s[0].len:
        result[i] = newSeq[T](s.len)
        for j in 0..<s.len:
            result[i][j] = s[j][i]