function [total, elec, peak, bat, reg, regc, regp] = ...
    both(fig_flag, lambda, battery, T, ts, tt, s, r)
cvx_begin quiet
    variables c b(T,1) y(T,1);
    minimize (lambda.elec*ones(1,T)*(s-b)*ts + lambda.peak*max(s-b) ...
        + lambda.battery*norm(b,1)*ts - (lambda.c*c*ts*T-lambda.p*ts*norm(-s+b+y-c*r,1)));
            subject to
            y == s;
            ones(1,T)*b == 0;
            c >= 0;
            b >= -battery.power;       
            b <= battery.power;
            tril(ones(T))*b*ts <= ones(T,1)*...
                (battery.socini-battery.socmin)*battery.energy;
            tril(ones(T))*b*ts >= ones(T,1)*...
                (battery.socini-battery.socmax)*battery.energy;
cvx_end

% Electricity bill4
total = lambda.elec*ones(1,T)*(s-b)*ts + lambda.peak*max(s-b) ...
        + lambda.battery*norm(b,1)*ts -...
        (lambda.c*c*ts*T-lambda.p*ts*norm(-s+b+y-c*r,1));
elec = lambda.elec*ones(1,T)*(s-b)*ts;
peak = lambda.peak*max(s-b);
bat = lambda.battery*norm(b,1)*ts;
reg = - lambda.c*c*ts*T + lambda.p*ts*norm(-s+b+y-c*r,1);
regc = - lambda.c*c*ts*T;
regp = +lambda.p*ts*norm(-s+b+y-c*r,1);


if fig_flag==1
    %SoC
    SoC_4 = zeros(T,1);
    SoC_4(1) = battery.socini;
    for i = 2:T
        SoC_4(i) = (battery.socini*battery.energy-sum(b(1:i-1))*ts)/battery.energy;
    end

    % figure
    figure;
    subplot(2,1,1)
    hold all;
    plot(tt,s, '-.b','LineWidth', 2)
    plot(tt,s-b, '-r', 'LineWidth', 2);
    plot(tt,s-c*r, '--g', 'LineWidth', 2);

    hold off;
    grid on
    xlabel('time[s]');
    ylabel('power[MW]');
    legend('DC demand','grid consumption','Demand + reg');
    title(sprintf('Battery for both reg & shaving, c = %.2f, peak shaved=%.2f', c, max(s)-max(s-b)));

    subplot(2,1,2)
    plot(tt,SoC_4,'b');
    grid on
    xlabel('time[s]');
    ylabel('SoC[%]');
    title('Battery for both reg & shaving: SoC curve');
end

end
