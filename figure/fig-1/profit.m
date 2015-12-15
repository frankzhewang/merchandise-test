function [MPrftT,MPrftNT] = profit(qMax, p, c, demandFilename)
% PROFIT Computes the ex-ante expected profit of a
%   two-store merchandise testing problem under gamma-Poisson demand using 
%   a naive Monte Carlo simulation method.

if (nargin ~= 4)
    error('Incorrect number of input arguments.');
end

load([demandFilename,'.mat'],'n','a','b','T','k1','k2','Tau','D2');

Tau1 = Tau(:,1:qMax,1);
Tau2 = Tau(:,1:qMax,2);

CumTau1 = cumsum(Tau1,2); % arrival time epochs for store 1, period 1
CumTau2 = cumsum(Tau2,2); % arrival time epochs for store 2, period 1
D11 = sum(CumTau1 <= T,2); % random demand for store 1, period 1, n by 1 vector
D12 = sum(CumTau2 <= T,2); % random demand for store 2, period 1, n by 1 vector

%% computes expected profits for q=0 to ceil(qMax/2)
qMid = ceil((qMax-1)/2);

S1 = min(repmat(D11,1,qMid+1),repmat(0:qMid,n,1)); % sales of store 1, period 1
S2 = min(repmat(D12,1,qMid+1),repmat(qMax:-1:qMax-qMid,n,1)); % sales of store 2, period 1
T1 = min([zeros(n,1) CumTau1*eye(qMax,qMid)],T); % actual selling period of store 1, period 1
T2 = min(CumTau2*flipud(eye(qMax,qMid+1)),T); % actual selling period of store 2, period 1

cf = (p-c)/p; % critical fractile

%% with timing information
% Bayesian updating with timing information
At = a + S1 + S2;
Bt = b + k1.*T1 + k2.*T2;

% optimal ordering quantities for period 2
Yt1 = nbininv((p-c)/p,At,Bt./(k1+Bt));
Yt2 = nbininv((p-c)/p,At,Bt./(k2+Bt));

%% without timing information
E1 = repmat(D11,1,qMid+1) >= repmat(0:qMid,n,1); % whether store 1 stocks out
E2 = repmat(D12,1,qMid+1) >= repmat(qMax:-1:qMax-qMid,n,1); % whether store 2 stocks out
E = E1 + E2*2 + 1; % convert to index of solution table

% no timing information
% TODO: do this only once
[Sol1,Sol2] = solutionTable(cf,qMax,a,b,T,k1,k2);
Ynt1 = Sol1(sub2ind(size(Sol1),S1+1,S2+1,E));
Ynt2 = Sol2(sub2ind(size(Sol2),S1+1,S2+1,E));

% profit in period 2
D21 = repmat(D2(:,1),1,qMid+1);
D22 = repmat(D2(:,2),1,qMid+1);

prft = @(y,d) p.*min(y,d) - c.*y;

ProfitT = prft(Yt1,D21) + prft(Yt2,D22);
ProfitNT = prft(Ynt1,D21) + prft(Ynt2,D22);

MPrftT = mean(ProfitT);
MPrftNT = mean(ProfitNT);

end