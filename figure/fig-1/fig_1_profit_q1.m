% Figure 1
% Ex-ante expected profit Pi(q1, Q-q1|alpha, beta) as a funciton of q1 in a
% two-identical-store example under gamma-Poisson demand when Q = 5, 10, 15

%% load data
if ~exist('out/profit.mat', 'file')
    error('Cannot find data file.');
end

S = load('out/profit.mat', ...
         'PT_Q5', 'PT_Q10', 'PT_Q15', ...
         'PNT_Q5', 'PNT_Q10', 'PNT_Q15');
PT_Q5 = S.PT_Q5;
PT_Q10 = S.PT_Q10;
PT_Q15 = S.PT_Q15;
PNT_Q5 = S.PNT_Q5;
PNT_Q10 = S.PNT_Q10;
PNT_Q15 = S.PNT_Q15;
clear S

%% generate plots
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 14)

figure;
h15 = plot(0:7, PT_Q15, 'r--^', 0:7, PNT_Q15,'b-o');
xlabel('q_1');
ylabel('\Pi (q_1, Q-q_1|\alpha, \beta)');
legend('With Timing Info.','Without Timing Info.','location','southeast');
xlim([-1 8]);
ylim([75 80]);
set(gca,'XTick',0:7);
%set(gca,'YTick',[-1:1:20]);
set(h15,'LineWidth',2);
ar = get(gca,'DataAspectRatio');
grid on

figure;
h10 = plot(0:5, PT_Q10, 'r--^', 0:5, PNT_Q10,'b-o');
xlabel('q_1');
ylabel('\Pi (q_1, Q-q_1|\alpha, \beta)');
xlim([-1 6]);
ylim([75 80]);
set(gca,'XTick',0:5);
%set(gca,'YTick',[-1:1:20]);
set(h10,'LineWidth',2);
set(gca,'DataAspectRatio',ar);
grid on
%legend('Timing Info. Available','Timing Info. Unavailable');

figure;
h5 = plot(0:2, PT_Q5, 'r--^', 0:2, PNT_Q5, 'b-o');
xlabel('q_1');
ylabel('\Pi (q_1, Q-q_1|\alpha, \beta)');
xlim([-1 3]);
ylim([75 80]);
set(gca,'XTick',0:2);
%set(gca,'YTick',[-1:1:20]);
set(h5,'LineWidth',2);
set(gca,'DataAspectRatio',ar);
grid on
%legend('Timing Info. Available','Timing Info. Unavailable');
