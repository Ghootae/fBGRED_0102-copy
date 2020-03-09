% measuring voxel-level correlation b/w redundancy gain and background
% connectivity

function main_visRes_bgcVoxCorr_group(subjGr, pathGr)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%load subj-level results and summarizing
for ss = 1:subjGr.nSubj
    % corrBGRed{roi}(BGvalType, redType), BGvalType(rel,irrel,rel-irrel),
    % redType(sin,sam,dif,sam-sin,sam-dif)
    load([pathGr.subj{ss} '/results/neural/main_visRes_bgcVoxCorr/corrBGRed.mat']);
    for recRoi = 1:4%v1~v4
        for BGvalType = 1:3%1:rel, 2:irrel, 3:rel-irrel values (BG)
            for redType = 1:5%sin,sam,dif,sam-sin,sam-dif
                corrBGRed_summary_gr{recRoi}(ss, (BGvalType-1)*5+redType) = corrBGRed{recRoi}(BGvalType, redType);
            end
        end
    end
end%for ss

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%stats
for recRoi = 1:4%v1~v4
    for BGvalType = 1:3%1:rel, 2:irrel, 3:rel-irrel values (BG)
        for redType = 1:5%sin,sam,dif,sam-sin,sam-dif
            xPart = corrBGRed_summary_gr{recRoi}(:, (BGvalType-1)*5+redType);
            ref = xPart*0;%reference
            corrBGRed_stat_mean(redType, (recRoi-1)*3+BGvalType) = mean(xPart);
            corrBGRed_stat_sem(redType, (recRoi-1)*3+BGvalType) = std(xPart)/sqrt(subjGr.nSubj);
            [H,P,CI,STATS] = ttest(xPart, ref);%vs zero.
            corrBGRed_stat_tval(redType, (recRoi-1)*3+BGvalType) = STATS.tstat;%t value
            corrBGRed_stat_pval(redType, (recRoi-1)*3+BGvalType) = P;%p value
        end
    end
end%recRoi

%% save results
ST.name = 'main_visRes_bgcVoxCorr_group';
output_dir = [pathGr.results_neural '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/corrBGRed_summary_gr.mat'], 'corrBGRed_summary_gr');
save([output_dir '/corrBGRed_stat_mean.mat'], 'corrBGRed_stat_mean');
save([output_dir '/corrBGRed_stat_sem.mat'], 'corrBGRed_stat_sem');
save([output_dir '/corrBGRed_stat_tval.mat'], 'corrBGRed_stat_tval');
save([output_dir '/corrBGRed_stat_pval.mat'], 'corrBGRed_stat_pval');
