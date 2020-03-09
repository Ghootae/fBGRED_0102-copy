% getting mean (z-scored) activation for each of single, same, different
%conditions

function main_visRes_group(subjGr, pathGr)
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
