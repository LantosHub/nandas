# %%
import numpy as np
import pandas as pd
import random
import hashlib

# %%
df1 = pd.DataFrame()

for i in range(1000_000):
    df1 = pd.concat([
        df1, pd.DataFrame([{
            "id": hashlib.md5(str(i).encode("utf-8")).hexdigest(),
            "amount": random.random()*100000
        }])
    ])

df1.set_index("id")
# %%
df2 = pd.DataFrame()

for i in range(1000_000):
    if i % 3 == 0:
        df2 = pd.concat([
            df2, pd.DataFrame([{
                "id1": "importantString",
                "id2": "importantString",
                "id3": hashlib.md5(str(i).encode("utf-8")).hexdigest(),
                "spent": random.random()*100000
            }])
        ])
    elif i % 2 == 0:
        df2 = pd.concat([
            df2, pd.DataFrame([{
                "id1": "importantString",
                "id2": hashlib.md5(str(i).encode("utf-8")).hexdigest(),
                "id3": "importantString",
                "spent": random.random()*100000
            }])
        ])
    else:
        df2 = pd.concat([
            df2, pd.DataFrame([{
                "id1": hashlib.md5(str(i).encode("utf-8")).hexdigest(),
                "id2": "importantString",
                "id3": "importantString",
                "spent": random.random()*100000
            }])
        ])

df2.set_index(["id1", "id2", "id3"])

# %%
