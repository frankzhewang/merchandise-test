function no_timing(id, c, demandPath)
% NO_TIMING Compute ex ante expected profit under all possible allocations
%           for a two-store merchandise testing problem.
%
% Usage: NO_TIMING(id, c, demandPath)
%   id:         string. demand data file id.
%   c:          scalar. unit procurement cost.
%   demandPath: string. path where demand data files lie.

%% parameter setting
% TODO: make these adjustable
p = 20; % unit selling price
qMax = 30; % inventory limit Q

%% load demand and paratmers
S = load([demandPath '/demand-abGm' id '.mat'] ...
    ,'a','b','Gm','D1','D2');
a = S.a; % shape parameter of gamma prior
b = S.b; % scale parameter of gamma prior
Gm = S.Gm; % relative demand coeff.
D1 = S.D1; % period 1 demand
D2 = S.D2; % period 2 demand
clear S

[nTrial,~] = size(D1);
nStore = length(Gm);

%% single-period profit function
profit = @(y,d) p.*min(y,d) - c.*y;

%% enumerate all candidate allocations
% TODO: do this only once for each (nStore, qMax)
nAlloc = nchoosek(qMax+nStore-1,nStore-1);
Allocs = zeros(nAlloc,nStore);
iAlloc = 0;
for q1 = 0:qMax
    iAlloc = iAlloc + 1;
    Allocs(iAlloc,:) = [q1 qMax-q1];
end
assert(nAlloc==iAlloc);

%% sales observation index look-up table
% TODO: do this only once for each (nStore, qMax)
SIndLookUp = zeros((qMax+1)^nStore,1);
iS = 0;
for s1 = 0:qMax
    for s2 = 0:qMax-s1
        iS = iS+1;
        SIndLookUp(bi2de([s1 s2],qMax+1,'left-msb')+1) = iS;
    end
end

%% without timing information
% load solution table
S = load(['../out/sol-tab-combine/' id '/sol-tab-abGm' id ...
    '-c' sprintf('%d',c) '.mat'],'TabSol');
TabSol = S.TabSol;
clear S

% compute profit for each demand trial under each allocation
ProfitNoTiming = zeros(nTrial, nAlloc);
for ia = 1:nAlloc
    S1 = min(D1, repmat(Allocs(ia,:),nTrial,1));
    E1 = (D1 >= repmat(Allocs(ia,:),nTrial,1));
    SInd = repmat(SIndLookUp(bi2de(S1,qMax+1,'left-msb')+1), 1, nStore);
    EInd = repmat(bi2de(E1,'left-msb') + 1, 1, nStore);
    Y = TabSol(sub2ind(size(TabSol),SInd,EInd,repmat(1:nStore,nTrial,1)));
    ProfitNoTiming(:,ia) = sum(profit(Y,D2), 2);
    fprintf('Computation completed for Allocation %d.\n',ia);
end

% compute expected profit for each allocation
MeanProfitNoTiming = mean(ProfitNoTiming);

mkdir(['../out/no-timing/' id]);
save(['../out/no-timing/' id '/no-timing-abGm' id ...
    '-c' sprintf('%d',c) '.mat'] ...
    ,'a','b','Gm','p','c','qMax' ...
    ,'MeanProfitNoTiming');
