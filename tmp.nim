import bignum


proc a(m, n: Int): Int =
    if m == 0:
        result = n + 1
    elif m > 0 and n == 0:
        result = a(m - 1, newInt(1))
    elif m > 0 and n > 0:
        result = a(m - 1, a(m, n - 1))

var i = a(newInt(3), newInt(3))
echo i