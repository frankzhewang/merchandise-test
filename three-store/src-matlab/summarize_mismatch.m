% Matlab script
% Summarize profits when allocation policy does not align with availability 
% of timing information

%% parameters
nInstance = 1200;
nStore = 3;
qMax = 30;
nC = 10;

%% allocation index converting table
% TODO: do this only once
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

%% profit with timing info. under optimal no-timing allocation
S = load('../out/no-timing/no-timing-summary.mat','OptAlloc');
NoTimingOptAlloc = S.OptAlloc;
clear S

fprintf('Summarizing profits with timing info. under optimal no-timing allocation ...\n');
NoTimingOptProfit = zeros(nInstance, 1);
ins = 0;
for id = 1:120
    S = load(['../out/timing/timing-abGm' sprintf('%03d',id) '.mat']...
             ,'MeanProfitTiming');

    MeanProfit = S.MeanProfitTiming;
    clear S
    
    for ic = 1:nC
        ins = ins + 1;
        
        NoTimingOptProfit(ins) = MeanProfit(Alloc2Ind(bi2de(NoTimingOptAlloc(ins,:),qMax+1,'left-msb')+1),ic);
        fprintf('Instance %d completed.\n', ins);
    end
end


%% profit without timing info. under optimal timing allcation
S = load('../out/timing/timing-summary.mat','OptAlloc');
TimingOptAlloc = S.OptAlloc;
clear S

fprintf('Summarizing profits without timing info. under optimal timing allocation ...\n');
TimingOptProfit = zeros(nInstance, 1);
ins = 0;
for id = 1:120
    for c = 1:10
        S = load(['../out/no-timing/' sprintf('%03d',id) ...
            '/notiming-abGm' sprintf('%03d',id) ...
            '-c' sprintf('%d',c) '.mat'],'MeanProfitNoTiming');
        MeanProfit = S.MeanProfitNoTiming;
        clear S
        
        ins = ins + 1;
        
        TimingOptProfit(ins) = MeanProfit(Alloc2Ind(bi2de(TimingOptAlloc(ins,:),qMax+1,'left-msb')+1));
        fprintf('Instance %d completed.\n', ins);
    end
end

%% save output data
save('../out/mismatch-summary.mat', 'NoTimingOptProfit', 'TimingOptProfit');


