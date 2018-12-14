function score = ENIQA(img)
% The input parameter img could be the image object or the path string
if ischar(img)
	img = imread(img);
end

load('model/models')	% Load the models pretrained on LIVE

scale = 2;
feature = featureExtract56(img, scale);
score = predict(feature, svrmodels, svcmodel);


