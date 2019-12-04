from urllib import request
import AverageComp
import Returns

knownURL = {'goog':"http://quotes.wsj.com/GOOG/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'ivv' :"http://quotes.wsj.com/IVV/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019"
            }

while 1:

    userInput = input("Hello! Please Enter the assets you would like info on.\nPlease seperate your asset tickers with commas and in lower-case.\n Tickers: ")

    parsedUserInput = str.strip(userInput)
    #print(parsedUserInput)
    parsedUserInput = str.split(userInput, ',')
    parsedUserInput = str.strip(parsedUserInput)

    print(parsedUserInput)

    for ticker in parsedUserInput:
        try:
            temp = knownURL[ticker]
        except:
            print("System does not know ticker: ", ticker)
            parsedUserInput.remove(ticker)
            break


    for ticker in parsedUserInput:
        filename, header = request.urlretrieve(knownURL[ticker])
        print(filename)
        print(ticker)
        print("Averages for", AverageComp.averagecomp(filename))




