function [subjGr, pathGr] = path_setting_group
pathGr.prjt = pwd;
pathGr.subjRoot = [pathGr.prjt '/subjects'];
subjList = dir([pathGr.subjRoot '/fBGRED_0102_*']);
subjExclude = {'01'...%no ffa
    ,'07'...%no ffa
    };%to be excluded subjects
xCheck = [];
for ss = 1:length(subjList)
    for ex = 1:length(subjExclude)
        if strcmp(subjList(ss).name(end-1:end), subjExclude{ex})
            xCheck(end+1) = ss;
        end
    end%for ex
end%for ss
subjList(xCheck) = [];%exclude

subjGr.nSubj = length(subjList);

for ss = 1:subjGr.nSubj
    pathGr.subj{ss} = [pathGr.subjRoot '/' subjList(ss).name];
end%for ss

pathGr.results_behav = [pathGr.prjt '/results/behavioral'];
pathGr.results_neural = [pathGr.prjt '/results/neural'];

%% save
save([pathGr.prjt '/pathGr.mat'], 'pathGr');
save([pathGr.prjt '/subjGr.mat'], 'subjGr');