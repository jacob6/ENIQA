# ENIQA: Entropy-based No-reference Image Quality Assessment

## Authors

## Experiments

All experiments are carried out on Matlab R2016a on 64-bit Windows 7 and the detailed
results are given in the paper. The codes are also testified on Ubuntu 16.04 with
Matlab R2016b and work well.

Two IQA datasets, [LIVE](http://live.ece.utexas.edu/research/quality/subjective.htm) and
[TID2013](http://www.ponomarenko.info/tid2013.htm), are used in out experiments.

This table shows the good performance of ENIQA compared with several classical NR and FR
IQA methods

## Usage

For evaluating, we provide two ways:
You can first load the image and then calculate the score by

```MATLAB
img = imread(img_path);
score = ENIQA(img);
```

or simply input the path of the image

```MATLAB
score = ENIQA(img_path);
```

For training a new model on LIVE, try `crossValidationOnLIVE`

For cross-database evaluation, try `testOnTID2013`

To do this, you have to prepare a model pretrained on another dataset.

## Pretrained models

We have trained a model on the whole LIVE dataset and you can find it on ENIQA_release/model.

## Dependencies

libSVM, explicitly the mex files, is required to perform the classification and regression.
You can download it from [here](https://www.csie.ntu.edu.tw/~cjlin/libsvm/).
