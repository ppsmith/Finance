import pandas as pd
import numpy as np
import Returns
import tickerDict



def beta(file):
    returnsAsset = Returns.simpleRet(file)
    returnsMarker = tickerDict.knownURL['ivv']

    return (np.cov(returnsAsset, returnsMarker)/np.var(returnsMarker))