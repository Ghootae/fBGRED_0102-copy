% getting mean (z-scored) activation for each of single, same, different
%conditions


function main_visRes_bgcMedSplit(path)
%%
addpath('~/fMRI_analysis/packages/NIfTI_20140122/')
%% load variables and design matrix
load([path.behavioralSetting '/var.mat']);
load([path.behavioralSetting '/param.mat']);
load([path.behavioralSetting '/time.mat']);
load([path.behavioralSetting '/key.mat']);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%roi name info & design matrix
%% roi info
% seedsROIs_name = {'ffa','ppa'};
% 
% recRois_name{1} = {'l_V1v','r_V1v', 'r_V1d', 'l_V1d'};%{roi}{pQuad for single}
% recRois_name{2} = {'l_V2v','r_V2v', 'r_V2d', 'l_V2d'};
% recRois_name{3} = {'l_V3v','r_V3v', 'r_V3d', 'l_V3d'};
% recRois_name{4} = {'l_hV4','r_hV4', 'r_hV4', 'l_hV4'};
% recRois_name{5} = {'ffa','ffa', 'ffa', 'ffa'};
% recRois_name{6} = {'ppa','ppa', 'ppa', 'ppa'};

load([path.rois '/seedsROIs_name.mat'], 'seedsROIs_name');
load([path.rois '/recRois_name.mat'], 'recRois_name');

load([path.rois '/seedROI.mat'], 'seedROI');
load([path.rois '/recROI.mat'], 'recROI');
load([path.rois '/recROI_ventDor.mat'], 'recROI_ventDor');%by ventral and dorsal(left+right)
%% design matrix
load([path.behavioralDesign '/mainMat'], 'mainMat');
load([path.behavioralDesign '/mn'], 'mn');
% blk: 1
% upCond: 2
% loCond: 3
% upCate: 4
% loCate: [5 6 7 8]
% imgID: [9 10 11 12]
% onset: 13
% catch: 14
% resp: 15
% rt: 16
% acc: 17
sameDiff_realIndx = [5 6];%cope index for same and diff (1~4 for single)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%roi name info & design matrix
ST.name = 'bgc_connectivity';
output_dir = [path.neural_results '/' ST.name];
load([output_dir '/bg_vox_corr.mat'], 'bg_vox_corr');
load([output_dir '/bg_vox_corrIndx.mat'], 'bg_vox_corrIndx');

% bg_vox_corrIndx.rel = 1;
% bg_vox_corrIndx.irrel = 2;
% bg_vox_corrIndx.relIrrel = 3;
% bg_vox_corrIndx.medRel = 4;
% bg_vox_corrIndx.medIrrel = 5;
% bg_vox_corrIndx.medRelIrrel = 6;
% bg_vox_corrIndx.vdVoxIndx = 7;

tmpIndx = bg_vox_corrIndx;
valIndx = [tmpIndx.medRel tmpIndx.medIrrel tmpIndx.medRelIrrel];
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%getting a zstat val for each condition
% note that single condition is calculated by each pQuad(pQ1~oQ4)
upCond = 1;%single
cate = 2;%always scene

for scan = 1:var.main.nScan %load data for each of scans (to calculate for each of categories(face, scene))
    output_dir = [path.analysis.firstlevel '/main_SinQsSamDiff_0' num2str(scan) '.feat/stats'];
    %% single (pQ1~pQ4)
    for pQuad = 1:var.main.nCond_lower(upCond)%pQ1~pQ4
        xBetaMap = [output_dir '/zstat' num2str(pQuad) '_standard.nii'];
        if ~exist(xBetaMap)
            gunzip([xBetaMap '.gz']);
            fprintf('unzipping: %s\n', xBetaMap)
        end%if ~exist
        nii = load_untouch_nii(xBetaMap);
        xVol = nii.img;
        
        for roi = 1:length(recRois_name)-2%v1~v4
            for med = 1:2%1:low, 2:high bg val for each voxel
                for valType = 1:length(valIndx)%median-split by 1:rel, 2:irrel, 3:rel-irrel values
                    xIndx = bg_vox_corr{roi}{pQuad}{cate}(bg_vox_corr{roi}{pQuad}{cate}(:, valIndx(valType)) == med, tmpIndx.vdVoxIndx);
                    %                 act_sin_roi_pQuad_scan(roi, pQuad, scan) = mean(xVol(recROI{roi}{pQuad}(:,1)).*recROI{roi}{pQuad}(:,2));
                    act_sin_med_valType_roi_pQuad_scan{med}{valType}(roi, pQuad, scan) = mean(xVol(xIndx));
                end
            end%for med
        end%for roi
    end%for pQuad
    
    %% same & diff
    for sameDiff = 1:length(sameDiff_realIndx)
        xBetaMap = [output_dir '/zstat' num2str(sameDiff_realIndx(sameDiff)) '_standard.nii'];
        if ~exist(xBetaMap)
            gunzip([xBetaMap '.gz']);
            fprintf('unzipping: %s\n', xBetaMap)
        end%if ~exist
        nii = load_untouch_nii(xBetaMap);
        xVol = nii.img;
        for roi = 1:length(recRois_name)-2%v1~v4
            for med = 1:2%1:low, 2:high bg val for each voxel
                for valType = 1:length(valIndx)%median-split by 1:rel, 2:irrel, 3:rel-irrel values
                    xIndxCol = [];
                    for rQuad = 1:length(recROI{roi})%collapsing for all sub-regions' index, note that potential index overlap is ignored
                        tempIndx = bg_vox_corr{roi}{rQuad}{cate}(bg_vox_corr{roi}{rQuad}{cate}(:,valIndx(valType)) == med, tmpIndx.vdVoxIndx);
                        xIndxCol = [xIndxCol; tempIndx];%index, activation values
                    end%for rQuad
                    act_med_valType_roi_samDiff_scan{med}{valType}(roi, sameDiff, scan) = mean(xVol(xIndxCol(:,1)));
                end%for valType 
            end%for med
        end%for roi
    end%for sameDiff
end%for scan

%% averaging roi x upConditions (single, same, different)
for med = 1:2%1:low, 2:high bg val for each voxel
    for valType = 1:length(valIndx)%median-split by 1:rel, 2:irrel, 3:rel-irrel values
        meanAct_med_valType_roi_SinSamDiff{valType}(:,(med-1)*3+1) = mean(mean(act_sin_med_valType_roi_pQuad_scan{med}{valType},3),2);%sin,avrg scans -> avrg pQuads
        meanAct_med_valType_roi_SinSamDiff{valType}(:,(med-1)*3+2:(med-1)*3+3) = mean(act_med_valType_roi_samDiff_scan{med}{valType},3);%same and diff, avrg scans
    end%for valType
end%for med

%% save results
% [ST, I] = dbstack;
ST.name = 'main_visRes_bgcMedSplit';
output_dir = [path.neural_results '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/act_sin_med_valType_roi_pQuad_scan.mat'], 'act_sin_med_valType_roi_pQuad_scan');
save([output_dir '/act_med_valType_roi_samDiff_scan.mat'], 'act_med_valType_roi_samDiff_scan');
save([output_dir '/meanAct_med_valType_roi_SinSamDiff.mat'], 'meanAct_med_valType_roi_SinSamDiff');
