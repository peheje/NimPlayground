proc multiply(a, b: int): int =
    var
        left = a
        right = b
    while left != 0:
        if left mod 2 != 0:
            result += right
        left = left div 2   # Bitshift right
        right = right * 2   # Bitshift left

echo multiply(66, 46)
echo multiply(66, 0)
echo multiply(4678, 231452)