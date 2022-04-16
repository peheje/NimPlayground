import std/sequtils

# This is how you would probably do it by hand
var left = 57
var right = 91

# Left hand side
var lefts: seq[int]
while left != 0:
    lefts.add left
    left = left div 2

echo lefts

# Right hand side
var rights: seq[int]
while len(rights) != len(lefts):
    rights.add right
    right = right * 2

echo rights

# Filter out rows with even rights
var filtered: seq[(int, int)]
for row in zip(lefts, rights):
    if row[0] mod 2 != 0:
        filtered.add row

echo filtered

# Add right hand side
var ans = 0
for row in filtered:
    ans += row[1]

echo ans