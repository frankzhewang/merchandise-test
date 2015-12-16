% Figure 6b
% Optimality gaps under heuristic test inventory allocation policies (N=3)
% Timing information unobservable

load('../../three-store/out/no-timing/no-timing-summary.mat');
load('../../three-store/out/mismatch-summary.mat', 'TimingOptProfit');

Profits = [LDFSearchProfit TimingOptProfit HDFSearchProfit ...
           One1Profit One2Profit One3Profit ...
           Two12Profit Two23Profit Two13Profit ...
           ThreeProfit];

[~,nPolicy] = size(Profits);

PercentGaps = (repmat(OptProfit,1,nPolicy) - Profits) ...
    ./repmat(OptProfit,1,nPolicy)*100;

figure;
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 14)
boxplot(PercentGaps,'labels'...
    ,{'SP-S','T*','VP-S','H','M','L','HM','ML','HL','HML'},'whisker',0);
h = findobj(gca,'tag','Outliers');
set(h,'Marker','o');
xlabel('Test Inventory Allocation Policy');
ylabel('% Optimality Gap in Ex-ante Expected Total Profit')