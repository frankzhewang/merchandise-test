function gen_demand(id, a, meanLm, gm, outPath)
% JOB_GEN_DEMAND Monte Carlo simulation of demand paths for a
% three-heterogeneous-store merchandise testing problem.
% 
% Demand model is gamma-Poisson.
%
% Uses naive sampling method.
%
% Usage: JOB_GEN_DEMAND(id, a, meanLm, gm, outPath)
%   id:     string. instance id as specified in parameter files.
%   a:      scalar. alpha, scale parameter of gamma prior.
%   meanLm: scalar. lambda, ex ante mean arrival rate.
%   gm:     scalar. relative demand coefficient of store 1 as its ratio to
%                   store 3.
%   outPath: string. output path.

%% parameter setting

b = a/meanLm; % shape parameter of gamma prior
T = 1; % length in time of each period
Gm = [2*gm gm+1 2]./sum([2*gm gm+1 2]); % normalized relative demand coeffcients
nStore = length(Gm);
qMax = 30; % inventory limit Q
nTrial = 1e6; % number of trials

%% generate demand

pid = feature('getpid'); % use system pid as random seed
rs = rng(pid,'twister');

Lm = kron(Gm', gamrnd(a, 1/b, nTrial, 1)); % gm * lambda
Tau = exprnd(repmat(1./Lm, 1, qMax)); % inter-arrival times
CumTau = cumsum(Tau, 2);
clear Tau; % release memory

D1 = reshape(sum(CumTau <= T, 2), nTrial, nStore); % period 1 demand
D2 = reshape(poissrnd(Lm), nTrial, nStore); % period 2 demand

save([outPath '/demand-N3-abGm' id '.mat'] ...
     ,'a','b','T','Gm' ...
     ,'rs','Lm','CumTau','D1','D2');
