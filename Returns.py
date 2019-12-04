import pandas as pd
import numpy as np


def simpleRet(file):
    csv_file = pd.read_csv(file)
    prices = csv_file.loc[:, csv_file.columns[4]]
    returns = np.empty(len(prices), dtype='float')

    i = 0

    for price in prices:
        if i == len(prices) - 1: break
        else:
            returns[i] = (prices.at[i+1]/prices.at[i]) - 1
            i += 1
    return (file, returns)


def logReturns(file):
    csv_file = pd.read_csv(file)
    prices = csv_file.loc[:, csv_file.columns[4]]
    returns = np.empty(len(prices), dtype='float')
    i = 0

    for price in prices:
        if i == len(prices) - 1: break

        else:
            returns[i] = np.log(prices.at[i+1]/prices.at[i])
            i += 1
    return (file, returns)





