import sequtils

iterator test0(): int =
    for i in 0..10:
        yield i

iterator test1: seq[int] =
    for i in 0..10:
        yield test0.toSeq

for test0 in test1():
    for i in test0.items:
        echo i