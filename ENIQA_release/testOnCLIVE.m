%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test on CLIVE
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc, clear all;

% The location of your database
src = 'E:/lmh/Live In the Wild Image Quality Challenge Database/ChallengeDB_release/ChallengeDB_release/';
imgDir = [src, '/Images/'];

tmp = load(fullfile(src, 'Data/AllImages_release'));
fileNames = tmp.AllImages_release;
tmp = load(fullfile(src, 'Data/AllMOS_release'));
mos = tmp.AllMOS_release';
clear tmp;
load('model/models')

n = length(fileNames);
scores = zeros(n, 1);

%% Feature extraction
% load('data/ENIQA_features_56_w8_on_CLIVE', 'features');
features = zeros(n, 56);
parfor i = 1:n
    % Extract features in 2 scales
    curFileName = fileNames{i};
    disp(['Current Image: ', curFileName]);
    try
        curImg = imread(fullfile(imgDir, curFileName));
    catch
        curImg = imread(fullfile(imgDir, '/trainingImages', curFileName));
    end
    features(i,:) = featureExtract56(curImg, 2);
end
save('data/ENIQA_features_56_w8_on_CLIVE', 'features');

for i = 1:n
    scores(i) = predict(features(i,:), svrmodels, svcmodel);
end

%% Scatter plot
[SROCC, PLCC, RMSE] = evaluate(mos, scores)

drawScatter(mos_sel, scores, 'Objective score by ENIQA', 'MOS', 'CLIVE');
