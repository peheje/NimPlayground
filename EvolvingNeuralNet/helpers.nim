import json
import streams

proc argMax*[T](x: seq[T]): int =
    var max = x[0]
    result = 0
    for i in 1..<x.len:
        let value = x[i]
        if value > max:
            max = value
            result = i

proc argMaxBy*[T, V](s: openArray[T], call: proc(x: T): V): int =
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
