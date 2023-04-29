import numpy as np
import pandas as pd

### Object Creation

# Creating a series
s = pd.Series([1, 3, 5, np.nan, 6, 8])
print(s)

# Creating a DataFrame
dates = pd.date_range("20130101", periods=6)
print(dates)
df = pd.DataFrame(np.random.randn(6,4), index=dates, columns=list("ABCD"))
print(df)

# Creating a DataFrame using by passing a dictionary of objects
df2 = pd.DataFrame(
    {
        "A": 1.0,
        "B": pd.Timestamp("20130102"),
        "C": pd.Series(1, index=list(range(4)), dtype="float32"),
        "D": np.array([3] * 4, dtype="int32"),
        "E": pd.Categorical(["test", "train", "test", "train"]),
        "F": "foo",
    }
)
print(df2)
print(df2.dtypes)

#### Viewing data in DataFrames

# Viewing top 5 rows and bottom 3 (respectively)
print(df.head())
print(df.tail(3))

# Displaying the row names (row indexes)
print(df.index)

# Displaying the column names
print(df.columns)

# DataFrame.to_numpy() gives a NumPy representation of the underlying data.
# Note that this can be an expensive operation when your DataFrame has columns with different data types,
# which comes down to a fundamental difference between pandas and NumPy: NumPy arrays have one dtype for the entire array,
# while pandas DataFrames have one dtype per column. When you call DataFrame.to_numpy(),
# pandas will find the NumPy dtype that can hold all of the dtypes in the DataFrame.
# This may end up being object, which requires casting every value to a Python object.
# for df, our DataFrame of all floating-point values, and DataFrame.to_numpy() is fast and doesn't require copying data:
print(df.to_numpy())
# For df2, the DataFrame with multiple dtypes, DataFrame.to_numpy() is relatively expensive:
print(df2.to_numpy())
# DataFrame.to_numpy() # Does not include indexes of rows and columns

# describe() shows a quick summary of your data
print(df.describe())

# Transposition of the dataframe
print(df.T)

# df.sort_index() # sorts by an axis:
print(df.sort_index(axis=1, ascending=False))

#df.sort_values() # sorts by values:
print(df.sort_values(by="B"))

##### Selection

## Getting

# Selecting a single column, which yields a Series, equivalent to df.A:
print()
print(df["A"])
print()
print(df.A)

# Selecting via [](__getitem__), which slices the rows:
print()
print(df[0:3])
print()
print(df["20130102":"20130104"])

## Selection by label

# Getting a cross-section using a label
print()
print(df.loc[dates[0]])


# Selecting on multi-axis by label
print()
print(df.loc[:, ["A", "B"]])

# Label slicing, both endpoints included:
print()
print(df.loc["20130102": "20130104", ["A", "B"]])

# Reduction in the dimentions of the returned object:
print()
print(df.loc["20130102", ["A", "B"]])

# For getting a scalar value
print()
print(df.loc[dates[0], "A"])

# For getting fast access to a scalar (equivalent to the prior method):
print(df.at[dates[0], "A"])


## Selecion by position

# Select via the position of the passed integers:
print()
print(df.iloc[3])

# By integer slices, acting similar to NumPy/Python:
print()
print(df.iloc[3:5, 0:2])

# By lists of integer position locations, similar to the NumPy/Python style:
print()
print(df.iloc[[1, 2, 4], [0, 2]])

# For slicing rows explicitly:
print()
print(df.iloc[1:3, :])

# For slicing columns explicitly:
print()
print(df.iloc[:, 1:3])

# For getting a value explicitly:
print()
print(df.iloc[1, 1])

# For getting to a scalar (equivalent to the prior method):
print()
print(df.iat[1, 1])


## Boolean indexing

# Using a single column's values to select data:
print()
print(df[df["A"] > 0])

# Selecting values from a DataFrame where a boolean condition is met:
print()
print(df[df > 0])

# Using the isin() method for filtering:
df2 = df.copy()
df2["E"] = ["one", "one", "two", "three", "four", "three"]
print()
print(df2)
print()
print(df2[df2["E"].isin(["two", "four"])])

## Setting


# Setting a new column automatically aligns the data indexes:
s1 = pd.Series([1, 2, 3, 4, 5, 6], index=pd.date_range("20130102", periods=6))
print()
print(s1)
df["F"] = s1

# Setting values by label:
df.at[dates[0], "A"] = 0
print()
print(df)

# Setting values by position:
df.iat[0, 1] = 0
print()
print(df)

# Setting by assigning with a NumPy array:
df.loc[:, "D"] = np.array([5]*len(df))
print()
print(df)

# A "where" operation with a setting:
df2 = df.copy()
df2[df2 > 0] = -df2
print()
print(df2)


###### Mising Data
# Pandas uses primarily the value np.nan to represent missing data

# Reindexing allows you to change/add/delete the index on a specific
df1 = df.reindex(index=dates[0:4], columns=list(df.columns) + ["E"])
df1.loc[dates[0]:dates[1], "E"] = 1
print()
print(df1)

# DataFrame.dropna() # drops any row that have missing data:
print()
print(df1.dropna(how="any"))

# DataFrame.fillna() # fills any missing dat:
print()
print(df1.fillna(value=5))

# isna() # gets the boolean mask where values are nan:
print(pd.isna(df1))


#### Operations

## Stats
# Operations in general exclude missing data

# Performing a discriotive statistic:
print()
print(df.mean())

# Same operation by on the other axis:
print()
print(df.mean(1))

# Operating with objects that have different dimentionality and need alignment.
# In addition, pandas automatically broadcasts along the specified dimension:
s = pd.Series([1, 3, 5, np.nan, 6, 8], index=dates).shift(2)
print()
print(s)