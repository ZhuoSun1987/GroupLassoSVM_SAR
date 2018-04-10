function [ TtestScore ] = TtestFeatureScore( TrainFeatureMat,YList)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the t-test score for each feature,
%   based on two sample t-test.
%
%   TrainFeatureMat -> size=[n1,d];
%   TestFeatureMat  -> size=[n2,d];
%
%   YList => size=[n1,1], only -1 and 1.
%   
%   Output  TtestScore => size=[1,d];
%
%   Zhuo Sun  20160801


[n,d]=size(TrainFeatureMat);
YLabels=unique(YList);

X1=TrainFeatureMat(YList==1,:);
X2=TrainFeatureMat(YList==-1,:);

if ~isequal(YLabels,[-1;1])
    error('YList should only contains 1 and -1')
else
    [h,p,ci,stats] = ttest2(X1,X2,0.05,'both' );
    TtestScore=p;
end










end

