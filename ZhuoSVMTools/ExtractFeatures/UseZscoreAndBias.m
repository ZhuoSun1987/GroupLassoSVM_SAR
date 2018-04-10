function [ NewTrainX,NewTestX ] = UseZscoreAndBias( TrainX,TestX,UseBias,UseZscore )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   This function is used to make the zscore normalization (if UseZscore=1)
%   or add bias term (UseBias=1)
%
%   Zhuo Sun  20160704

NTrain=size(TrainX,1);
NTest =size(TestX,1);

if UseZscore==1
    [ NewTrainX,NewTestX  ] = ZscoreNormalizeFeature( TrainX, TestX );
else
    NewTrainX=TrainX;
    NewTestX =TestX;
    
end


if UseBias==1
    NewTrainX=[NewTrainX,ones(NTrain,1)];
    NewTestX =[NewTestX ,ones(NTest ,1)];
else
    NewTrainX=[NewTrainX,zeros(NTrain,1)];
    NewTestX =[NewTestX ,zeros(NTest ,1)];
    
end


end

