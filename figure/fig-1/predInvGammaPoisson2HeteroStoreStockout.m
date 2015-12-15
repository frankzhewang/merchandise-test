function y = predInvGammaPoisson2HeteroStoreStockout(cf,a,b,T,k,k1,s1,k2,s2)
% This function returns the smallest number y such that the cumulative
% predictive demand distribution function evaluated at y after Bayesian 
% updating >= critical fractile cf
%
% This function applies to merchandise test problem with at most two stores
% under stock-outs.
%
% Input:
%
% cf: scalar. critical fractile
% a: scalar. shape parameter of the gamma prior
% b: scalar. scale parameter of the gamma prior
% T: scalar. length in time of the testing period
% k: scalar.
% k1: scalar.
% s1: scalar. store 1 sales
% k2: scalar.
% s2: scalar. store 2 sales. optional
%
% Output:
%
% y: inverse of the cumulative predictive demand distribution function at
%   critical fractile cf

% one store
if nargin==7
    Signs = [1 -ones(1,s1)];
    Sales = [0 0:s1-1];
    Times = [0 (k1*T).*ones(1,s1)];
    Coeffs = Signs .* ((k1*T).^Sales) .* gamma(a+Sales) ...
        ./ gamma(Sales+1) ./ (b+Times).^(a+Sales);
    f = @(x) sum(Coeffs .* nbincdf(x,a+Sales,(b+Times)./(k+b+Times))) ...
        ./ sum(Coeffs);
end

% two store
if nargin==9
    Signs = [1 -ones(1,s1)]' * [1 -ones(1,s2)];
    Sales = repmat([0 0:s1-1]',1,s2+1) + repmat([0 0:s2-1],s1+1,1);
    Times = repmat([0 (k1*T).*ones(1,s1)]',1,s2+1) ...
        + repmat([0 (k2*T).*ones(1,s2)],s1+1,1);
    Facts = ([1 (k1*T).^[0:s1-1]]' ./ gamma([0 0:s1-1]'+1)) ...
        * ([1 (k2*T).^[0:s2-1]] ./ gamma([0 0:s2-1]+1)); % factorials
    Coeffs = Signs .* gamma(a+Sales) ...
        .* Facts ./ (b+Times).^(a+Sales);
    f = @(x) sum(sum(Coeffs .* nbincdf(x,a+Sales,(b+Times)./(k+b+Times)))) ...
        ./ sum(sum(Coeffs));
end

% binary search for the smallest y such that f(y)>=cf
if f(0) >= cf
    y = 0;
else
    yl = 0;
    yu = ceil(a/b);
    while f(yu) < cf
        yl = yu;
        yu = yu * 2;
    end
    while yu-yl > 1
        yu_ = yu;
        yl_ = yl;
        
        ymid = ceil((yl+yu)/2);
        if f(ymid) < cf
            yl = ymid;
        else
            yu = ymid;
        end
    end
    y = yu;
end
    
end

