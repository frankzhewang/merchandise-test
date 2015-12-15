% Matlab script
% Generate data for Figure 1.

%% parameter setting
a = 2; % scale parameter of gamma prior 
b = .4; % shape parameter of gamma prior
n = 1e6; % number of replications
T = 1; % length in time of each period
p = 10; % unit selling price;
c = 1; % unit procurement cost;
k1 = 1; % arrival rate multiplier of store 1
k2 = 1; % arrival rate multiplier of store 2
dMax = 15; % max. demand

%% generate random demand profile
rs = rng('shuffle'); % random number stream

Lm = gamrnd(a,1/b,n,1); % random arrival rates, n by 1 vector

Tau = NaN(n,dMax,2);
Tau(:,:,1) = exprnd(repmat(1./(k1.*Lm),1,dMax)); % random interarrival times for store 1, period 1, n by dMax matrix
Tau(:,:,2) = exprnd(repmat(1./(k2.*Lm),1,dMax)); % random interarrival times for store 2, period 1, n by dMax matrix

D2 = poissrnd([k1.*Lm k2.*Lm]);

if ~exist('out','dir')
    mkdir('out');
end

save('out/demand.mat','n','a','b','T','k1','k2' ...
    ,'Lm','Tau','D2','rs');

%% compute ex-ante expected profit
[PT_Q5, PNT_Q5] = profit(5,10,1,'out/demand');
[PT_Q10, PNT_Q10] = profit(10,10,1,'out/demand');
[PT_Q15, PNT_Q15] = profit(15,10,1,'out/demand');

%% save data
save('out/profit.mat', ...
     'PT_Q5', 'PT_Q10', 'PT_Q15', ...
     'PNT_Q5', 'PNT_Q10', 'PNT_Q15');


