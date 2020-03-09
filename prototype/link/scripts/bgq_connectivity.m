%measuring BG-conn b/w seeds(FFA, PPA) and recipients(V1~V4) for
%bg-quadrant

function bgq_connectivity(path)
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

load([path.rois '/seedROI.mat'], 'seedROI');%seedROI{roi}; 1:ffa, 2:ppa
load([path.rois '/recROI.mat'], 'recROI');%by quadrants, recROI{roi}{pQuad}, roi:v1~v4,ffa,ppa, pquad:q1~q4
load([path.rois '/recROI_ventDor.mat'], 'recROI_ventDor');%by ventral and dorsal(left+right), recROI_ventDor{roi}{ventDor}, roi:v1~v4,ffa,ppa, ventDor: left, right
%% design matrix & timing info (into vol #)
load([path.behavioralDesign '/BGMat'], 'BGMat');
load([path.behavioralDesign '/bg'], 'bg');
% bg.blk = 1;
% bg.quad = 2;
% bg.quadOrder = 3;
% bg.upCate = 4;
% bg.loCate = 5;%no meaning
% bg.catch = 5;%!!!
% bg.imgID = 6;
% bg.imgID_dist = 7;%for face run, scene images
% bg.onset = 8;
% bg.resp = 9;
% bg.rt = 10;
% bg.acc = 11;
for scan = 1:var.BG.nScan%note that this scan number is 1~4
    xMat = BGMat{2}{scan};%center
    upCateInfo(scan) = unique(xMat(bg.upCate,:));
    
    for quad = 1:var.BG.nQuad%by quadrants!!!
        tempOnset = xMat(bg.onset, xMat(bg.quad, :) == quad);
        volInfo{scan}{quad} = (tempOnset-time.BG.disDaq)/time.TR + 1;%into vol #
    end%for quad
end%for scan
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%load residual (aligned to the standard) pat
for cate = 1:var.BG.nUpper%task category, 1:face, 2:scene
    xCateScans = find(upCateInfo == cate);%scans of this category
    
    for scan = 1:length(xCateScans)%order of each cagegory (e.g., first and second runs of face)
        xScan = xCateScans(scan);
        xRes = [path.analysis.firstlevel '/bgq_0' num2str(xScan) '.feat/stats/res4d2standard.nii'];
        if ~exist(xRes)
            gunzip([xRes '.gz']);
        end%if ~exist
        nii = load_untouch_nii(xRes);
        resPat = nii.img;
        
        for vol = 1:size(resPat,4)
            xVol = resPat(:,:,:,vol);
            % seeds pat
            for roi = 1:length(seedsROIs_name)%1:ffa, 2:ppa
                seedResPat{cate}{scan}{roi}(:,vol) = xVol(seedROI{roi}(:,1)).*seedROI{roi}(:,2);%weighted
                seedResAct{cate}{scan}(roi,vol) = mean(seedResPat{cate}{scan}{roi}(:,vol));%mean
            end%for roi
            
            %% recipient pat
            % each quad
            for roi = 1:length(recRois_name)-2%v1~v4, no ffa and ppa
                for quad = 1:length(recRois_name{roi})
                    recResPat{cate}{scan}{roi}{quad}(:,vol) = xVol(recROI{roi}{quad}(:,1));
                    recResAct{cate}{scan}{roi}(quad,vol) = mean(recResPat{cate}{scan}{roi}{quad}(:,vol));%mean
                end%for quad
            end%for roi
            
            % collapsing left + right
            for roi = 1:length(recRois_name)-2%v1~v4, no ffa and ppa
                for ventDor = 1:2%1:ventral, 2:dorsal
                    recResPat_vd{cate}{scan}{roi}{ventDor}(:,vol) = xVol(recROI_ventDor{roi}{ventDor});
                    recResAct_vd{cate}{scan}{roi}(ventDor,vol) = mean(recResPat_vd{cate}{scan}{roi}{ventDor}(:,vol));%mean
                end%for ventDor
            end%for roi
        end%for vol
    end%for scan
end%for cate

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%measuring BG corr - {recipient roi: e.g, ventral V1}{ventral or dordal}, seedROIs x category
for cate = 1:var.BG.nUpper%task category, 1:face, 2:scene
    xCateScans = find(upCateInfo == cate);%scans of this category(e.g., first and second runs of face)
    
    for recRoi = 1:length(recRois_name)-2%v1~v4, no ffa and ppa
        for quad = 1:length(recRois_name{roi})
            %% recRoi by seedRoi background connectivity 
            %stim blocks (z-scoring within each run)
            recAct = [zscore(recResAct{cate}{1}{recRoi}(quad,volInfo{xCateScans(1)}{quad}))...
                zscore(recResAct_vd{cate}{2}{recRoi}(ventDor,volInfo{xCateScans(2)}{quad}))];%collapsing first and second runs
           
            
            for seedRoi = 1:length(seedsROIs_name)
                %stim blocks(z-scoring within each run)
                seedAct = [zscore(seedResAct{cate}{1}(seedRoi,volInfo{xCateScans(1)}{quad}))...
                    zscore(seedResAct{cate}{2}(seedRoi,volInfo{xCateScans(2)}{quad}))];%collapsing first and second runs
                
                bgCorr_quad{recRoi}(seedRoi, cate, quad) = corr(recAct', seedAct');
            end%for seedRoi
        end%for quad
    end%for recRoi
end%for cate

%collapsing across quadrants
for recRoi = 1:length(recRois_name)-2%v1~v4, no ffa and ppa
    bgCorr_quadCol{recRoi}  = mean(bgCorr_quad{recRoi}, 3);%averaging across quadrants
end%for recRoi

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%deviding high and low BG voxels (note that the division is based on each quadrant)
for cate = 1:var.BG.nUpper%1:face, 2:scene
    xCateScans = find(upCateInfo == cate);%scans of this category(e.g., first and second runs of face)
    
    for recRoi = 1:length(recRois_name)-2%v1~v4, no ffa and ppa
        for quad = 1:length(recRois_name{roi})%for each quadrant!!!
            %% recVox by seedRoi background connectivity and marking median-split index (stim blk only)
            recPat = [zscore(recResPat{cate}{1}{recRoi}{quad}(:,volInfo{xCateScans(1)}{quad}),0,2)...
                zscore(recResPat{cate}{2}{recRoi}{quad}(:,volInfo{xCateScans(2)}{quad}),0,2)];%collapsing first and second runs, nVox x time
            
            
            seedAct_rel = [zscore(seedResAct{cate}{1}(cate,volInfo{xCateScans(1)}{quad}))...
                zscore(seedResAct{cate}{2}(cate,volInfo{xCateScans(2)}{quad}))];%e.g., ffa acts for face runs
            seedAct_irrel = [zscore(seedResAct{cate}{1}(2/cate,volInfo{xCateScans(1)}{quad}))...
                zscore(seedResAct{cate}{2}(2/cate,volInfo{xCateScans(2)}{quad}))];%e.g., ppa acts for face runs
            
            deletedVoxIndx = [];%finding zero voxels (probably edge voxels), and erase them later!
            for vox = 1:size(recPat,1)
                if sum(recPat(vox,:) == 0) > 5
                    deletedVoxIndx = [deletedVoxIndx vox];%if zero point is greater than 5, record them to delete later
                end
                bg_vox_corr{recRoi}{quad}{cate}(vox,1) = corr(recPat(vox,:)', seedAct_rel');%with relevant roi
                bg_vox_corr{recRoi}{quad}{cate}(vox,2) = corr(recPat(vox,:)', seedAct_irrel');%with irrelevant roi
                bg_vox_corr{recRoi}{quad}{cate}(vox,3) = bg_vox_corr{recRoi}{quad}{cate}(vox,1) ...
                    - bg_vox_corr{recRoi}{quad}{cate}(vox,2);%rel-irrel
            end%for vox
            bg_vox_corr{recRoi}{quad}{cate}(:,7) = recROI{recRoi}{quad}(:,1);%voxel index
            
            %delete zero voxels
            bg_vox_corr{recRoi}{quad}{cate}(deletedVoxIndx,:) = [];
            
            % median-split index
            for val = 1:3%rel,irrel,rel-irrel
                xVal = bg_vox_corr{recRoi}{quad}{cate}(:,val);
                bg_vox_corr{recRoi}{quad}{cate}(xVal < median(xVal), 3+val) = 1;%low
                bg_vox_corr{recRoi}{quad}{cate}(xVal >= median(xVal), 3+val) = 2;%high
            end%for val
%             bg_vox_corr{recRoi}{quad}{cate}(:,7) = recROI{recRoi}{quad}(:,1);%voxel index
            
            %1:corr with rel seedROI(e.g., for face run, corr with FFA),
            %2:corr with irrel seedROI(e.g., for face run, corr with PPA),
            %3:rel-irrel
            %4:medIndx based on rel
            %5:medIndx based on irrel
            %6:medIndx based on rel-irrel
            %7:voxel index
        end%for ventDor
    end%for recRoi
end%for cate
%% save results
% [ST, I] = dbstack;
ST.name = 'bgq_connectivity';
output_dir = [path.neural_results '/' ST.name];
if ~exist(output_dir)
    mkdir(output_dir)
end
save([output_dir '/volInfo.mat'], 'volInfo');
save([output_dir '/volInfo_rest.mat'], 'seedResPat');

save([output_dir '/seedResPat.mat'], 'seedResPat');
save([output_dir '/seedResAct.mat'], 'seedResAct');

save([output_dir '/recResPat.mat'], 'recResPat');
save([output_dir '/recResAct.mat'], 'recResAct');

save([output_dir '/recResPat_vd.mat'], 'recResPat_vd');
save([output_dir '/recResAct_vd.mat'], 'recResAct_vd');

save([output_dir '/bgCorr_quad.mat'], 'bgCorr_quad');
save([output_dir '/bgCorr_quadCol.mat'], 'bgCorr_quadCol');

save([output_dir '/bg_vox_corr.mat'], 'bg_vox_corr');

bg_vox_corrIndx.rel = 1;
bg_vox_corrIndx.irrel = 2;
bg_vox_corrIndx.relIrrel = 3;
bg_vox_corrIndx.medRel = 4;
bg_vox_corrIndx.medIrrel = 5;
bg_vox_corrIndx.medRelIrrel = 6;
bg_vox_corrIndx.vdVoxIndx = 7;
save([output_dir '/bg_vox_corrIndx.mat'], 'bg_vox_corrIndx');
