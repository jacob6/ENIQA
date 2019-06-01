%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test on TID2013
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc, clear all;

% The location of your database
src = 'E:/mengxiting/database/TID2013/';

n_dis = 5;
load('model/models')

fid = fopen([src, 'mos_with_names.txt']);
FC = textscan(fid, '%f%s');
[mos, file_names] = deal(FC{:});
fclose(fid);

% Select 1 8 10 11 distortion types
% namely noise gblur jp2k and jpeg
logic_sel = cellfun(@(x) ~isempty(x), regexp(file_names, '[i I](2?)(?(1)[^5]|[0 1]\d)_(0?)(?(3)[1 8]|1{1}[0 1])'));
file_names_sel = file_names(logic_sel);
mos_sel = mos(logic_sel);

n = length(file_names_sel);
features = zeros(n, 56);
scores = zeros(n, 1);

% We have extracted the features on TID2013
% cuz it is really time consuming
% If you want to perform feature extraction on TID2013,
% uncomment this for-loop

% disp('Extracting features...');
% for i = 1:n
%     file_name_cur = file_names_sel{i};
%     disp(['Current Image: ', file_name_cur]);
%     img_cur = imread([src, 'distorted_images/', file_name_cur]);
%     features(i,:) = featureExtract56(img_cur, 2);
% end
% save('data/ENIQA_features_56_w8_on_TID2013', 'features');

load('data/ENIQA_features_56_w8_on_TID2013', 'features');
disp('Predicting scores...');
for i = 1:n
    file_name_cur = file_names_sel{i};
    disp(['Current Image: ', file_name_cur]);
    scores(i) = predict(features(i,:), svrmodels, svcmodel);
end

%% Scatter plot
[SROCC, PLCC, RMSE] = evaluate(mos_sel, scores)

drawScatter(mos_sel, scores, 'Objective score by ENIQA', 'MOS', 'TID2013');
