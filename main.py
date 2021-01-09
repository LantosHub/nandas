import pandas as pd
import time

startTime= time.time()
pd.read_csv("data/fatData1.csv")
print(time.time()- startTime)