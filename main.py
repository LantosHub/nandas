import time
import numpy as np
import sys
count = 10_000_000
if len(sys.argv) > 1:
    count = int(sys.argv[1])

arr = []
for i in range(0, count):
    arr.append(i)

print(f"first:{arr[0]}\nlast:{arr[-1]}\nlength:{len(arr)}")

starTime = time.time()
sumArr = 0
for i in arr:
    sumArr+=i
print(sumArr)
endTime = time.time()
print(f"py for:{endTime-starTime}s")


npArr = np.array(arr) 
starTime = time.time()
print(npArr.sum())
endTime = time.time()
print(f"np.sum:{endTime-starTime}s")

