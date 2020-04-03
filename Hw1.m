%Purpose:
   %Econ 525-Spring2020
%Note:
   %This m-file is dependent upon xyz files.
%Author: Phillip Smith - Janurary, 2020
%UNC Honor Pledge: I certify that no unauthorized assistance has been received
%or given in the completion of this work
 
%imports
import matlab.net.http.*

%harcoded values/space allocation
url1 = 'https://www.quandl.com/api/v3/datasets/WIKI/';
url2 = '.csv?start_date=2013-01-13&end_date=2019-01-01&api_key=HxTGtomxL79TZzQg_Ey4';
apiKey = 'HxTGtomxL79TZzQg_Ey4';
data = '';

%constructing the table to hold the answers
try
    list = readtable('S&P500Constiuents.txt');
    finalTable = createTableQ1(getTickers(list)); %returns a cell array of ticker names
    [response, completed, history] = process(tickers, url1, url2); %get tickers generates a cell array of tickers, process processes those tickers
    
catch
    MException.last
end

%function creates the table the final answer will go in for q1
function [finalTable] = createTableQ1(tickers)
    try
        avgRet = cell(numel(tickers), 1);  %makes a cell
        beta1= cell(numel(tickers), 1);
        beta2 = cell(numel(tickers), 1);
        beta3= cell(numel(tickers), 1);
        beta4= cell(numel(tickers), 1);
        beta5 = cell(numel(tickers), 1);
        finalTable = table(tickers, avgRet, beta1, beta2, beta3, beta4, beta5);%table that will hold the results. Esseentially the final answer
    catch
        MException.last
    end
end

%function get the S&P500 constituent ticker names
function [tickers] = getTickers(list)
    try
        for i=1:numel(list)
            tickers = {list{i}};
        end
    catch ME
        ME.identifier
        ME.message
    end
end

%process the data for each ticker and write the results into the table
function[response, completed, history] = process(tickers,url1, url2, finalTable)
    try
        for i = 1:numel(tickers)
            url = strcat(url1, upper(tickers{i}), url2);
            [response, completed, history] = send(matlab.net.http.RequestMessage(), url);
            m = mean(response.Body.Data.Adj_Close');
            finalTable.avgRet(i:1) = m;
        end
    catch ME
        ME.identifier
        ME.message
    end
end

 
 
 
 
 
 