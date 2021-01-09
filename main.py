import time
import pandas as pd

startTime = time.time()
pd.read_csv("data/fatData2.csv")
print(time.time()-startTime)