function setup_kcicpt()
%SETUP_KCICPT Add KCICPT project paths to the MATLAB search path.
root_dir = fileparts(mfilename('fullpath'));
addpath(root_dir);
addpath(fullfile(root_dir, 'kcipt'));
addpath(fullfile(root_dir, 'algorithms'));
addpath(fullfile(root_dir, 'data'));
addpath(fullfile(root_dir, 'bnt'));
addpath(genpathKPM(fullfile(root_dir, 'bnt')));
addpath(genpath(fullfile(root_dir, 'gpml-matlab')));
end
