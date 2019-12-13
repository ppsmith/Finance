import pandas as pd
import numpy as np
import Returns
import tickerDict



def beta(file):
    returnsAsset = Returns.simpleRet(file)
    returnsMarket = Returns.simpleRet(tickerDict.knownURL['ivv'])

    return (np.cov(returnsAsset, returnsMarket)/np.var(returnsMarket))