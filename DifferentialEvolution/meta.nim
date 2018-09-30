import macros

dumpTree:
    proc f1*(c: openarray[float]): float =
        let 
            x = c[0]
            y = c[1]
        result = x + y - 2

nnkCommand(
    nnkIdent("echo"),
    nnkStrLit("abc"),
    nnkStrLit("xyz")
)