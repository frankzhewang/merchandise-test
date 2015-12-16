function gen_demand(a, b, nStore, maxDemand, outPath, id)
% GEN_DEMAND Monte Carlo simulation of demand paths for a
% three-identical-store merchandise testing problem.
% 
% Demand model is gamma-Poisson.
%
% Uses naive sampling method.
%
% Usage: GEN_DEMAND(id, a, meanLm, gm, outPath)
%   id:     string. instance id as specified in parameter files.
%   a:      scalar. alpha, scale parameter of gamma prior.
%   meanLm: scalar. lambda, ex ante mean arrival rate.
%   gm:     scalar. relative demand coefficient of store 1 as its ratio to
%                   store 3.
%   outPath: string. output path.

%% parameter setting
T = 1; % length in time of each period
Gm = ones(1, nStore); % relative demand coeffcients
nTrial = 1e6; % number of trials

%% generate demand

pid = feature('getpid'); % use system pid as random seed
rs = rng(pid,'twister');

Lm = gamrnd(a, 1/b, nTrial, 1);
Tau = zeros(nTrial, maxDemand, nStore);
for i = 1:nStore
    Tau(:,:,i) = exprnd(repmat(1./Lm, 1, maxDemand)); % inter-arrival times
end

D2 = poissrnd(Lm); % period 2 demand in a representative store

%% save demand data
if ~exist(outPath,'dir')
    mkdir(outPath);
end
save([outPath '/demand-' id '.mat'], ...
     'a','b','T','Gm', ...
     'rs','Lm','Tau','D2');
