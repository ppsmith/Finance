import pandas as pd

FiftyDayAvg = 0
TwoHundoDayAvg = 0

def averagecomp(file):
    i = 0
    sum = 0
    csv_file = pd.read_csv(file)
    prices = csv_file.loc[:, csv_file.columns[4]]

    for price in prices:
        if i == 50: break
        else:
            sum += prices.at[i]
            i+=1
    FiftyDayAvg =  sum/50

    i = 0
    sum = 0

    for price in prices:
        if i == 200: break
        else:
            sum += prices.at[i]
            i+=1
    TwoHundoDayAvg = sum/200

    if(TwoHundoDayAvg > FiftyDayAvg):
        return("Two hundred day average larger than 50 day avertage,")

    if(TwoHundoDayAvg < FiftyDayAvg):
        return ("200 day average less than 50 day average.")

    else:
        return("ERROR: BAD LINK")








