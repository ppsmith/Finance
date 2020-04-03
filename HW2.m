priceData = readtable("EC525_HW2_SimData.xlsx", "Sheet", 'Prices');
numSharesData = readtable("EC525_HW2_SimData.xlsx", "Sheet", 'NumShares');
bookValueData = readtable("EC525_HW2_SimData.xlsx", "Sheet" ,'bookvaluepershare');

%clean prices (remove any values less than 1). Replace with the previous
%years price. 
for r = 2:height(priceData)
    for c = 1:width(priceData)
        if priceData{r , c} < 1
            priceData(r, c) = priceData(r-1, c);
        end
    end
end

%calculate market equity. Prices time the number of shares
marketEquity = table2array(priceData(:, 2:end)) .* table2array(numSharesData(:, 2:end));

%calculate the BE/ME ratio. Data give bookequity oer share data, so share
%number needs to be added back in 
beme = ((table2array(bookValueData(:, 2:end))) .* table2array(numSharesData(:, 2:end))) ./ marketEquity(:,:);

%create arrays nthat will hold bools indicating asset characterisitcs
small = zeros(height(priceData) - 1, width(priceData) - 1);
big = zeros(height(priceData) - 1, width(priceData) - 1);
value = zeros(height(priceData) - 1, width(priceData) - 1);
neutral = zeros(height(priceData) - 1, width(priceData) - 1);
growth = zeros(height(priceData) - 1, width(priceData) - 1);

%find returns for each asset
returns = tick2ret(priceData(:, 2:end));

%size is marekt equity
size = marketEquity;

%for each row(year), set cutoff points. 
for r = 1:height(priceData) - 1
    smallCutoff = prctile(size(r, :), 50);  %bottom half of size
    bemeLow = prctile(beme(r, :), 33);  %bottom third of BE/ME
    bemeNeutral = prctile(beme(r, :), 67); %bottom 2/3rds of BE/ME
    
    %make logical matrix
    for c = 1:width(priceData) -1
       if size(r, c) <= smallCutoff
           small(r, c) = 1;
       else
           big(r, c) = 1;
       end
       
       if beme(r,c) <= bemeLow
           growth(r, c) = 1;
       elseif beme(r,c) <= bemeNeutral
           neutral(r, c) = 1;
       else 
          value(r, c) = 1;
       end
    end
end
    
array2table(small);
array2table(big);
array2table(value);
array2table(neutral);
array2table(growth);

%combined tables are logical
%logical and
smallValue = small & value;
smallNeutral = small & neutral;
smallGrowth = small & growth;

%logical and
bigValue = big & value;
bigNeutral = big & neutral;
bigGrowth = big & growth;

%Matricese that will hold the returns for each of the 6 ports.
smallValueRetns = [];
smallNeutralRetns = [];
smallGrowthRetns = [];
bigValueRetns = [];
bigNeutralRetns = [];
bigGrowthRetns = [];
    
for r = 1:21
    for c=1:467
        if smallValue(r,c) %if the asset at c, year r is smallValue...
           smallValueRetns(r, c) = returns{r,c};  %add the returns for the asset to returns
           continue
        end
        
        if smallNeutral(r,c)
            smallNeutralRetns(r, c) = returns{r,c};
            continue
        end
        
        if smallGrowth(r,c)
           smallGrowthRetns(r, c) = returns{r,c};
           continue
        end
        
        if bigValue(r,c)
            bigValueRetns(r , c) = returns{r,c};
            continue
        end
        
        if bigNeutral(r,c)
            bigNeutralRetns(r , c) = returns{r,c};
            continue
        end
        
        if bigGrowth(r,c)
            bigGrowthRetns(r , c) = returns{r,c};
            continue
        end
    end
end

%average each of the rows. The average for each row is the return for the equally weighted portfolio for
%that year
smallValueRetns = mean(smallValueRetns, 2);
smallNeutralRetns = mean(smallNeutralRetns, 2);
smallGrowthRetns = mean(smallGrowthRetns, 2);

bigValueRetns = mean(bigValueRetns, 2);
bigNeutralRetns = mean(bigNeutralRetns, 2);
bigGrowthRetns = mean(bigGrowthRetns, 2);

%small stuff
figure(1);
hold on
svr = timeseries(smallValueRetns, priceData.Year(2:end));  %plot the avg. value returns against the years
svr.TimeInfo.Units = 'Years';
svr.Name = 'Small Value Returns (Percent)';
plot(svr)
snr = timeseries(smallNeutralRetns, priceData.Year(2:end));  %plot the avg. neural returns against the years
plot(snr)
sgr = timeseries(smallGrowthRetns, priceData.Year(2:end));  %plot the avg. growth returns against the years
plot(sgr)
title('Small Value, Neutral, and Growth Portfolio Returns');
xlabel('Years');
xlim([1999 2019])
ylabel('Returns (Percent)')
legend('Small Value', 'Small Neutral', 'Small Growth', 'location', 'northwest');
hold off

%descriptive stats for small
descriptiveStatsSmall = table('Size', [6, 3], 'VariableTypes',{ 'double', 'double', 'double'});
descriptiveStatsSmall.Properties.VariableNames = {'SmallValue', 'SmallNeutral', 'SmallGrowth'};
descriptiveStatsSmall.Properties.RowNames = {'Mean', 'Min', 'Max', 'Variance','Kurtosis', 'Skew'};

descriptiveStatsSmall.SmallValue(1) = mean(smallValueRetns);
descriptiveStatsSmall.SmallValue(2) = min(smallValueRetns);
descriptiveStatsSmall.SmallValue(3) =  max(smallValueRetns);
descriptiveStatsSmall.SmallValue(4) =  var(smallValueRetns);
descriptiveStatsSmall.SmallValue(5) = kurtosis(smallValueRetns);
descriptiveStatsSmall.SmallValue(6) = skewness(smallValueRetns);

descriptiveStatsSmall.SmallNeutral(1) = mean(smallNeutralRetns);
descriptiveStatsSmall.SmallNeutral(2) = min(smallNeutralRetns);
descriptiveStatsSmall.SmallNeutral(3) =  max(smallNeutralRetns);
descriptiveStatsSmall.SmallNeutral(4) =  var(smallNeutralRetns);
descriptiveStatsSmall.SmallNeutral(5) = kurtosis(smallNeutralRetns);
descriptiveStatsSmall.SmallNeutral(6) = skewness(smallNeutralRetns);

descriptiveStatsSmall.SmallGrowth(1) = mean(smallGrowthRetns);
descriptiveStatsSmall.SmallGrowth(2) = min(smallGrowthRetns);
descriptiveStatsSmall.SmallGrowth(3) =  max(smallGrowthRetns);
descriptiveStatsSmall.SmallGrowth(4) =  var(smallGrowthRetns);
descriptiveStatsSmall.SmallGrowth(5) = kurtosis(smallGrowthRetns);
descriptiveStatsSmall.SmallGrowth(6) = skewness(smallGrowthRetns);

%big stuff 
figure(2);
bvr = timeseries(bigValueRetns, priceData.Year(2:end));  %plot avg. value returns against years
bvr.TimeInfo.Units = 'Years';
bvr.Name = 'Big Value Returns (Decimal)';
plot(bvr)
hold on
bnr = timeseries(bigNeutralRetns, priceData.Year(2:end));  %plot avg. neutral returns agianst years
plot(bnr)
bgr = timeseries(bigGrowthRetns, priceData.Year(2:end));  %plot avg. growth returns against years
plot(bgr)
title('Big Value, Neutral, and Growth Portfolio Returns');
xlabel('Years');
xlim([1999 2019])
ylabel('Returns (Percent)')
legend('Big Value', 'Big Neutral', 'big Growth', 'location', 'northwest');
hold off

descriptiveStatsBig = table('Size', [6, 3], 'VariableTypes',{ 'double', 'double', 'double'});
descriptiveStatsBig.Properties.VariableNames = {'BigValue', 'BigNeutral', 'BigGrowth'};
descriptiveStatsBig.Properties.RowNames = {'Mean', 'Min', 'Max', 'Variance','Kurtosis', 'Skew'};

descriptiveStatsBigs.BigValue(1) = mean(bigValueRetns);
descriptiveStatsBig.BigValue(2) = min(bigValueRetns);
descriptiveStatsBig.BigValue(3) =  max(bigValueRetns);
descriptiveStatsBig.BigValue(4) =  var(bigValueRetns);
descriptiveStatsBigs.BigValue(5) = kurtosis(bigValueRetns);
descriptiveStatsBig.BigValue(6) = skewness(bigValueRetns);

descriptiveStatsBig.BigNeutral(1) = mean(bigNeutralRetns);
descriptiveStatsBig.BigNeutral(2) = min(bigNeutralRetns);
descriptiveStatsBig.BigNeutral(3) =  max(bigNeutralRetns);
descriptiveStatsBig.BigNeutral(4) =  var(bigNeutralRetns);
descriptiveStatsBig.BigNeutral(5) = kurtosis(bigNeutralRetns);
descriptiveStatsBig.BigNeutral(6) = skewness(bigNeutralRetns);

descriptiveStatsBig.BigGrowth(1) = mean(bigGrowthRetns);
descriptiveStatsBig.BigGrowth(2) = min(bigGrowthRetns);
descriptiveStatsBig.BigGrowth(3) =  max(bigGrowthRetns);
descriptiveStatsBig.BigGrowth(4) =  var(bigGrowthRetns);
descriptiveStatsBig.BigGrowth(5) = kurtosis(bigGrowthRetns);
descriptiveStatsBig.BigGrowth(6) = skewness(bigGrowthRetns);

SMB = (.33*(smallGrowthRetns  +  smallValueRetns +  smallNeutralRetns)) - (.33*(bigGrowthRetns + bigNeutralRetns + bigValueRetns));
HML = (.5*(smallValueRetns + bigValueRetns)) - (.5*(smallGrowthRetns + bigGrowthRetns));

stats = table('Size', [6, 2], 'VariableTypes',{ 'double', 'double'});
stats.Properties.VariableNames = {'SMB', 'HML'};
stats.Properties.RowNames = {'Mean', 'Min', 'Max', 'Variance','Kurtosis', 'Skew'};

stats.SMB(1) = mean(SMB);
stats.SMB(2) = min(SMB);
stats.SMB(3) = max(SMB);
stats.SMB(4) = var(SMB);
stats.SMB(5) = kurtosis(SMB);
stats.SMB(6) = skewness(SMB);

stats.HML(1) = mean(HML);
stats.HML(2) = min(HML);
stats.HML(3) = max(HML);
stats.HML(4) = var(HML);
stats.HML(5) = kurtosis(HML);
stats.HML(6) = skewness(HML);

figure(3);
factorTime = timeseries(HML, priceData.Year(2:end));
plot(factorTime);
hold on
smbTime =  timeseries(SMB, priceData.Year(2:end));
plot(smbTime);
legend('HML', 'SMB','location', 'northwest');
factorTime.TimeInfo.Units = 'Years';
title('SMB and HML from 1999 to 2019');
xlabel('Years');
ylabel('Factor Average Yearly Simple Returns (Decimal)');
xlim([1999 2019]);

%writetable(stats, 'HMLstats.csv', "WriteVariableNames", true, "WriteRowNames", true);
%writetable(descriptiveStatsBig, 'bigSizeStats.csv', "WriteVariableNames",true, "WriteRowNames", true);
%writetable(descriptiveStatsSmall, 'smallStats.csv', "WriteVariableNames", true, "WriteRowNames", true);






















