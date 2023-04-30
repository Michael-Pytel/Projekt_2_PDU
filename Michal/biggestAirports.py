import numpy as np
import pandas as pd

def main():
    df = pd.read_csv("../Dane/1999.csv")
    df = df.groupby("Origin")[["Day"]].count()
    df = df.sort_values(by="Month", ascending=False)
    print(df.head())

if __name__ == "__main__":
    main()