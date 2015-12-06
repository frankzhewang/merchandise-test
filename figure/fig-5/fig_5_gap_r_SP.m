% Figure 5
% Optimality gaps of the Service-Priority policy with various values of
% target service level r when timing information is observable (N=2)

S = load('../../two-store/out/no-timing/no-timing-summary.mat');
Gaps = repmat(S.OptProfit, 1, 20) - S.LDFProfit(:,31:50);
Gaps = Gaps ./ repmat(S.OptProfit, 1, 20);
Gaps = Gaps * 100;

x = (80:99) ./ 100;

set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 14)

figure;
plot(x,mean(Gaps),x,max(Gaps));
plot(x,mean(Gaps),'bo--',x,max(Gaps),'rv-','LineWidth',1);
xlabel('Target Service Level r');
ylabel('% Optimality Gap of Service-Priority Policy');
legend('Mean','Max','location','northeast');
xlim([0.8 1]);
% ylim([-2 32]);
set(gca,'XTick',[0.8:.01:1]);
% set(gca,'YTick',[0:2:30]);
set(gca,'LineWidth',1);
grid on
