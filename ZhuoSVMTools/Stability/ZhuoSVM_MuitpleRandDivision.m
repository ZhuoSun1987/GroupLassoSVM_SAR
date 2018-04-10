function [ WList ] = ZhuoSVM_MuitpleRandDivision( FeatureMatrix,LabelList,Lambda,SAAOption,SparseOpt,Nfold,Repeatable)
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
    %% make the divideing
    test_ind=rand_ind([floor((i-1)*N/Nfold)+1:floor(i*N/Nfold)]');
    train_ind = [1:N]';
    train_ind(test_ind) = [];
    TrainFeature=FeatureMatrix(train_ind,:);
    TrainYList  =LabelList(train_ind,:);
    TestFeature =FeatureMatrix(test_ind,:);
    TestYList   =LabelList(test_ind,:);
    %% doing the classification

    [PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrian,AUCTest,ModifyAcc,W]=LinearSVM_TrainTest(TrainFeature,TrainYList,TestFeature,TestYList,Lambda,SAAOption,SparseOpt); 
    WList{i}=W;
end
end

