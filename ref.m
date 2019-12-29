function [total, elec, peak, bat, reg, regc, regp] = ...
    ref(lambda, T, ts, s)

total = lambda.elec*ones(1,T)*s*ts + lambda.peak*max(s);
elec = lambda.elec*ones(1,T)*s*ts;
peak = lambda.peak*max(s);
bat = 0;
reg = 0;
regc = 0;
regp = 0;

end