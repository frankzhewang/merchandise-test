% summarize two-store timing output data

%% initialize
nInstance = 1200;
nStore = 2;
qMax = 30; % inventory limit Q

C = 10:-1:1; % unit procurement cost c
[~,nC] = size(C);

% allocations
OptAlloc = zeros(nInstance,nStore);
MSAlloc = zeros(nInstance,nStore);

% profits
OptProfit = zeros(nInstance,1);
MSProfit = zeros(nInstance,1);
OneProfit = zeros(nInstance,1);
TwoProfit = zeros(nInstance,1);

%% enumerate all candidate allocations
nAlloc = nchoosek(qMax+nStore-1,nStore-1);
Ind2Alloc = zeros(nAlloc,nStore);
Alloc2Ind = zeros((qMax+1)^nStore,1);
iAlloc = 0;
for q1 = 0:qMax
    iAlloc = iAlloc + 1;
    Ind2Alloc(iAlloc,:) = [q1 qMax-q1];
    Alloc2Ind(bi2de([q1 qMax-q1],qMax+1,'left-msb')+1) = iAlloc;
end

%% summarize data
ins = 0;
for id = 1:120
    S = load(['../../two-store/out/timing/timing-abGm' sprintf('%03d',id) '.mat']...
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

        OneProfit(ins) = MeanProfit(Alloc2Ind(bi2de([30 0],qMax+1,'left-msb')+1),ic);
        TwoProfit(ins) = MeanProfit(Alloc2Ind(bi2de([15 15],qMax+1,'left-msb')+1),ic);
    end
    disp(ins);
end

save('timing-summary.mat'...
     ,'OptAlloc','MSAlloc' ...
     ,'OptProfit','MSProfit','OneProfit','TwoProfit');