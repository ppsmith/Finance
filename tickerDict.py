

knownURL = {'goog':"http://quotes.wsj.com/GOOG/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'aapl' :"http://quotes.wsj.com/AAPL/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'msft' :"http://quotes.wsj.com/MSFT/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'tsla' : "http://quotes.wsj.com/TSLA/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",
            'wmt' : "http://quotes.wsj.com/WMT/historical-prices/download?MOD_VIEW=page&num_rows=6299.041666666667&range_days=6299.041666666667&startDate=09/06/2000&endDate=11/29/2019",

def validate(ticker):
    return knownURL[ticker]