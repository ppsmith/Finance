import pandas as pd
import numpy as np
import Returns



def beta(file):
    returns = Returns.simpleRet(file)

    return (np.cov(returns))