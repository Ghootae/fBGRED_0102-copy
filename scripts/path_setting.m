% group-level path
function [subj path] = path_setting
path.currDir = pwd;
subj.NM = path.currDir(end-2:end);
subj.SN = path.currDir(end-5:end-4);
cd ..
path.subjRoot = pwd;
%%
path.behavioralData = [path.currDir '/behavioralData'];
path.behavioralDesign = [path.currDir '/behavioralDesign'];
path.behavioralSetting = [path.currDir '/behavioralSetting'];
path.designRoot = [path.currDir '/design'];
path.fsf = [path.currDir '/fsf'];
path.regressor = [path.currDir '/regressor'];
path.results = [path.currDir '/results'];
path.behav_results = [path.results '/behavioral'];
path.neural_results = [path.results '/neural'];
path.scripts = [path.currDir '/scripts'];

path.analysis.root = [path.currDir '/analysis'];
path.analysis.firstlevel = [path.analysis.root '/firstlevel'];
path.analysis.secondlevel = [path.analysis.root '/secondlevel'];

path.nifti = [path.currDir '/data/nifti'];
path.standardROIs = ['../../ROIs'];
path.rois = [path.currDir '/rois'];
%% generate a folder for each of runs(study for day1, post and loc for day2)
%load vars
load([path.behavioralSetting '/var.mat']);

% main
for scan = 1:var.main.nScan
    path.design{1}{scan} = [path.designRoot '/main_run' num2str(scan)];
    if ~exist(path.design{1}{scan})
        mkdir(path.design{1}{scan});
    end
end%for scan

% bg-center
for scan = 1:var.BG.nScan
    path.design{2}{scan} = [path.designRoot '/BG_center_run' num2str(scan)];
    if ~exist(path.design{2}{scan})
        mkdir(path.design{2}{scan});
    end
end%for scan

% fs
for scan = 1:var.FS.nScan
    path.design{3}{scan} = [path.designRoot '/FS_run' num2str(scan)];
    if ~exist(path.design{3}{scan})
        mkdir(path.design{3}{scan});
    end
end%for scan

% mr
for scan = 1:var.MR.nScan
    path.design{4}{scan} = [path.designRoot '/MR_run' num2str(scan)];
    if ~exist(path.design{4}{scan})
        mkdir(path.design{4}{scan});
    end
end%for scan

% bg-quad
for scan = 1:var.BG.nScan
    path.design{5}{scan} = [path.designRoot '/BG_quad_run' num2str(scan)];
    if ~exist(path.design{5}{scan})
        mkdir(path.design{5}{scan});
    end
end%for scan
%% save
save([path.currDir '/path.mat'], 'path');
save([path.currDir '/subj.mat'], 'subj');
cd(path.currDir)
