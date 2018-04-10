function [ WList ] = ZhuoSVM_AddRandNoiseMultiTimes( FeatureMatrix,LabelList,NoiseLevel,Lambda,SAAOption,SparseOpt,Nfold,Repeatable)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%   this function is used to compute the SVM multiple times, while each
%   time change a few subjects, which is similar to the cross-validation
%
%   Zhuo Sun  20160906

if Repeatable==1
    rand('state',0); % reset random seed
end

N=size(FeatureMatrix,1);
rand_ind = randperm(N);
WList=cell(Nfold,1);

parfor i=1:Nfold
    [FeatureMatrixArray]=RandAddNoiseMultipleTimes(FeatureMatrix,NoiseLevel,1);
    %% doing the classification
    TrainFeature=FeatureMatrixArray{1};
    TrainYList=LabelList;
    %[PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrian,AUCTest,ModifyAcc,W]=LinearSVM_TrainTest(TrainFeature,TrainYList,TestFeature,TestYList,Lambda,SAAOption,SparseOpt); 
    [PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrian,AUCTest,ModifyAcc,W]=LinearSVM_TrainTest(TrainFeature,TrainYList,TrainFeature,TrainYList,Lambda,SAAOption,SparseOpt); 
    WList{i}=W;
end
end
