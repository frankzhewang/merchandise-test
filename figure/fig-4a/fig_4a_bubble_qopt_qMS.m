% Figure 4a
% Comparison of the heuristic and the optimal allocation policies (N=2)
% Timing information observable

S = load('../../two-store/out/timing/timing-summary.mat','OptAlloc','MSAlloc');
X = S.OptAlloc(:,1);
Y = S.MSAlloc(:,1);

Pairs = [X Y];
UniqPairs = unique(Pairs,'rows');
UniqPairCnts = zeros(length(UniqPairs),1);
for pair = Pairs'
    [~,i] = ismember(pair', UniqPairs, 'rows');
    UniqPairCnts(i) = UniqPairCnts(i) + 1;
end

set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 14)

figure;
plot(-2:32,-2:32,'k-');
hold on
scatter(UniqPairs(:,1),UniqPairs(:,2),sqrt(UniqPairCnts).*50,'r','LineWidth',1);
xlabel('$q_1^{T^*}$','interpreter','latex','fontsize',20);
ylabel('$q_1^\mathrm{MS}$','interpreter','latex','fontsize',20);
xlim([-2 32]);
ylim([-2 32]);
set(gca,'XTick',(0:2:30));
set(gca,'YTick',(0:2:30));
set(gca,'LineWidth',1);
grid on
hold off