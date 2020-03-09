% running post-GLM analyses

function group_running_post_GLM
%% setting
addpath('scripts/');
pathGr.prjt = pwd;
[subjGr, pathGr] = path_setting_group;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%running "main_visRes" for each subject
for ss = 14:subjGr.nSubj
    cd(pathGr.subj{ss});
    addpath([pathGr.subj{ss} '/scripts/']);
    
    path.currDir = pwd;
    if ~exist([path.currDir '/path.mat'])
        [subj path] = path_setting;
    else
        load([path.currDir '/path.mat'], 'path');
        load([path.currDir '/subj.mat'], 'subj');
    end%if
%     
%     % getting ROI index
%     if ~exist([path.rois '/seedROI.mat'])
%         getROIs_index(path);
%     end%if
%     
%     % visual redundancy
%     ST.name = 'main_visRes';
%     output_dir = [path.neural_results '/' ST.name];
%     if ~exist([output_dir '/meanAct_roi_SinSamDiff.mat'])%if not run yet
%         main_visRes(path);
%     end%if
%     
%     % background connectivity-center
%     ST.name = 'bgc_connectivity';
%     output_dir = [path.neural_results '/' ST.name];
%     if ~exist([output_dir '/bg_vox_corr.mat'])%if not run yet
%         bgc_connectivity(path);
%     end%if
%     
%     % background connectivity-quadrant
%     ST.name = 'bgq_connectivity';
%     output_dir = [path.neural_results '/' ST.name];
%     if ~exist([output_dir '/bg_vox_corr.mat'])%if not run yet
%         bgq_connectivity(path);
%     end%if
%     
%     % median-split of redundancy by BG-C
%     ST.name = 'main_visRes_bgcMedSplit';
%     output_dir = [path.neural_results '/' ST.name];
%     if ~exist([output_dir '/meanAct_med_valType_roi_SinSamDiff.mat'])%if not run yet
%         main_visRes_bgcMedSplit(path);
%     end%if
%     
%     % median-split of redundancy by BG-Q
%     ST.name = 'main_visRes_bgqMedSplit';
%     output_dir = [path.neural_results '/' ST.name];
%     if ~exist([output_dir '/meanAct_med_valType_roi_SinSamDiff.mat'])%if not run yet
%         main_visRes_bgqMedSplit(path);
%     end%if
    
    % correlation b/w voxel-level BG-C and redundancy
    ST.name = 'main_visRes_bgcVoxCorr';
    output_dir = [path.neural_results '/' ST.name];
%     if ~exist([output_dir '/corrBGRed.mat'])%if not run yet
        main_visRes_bgcVoxCorr(path);
%     end%if
    rmpath('scripts/');
end%for ss
cd(pathGr.prjt);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%load subj-level results and summarizing
for ss = 1:subjGr.nSubj
    % meanAct_roi_SinSamDiff, 6 rois x 3(sin,sam,dif)
    load([pathGr.subj{ss} '/results/neural/main_visRes/meanAct_roi_SinSamDiff.mat']);
    
    for roi = 1:6%v1~4, ffa, ppa
        mnActROICond_summary_gr(ss,(roi-1)*3+1:roi*3) = meanAct_roi_SinSamDiff(roi,:);
    end%for roi
end%for ss

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%stats
for roi = 1:6
    xPart = mnActROICond_summary_gr(:,(roi-1)*3+1:roi*3);
    mnActROICond_stat_mean(:,roi) = mean(xPart);%3(sin,same,diff) x 6(ROIs)
    mnActROICond_stat_sem(:,roi) = std(xPart)/sqrt(subjGr.nSubj);%3(sin,same,diff) x 6(ROIs)
    [H,P,CI,STATS] = ttest(xPart(:,1), xPart(:,2));%sin vs. same
    mnActROICond_stat_tval(1,roi) = STATS.tstat;%t value
    mnActROICond_stat_pval(1,roi) = P;%p value
    [H,P,CI,STATS] = ttest(xPart(:,3), xPart(:,2));%diff vs. same
    mnActROICond_stat_tval(2,roi) = STATS.tstat;%t value
    mnActROICond_stat_pval(2,roi) = P;%p value
end%for roi

%% save results
ST.name = 'main_visRes_group';
output_dir = [pathGr.results_neural '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/mnActROICond_summary_gr.mat'], 'mnActROICond_summary_gr');
save([output_dir '/mnActROICond_stat_mean.mat'], 'mnActROICond_stat_mean');
save([output_dir '/mnActROICond_stat_sem.mat'], 'mnActROICond_stat_sem');
save([output_dir '/mnActROICond_stat_tval.mat'], 'mnActROICond_stat_tval');
save([output_dir '/mnActROICond_stat_pval.mat'], 'mnActROICond_stat_pval');
