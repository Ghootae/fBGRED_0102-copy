% measuring voxel-level correlation b/w redundancy gain and background
% connectivity


function main_visRes_bgcVoxCorr(path)
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
load([output_dir '/bg_vox_corr.mat'], 'bg_vox_corr');%bg_vox_corr{roi}{pQuad}{cate}
load([output_dir '/bg_vox_corrIndx.mat'], 'bg_vox_corrIndx');

% bg_vox_corrIndx.rel = 1;
% bg_vox_corrIndx.irrel = 2;
% bg_vox_corrIndx.relIrrel = 3;
% bg_vox_corrIndx.medRel = 4;
% bg_vox_corrIndx.medIrrel = 5;
% bg_vox_corrIndx.medRelIrrel = 6;
% bg_vox_corrIndx.vdVoxIndx = 7;

tmpIndx = bg_vox_corrIndx;
valIndx = [tmpIndx.rel tmpIndx.irrel tmpIndx.relIrrel];%rel,irrel,rel-irrel
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
            xIndx = bg_vox_corr{roi}{pQuad}{cate}(:, tmpIndx.vdVoxIndx);
            for valType = 1:length(valIndx)%1:rel, 2:irrel, 3:rel-irrel values
                voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,valType) = bg_vox_corr{roi}{pQuad}{cate}(:,valIndx(valType));%bg index
                voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,length(valIndx)+1) = xVol(xIndx);%single act
            end%for valType
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
            for pQuad = 1:var.main.nCond_lower(upCond)%pQ1~pQ4
                xIndx = bg_vox_corr{roi}{pQuad}{cate}(:, tmpIndx.vdVoxIndx);
                voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,length(valIndx)+1+sameDiff) = xVol(xIndx);%single act
                
                if sameDiff == 2%if different
                    voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,7) = voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,5) - ...
                        voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,4);%same-single
                    voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,8) = voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,5) - ...
                        voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,6);%same-different
                end%if sameDiff
            end%for pQuad
        end%for roi
    end%for sameDiff
end%for scan

%% check redundancy gain
for roi = 1:length(recRois_name)-2%v1~v4
    for scan = 1:var.main.nScan %load data for each of scans (to calculate for each of categories(face, scene))
        for pQuad = 1:var.main.nCond_lower(upCond)%pQ1~pQ4
            redGainCheck{roi}((scan-1)*4+pQuad, :) = mean(voxAct_bg_sinSamDif{scan}{roi}{pQuad}(:,4:6));
        end%for pQuad
    end%for scan
end%for roi

%% measuring corr b/w BG and redundancy gain
for roi = 1:length(recRois_name)-2%v1~v4
    for scan = 1:var.main.nScan %load data for each of scans (to calculate for each of categories(face, scene))
        % concat
        tempCol = [];
        for pQuad = 1:var.main.nCond_lower(upCond)%pQ1~pQ4
            tempCol = [tempCol; voxAct_bg_sinSamDif{scan}{roi}{pQuad}];
        end%for pQuad
        % corr
        clear tempCorr
        for BGvalType = 1:length(valIndx)%1:rel, 2:irrel, 3:rel-irrel values (BG)
            for redType = 1:5%sin,sam,dif,sam-sin,sam-dif
                tempCorr(BGvalType, redType, scan) = corr(tempCol(:,BGvalType), tempCol(:,length(valIndx)+redType));
            end
        end%for BGvalTyp
    end%for scan
    corrBGRed{roi} = mean(tempCorr, 3);%avr across scans
end%for roi

%% save results
ST.name = 'main_visRes_bgcVoxCorr';
output_dir = [path.neural_results '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/voxAct_bg_sinSamDif.mat'], 'voxAct_bg_sinSamDif');
save([output_dir '/redGainCheck.mat'], 'redGainCheck');
save([output_dir '/corrBGRed.mat'], 'corrBGRed');
