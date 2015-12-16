% Figure 6a
% Optimality gaps under heuristic test inventory allocation policies (N=3)
% Timing information observable

load('../../three-store/out/timing/timing-summary.mat');
load('../../three-store/out/mismatch-summary.mat', 'NoTimingOptProfit');

Profits = [MSProfit NoTimingOptProfit One1Profit One2Profit One3Profit ...
    Two12Profit Two23Profit Two13Profit ThreeProfit];
[~,nPolicy] = size(Profits);

PercentGaps = (repmat(OptProfit,1,nPolicy) - Profits) ...
    ./repmat(OptProfit,1,nPolicy)*100;

set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 14)
h = boxplot(PercentGaps,'labels'...
    ,{'MS','NT*','H','M','L','HM','ML','HL','HML'},'whisker',0);
hout = findobj(gca,'tag','Outliers');
set(hout,'Marker','o');
xlabel('Test Inventory Allocation Policy');
ylabel('% Optimality Gap in Ex-ante Expected Total Profit')