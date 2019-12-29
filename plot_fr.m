figure;
subplot(2,1,1)
plot(RegD_signal(1,:), 'b', 'LineWidth', 2)
legend('RegD 2014');
subplot(2,1,2)
plot(sig2018, 'r', 'LineWidth', 2)
ylim([-1, 1])
legend('RegD 2018');