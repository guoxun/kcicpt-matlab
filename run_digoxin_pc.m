function run_digoxin_pc(digoxin,pvalue)
tic;
    addpath('bnt');
    addpath(genpathKPM('bnt'));
    addpath('kcipt');
    addpath('data');
%    load digoxin.dat;
    [row,col] = size(digoxin);
    mu = mean(digoxin, 1);
    sd = std(digoxin, 0, 1);
    mus = repmat(mu, size(digoxin, 1), 1);
    sds = repmat(sd, size(digoxin, 1), 1);
    scaled_boston_wout_discrete = (digoxin - mus) ./ sds;
    global sigmas ;
    global sigmas_index;
    global debugNum;
    debugNum =1;
    sigmas_index = zeros(col,1);
    sigmas = zeros(col,1);
    for i = 1:col
    sigmas(i) = median_pdist(scaled_boston_wout_discrete(:,i));   
  % sigmas(i) = 1;
    end
    % MATLAB 2010
    % (For repeatability)
    s = RandStream('mcg16807','Seed',0);
    RandStream.setGlobalStream(s);

    citest = kcipt_pc(scaled_boston_wout_discrete, pvalue);
    P = learn_struct_pdag_pc(citest, col, col)
    type boston_names3
    toc;
end
