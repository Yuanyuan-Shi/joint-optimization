function [total, elec, peak, bat, reg, regc, regp] = ...
    reg_only(fig_flag, lambda, battery, T, ts, tt, s, r)

% Regulation only
% Use Optimal control to calculate optimal regulation capacity bidding C
% and battery response
cvx_begin quiet
    variables c b(T,1) z;
    minimize (lambda.elec*ones(1,T)*(s-b)*ts + ...
        + lambda.battery*norm(b,1)*ts...
        - (lambda.c*c*ts*T-lambda.p*ts*norm(b-c*r,1)));
            subject to
            c >= 0;
            ones(1,T)*b == 0;
            b >= -battery.power;       
            b <= battery.power;
            tril(ones(T))*b*ts <= ones(T,1)*...
                (battery.socini-battery.socmin)*battery.energy;
            tril(ones(T))*b*ts >= ones(T,1)*...
                (battery.socini-battery.socmax)*battery.energy;
cvx_end
disp(c)
% % Simple online battery control algorithm; uncomment the below code if we
% want to do online battery control instead of look-ahead planning
% SoC_sim = zeros(T+1,1);
% SoC_sim(1) = battery.socini; %Initial
% simx = zeros(T,1);
% 
% for i = 1:T
%     simx(i) = c*r(i);
%     if(simx(i)>B_P)
%         simx(i)=B_p;
%     end
%     if(simx(i)<-B_P)
%         simx(i)=-B_P;
%     end
%     
%     SoC_sim(i+1) = (SoC_sim(i)*B_E - simx(i)*ts)/B_E; %SoC for next second
%     if(SoC_sim(i+1)>SoC_max)
%         SoC_sim(i+1)=SoC_max;
%         simx(i) = (SoC_sim(i)-SoC_sim(i+1))*B_E/ts;
%     end
%     
%     if(SoC_sim(i+1)<SoC_min)
%         SoC_sim(i+1)=SoC_min;
%         simx(i) = (SoC_sim(i)-SoC_sim(i+1))*B_E/ts;
%     end    
% end

% Bill
total = lambda.elec*ones(1,T)*(s-b)*ts + lambda.peak*max(s-b) ...
        + lambda.battery*norm(b,1)*ts ...
        -(lambda.c*c*ts*T-lambda.p*ts*norm(b-c*r,1));
elec = lambda.elec*ones(1,T)*(s-b)*ts;
peak = lambda.peak*max(s-b);
bat = lambda.battery*norm(b,1)*ts;
reg = - lambda.c*c*ts*T + lambda.p*ts*norm(b-c*r,1);
regc = - lambda.c*c*ts*T;
regp = +lambda.p*ts*norm(b-c*r,1);

if fig_flag == 1 %Need to plot figures 
    % SoC
    SoC_2 = zeros(T,1);
    SoC_2(1) = battery.socini;
    for i = 2:T
        SoC_2(i) = (battery.socini*battery.energy...
            -sum(b(1:i-1))*ts)/battery.energy;
    end

    subplot(2,1,1)
    hold all;
    plot(tt,s, '-.b','LineWidth', 2)
    plot(tt,s-b, '-r', 'LineWidth', 2);
    plot(tt,s-c*r, '.g', 'LineWidth', 2);
    hold off;
    xlabel('time[s]');
    ylabel('power[MW]');
    grid on
    legend('DC demand','grid consumption','Demand + reg');
    title(sprintf('Battery only for regulation (Bidded c:%.2f, peak shaved: %.2f',...
        c,max(s)-max(s-b)));

    subplot(2,1,2)
    plot(SoC_2,'b');
    xlabel('time[s]');
    ylabel('SoC[%]');
    grid on
    title('Battery only for regulation: SoC curve');
end 

end
