function [ Acc,AUC,ModifyAcc,UserDefThresAcc ] = PredictPerform_LinearSVM_Zhuo( W,Feature,Label,Thres )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   size(Feature)=[n,d+1];
%   size(W)=[d+1,1];
%   size(Label)=[n,1];
%   Thres, default is 0
%
%   Zhuo Sun   20160621

if nargin<4 | isempty(Thres)
    Thres=0;
end

Scores=Feature*W;

PredLabel=2*(Scores>=0)-1;

Acc=sum(PredLabel==Label)/length(PredLabel);

[X,Y,T,AUC,OPTROCPT,SUBY,SUBYNAMES]= perfcurve(Label,Scores,1);

ModifyPredLabel=2*(Scores>=OPTROCPT(1))-1;
ModifyAcc=sum(ModifyPredLabel==Label)/length(PredLabel);

UserDefThresAcc=sum(2*(Scores>=Thres)-1==Label)/length(PredLabel);
end

