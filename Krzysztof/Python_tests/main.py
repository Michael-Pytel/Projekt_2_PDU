import pandas as pd
import numpy as np


def main():
    print("Data analysis with Python")
    df = pd.read_csv("example_df.csv")
    print(df)
    print(df.head(1))
    print(df.columns)
    print(df["Col1"])
    df = df.sort_values(by="NR", ascending=False)  # sort rows by NR values
    df.index = sorted(df.index)  # change row names
    print(df)


if __name__ == '__main__':
    main()
