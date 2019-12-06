from urllib import request
import AverageComp
import Returns
import time
import tickerDict

#knownURL is dictionary of known URL for data pulls

knownURL = {'goog':"http://quotes.wsj.com/GOOG/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'aapl' :"http://quotes.wsj.com/AAPL/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'msft' :"http://quotes.wsj.com/MSFT/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'tsla' : "http://quotes.wsj.com/TSLA/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019"
            }

knownFil = {} #Future optimiztion. If we already have the file, there is no reason to re-download it

def removeSpace(parsedUserInput):  #func. does not work as intended. Will not have any impact on code
    for ticker in parsedUserInput:
        ticker.lstrip(' ')

def simpleRet(parsedUserInput, entire = 0, partial = 0): #function allows for differnet specifications for output. Default is to not return anything. Func. largly used by beta and other backend computation
    for ticker in parsedUserInput:
        filename, header = request.urlretrieve(knownURL[ticker])
        answer = Returns.simpleRet(filename)

        if(entire == 1):
            print (f"Returns for {ticker}: ")
            for result in range(len(answer)):
                print (answer[result])

        if(partial == 1):
            print(f"Returns for {ticker}: ", answer)

        else:
            continue


def averages(parsedUserInput):
    for ticker in parsedUserInput:
        if not tickerDict.validate(ticker):  #ensures we know where the data is located on the web. Will add logic to try to resolve ticker in the future
            parsedUserInput.remove(ticker)
            print("Unknown ticker!")
        try:
            filename, header = request.urlretrieve(knownURL[ticker])
            print (f"Averages for {ticker}: ", AverageComp.averagecomp(filename))
        except:
            print("Could not download data!")


while 1:
    userInput = input("Hello! Please Enter the assets you would like info on.\nPlease seperate your asset tickers with commas and in lower-case.\n Tickers: ")  #get user input

    if(userInput == ''):continue  #hack to fix bug with input()

    userInput.replace('\n', '\0')  #input sanitization

    parsedUserInput = userInput.split(',')  #delimit input on ',' into a list

    removeSpace(parsedUserInput)  #attempt do remove space from list items. Does not work
    averages(parsedUserInput)  #displat result of the average function
    simpleRet(parsedUserInput, 0, 1)  #display partial simple retrun array

    request.urlcleanup()  #remove tmp files generated

    time.sleep(.1)  #allows all processing to finish before call to input. Not great code.





