import numpy as np
import pandas as pd

df = pd.read_csv("../Dane/2001.csv")
df = df.groupby("Month")[["Origin"]].count()
print(df)