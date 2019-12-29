clear;
clc;
close all;
fig_flag = 1; % Show figures

%% Define battery
battery.n = 5000; % Charge and discharge cycles
battery.cell = 0.3;% Cell price, $/Wh
battery.power = 1; % MW, battery power
battery.energy = battery.power*(3/60); % MWh, battery energy, up for 3min
battery.socmax = 0.8; 
battery.socmin = 0.2;
battery.socini = 0.6;

%% Price 
lambda.elec = 47; %Electricity price, $/MWh
lambda.peak = 12*1000/30/24; %Peak demand charge, 12,000$/MW
lambda.c = 50;  %Unit regulation revenue //$100 for new signal
lambda.p = 500; %Mismatch panelty //$500 for new signal
lambda.battery = battery.cell*10^(6)/...
    (2*battery.n*(battery.socmax-battery.socmin)); %Battery cost, $/MWh

%% Signal
load('PJM_Reg_Signal_2013_06-201405.mat');%PJM frequency regulation signal 2013-2014
load('UWEE_load.mat');
school = school(~isnan(school));
school = repmat(school,1,45); % change the school data resolution to 20s
eecs = reshape(school',35023*45,1);
rr = reshape(RegD_signal',365*43201,1); %resolution: 2s
r_tem = rr(1:2:end,:); %use old frequency regulation signal, change resolution to 4s
%r_tem = sig2018(1:2:end, :); %use new frequency regulation signal, change resolution to 4s

%% Parameters
hour = 1;
ts = 4/3600;
T = hour*1/ts;
tt = 4:4:3600*hour;

for i = 1:1
    r = r_tem((i-1)*T+1:i*T);
    
    % UW EE building load
    s = eecs((i-1)*T+1:6:i*T*6);
    s = s/max(s);
    
    
    % Reference electricity bill: Not using battery
    %[bill1.total, bill1.elec, bill1.peak, bill1.battery, bill1.reg...
    %            bill1.regc, bill1.regp] = = ref(lambda, T, ts, s); %if
    %            want to look at the seperate bill for peak demand charge &
    %            energy cost, uncomment this line;
    [bill1.total, ~] = ref(lambda, T, ts, s);
    
    % Electricity bill doing frequency regulation only 
    %[bill2.total, bill2.elec, bill2.peak, bll2.ibattery, bill2.reg...
    %            bill2.regc, bill2.regp] = reg_only(lambda, battery, T, ts, tt, s, r);
    [bill2.total, ~] = reg_only(fig_flag, lambda, battery, T, ts, tt, s, r);
    
    % Electricity bill doing peak shaving only
    %[bill3.total, bill3.elec, bill3.peak, bill3.battery, bill3.reg...
    %     bill3.regc, bill3.regp] = ps_only(lambda, battery, T, ts, tt, s);
    [bill3.total,~] = ps_only(fig_flag, lambda, battery, T, ts, tt, s);
    
    % Electricity bill doing joint optimization (both peak shaving & frequency regulation)
    %[bill4.total, bill4.elec, bill4.peak, bill4.battery, bill4.reg...
    %            bill4.regc, bill4.regp] = both(lambda, battery, T, ts, tt, s, r);
    [bill4.total,~] = both(fig_flag, lambda, battery, T, ts, tt, s, r);
    
    bill(i,:) = [bill1.total, bill2.total, bill3.total, bill4.total];
    
    %saving = ((bill1.total-bill4.total)-(2*bill1.total-bill2.total-bill3.total));
end

if fig_flag==1
    B = [bill1.total/bill1.total, bill2.total/bill1.total,...
        bill3.total/bill1.total, bill4.total/bill1.total];
    figure;
    hold all;
    bar(B,0.5)
    grid on
    hold off
    ylabel('Normalized electricity bill (bill/bill with no battery)');
    title('Normalized electricity bill under four policy');
end