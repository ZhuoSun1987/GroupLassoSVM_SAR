function [ SelectResult,UseIndex ] = FeatureSelect_WeightAbsPercentile( W,FeatureTrain,FeatureTest,Percentile )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
%
%   this fucntion is used to make feature selection based on the W weight
%
%   Zhuo Sun  20160801

W=abs(W);

[n1,d1]=size(FeatureTrain);
[n2,d2]=size(FeatureTest);
[n3,d3]=size(W);

if d1==d2 && d2==d3
    PrecentileThres=prctile(W,100-Percentile);
    UseIndex=(W>=PrecentileThres);
    SelectResult.Train=FeatureTrain(:,UseIndex);
    SelectResult.Test =FeatureTest (:,UseIndex);
    
else
    error('Input size problem');
end

end

