import asynchttpserver, asyncdispatch, streams, json

var server = newAsyncHttpServer()
proc cb(req: Request) {.async.} =
    # Read file
    let file = newFileStream("/Users/phj/GitRepos/nim_genetic/DifferentialEvolution/index.html", FileMode.fmRead)
    var html = file.readAll()

    if req.reqMethod == HttpMethod.HttpPost:
        let json = parseJson(req.body)
        let equation = json["equation"].getStr()
        echo equation

        await req.respond(Http200, equation)
    else:
        await req.respond(Http200, html)

try:
    waitFor server.serve(Port(3333), cb)
finally:
    server.close()