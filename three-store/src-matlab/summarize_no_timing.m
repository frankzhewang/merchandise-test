% Matlab script
% Summarize expected profit under various policies for three-store problem
% without timing information

%% initialize
nInstance = 1200;
nStore = 3;
qMax = 30;

SL = (50:99)./100; % search set for target service level r
[~,nSL] = size(SL);

% allocations
OptAlloc = zeros(nInstance,nStore);
LDFAlloc = zeros(nInstance,nStore,nSL);
HDFAlloc = zeros(nInstance,nStore,nSL);
LDFSearchAlloc = zeros(nInstance,nStore);
HDFSearchAlloc = zeros(nInstance,nStore);

% profits 
OptProfit = zeros(nInstance,1); % Optimal 
LDFProfit = zeros(nInstance,nSL); % Lowest-Demand-First / Service-Priority
HDFProfit = zeros(nInstance,nSL); % Highest-Demand-First / Volume-Priority
LDFSearchProfit = zeros(nInstance,1); % LDF/SP w/ search over r
HDFSearchProfit = zeros(nInstance,1); % HDF/VP w/ search over r
One1Profit = zeros(nInstance,1); % H / All-in-Store-1
One2Profit = zeros(nInstance,1); % M / All-in-Store-2
One3Profit = zeros(nInstance,1); % L / All-in-Store-3
Two12Profit = zeros(nInstance,1); % HM
Two23Profit = zeros(nInstance,1); % ML
Two13Profit = zeros(nInstance,1); % HL
ThreeProfit = zeros(nInstance,1); % HML

%% enumerate all candidate allocations
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

%% sales observation index look-up table
% TODO: do this only once
SIndLookUp = zeros((qMax+1)^nStore,1);
iS = 0;
for s1 = 0:qMax
    for s2 = 0:qMax-s1
        for s3 = 0:qMax-s1-s2
            iS = iS+1;
            sCode = bi2de([s1 s2 s3],qMax+1,'left-msb')+1;
            SIndLookUp(sCode) = iS;
        end
    end
end

%% compute expected profits under different policies
ins = 0;
for id = 1:120
    for c = 1:10
        S = load(['../out/no-timing/' sprintf('%03d',id) ...
                  '/no-timing-abGm' sprintf('%03d',id) ...
                  '-c' sprintf('%d',c) '.mat']...
                 ,'a','b','Gm','MeanProfitNoTiming');
        
        MeanProfit = S.MeanProfitNoTiming;
        a = S.a;
        b = S.b;
        Gm = S.Gm;
        clear S
        
        ins = ins + 1;
        
        [OptProfit(ins),iOptAlloc] = max(MeanProfit);
        OptAlloc(ins,:) = Ind2Alloc(iOptAlloc,:);
        
        % use ascending allocation for identical-store cases
        if Gm(ins,1)==1/nStore % TODO: avoid use of == for float comparison
            OptAlloc(ins,:) = sort(OptAlloc(ins,:));
        end
        
        for iSL = 1:nSL
            sl = SL(iSL); % service level target
            
            % LDF/SP policy
            y = zeros(1,nStore);
            cum = nbinpdf(y,a,b./(Gm+b));

            q = qMax;
            while q > 0 && any(cum<sl)
                n = find(cum<sl,1,'last');
                y(n) = y(n)+1;
                cum(n) = cum(n) + nbinpdf(y(n),a,b/(Gm(n)+b));
                q = q - 1;
            end
            y(1) = y(1) + q;
            LDFAlloc(ins,:,iSL) = y;
            LDFProfit(ins,iSL) = MeanProfit(...
                Alloc2Ind(bi2de(y,qMax+1,'left-msb')+1));
            
            % HDF/VP policy
            y = zeros(1,nStore);
            cum = nbinpdf(y,a,b./(Gm+b));

            q = qMax;
            while q > 0 && any(cum<sl)
                n = find(cum<sl,1,'first');
                y(n) = y(n)+1;
                cum(n) = cum(n) + nbinpdf(y(n),a,b/(Gm(n)+b));
                q = q - 1;
            end
            y(end) = y(end) + q;
            HDFAlloc(ins,:,iSL) = y;
            HDFProfit(ins,iSL) = MeanProfit(...
                Alloc2Ind(bi2de(y,qMax+1,'left-msb')+1));
        end
        
        % TODO: avoid hard-coding parameters
        One1Profit(ins) = MeanProfit(Alloc2Ind(bi2de([30 0 0],qMax+1,'left-msb')+1));
        One2Profit(ins) = MeanProfit(Alloc2Ind(bi2de([0 30 0],qMax+1,'left-msb')+1));
        One3Profit(ins) = MeanProfit(Alloc2Ind(bi2de([0 0 30],qMax+1,'left-msb')+1));
        Two12Profit(ins) = MeanProfit(Alloc2Ind(bi2de([15 15 0],qMax+1,'left-msb')+1));
        Two23Profit(ins) = MeanProfit(Alloc2Ind(bi2de([0 15 15],qMax+1,'left-msb')+1));
        Two13Profit(ins) = MeanProfit(Alloc2Ind(bi2de([15 0 15],qMax+1,'left-msb')+1));
        ThreeProfit(ins) = MeanProfit(Alloc2Ind(bi2de([10 10 10],qMax+1,'left-msb')+1));
        
        fprintf('Instance %d completed.\n', ins); % TODO: clean debug code
    end
end

%%

% LDF-S / SP-S policy
[LDFSearchProfit,Ind] = max(LDFProfit,[],2);
LDFSearchAlloc = LDFAlloc(sub2ind( size(LDFAlloc)...
                                   ,repmat((1:nInstance)',1,nStore)...
                                   ,repmat(1:nStore,nInstance,1)...
                                   ,repmat(Ind,1,nStore) ));

% HDF-S / VP-S policy
[HDFSearchProfit,Ind] = max(HDFProfit,[],2);
HDFSearchAlloc = HDFAlloc(sub2ind( size(HDFAlloc)...
                                   ,repmat((1:nInstance)',1,nStore)...
                                   ,repmat(1:nStore,nInstance,1)...
                                   ,repmat(Ind,1,nStore) ));

save('../out/no-timing/no-timing-summary.mat' ...
     ,'OptAlloc','LDFAlloc','HDFAlloc','LDFSearchAlloc','HDFSearchAlloc' ...
     ,'OptProfit','LDFProfit','HDFProfit','LDFSearchProfit','HDFSearchProfit' ...
     ,'One1Profit','One2Profit','One3Profit' ...
     ,'Two12Profit','Two23Profit','Two13Profit' ...
     ,'ThreeProfit');
