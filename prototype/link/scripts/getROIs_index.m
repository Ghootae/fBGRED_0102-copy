% getting each ROI's index (based on the standard space)

function getROIs_index(path)
%%
addpath('~/fMRI_analysis/packages/NIfTI_20140122/')
%% load variables and design matrix
load([path.behavioralSetting '/var.mat']);
load([path.behavioralSetting '/param.mat']);
load([path.behavioralSetting '/time.mat']);
load([path.behavioralSetting '/key.mat']);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%roi name info
seedsROIs_name = {'ffa','ppa'};

recRois_name{1} = {'l_V1v','r_V1v', 'r_V1d', 'l_V1d'};%{roi}{pQuad for single}
recRois_name{2} = {'l_V2v','r_V2v', 'r_V2d', 'l_V2d'};
recRois_name{3} = {'l_V3v','r_V3v', 'r_V3d', 'l_V3d'};
recRois_name{4} = {'l_hV4','r_hV4', 'r_hV4', 'l_hV4'};
recRois_name{5} = {'ffa','ffa', 'ffa', 'ffa'};
recRois_name{6} = {'ppa','ppa', 'ppa', 'ppa'};

save([path.rois '/seedsROIs_name.mat'], 'seedsROIs_name');
save([path.rois '/recRois_name.mat'], 'recRois_name');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% extracting roi index
if ~exist([path.rois '/seedROI.mat'])
    % seeds
    for roi = 1:length(seedsROIs_name)
        xROI = [path.analysis.secondlevel '/FS.gfeat/' seedsROIs_name{roi} 'Sphere_gauss.nii'];
        if ~exist(xROI)
            gunzip([xROI '.gz']);
        end%if ~exist
        nii = load_untouch_nii(xROI);
        seedROI{roi}(:,1) = find(nii.img > 0);%index, greater than 0
        seedROI{roi}(:,2) = nii.img(seedROI{roi}(:,1));%value of each index
    end%for roi
    
    %recipients
    for roi = 1:length(recRois_name)
        for pQuad = 1:length(recRois_name{roi})%presentation quadrant(pQ1, pQ2...)
            if roi <= 4%v1~v4, common
                xROI = [path.standardROIs '/' recRois_name{roi}{pQuad} '_2mm.nii'];
            else
                xROI = [path.analysis.secondlevel '/FS.gfeat/' recRois_name{roi}{pQuad} 'Sphere_gauss.nii'];
            end
                
            if ~exist(xROI)
                gunzip([xROI '.gz']);
            end%if ~exist
            nii = load_untouch_nii(xROI);
            recROI{roi}{pQuad}(:,1) = find(nii.img > 0);%index, greater than 0
            recROI{roi}{pQuad}(:,2) = nii.img(recROI{roi}{pQuad}(:,1));%value of each index
        end%for quad
    end%for roi
    
    % collapsing left + right
    for roi = 1:length(recRois_name)-2%v1~v4, no ffa and ppa
        for ventDor = 1:2%1:ventral, 2:dorsal
            recROI_ventDor{roi}{ventDor} = unique([recROI{roi}{(ventDor-1)*2+1}(:,1); recROI{roi}{ventDor*2}(:,1)]);
        end%for ventDor
    end%for roi
    
    save([path.rois '/seedROI.mat'], 'seedROI');
    save([path.rois '/recROI.mat'], 'recROI');
    save([path.rois '/recROI_ventDor.mat'], 'recROI_ventDor');
end%if ~exist
