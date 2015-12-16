% Figure 2
% Ex-ante expected profit in a three-identical-store example as a function 
% of total test inventory Q under various allocation policies.

qMax = 40;

MPrftNT1 = zeros(1,qMax+1);
MPrftNT2 = zeros(1,qMax+1);
MPrftNT3 = zeros(1,qMax+1);
MaxMPrftNT = zeros(1,qMax+1);
MaxMPrftT = zeros(1,qMax+1);

for q = 0:qMax
    S = load(['../../three-store-Q40/out/profit-N3-Q' sprintf('%d',q) '.mat']);
    MPrftNT1(q+1) = S.mPrftNT1;
    MPrftNT2(q+1) = S.mPrftNT2;
    MPrftNT3(q+1) = S.mPrftNT3;
    MaxMPrftNT(q+1) = S.maxMPrftNT;
    MaxMPrftT(q+1) = S.maxMPrftT;
    clear S
end

figure('color','white');
h=plot(0:qMax, MPrftNT1, 'k.:', ...
       0:qMax, MPrftNT2, 'b.--', ...
       0:qMax, MPrftNT3, 'g.-', ...
       0:qMax, MaxMPrftNT, 'ro', ...
       0:qMax, MaxMPrftT, 'mv-' ...
      );

set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 16)
set(h,'LineWidth',1.5);
grid on;
xlabel('Total Test Inventory Q');
ylabel('Ex-ante Expected Profit');

legend('Single-Store without Timing Info.', ...
       'Two-Store without Timing Info.', ...
       'Three-Store (Even-Split) without Timing Info.', ...
       'Optimal without Timing Info.', ...
       'Optimal with Timing Info.', ...
       'location','southeast');

set(gcf,'Position',[10 10 1000 420]);
    