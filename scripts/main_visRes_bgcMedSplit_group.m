% getting mean (z-scored) activation for each of single, same, different
%conditions


function main_visRes_bgcMedSplit_group(subjGr, pathGr)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%load subj-level results and summarizing
for ss = 1:subjGr.nSubj
    % meanAct_med_valType_roi_SinSamDiff{valType}, 4(roi: v1~v4) x 3(redan cond: sin,sam,dif)
    %valType: median-split by 1:rel, 2:irrel, 3:rel-irrel values
    load([pathGr.subj{ss} '/results/neural/main_visRes_bgcMedSplit/meanAct_med_valType_roi_SinSamDiff.mat']);
    for valType = 1:3% 1:rel, 2:irrel, 3:rel-irrel values
        for recRoi = 1:4%v1~v4
            meanAct_med_summary_gr{valType}(ss, (recRoi-1)*6+1:recRoi*6) = ...%e.g.,V1-low-sin,sam,diff; V1-high-sin,sam,diff ...
                meanAct_med_valType_roi_SinSamDiff{valType}(recRoi, :);
        end
    end%for valType
end%for ss

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%stats
for valType = 1:3% 1:rel, 2:irrel, 3:rel-irrel values
    for recRoi = 1:4%v1~v4
        for med = 1:2%low, high
            for cond = 1:3%sin,sam,dif
                xPart = meanAct_med_summary_gr{valType}(:, (recRoi-1)*6+(med-1)*3+cond);
                meanAct_med_stat_mean{valType}(cond, (recRoi-1)*2+med) = mean(xPart);
                meanAct_med_stat_sem{valType}(cond, (recRoi-1)*2+med) = std(xPart)/sqrt(subjGr.nSubj);
            end%for cond
            
            xPart = meanAct_med_summary_gr{valType}(:, (recRoi-1)*6+(med-1)*3+1:(recRoi-1)*6+(med-1)*3+3);
            %sam - sin
            meanAct_red_med_stat_mean{valType}(med, (recRoi-1)*2+1) = mean([xPart(:,2)-xPart(:,1)]);
            meanAct_red_med_stat_sem{valType}(med, (recRoi-1)*2+1) = std([xPart(:,2)-xPart(:,1)])/sqrt(subjGr.nSubj);
            
            %sam - dif
            meanAct_red_med_stat_mean{valType}(med, (recRoi-1)*2+2) = mean([xPart(:,2)-xPart(:,3)]);
            meanAct_red_med_stat_sem{valType}(med, (recRoi-1)*2+2) = std([xPart(:,2)-xPart(:,3)])/sqrt(subjGr.nSubj);
            
            [H,P,CI,STATS] = ttest(xPart(:,1), xPart(:,2));%sin vs. sam
            meanAct_red_med_stat_tval{valType}(med,(recRoi-1)*2+1) = STATS.tstat;%t value
            meanAct_red_med_stat_pval{valType}(med,(recRoi-1)*2+1) = P;%p value
            
            [H,P,CI,STATS] = ttest(xPart(:,3), xPart(:,2));%dif vs. sam
            meanAct_red_med_stat_tval{valType}(med,(recRoi-1)*2+2) = STATS.tstat;%t value
            meanAct_red_med_stat_pval{valType}(med,(recRoi-1)*2+2) = P;%p value
        end%for med
        
        %% interaction
        xPart = meanAct_med_summary_gr{valType}(:, (recRoi-1)*6+1:recRoi*6);
        %sin vs. sam
        [H,P,CI,STATS] = ttest([xPart(:,2)-xPart(:,1)], [xPart(:,5)-xPart(:,4)]);
        meanAct_med_inter_stat_tval{valType}(1, recRoi) = STATS.tstat;%t value;
        meanAct_med_inter_stat_pval{valType}(1, recRoi) = P;%p value
        
        %dif vs. sam
        [H,P,CI,STATS] = ttest([xPart(:,2)-xPart(:,3)], [xPart(:,5)-xPart(:,6)]);
        meanAct_med_inter_stat_tval{valType}(2, recRoi) = STATS.tstat;%t value;
        meanAct_med_inter_stat_pval{valType}(2, recRoi) = P;%p value
        
    end%for recRoi
end%for valType
%% save results
ST.name = 'main_visRes_bgcMedSplit_group';
output_dir = [pathGr.results_neural '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/meanAct_med_summary_gr.mat'], 'meanAct_med_summary_gr');
save([output_dir '/meanAct_med_stat_mean.mat'], 'meanAct_med_stat_mean');
save([output_dir '/meanAct_med_stat_sem.mat'], 'meanAct_med_stat_sem');
save([output_dir '/meanAct_red_med_stat_mean.mat'], 'meanAct_red_med_stat_mean');
save([output_dir '/meanAct_red_med_stat_sem.mat'], 'meanAct_red_med_stat_sem');

save([output_dir '/meanAct_red_med_stat_tval.mat'], 'meanAct_red_med_stat_tval');
save([output_dir '/meanAct_red_med_stat_pval.mat'], 'meanAct_red_med_stat_pval');

save([output_dir '/meanAct_med_inter_stat_tval.mat'], 'meanAct_med_inter_stat_tval');
save([output_dir '/meanAct_med_inter_stat_pval.mat'], 'meanAct_med_inter_stat_pval');
