import tables
import md5
import random
type
    MyObj = ref object
        key1: string
        key2: string
        val: float
        paid: float

var myObjs = newSeq[MyObj]()
var lookUp1 = initTable[string, MyObj]()
var lookUp2 = initTable[string, MyObj]()

for i in 0..100:
    if i.mod(2) == 0:
        myObjs.add MyObj(
            key1: $toMd5($i),
            key2: "key2",
            val: random.rand(100_000.00)
        )
    else:
        myObjs.add MyObj(
            key1: "key1",
            key2: $toMd5($i),
            val: random.rand(100_000.00)
        )
    
for myObj in myObjs:
    lookUp1[myObj.key1] =  myObj
    lookUp2[myObj.key2] =  myObj

try:
    echo lookUp1[$toMd5("1")][]
except KeyError:
    lookUp2[$toMd5("1")].paid = 100
    echo lookUp2[$toMd5("1")][]
    echo myObjs[1][]
    
