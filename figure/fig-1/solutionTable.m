function [ Sol1, Sol2 ] = solutionTable(cf,Q,a,b,T,k1,k2)
% SOLUTIONTABLE Computes optimal base-stock levels for the primary selling 
% season in a two-store merchandise test problem under gamma-Poisson demand
% , given possibly censored demand observations without timing information 
% during the testing period.
% 
% The length in time of the primary selling season is normalized to 1.
%
% Input:
%
% a: scalar. shape parameter of the gamma prior
% b: scalar. scale parameter of the gamma prior
% T: scalar. length in time of the testing period
% Q: scalar. total inventory available for testing
% cf: scalar. critical fractile
%
% Output:
% 
% Sol: Q+1 by Q+1 by 4 matrix
%   Sol(s1,s2,1): optimal base-stock level if observing sales s1 and s2,
%       neither store stocks out;
%   Sol(s1,s2,2): optimal base-stock level if observing sales s1 and s2, 
%       store 1 stocks out but store 2 does not;
%   Sol(s1,s2,3): optmial base-stock level if observing sales s1 and s2,
%       store 1 does not stock out but store 2 does;
%   Sol(s1,s2,4): optimal base-stock level if observing sales s1 and s2,
%       neither store stocks out;

Sol1 = zeros(Q+1,Q+1,4);
Sol2 = zeros(Q+1,Q+1,4);

% neither store stocks out
Sales = repmat([0:Q],Q+1,1) + repmat([0:Q]',1,Q+1); % total sales
time = (k1+k2)*T; % total effective selling time
Sol1(:,:,1) = nbininv(cf, a+Sales, (b+time)/(k1+b+time));
Sol2(:,:,1) = nbininv(cf, a+Sales, (b+time)/(k2+b+time));

% store 1 stocks out, store 2 does not
Sol1(1,:,2) = nbininv(cf, a+[0:Q], (b+k2*T)/(k1+b+k2*T)); % store 1 has 0 sales
Sol2(1,:,2) = nbininv(cf, a+[0:Q], (b+k2*T)/(k2+b+k2*T)); % store 1 has 0 sales
for s1 = 1:Q
    for s2 = 0:Q
        Sol1(s1+1,s2+1,2) ...
            = predInvGammaPoisson2HeteroStoreStockout(cf,a+s2,b+k2*T,T,k1,k1,s1);
        Sol2(s1+1,s2+1,2) ...
            = predInvGammaPoisson2HeteroStoreStockout(cf,a+s2,b+k2*T,T,k2,k1,s1);
    end
end

% store 1 does not stock out, store 2 does
Sol1(:,1,3) = nbininv(cf, a+[0:Q], (b+k1*T)/(k1+b+k1*T)); % store 2 has 0 sales
Sol2(:,1,3) = nbininv(cf, a+[0:Q], (b+k1*T)/(k2+b+k1*T)); % store 2 has 0 sales
for s1 = 0:Q
    for s2 = 1:Q
        Sol1(s1+1,s2+1,3) ...
            = predInvGammaPoisson2HeteroStoreStockout(cf,a+s1,b+k1*T,T,k1,k2,s2);
        Sol2(s1+1,s2+1,3) ...
            = predInvGammaPoisson2HeteroStoreStockout(cf,a+s1,b+k1*T,T,k2,k2,s2);
    end
end

% both stores stock out
for s1 = 0:Q
    for s2 = 0:Q
        Sol1(s1+1,s2+1,4) ...
            = predInvGammaPoisson2HeteroStoreStockout(cf,a,b,T,k1,k1,s1,k2,s2);
        Sol2(s1+1,s2+1,4) ...
            = predInvGammaPoisson2HeteroStoreStockout(cf,a,b,T,k2,k1,s1,k2,s2);
    end
end

end

