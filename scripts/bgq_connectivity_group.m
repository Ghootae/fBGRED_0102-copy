%measuring BG-conn b/w seeds(FFA, PPA) and recipients(V1~V4) for bg-center

function bgq_connectivity_group(subjGr, pathGr)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%load subj-level results and summarizing
for ss = 1:subjGr.nSubj
    %bgCorr_quadCol{recRoi}, 2(seed: ffa,ppa) x 2(task: face,scene)
    load([pathGr.subj{ss} '/results/neural/bgq_connectivity/bgCorr_quadCol.mat']);
    for recRoi = 1:4%v1~v4
        for seedRoi = 1:2%ffa,ppa
            for task = 1:2%face,scene
                bgCorr_summary_gr{seedRoi}(ss, (recRoi-1)*2+task) = ...%e.g., V1:face,scene, V2:face,scene ...
                    bgCorr_quadCol{recRoi}(seedRoi, task);
            end
        end
    end
end%for ss

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%stats
for recRoi = 1:4%v1~v4
    %e.g., ffa-V1 connectivity for face vs. scene attention task
    for seedRoi = 1:2%ffa,ppa
        xPart = bgCorr_summary_gr{seedRoi}(:, (recRoi-1)*2+1:recRoi*2);
        bgCorr_stat_mean{seedRoi}(:,recRoi) = mean(xPart);%2(task:face,scene) x 4(ROIs)
        bgCorr_stat_sem{seedRoi}(:,recRoi) = std(xPart)/sqrt(subjGr.nSubj);%2(task:face,scene) x 6(ROIs)
        [H,P,CI,STATS] = ttest(xPart(:,1), xPart(:,2));%face vs. scene
        bgCorr_stat_tval{seedRoi}(1,recRoi) = STATS.tstat;%t value
        bgCorr_stat_pval{seedRoi}(1,recRoi) = P;%p value
    end%for seedRoi
    
    %e.g., interaction (face-scene b/w ffa and ppa)
    clear xPart
    xPart(:,1) = bgCorr_summary_gr{1}(:, (recRoi-1)*2+1) - bgCorr_summary_gr{1}(:, recRoi*2);%face-scene
    xPart(:,2) = bgCorr_summary_gr{2}(:, (recRoi-1)*2+1) - bgCorr_summary_gr{2}(:, recRoi*2);%face-scene
    [H,P,CI,STATS] = ttest(xPart(:,1), xPart(:,2));%ffa vs. ppa
    bgCorr_stat_inter_tval(1,recRoi) = STATS.tstat;%t value
    bgCorr_stat_inter_pval(1,recRoi) = P;%p value
end%for recRoi

%% save results
ST.name = 'bgq_connectivity_group';
output_dir = [pathGr.results_neural '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/bgCorr_summary_gr.mat'], 'bgCorr_summary_gr');
save([output_dir '/bgCorr_stat_mean.mat'], 'bgCorr_stat_mean');
save([output_dir '/bgCorr_stat_sem.mat'], 'bgCorr_stat_sem');
save([output_dir '/bgCorr_stat_tval.mat'], 'bgCorr_stat_tval');
save([output_dir '/bgCorr_stat_pval.mat'], 'bgCorr_stat_pval');

save([output_dir '/bgCorr_stat_inter_tval.mat'], 'bgCorr_stat_inter_tval');
save([output_dir '/bgCorr_stat_inter_pval.mat'], 'bgCorr_stat_inter_pval');

