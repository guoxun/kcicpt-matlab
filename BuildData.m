function [scaled_boston_wout_discrete]=BuildData(digoxin) 
    mu = mean(digoxin, 1);
    sd = std(digoxin, 0, 1);
    mus = repmat(mu, size(digoxin, 1), 1);
    sds = repmat(sd, size(digoxin, 1), 1);
    scaled_boston_wout_discrete = (digoxin - mus) ./ sds;
end