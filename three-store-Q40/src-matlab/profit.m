function profit(demandPath, id, qMax, p, c)
% PROFIT Computes the ex-ante expected profit of a representative
%   store as a function of Q for a 3-identical-store problem
% Demand model is gamma-Poisson
%
% Usage: PROFIT(demandFile, qMax, blkSize)
%   demandPath: string. demand file path.
%   id: string. demand file identifier.
%   qMax: scalar. test inventory limit.

%% load demand data

S = load([demandPath '/demand-' id '.mat'],'a','b','T','Gm','Tau','D2');

a = S.a; % scale parameter of gamma prior 
b = S.b; % shape parameter of gamma prior
T = S.T; % length in time of each period
% p = 10; % unit selling price;
% c = 1; % unit holding cost;
nStore = length(S.Gm); % number of stores;

D2 = S.D2;
[nTrial,~] = size(S.D2); % number of replications
Tau = S.Tau(:,1:qMax,:);

clear S

%% load solution table
S = load('../sol-tab/sol-tab-a2-b04-T1-nvr09-Q40.mat','Sol');
Sol = S.Sol;
clear S

%% enumerate all test allocations that use up all available test inventory
nAlloc = qMax^2/2+3*qMax/2+1; % total number of test allocations
Q = zeros(nStore,nAlloc); % Q(i,j) = test inventory level at store i under allocation j
iAlloc = 0;
for q1 = 0:qMax
    for q2 = 0:qMax-q1
        iAlloc = iAlloc+1;
        Q(1,iAlloc) = q1;
        Q(2,iAlloc) = q2;
        Q(3,iAlloc) = qMax-q1-q2;
    end
end
assert(nAlloc==iAlloc); 

%% slice n trials into blocks for execution
blkSize = 1e3;
nBlk = round(nTrial/blkSize);

Yt = zeros(nTrial,nAlloc);
Ynt = zeros(nTrial,nAlloc);
for blk = 1 : nBlk
    
    slice = blkSize*(blk-1)+1 : blkSize*blk;

    Tau_ = Tau(slice,1:qMax,:);

    S = zeros(blkSize,nAlloc,nStore);
    Tm = zeros(blkSize,nAlloc,nStore);
    E = zeros(blkSize,nAlloc,nStore);
    for i = 1:nStore
        CumTau = cumsum(Tau_(:,:,i),2); 

        % random demand for store i, n by 1 vector
        D = sum(CumTau <= T,2); 

        % sales of store i, nTrial by nAlloc matrix
        S(:,:,i) = min(repmat(D,1,nAlloc),repmat(Q(i,:),blkSize,1)); 

        % arrival time epochs for store i with 0 epochs, nTrial by qMax+1 matrix
        CumTau0 = [zeros(blkSize,1) CumTau];
        clear CumTau

        % effective selling period of store i, nTrial by nAlloc matrix
        Tm(:,:,i) = min(CumTau0(sub2ind(size(CumTau0),...
            repmat((1:blkSize)',1,nAlloc),repmat(Q(i,:)+1,blkSize,1))), T);
        clear CumTau0

        % whether store i stocks out, n by nPlan binary matrix
        E(:,:,i) = double(repmat(D,1,nAlloc) >= repmat(Q(i,:),blkSize,1));

        clear D
    end

    clear Tau_

    %% with timing information
    At = a + sum(S,3);
    Bt = b + sum(Tm,3);
    clear Tm

    Yt(slice,:) = nbininv((p-c)/p,At,Bt./(1+Bt));

    clear At Bt

    %% without timing information
    % TODO: avoid hard-coding parameters
    % sales observation index
    SInd = S(:,:,1).*((40+1)^2) + S(:,:,2).*(40+1) + S(:,:,3) + 1;
    % stockout index
    EInd = E(:,:,1).*4 + E(:,:,2).*2 + E(:,:,3) + 1;

    clear S E

    Ynt(slice,:) = Sol(sub2ind(size(Sol),SInd,EInd));
    
    clear SInd EInd
end

clear Tau

%% mean profit of different allocation policies 
% profit in period 2
D2s = repmat(D2,1,nAlloc);

prft = @(y,d) p.*min(y,d) - c.*y;

ProfitT = 3 .* prft(Yt,D2s);
ProfitNT = 3 .* prft(Ynt,D2s);

MPrftT = mean(ProfitT);
MPrftNT = mean(ProfitNT);

% optimal profit with timing information
maxMPrftT = max(MPrftT);

% optimal profit without timign information
maxMPrftNT = max(MPrftNT);

% single-store
Policy1 = unique(perms([qMax,0,0]),'rows');

% two-store
if (mod(qMax,2)==0)
    Policy2 = unique(perms([qMax/2,qMax/2,0]),'rows');
else
    Policy2 = perms([(qMax+1)/2, (qMax-1)/2, 0]);
end

% three-store / even-split
if (mod(qMax,3)==0)
    Policy3 = repmat(qMax/3,1,3);
elseif (mod(qMax,3)==1)
    Policy3 = unique(perms([(qMax+2)/3,(qMax-1)/3,(qMax-1)/3]),'rows');
else
    Policy3 = unique(perms([(qMax+1)/3,(qMax+1)/3,(qMax-2)/3]),'rows');
end

[~,I1] = ismember(Policy1,Q','rows');
mPrftNT1 = mean(MPrftNT(I1'));

[~,I2] = ismember(Policy2,Q','rows');
mPrftNT2 = mean(MPrftNT(I2'));

[~,I3] = ismember(Policy3,Q','rows');
mPrftNT3 = mean(MPrftNT(I3'));

%% save results
if ~exist('../out','dir')
    mkdir('../out');
end
save(['../out/profit-N3-Q' sprintf('%d',qMax) '.mat'], ...
     'a','b','T','nTrial','p','c', ...
     'mPrftNT1','mPrftNT2','mPrftNT3','maxMPrftNT', 'maxMPrftT' ...
    );
