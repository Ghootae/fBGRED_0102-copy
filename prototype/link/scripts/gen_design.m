%generating design for GLM
function gen_design(path)

%% load variables and design matrix
load([path.behavioralSetting '/var.mat']);
load([path.behavioralSetting '/param.mat']);
load([path.behavioralSetting '/time.mat']);
load([path.behavioralSetting '/key.mat']);
%%
load([path.behavioralDesign '/mainMat.mat']);
load([path.behavioralDesign '/mn.mat']);
% mn.blk = 1;
% mn.upCond = 2;
% mn.loCond = 3;
% mn.upCate = 4;
% mn.loCate = [5:8];%for diff cond, 4 images
% mn.imgID = [9:12];%for diff cond, 4 images
% mn.onset = 13;
% mn.catch = 14;
% mn.resp = 15;
% mn.rt = 16;
% mn.acc = 17;
mn.trialBlk = 18;


load([path.behavioralDesign '/BGMat'], 'BGMat');
load([path.behavioralDesign '/bg'], 'bg');
% bg.blk = 1;
% bg.quad = 2;
% bg.quadOrder = 3;
% bg.upCate = 4;
% bg.loCate = 5;
% bg.imgID = 6;
% bg.onset = 7;
% bg.resp = 8;
% bg.rt = 9;
% bg.acc = 10;
bg.trialBlk = 11;

load([path.behavioralDesign '/FSMat'], 'FSMat');
load([path.behavioralDesign '/fs'], 'fs');
% fs.blk = 1;
% fs.upCate = 2;
% fs.loCate = 3;
% fs.imgID = 4;
% fs.onset = 5;
% fs.resp = 6;
% fs.rt = 7;
% fs.acc = 8;
fs.trialBlk = 9;

load([path.behavioralDesign '/MRMat'], 'MRMat');
load([path.behavioralDesign '/mr'], 'mr');
% mr.blk = 1;
% mr.upCate = 2;
% mr.onset = 3;
% mr.catch = 4;
% mr.resp = 5;
% mr.rt = 6;
% mr.acc = 7;
mr.trialBlk = 8;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%open text file and write timing info

%% main
upCondList = {'single','same','diff'};
for scan = 1:var.main.nScan
    xData = mainMat{scan};
    for blk = 1:var.main.nBlk
        xData(mn.trialBlk, xData(mn.blk,:) == blk) = 1:var.main.nTrial_blk;
    end%for blk
    %%
    for upCond = 1:var.main.nCond_upper%sin,sam,dif
        if upCond == 1%if single, gen design for each quad
            % single collapsed
            logName_con = [path.design{1}{scan} '/' upCondList{upCond} '.txt'];
            logFid_con = fopen(logName_con, 'w');
            temp_onset = sort(xData(mn.onset, xData(mn.upCond,:) == upCond)) - time.main.disDaq;%note that disdaq was reflected
            %% sorting out data
            for tt = 1:length(temp_onset)
                xOnset = temp_onset(tt);
                fprintf(logFid_con, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.main.stimON), num2str(1));
            end%for trial
            fclose all;
            %% Q1~Q4
            for loCond = 1:var.main.nCond_lower(upCond)
                logName = [path.design{1}{scan} '/' upCondList{upCond} '_' var.main.cond{upCond}{loCond} '.txt'];
                logFid = fopen(logName, 'w');
                %% sorting out data
                for trial = 1:var.main.nTrial_blk
                    xOnset = xData(mn.onset, xData(mn.upCond,:) == upCond & ...
                        xData(mn.loCond,:) == loCond & xData(mn.trialBlk,:) == trial) - time.main.disDaq;%note that disdaq was reflected
                    fprintf(logFid, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.main.stimON), num2str(1));
                end%for trial
                fclose all;
            end%for loCond
        else%for same and diff, collapse all four blks
            logName = [path.design{1}{scan} '/' upCondList{upCond} '.txt'];
            logFid = fopen(logName, 'w');
            
            temp_onset = sort(xData(mn.onset, xData(mn.upCond,:) == upCond)) - time.main.disDaq;%note that disdaq was reflected
            
            %% sorting out data
            for tt = 1:length(temp_onset)
                xOnset = temp_onset(tt);
                fprintf(logFid, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.main.stimON), num2str(1));
            end%for trial
            fclose all;
        end%if upCond
    end%for upCond
end%for scan

%% BG-center & quad
cntQuadList = {'cnt', 'quad'};
for cntQuad = 1:length(cntQuadList)%center, quadrants
    for scan = 1:var.BG.nScan
        xData = BGMat{cntQuad}{scan};
        if cntQuad == 2
            %% by each quad
            for quad = 1:var.BG.nQuad
                logName = [path.design{5}{scan} '/' var.main.cond{1}{quad} '.txt'];
                logFid = fopen(logName, 'w');
                %% sorting out data
                temp_onset = sort(xData(bg.onset, xData(bg.quad,:) == quad)) - time.BG.disDaq;%note that disdaq was reflected
                for tt = 1:length(temp_onset)
                    xOnset = temp_onset(tt);
                    fprintf(logFid, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.BG.stimON), num2str(1));
                end%for trial
                fclose all;
            end%for quad
        end%if cntQuad
        
        %% w/o quad (just stim)
        if cntQuad == 2
            logName = [path.design{5}{scan} '/quadCol.txt'];
        else
            logName = [path.design{2}{scan} '/quadCol.txt'];
        end
        logFid = fopen(logName, 'w');
        %% sorting out data
        temp_onset = sort(xData(bg.onset, :)) - time.BG.disDaq;%note that disdaq was reflected
        for tt = 1:length(temp_onset)
            xOnset = temp_onset(tt);
            fprintf(logFid, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.BG.stimON), num2str(1));
        end%for trial
        fclose all;
    end%for scan
end%for cntQuad

%% FS
for scan = 1:var.FS.nScan
    xData = FSMat{scan};
    %%
    for upCate = 1:var.FS.nUpper
        logName = [path.design{3}{scan} '/' var.cate_upper{upCate} '.txt'];
        logFid = fopen(logName, 'w');
        %% sorting out data
        temp_onset = sort(xData(fs.onset, xData(fs.upCate,:) == upCate)) - time.FS.disDaq;%note that disdaq was reflected
        for tt = 1:length(temp_onset)
            xOnset = temp_onset(tt);
            fprintf(logFid, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.FS.stimON), num2str(1));
        end%for trial
        fclose all;
    end%for quad
    
    %% stim on irrespective of category (for BG analysis)
    logName = [path.design{3}{scan} '/stimOn.txt'];
    logFid = fopen(logName, 'w');
    %% sorting out data
    temp_onset = sort(xData(fs.onset, :)) - time.FS.disDaq;%note that disdaq was reflected
    for tt = 1:length(temp_onset)
        xOnset = temp_onset(tt);
        fprintf(logFid, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.FS.stimON), num2str(1));
    end%for trial
    fclose all;
end%for scan

%% MR
cateList = {'vertical', 'horizontal'};

for scan = 1:var.MR.nScan
    xData = MRMat{scan};
    %%
    for upCate = 1:var.MR.nUpper
        logName = [path.design{4}{scan} '/' cateList{upCate} '.txt'];
        logFid = fopen(logName, 'w');
        %% sorting out data
        temp_onset = sort(xData(mr.onset, xData(mr.upCate,:) == upCate)) - time.MR.disDaq;%note that disdaq was reflected
        for tt = 1:length(temp_onset)
            xOnset = temp_onset(tt);
            fprintf(logFid, '%s\t %s\t %s\n', num2str(xOnset), num2str(time.MR.ISI), num2str(1));
        end%for trial
        fclose all;
    end%for quad
end%for scan