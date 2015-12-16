% Matlab script
% Summarize expected profit under various policies for three-store problem
% with timing information

%% initialize
nInstance = 1200;
nStore = 3;
qMax = 30; % inventory limit Q

C = 10:-1:1; % unit procurement cost c
[~,nC] = size(C);

% allocations
OptAlloc = zeros(nInstance,nStore);
MSAlloc = zeros(nInstance,nStore);

% profits
OptProfit = zeros(nInstance,1);
MSProfit = zeros(nInstance,1);
One1Profit = zeros(nInstance,1);
One2Profit = zeros(nInstance,1);
One3Profit = zeros(nInstance,1);
Two12Profit = zeros(nInstance,1);
Two23Profit = zeros(nInstance,1);
Two13Profit = zeros(nInstance,1);
ThreeProfit = zeros(nInstance,1);

%% enumerate all candidate allocations
nAlloc = nchoosek(qMax+nStore-1,nStore-1);
Ind2Alloc = zeros(nAlloc,nStore);
Alloc2Ind = zeros((qMax+1)^nStore,1);
iAlloc = 0;
for q1 = 0:qMax
    for q2 = 0:qMax-q1
        iAlloc = iAlloc + 1;
        Ind2Alloc(iAlloc,:) = [q1 q2 qMax-q1-q2];
        Alloc2Ind(bi2de([q1 q2 qMax-q1-q2],qMax+1,'left-msb')+1) = iAlloc;
    end
end

%% summarize data
ins = 0;
for id = 1:120
    S = load(['../out/timing/timing-abGm' sprintf('%03d',id) '.mat']...
        ,'a','b','Gm','MeanProfitTiming');

    MeanProfit = S.MeanProfitTiming;
    a = S.a;
    b = S.b;
    Gm = S.Gm;
    clear S
    
    for ic = 1:nC
        ins = ins + 1;

        [OptProfit(ins),iOptAlloc] = max(MeanProfit(:,ic));
        OptAlloc(ins,:) = Ind2Alloc(iOptAlloc,:);

        if Gm(1)==1/nStore
            OptAlloc(ins,:) = sort(OptAlloc(ins,:),2,'descend');
        end
        
        % MS allocation
        y = zeros(1,nStore);
        for q = 1:qMax
            [~,n] = min(nbincdf(y,a,b./(Gm+b)));
            y(n) = y(n) + 1;
        end
        MSAlloc(ins,:) = y;
        MSProfit(ins) = MeanProfit(Alloc2Ind(bi2de(y,qMax+1,'left-msb')+1),ic);

        One1Profit(ins) = MeanProfit(Alloc2Ind(bi2de([30 0 0],qMax+1,'left-msb')+1),ic);
        One2Profit(ins) = MeanProfit(Alloc2Ind(bi2de([0 30 0],qMax+1,'left-msb')+1),ic);
        One3Profit(ins) = MeanProfit(Alloc2Ind(bi2de([0 0 30],qMax+1,'left-msb')+1),ic);
        Two12Profit(ins) = MeanProfit(Alloc2Ind(bi2de([15 15 0],qMax+1,'left-msb')+1),ic);
        Two23Profit(ins) = MeanProfit(Alloc2Ind(bi2de([0 15 15],qMax+1,'left-msb')+1),ic);
        Two13Profit(ins) = MeanProfit(Alloc2Ind(bi2de([15 0 15],qMax+1,'left-msb')+1),ic);
        ThreeProfit(ins) = MeanProfit(Alloc2Ind(bi2de([10 10 10],qMax+1,'left-msb')+1),ic);
    end
    prinft('Instance %d completed.\n', ins);
end

save('../out/timing/timing-summary.mat'...
     ,'OptAlloc','MSAlloc' ...
     ,'OptProfit','MSProfit' ...
     ,'One1Profit','One2Profit','One3Profit'...
     ,'Two12Profit','Two23Profit','Two13Profit'...
     ,'ThreeProfit');