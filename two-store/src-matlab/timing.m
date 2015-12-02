function timing(id, a, meanLm, gm, demandPath)

%% parameter setting
b = a/meanLm; % shape parameter of gamma prior
T = 1; % length in time of each period
p = 20; % unit selling price;
C = 10:-1:1; % unit purchasing cost;
Gm = [gm 1]./sum([gm 1]); % relative demand coefficients
nStore = length(Gm);
qMax = 30;

%% load demand
S = load([demandPath '/demand-abGm' id '.mat'] ...
    ,'CumTau','D1','D2');
CumTau = S.CumTau;
D1 = S.D1;
D2 = S.D2;
clear S

[nTrial,~] = size(D1); 

%% enumerate all candidate allocations
nAlloc = nchoosek(qMax+nStore-1,nStore-1);
Allocs = zeros(nAlloc,nStore);
iAlloc = 0;
for q1 = 0:qMax
    iAlloc = iAlloc + 1;
    Allocs(iAlloc,:) = [q1 qMax-q1];
end
assert(nAlloc==iAlloc);

%% single-period profit function
profit = @(y,d,c_) p.*min(y,d) - c_.*y;

%% with timing information
[~,nC] = size(C);
MeanProfitTiming = zeros(nAlloc,nC);
CumTau = [zeros(nTrial*nStore,1) CumTau];
for iAlloc = 1:nAlloc
    fprintf('Allocation %d starts ...\n',iAlloc); tic;
    S1 = min(D1, repmat(Allocs(iAlloc,:),nTrial,1));
    T1 = reshape( min(...
        CumTau(sub2ind(size(CumTau) ... 
        ,(1:nTrial*nStore)' ...
        ,kron(Allocs(iAlloc,:)',ones(nTrial,1)) + 1)) ...
        ,T), nTrial, nStore);
        
    A = repmat(a + sum(S1, 2), 1, nStore);
    B = repmat(b + sum(repmat(Gm,nTrial,1) .* T1, 2), 1, nStore);
    
    % Y = zeros(nTrial, nStore, nC);
    P = B./(repmat(Gm,nTrial,1)+B);
    y = zeros(nTrial, nStore);
    cumdist = nbinpdf(0,A,P);
    for iC = 1:nC
        nvRatio = (p-C(iC))/p;
        k = find(cumdist < nvRatio);
        while ~isempty(k)
            y(k) = y(k) + 1;
            
            % slicing to avoid memory leak
            sliceSize = 1e4;
            nSlice = floor(length(k)/sliceSize);
            for is = 1:nSlice
                slice = 1+(is-1)*sliceSize : is*sliceSize;
                cumdist(k(slice)) = cumdist(k(slice)) ...
                    + nbinpdf( y(k(slice)),A(k(slice)),P(k(slice)) );
            end
            if nSlice*sliceSize < length(k)
                slice = nSlice*sliceSize+1 : length(k);
                cumdist(k(slice)) = cumdist(k(slice)) ...
                    + nbinpdf( y(k(slice)),A(k(slice)),P(k(slice)) );                
            end
            k = k(cumdist(k) < nvRatio);
        end
        MeanProfitTiming(iAlloc,iC) = mean(sum(profit(y,D2,C(iC)), 2));
    end
    fprintf('Done. Lasted %f secs.\n', toc);
end

mkdir('../out/timing');
save(['../out/timing/timing-abGm' id '.mat'] ...
    ,'a','b','T','Gm'...
    ,'MeanProfitTiming');
