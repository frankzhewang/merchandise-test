% Matlab script
% compute expected profit under various policies for two-store problem
% without timing information

%% initialize
nInstance = 1200;
nStore = 2;
qMax = 30;

SL = (50:99)./100; % search set for target service level r
[~,nSL] = size(SL);

% paramters
% TODO: avoid hard-coding parameters

Alpha = zeros(nInstance,1);
Beta = zeros(nInstance,1);
Gm = zeros(nInstance,nStore);
C = zeros(nInstance,1);

ins = 0;
for alpha = [1,2,4,8]
    for meanLm = (1:6).*10
        for gm = 1:5
            for c = 1:10
                ins = ins + 1;
                Alpha(ins) = alpha;
                Beta(ins) = alpha/meanLm;
                Gm(ins,:) = [gm,1]./sum([gm,1]);
                C(ins) = c;
            end
        end
    end
end

% allocations
OptAlloc = zeros(nInstance,nStore);
LDFAlloc = zeros(nInstance,nStore,nSL);
HDFAlloc = zeros(nInstance,nStore,nSL);
LDFSearchAlloc = zeros(nInstance,nStore);
HDFSearchAlloc = zeros(nInstance,nStore);

% profits 
OptProfit = zeros(nInstance,1);
LDFProfit = zeros(nInstance,nSL); % Lowest-Demand-First / Service-Priority
HDFProfit = zeros(nInstance,nSL); % Highest-Demand-First / Volume-Priority
LDFSearchProfit = zeros(nInstance,1); % LDF/SP w/ search over r
HDFSearchProfit = zeros(nInstance,1); % HDF/VP w/ search over r
One1Profit = zeros(nInstance,1); % All-in-Store-1
One2Profit = zeros(nInstance,1); % All-in-Store-2
TwoProfit = zeros(nInstance,1); % Even-Split

%% enumerate all candidate allocations
% TODO: do this only once
nAlloc = nchoosek(qMax+nStore-1,nStore-1);
Ind2Alloc = zeros(nAlloc,nStore);
Alloc2Ind = zeros((qMax+1)^nStore,1);
iAlloc = 0;
for q1 = 0:qMax
    iAlloc = iAlloc + 1;
    Ind2Alloc(iAlloc,:) = [q1 qMax-q1];
    Alloc2Ind(bi2de([q1 qMax-q1],qMax+1,'left-msb')+1) = iAlloc;
end

%% sales observation index look-up table
% TODO: do this only once
SIndLookUp = zeros((qMax+1)^nStore,1);
iS = 0;
for s1 = 0:qMax
    for s2 = 0:qMax-s1
        iS = iS+1;
        SIndLookUp(bi2de([s1 s2],qMax+1,'left-msb')+1) = iS;
    end
end

%% compute expected profits under different policies
ins = 0;
for id = 1:120
    for c = 1:10
        S = load(['../out/no-timing/' sprintf('%03d',id) ...
            '/no-timing-abGm' sprintf('%03d',id) ...
            '-c' sprintf('%d',c) '.mat'],'MeanProfitNoTiming');
        
        MeanProfit = S.MeanProfitNoTiming;
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
            cum = nbinpdf(y ...
                ,Alpha(ins).*ones(1,nStore) ...
                ,(Beta(ins).*ones(1,nStore)) ...
                    ./(Gm(ins,:)+Beta(ins).*ones(1,nStore)));

            q = qMax;
            while q > 0 && any(cum<sl)
                n = find(cum<sl,1,'last');
                y(n) = y(n)+1;
                cum(n) = cum(n) + nbinpdf(y(n) ...
                    ,Alpha(ins),Beta(ins)/(Gm(ins,n)+Beta(ins)));
                q = q - 1;
            end
            y(1) = y(1) + q;
            LDFAlloc(ins,:,iSL) = y;
            LDFProfit(ins,iSL) = MeanProfit(...
                Alloc2Ind(bi2de(y,qMax+1,'left-msb')+1));
            
            % HDF/VP policy
            y = zeros(1,nStore);
            cum = nbinpdf(y ...
                ,Alpha(ins).*ones(1,nStore) ...
                ,(Beta(ins).*ones(1,nStore)) ...
                    ./(Gm(ins,:)+Beta(ins).*ones(1,nStore)));

            q = qMax;
            while q > 0 && any(cum<sl)
                n = find(cum<sl,1,'first');
                y(n) = y(n)+1;
                cum(n) = cum(n) + nbinpdf(y(n) ...
                    ,Alpha(ins),Beta(ins)/(Gm(ins,n)+Beta(ins)));
                q = q - 1;
            end
            y(end) = y(end) + q;
            HDFAlloc(ins,:,iSL) = y;
            HDFProfit(ins,iSL) = MeanProfit(...
                Alloc2Ind(bi2de(y,qMax+1,'left-msb')+1));
        end
        
        % TODO: avoid hard-coding parameters
        One1Profit(ins) = MeanProfit(Alloc2Ind(bi2de([30 0],qMax+1,'left-msb')+1));
        One2Profit(ins) = MeanProfit(Alloc2Ind(bi2de([0 30],qMax+1,'left-msb')+1));
        TwoProfit(ins) = MeanProfit(Alloc2Ind(bi2de([15 15],qMax+1,'left-msb')+1));
        
        disp(ins); % TODO: clean debug code
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
     ,'One1Profit','One2Profit' ...
     ,'TwoProfit');
