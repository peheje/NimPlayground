import random, math, times

proc strcmp(a, b: cstring): cint {.importc: "strcmp", nodecl.}
echo strcmp("abc", "def")
echo strcmp("hello", "hello")
 
proc printf(formatstr: cstring) {.header: "<stdio.h>", varargs.}
 
var x = "foo"
printf("Hello %d %s!\n", 12, x)

proc time(p: ptr void) {.header: "<time.h>", varargs.}
proc srand(i: cint) {.header: "<stdlib.h>", varargs.}
proc rand(): cint {.importc: "rand", nodecl.}
echo epochTime()
srand(time(nil))
echo (rand().toFloat / pow(2.0, 32.0))