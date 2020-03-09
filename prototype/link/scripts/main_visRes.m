% getting mean (z-scored) activation for each of single, same, different
%conditions


function main_visRes(path)
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
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%getting a zstat val for each condition
% note that single condition is calculated by each pQuad(pQ1~oQ4)
upCond = 1;%single
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
        for roi = 1:length(recRois_name)
            act_sin_roi_pQuad_scan(roi, pQuad, scan) = mean(xVol(recROI{roi}{pQuad}(:,1)).*recROI{roi}{pQuad}(:,2));
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
        for roi = 1:length(recRois_name)
            xIndxCol = [];
            for rQuad = 1:length(recROI{roi})%collapsing for all sub-regions' index, note that potential index overlap is ignored
                xIndxCol = [xIndxCol; recROI{roi}{rQuad}];%index, activation values
            end%for rQuad
            act_roi_samDiff_scan(roi, sameDiff, scan) = mean(xVol(xIndxCol(:,1)).*xIndxCol(:,2));
        end%for roi
    end%for sameDiff
end%for scan

%% averaging roi x upConditions (single, same, different)
meanAct_roi_SinSamDiff(:,1) = mean(mean(act_sin_roi_pQuad_scan,3),2);%sin,avrg scans -> avrg pQuads
meanAct_roi_SinSamDiff(:,2:3) = mean(act_roi_samDiff_scan,3);%same and diff, avrg scans

%% save results
% [ST, I] = dbstack;
ST.name = 'main_visRes';
output_dir = [path.neural_results '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/meanAct_roi_SinSamDiff.mat'], 'meanAct_roi_SinSamDiff');
% load([output_dir '/meanAct_roi_SinSamDiff.mat'], 'meanAct_roi_SinSamDiff');
