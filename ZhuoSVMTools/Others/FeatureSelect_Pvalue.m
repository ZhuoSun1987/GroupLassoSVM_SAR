
function [ ThresholdFeature,RatioRankFeature,UseIndex ] = FeatureSelect_Pvalue( TtestScore,TrainFeature,TestFeature,Threshold,Ratio )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to make feature selection based the p-value
%   (TtestScore), TrainFeature size is [n1,d], TestFeature size is [n2,d],
%   TtestScore size is [1,d];
%   
%
%   Zhuo Sun  20160801

ThresholdFeature=[];
RatioRankFeature=[];

[n1,d1]=size(TrainFeature);
[n2,d2]=size(TestFeature);
[n3,d3]=size(TtestScore);

if d1==d2 & d2==d3
   if ~isempty(Threshold)
       UseIndex=(TtestScore<=Threshold);
       ThresholdFeature.Train=TrainFeature(:,UseIndex);
       ThresholdFeature.Test =TestFeature (:,UseIndex); 
   end
   
   if ~isempty(Ratio)
       Percentile = prctile(TtestScore,Ratio)
       UseIndex=(TtestScore<=Percentile);
       RatioRankFeature.Train=TrainFeature(:,UseIndex);
       RatioRankFeature.Test =TestFeature (:,UseIndex); 
   end 
   
    
else
    error('The size of input are not match')
end




end

