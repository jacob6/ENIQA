%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Train and test on LIVE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
warning off;

% Directory of the database
% Change it to your own
src = '/media/yang/0001DB8C00052535/mengxiting/database/LIVE2016/databaserelease2/';

ranges = [{1:227}; {228:460}; {461:634}; {635:808}; {809:982}];
dirs = {'jp2k/'; 'jpeg/'; 'wn/'; 'gblur/'; 'fastfading/'};
name_imgs = {'bikes.bmp'; 'building2.bmp'; 'buildings.bmp'; 'caps.bmp'
    'carnivaldolls.bmp'; 'cemetry.bmp'; 'churchandcapitol.bmp' ;
    'coinsinfountain.bmp'; 'dancers.bmp'; 'flowersonih35.bmp';
    'house.bmp'; 'lighthouse.bmp'; 'lighthouse2.bmp'; 'manfishing.bmp';
    'monarch.bmp'; 'ocean.bmp'; 'paintedhouse.bmp'; 'parrots.bmp';
    'plane.bmp'; 'rapids.bmp'; 'sailing1.bmp'; 'sailing2.bmp'; 'sailing3.bmp';
    'sailing4.bmp'; 'statue.bmp'; 'stream.bmp'; 'studentsculpture.bmp';
    'woman.bmp'; 'womanhat.bmp'};

load([src 'dmos']);
features = zeros(982, 56);

N = 1000;   % The number of epochs

SEL_PER = 80/100;   % The percentage of training set

fcn_norm = @(a) a./max(dmos); % Scaling function for training set
fcn_denorm = @(a) a.*max(dmos);    % Denormalization

dmos = feval(fcn_norm, dmos(:));

n_dis = length(dirs);   % The number of distortion types

svrmodels = cell(N,n_dis);
svcmodels = cell(N,1);

SROCCs = zeros(N, n_dis+1);
PLCCs = zeros(N, n_dis+1);
RMSEs = zeros(N, n_dis+1);

pred_acc = zeros(n_dis, n_dis, N);

%% Extract features
for i = 1:n_dis
    k_range = ranges{i};
    img_dir = [src, dirs{i}];
    features(ranges{i},:) = featureExtract(k_range, img_dir);
end
% The feature extraction might take long, 
% thus, you could save the features for next time use
% save('data/ENIQA_features_56_w8_on_LIVE', 'features');
% load('data/ENIQA_features_56_w8_on_LIVE', 'features')

disp('Features extracted')

%% Train and test for N epochs
% Generate a combination list for selection
n_imgs = length(name_imgs);
n_imgs_sel = round(n_imgs*SEL_PER);
% COMs = nchoosek(1:n_imgs,n_imgs_sel);
load('data/COMs')
len = size(COMs,1);

for n = 1:N
    disp(['Epoch ', num2str(n)])
    
    %% Split the data sets for cross validation
    feature_train = cell(n_dis,1);
    label_train = cell(n_dis,1);
    feature_test = cell(n_dis,1);
    label_test = cell(n_dis,1);
    
    sel = name_imgs(COMs(randi(len),:));
    
    for i = 1:n_dis
        range_cur = ranges{i};
        dmos_cur = dmos(range_cur);
        features_cur = features(range_cur,:);
        
        % Open the info file and read image names
        fid = fopen([src, dirs{i}, 'info.txt']);
        FC = textscan(fid,'%s%s%f');
        fclose(fid);
        name_imgs_cur = FC{1};
        lia = ismember(name_imgs_cur, sel);
        
        % Save the selected features and labels
        feature_train{i} = features_cur(lia,:);
        label_train{i} = dmos_cur(lia);
        feature_test{i} = features_cur(~lia,:);
        label_test{i} = dmos_cur(~lia);
    end
    
    %     disp('Datasets split')
    
    %% Cross validation
    % Convert the training and testing datasets into matrices
    x_train = cell2mat(feature_train);
    y_train = cell2mat(label_train);
    x_test = cell2mat(feature_test);
    y_test = cell2mat(label_test);
    
    % Generate the labels for classification
    label_train_svc = cell2mat([arrayfun(@(i) i*ones(size(label_train{i})), 1:n_dis, 'UniformOutput', false)]');
    len_test = cellfun(@length, label_test);
    incr_acc = 1./len_test;
    
    for i = 1:n_dis
        svrmodel = svmtrain(label_train{i}, feature_train{i}, '-s 4 -q');
        svrmodels{n,i} = svrmodel;
    end
    svcmodel = svmtrain(label_train_svc, x_train, '-s 0 -b 1 -q -c 1e4 -g 1e-4');
    svcmodels{n} = svcmodel;
    
    scores = cell(n_dis,1);
    for i = 1:n_dis
        score = zeros(len_test(i),1);
        for j = 1:len_test(i)
            [score(j), pred_class] = predict(feature_test{i}(j,:), svrmodels(n,:), svcmodel);
            pred_acc(i, pred_class, n) = pred_acc(i, pred_class, n) + incr_acc(i);
        end
        scores{i} = score;
        [SROCCs(n,i), PLCCs(n,i), RMSEs(n,i)] = evaluate(label_test{i}, score);
        clear score;
    end
    
    score_all = cell2mat(scores);
    [SROCCs(n,end), PLCCs(n,end), RMSEs(n,end)] = evaluate(y_test, score_all);

end

%% Calculate medians
RMSEs = feval(fcn_denorm, RMSEs);

SROCC_all_mid = median(SROCCs(:,n_dis+1));
[~, idx] = min(abs(SROCCs(:,n_dis+1) - SROCC_all_mid));
SROCC_mid = median(SROCCs);
PLCC_mid = median(PLCCs);
RMSE_mid = median(RMSEs);

pred_acc_mid = pred_acc(:,:,idx);
pred_acc_type_mid = diag(pred_acc_mid);
pred_acc_all_mid = mean(pred_acc_type_mid);

svcmodel_sel = svcmodels{idx};
svrmodel_sel = svrmodels(idx,:);

% Uncomment this if you want to save the best result
% save('model/best_models', 'svcmodel_sel', 'svrmodel_sel')
