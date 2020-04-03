%Purpose:
   %Econ 525-Spring2020
%Note:
   %This m-file is dependent upon xyz files.
%Author: Phillip Smith - Janurary, 2020
%UNC Honor Pledge: I certify that no unauthorized assistance has been received
%or given in the completion of this work

%constants
apiKey = 'HxTGtomxL79TZzQg_Ey4';
constituents = table2array(readtable("S&P500Constiuents.txt"));
url1 = 'https://www.quandl.com/api/v3/datasets/WIKI/';
url2 = '.csv?start_date=2013-01-13&end_date=2018-12-31&qopts.columns=date,adj_close&collapse=monthly&api_key=HxTGtomxL79TZzQg_Ey4';
localPrices = 'C:\Users\ppsmith\MATLAB Drive\Data\totalData.txt';

%cell array containg the price matrix of eash asset in constituents
container = {};  %holds the data for each asset
totalData = table();  %holds all of the data 
tenYearData = table();  %holds ten year bond yield data
tenMinusTwo = table();  %holds yield spread data
SP5dy = table();  %holds dividend yield data
DIP = table();  %holds IP change data
logMonthlyRet = [];  %holds log monthly returns for each asset, row major
factors = {'Ten Year', 'Ten Minus 2', 'Dividend Yield', 'Change in IP'};  

%answerTable is the object that will contain the answer to the homework
%question 1
answerTable = table('Size', [numel(constituents), 7], 'VariableTypes', ["string", "double","double", "double", "double", "double", "double"]);
answerTable.Properties.VariableNames = {'Ticker', 'MeanRet', 'Beta1', 'Beta2', 'Beta3', 'Beta4', 'Beta5'};

%table holds answer to second part of the equation
answerLambda = table('Size', [4, 3], 'VariableTypes', ["string", "double", "double"]);
answerLambda.Properties.VariableNames = {'Factor', 'Lambda', 'tstat'};

lambdaFama = table('Size', [4,3], 'VariableTypes', ["string", "double", "double"]);
lambdaFama.Properties.VariableNames = {'Factor' 'Lambdas', 'tstat'};

%Call gets the stock data.
[prices, answerTable, container] = getPrices(constituents,url1, url2, totalData, answerTable, container); %downloads prices and formats output table

%remove any missing data
answerTable = rmmissing(answerTable);

tenYearData = get10Year();  %gets the ten year bond yield data
tenMinusTwo = getTenMinusTwo(); %gets 10 minus 2 data
SP5dy = timetable2table(getDivYield());  %gets div yield data
DIP = getDIP();  %gets change in industrial production data

%find the logMeans of the assets
[answerTable,logMonthlyRet] = logMean(answerTable, container, logMonthlyRet);

%does first pass and second pass regression and displays the results
answerTable = firstPass(container, answerTable, tenYearData,tenMinusTwo, SP5dy, DIP, logMonthlyRet)
answerLambda = secondPass(answerLambda, answerTable, factors)
lambdaFama = famaMcBeth(logMonthlyRet, factors, answerTable,lambdaFama)

writetable(answerTable, 'answerTable.csv', 'WriteRowNames', true, 'WriteVariableNames', true);
writetable(answerLambda, 'lambdaTable.csv', 'WriteRowNames',true, 'WriteVariableNames',true);
writetable(lambdaFama, 'lambdaFama.csv', 'WriteRowNames',true, 'WriteVariableNames',true);

%--------------------------------------------------------------------------------------------------------------------------%

%%%%%%%%%%%%%%%FUNCTIONS%%%%%%%%%%%%%%%%%

%downloads price data and formats table to hold answers
function [totalData, answerTable, container] = getPrices(constituents, url1, url2, totalData, answerTable, container)
     i = 1; %iterates through every constituent we can actully get data on
     j = 1; %iterates through every costituent 
     while j <= numel(constituents)  %for each constituent...
         try
            url = strcat(url1, upper(constituents{j}), url2);  %builds url from constituent parts
            [response] = send(matlab.net.http.RequestMessage(), url);  %response object has info about conmnection and data in it
            data = response.Body.Data;
            if(height(data) ~= 63)  %ensure that the data is of the proper length
                j = j + 1;  %if not, advance in constituent list, but not in answer table
                continue
            end
            data = removevars(data, {'Open', 'High', 'Low', 'Close', 'Volume', 'Ex_Dividend', ...
                                     'SplitRatio', 'Adj_Open', 'Adj_High', 'Adj_Volume', 'Adj_Low'});  %remove uneeded data
            data.Ticker = repmat(string(constituents{i}), size(data, 1), 1); %record the ticker
            totalData = [totalData; data];  %add to total data
            container{i} = data;  %add data into the container
            answerTable.Ticker{i} = constituents{j};  %add ticker to answer table
            i = i + 1
            j = j + 1;
         catch ME  %on connection error, treat as though the data was the wroung length
            j = j + 1;
            continue
        end
     end
end

%gets the ten-year bond data
function [tenYearData] = get10Year()
    url =  ['https://fred.stlouisfed.org/graph/fredgraph.csv?' ...
        'bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&' ...
        'graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&' ...
        'txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&s' ...
        'how_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=DGS10&' ...
        'scale=left&cosd=2013-01-01&coed=2018-03-31&line_color=%234572a7&' ...
        'link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&' ...
        'ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=eop&fgst=lin&' ...
        'fgsnd=2009-06-01&line_index=1&transformation=lin&v' ...
        'intage_date=2020-01-25&revision_date=2020-01-25&nd=1962-01-02'];  %API URL with that formats the data downloaded
    
        [response] = send(matlab.net.http.RequestMessage(), url);  %send URL GET request, store response
        data = response.Body.Data;  %get data from the response
        for i=1:height(data)  %if there is data missing for a data, set the missing data value to the previous value
            tmp = data{i ,2};
            if(strcmp(data{i,2}, "."))
                data{i,2} = data{i-1,2};
            end
        end
        tenYearData = data;     
end

%calculates the monthly average log returns of the data
function [answerTable, logMonthlyRet] = logMean(answerTable, container, logMonthlyRet)
    for i = 1:numel(container)
        try
            logPrices = zeros(height(container{i}),1);  %place holder
            container{i} = addvars(container{i}, logPrices);  %add to containter table
            container{i}.logPrices = log(container{i}.Adj_Close);  %populate
            answerTable{i,2} = mean(container{i}.logPrices);  %take average, and assign to answer table
            tmpRet = tick2ret(container{i}.logPrices)';  %tmp holding data
            logMonthlyRet = [logMonthlyRet; tmpRet];  %concat
            continue;
        catch ME  %i corresponds to a ticker. On failure, display i. 
            i  
            continue
        end
    end
    logMonthlyRet = logMonthlyRet;  %'return' statement
end

%gets the tens minus twos data
function [tenMinusTwo] = getTenMinusTwo()
    url = ['https://fred.stlouisfed.org/graph/fredgraph.csv?' ...
        'bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&' ...
        'graph_bgcolor=%23ffffff&height=450&mode=fred&' ...
        'recession_bars=on&txtcolor=%23444444&ts=12&' ...
        'tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&' ...
        'show_axis_titles=yes&show_tooltip=yes&id=T10Y2Y&scale=left&' ...
        'cosd=2013-01-01&coed=2018-03-31&line_color=%234572a7&' ...
        'link_values=false&line_style=solid&mark_type=none&mw=3&lw=2' ...
        '&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=eop&' ...
        'fgst=lin&fgsnd=2009-06-01&line_index=1&transformation=lin&' ...
        'vintage_date=2020-01-25&revision_date=2020-01-25&nd=1976-06-01'];  %API URL with correct dates and frequency
    [response] = send(matlab.net.http.RequestMessage(), url);  %get response
        data = response.Body.Data;  %get data
        for i=1:height(data)  %if data has missing vlaues, assign missing value to the most recently available data
            tmp = data{i ,2};
            if(strcmp(data{i,2}, "."))
                data{i,2} = data{i-1,2};
            end
        end
        tenMinusTwo = data;
end

%gets the S&P500 dividend yield data
function [SP5dy] = getDivYield()
    socket = quandl('HxTGtomxL79TZzQg_Ey4');  %create socket
    data = history(socket, 'MULTPL/SP500_DIV_YIELD_MONTH');
    timedData = data((23:85), :);  %get data over correct timer period
    SP5dy = timedData;  %'return' statement
end

%gets the percent change in inventory data
function [DIP] = getDIP()
    url = ['https://fred.stlouisfed.org/graph/fredgraph.csv?' ...
        'bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&' ...
        'graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&' ...
        'txtcolor=%23444444&ts=12&tts=12&width=748&nt=0&thu=0&trc=0&' ...
        'show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=INDPRO&' ...
        'scale=left&cosd=2013-01-13&coed=2018-03-31&line_color=%234572a7&' ...
        'link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&' ...
        'oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=2009-06-01&' ...
        'line_index=1&transformation=pch&vintage_date=2020-01-23&revision_date=2020-01-23&nd=1919-01-01'];  %API URL with correct dates and frequency
    
    [response] = send(matlab.net.http.RequestMessage(), url);  %get response
        data = response.Body.Data;  %get data
        for i=1:height(data)  %adjust for missing data
            tmp = data{i ,2};
            if(strcmp(data{i,2}, "."))
                data{i,2} = data{i-1,2};
            end
        end
        DIP = data; %'return' statement
end

%estimate the betas
function [answerTable] = firstPass(container, answerTable, tenYearData, tenMinusTwo, SP5dy, DIP, logMonthlyRet)
    for i = 1:numel(container)  %loop through each asset
        y = logMonthlyRet(i, :);  %get monthly returns for asset i
        tmp = ones(size(container{i},1) - 1,1);  %tmp hold
        tmp1 = table2array(tenYearData(2:end, 2));  %translate
        if(numel(tmp) ~= numel(tmp1))  %ensure length
            answerTable{i, 'Ticker'} = NaN;  %if not same length, data is corrupted. Adjust answer table
            continue;
        end
        
        %X's to regress
        X = [tmp table2array(tenYearData(2:end, 2)), table2array(tenMinusTwo(2:end, 2)), table2array(SP5dy(2:end, 2)), table2array(DIP(2:end, 2))]; 
        [b, bint, r, rint, stats] = regress(y', X);  %regress
        %assign to answerTable
        answerTable{i, 'Beta1'} = b(1,1);
        answerTable{i, 'Beta2'} = b(2,1);
        answerTable{i, 'Beta3'} = b(3,1);
        answerTable{i, 'Beta4'} = b(4,1);
        answerTable{i, 'Beta5'} = b(5,1);
    end
end

function [answerLambda] = secondPass(answerLambda, answerTable, factors)
   y = answerTable.MeanRet;
   for i=1:4  %for each factor
        X = [answerTable{:, i+3}];  %X's to regress
        lambda = fitlm(y ,X);  %make a linear model
        answerLambda.Factor{i} = char(factors(i));  %insert factor name into table
        answerLambda.Lambda(i) = lambda.Coefficients.Estimate(2);  %insert lambda value into table
        answerLambda.tstat(i) = lambda.Coefficients.tStat(2);  %insert t-stat into table
   end
end

%finds betasusing fama-macBeth method. 
function [lambdaFama] = famaMcBeth(logMonthlyRet, factors, answerTable, lambdaFama)
    lambdas = []; %strucutre that will hold the lambdas to be averaged. 
    T =  size(logMonthlyRet, 2);
    for j =1:numel(factors)
        for i = 1:T  %for each month
            y = logMonthlyRet(:, i);  %y is the logReturns for all assets that month
            X = [ones(size(answerTable.Beta1,1), 1) table2array(answerTable(:, j + 2))];
            [lambda, bint, r, rint, stats] = regress(y, X);
            lambdas = [lambdas lambda(2,1)];
        end
        tStat = mean(lambdas) / ((1/sqrt(T))*std(lambdas));
        lambdaFama.tstat(j) = tStat;
        lambdaFama.Lambdas(j) = mean(lambdas);
        lambdaFama.Factor{j} = char(factors(j));
        graph = timeseries(lambdas);
        graph.Name = strcat('Lambdas of', ' ', char(factors(j)));
        graph.TimeInfo.Units = 'days';
        graph.TimeInfo.StartDate = '01-Jan-2013';
        graph.TimeInfo.Increment = 31;
        plot(graph)
        saveas(plot(graph), string(factors(j)));
        lambdas = [];
    end
end
