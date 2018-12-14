%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test on TID2013
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc, clear all;

% The location of your database
src = '/media/yang/0001DB8C00052535/mengxiting/database/TID2013/';

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
load('data/ENIQA_features_56_w8_on_TID2013', 'features');

for i = 1:n
    % Extract features in 2 scales
    file_name_cur = file_names_sel{i};
    disp(['Current Image: ', file_name_cur]);
    img_cur = imread([src, 'distorted_images/', file_name_cur]);
    % If you want to perform feature extraction on TID2013, uncomment this line
    % features(i,:) = featureExtract56(img_cur, 2);
    scores(i) = predict(features(i,:), svrmodels, svcmodel);
end

%% Scatter plot
figure;
plot(scores,mos_sel,'+b');
hold on;

beta(1) = max(mos_sel);
beta(2) = min(mos_sel);
beta(3) = mean(scores);
beta(4) = 0.1;
beta(5) = 0.1;
logistic = @(beta,x)(beta(1)*(1/2-1./(1+exp(beta(2)*(x-beta(3)))))+beta(4)*x+beta(5));
[bayta, ehat,J] = nlinfit(scores,mos_sel,logistic,beta);
[ypre , ~] = nlpredci(logistic,scores,bayta,ehat,J);

cc=abs(corrcoef(ypre,mos_sel));
CC=cc(1,2);
SROCC = abs(corr( mos_sel, scores, 'type', 'spearman'));
PLCC = corr(mos_sel, ypre, 'type','Pearson');	% pearson linear coefficient
KROCC = abs(corr(mos_sel, scores, 'type', 'kendall'));
RMSE = sqrt(mean((ypre - mos_sel).^2));	% root mean squared error
MAE=mean(abs(ypre-mos_sel));

t = min(scores):0.01:max(scores);
[ypre, junk] = nlpredci(logistic,t,bayta,ehat,J);
p=plot(t,ypre);   
set(p,'Color','black','LineWidth',2);
legend('Images in TID2013','Curve fitted with logistic function', 'Location','SouthWest');
xlabel('Objective score by ENIQA');
ylabel('MOS');
hold off;
