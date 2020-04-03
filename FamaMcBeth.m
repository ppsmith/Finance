%Purpose: 
%   Estimate a Fama MacBeth factor pricing model.  Uses Dow 30 (DuPont omitted due to name change), and Non Farm Payoll growth as the factor of interest. 
%   Using the NFP as a factor is computational simple, but notice that we
%   really should be looking at the unexpected portion of the NFP release.
%Author:
%   Mike Aguilar, UNC Economics, 17Jan2018

%Housekeeping
    clear all; close all; clc; 

%% Import the data
    load NFPDow_Data
        
% Clean up the data
    Ret = data(:,2:30); %Name the returns
    NFP = data(:,31);  %Name the NFP
    Dates = data(:,1)+datenum('30-Dec-1899'); %Trick to push dates to the right "pivot" year
    
%% First Pass: Estimate the betas
beta = zeros(size(Ret,2),1); 
for i = 1:size(Ret,2) %loop over each asset
    y = Ret(:,i); %Set the "y"
    X = [ones(size(NFP,1),1) NFP]; %set the "X"
    [b,bint,r,rint,stats] = regress(y,X); %Conduct regression. Add ones vector for intercept. 
    %[B,TSTAT,S2,VCV,VCV_WHITE,R2,RBAR,YHAT] = ols(y,X,1); %conduct the regression
    beta(i,1) = b(2,1); %grab the betas and stack
end

%% Second Pass: Regress avg returns on estimated betas (assume no risk free)
    T = size(Ret,1); %# of months
    for t = 1:T %Loop over each month
    y = Ret(t,:); %Set the y 
    X = [ones(size(beta,1),1) beta]; % Set the X; add ones for intercept
    [lambda,bint,r,rint,stats] = regress(y',X); %Regress returns on estiamted betas
    %[Lambda,TSTAT,S2,VCV,VCV_WHITE,R2,RBAR,YHAT] = ols(y,X,1); % conduct the regression
    %Grab the Lambda
        Lambda1(t,:) = lambda(2,1); 
    end
    %Summarize by avg the lambdas over time
    AvgL = mean(Lambda1); 
    %Create a t-statistic for this avg lambda
    tstat = AvgL / ((1/sqrt(T))*std(Lambda1)); 
    
    %Clean up for readability
    out = [AvgL;tstat]; %Group for the table
    Results_table = array2table(out,'VariableNames',{'Lambda1'},'RowNames',{'Estimate';'TStat'}) %create a table
    %Interpret the coefficient of interest: The small t-stat suggests the
    %NFP factor used here is NOT priced in the cross section. 