function [total, elec, peak, bat, reg, regc, regp] = ...
    ps_only(fig_flag, lambda, battery, T, ts, tt, s)

cvx_begin quiet
    variables b(T,1);
    minimize (lambda.elec*ones(1,T)*(s-b)*ts + ...
        lambda.peak*max(s-b) + lambda.battery*norm(b,1)*ts);
    subject to
    ones(1,T)*b == 0;
    b >= -battery.power;       
    b <= battery.power;
    tril(ones(T))*b*ts <= ones(T,1)*...
        (battery.socini-battery.socmin)*battery.energy;
    tril(ones(T))*b*ts >= ones(T,1)*...
        (battery.socini-battery.socmax)*battery.energy;
cvx_end

% Bill
total = lambda.elec*ones(1,T)*(s-b)*ts + lambda.peak*max(s-b)...
    + lambda.battery*norm(b,1)*ts;
elec = lambda.elec*ones(1,T)*(s-b)*ts;
peak = lambda.peak*max(s-b);
bat = lambda.battery*norm(b,1)*ts;
reg = 0;
regc = 0;
regp = 0;

if fig_flag == 1
    % SoC
    SoC_3 = zeros(T,1);
    SoC_3(1) = battery.socini;
    for i = 2:T
        SoC_3(i) = (battery.socini*battery.energy-sum(b(1:i-1))*ts)/battery.energy;
    end

    % figure
    figure;
    subplot(2,1,1)
    hold all;
    plot(tt,s,'-.b','LineWidth',2);
    plot(tt,s-b,'--g','LineWidth',2);
    hold off;
    xlabel('time[s]');
    ylabel('power[MW]');
    grid on
    legend('grid consumption','after shaving');
    title(sprintf('Peak shaving only, shaved peak: %.2f', max(s)-max(s-b)));

    subplot(2,1,2)
    plot(tt,SoC_3,'b');
    xlabel('time[s]');
    ylabel('SoC[%]');
    grid on
    title('Battery only for peak shaving: SoC curve');
end
end