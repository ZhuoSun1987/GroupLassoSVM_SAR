function [ PredScore,PredLabel ] = ZhuoLinearSVM_Pred(W,X,Thres)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if nargin<3
    Thres=0;
end
PredScore=X*W;
PredLabel=zeros(size(PredScore));
PredLabel(PredScore>=Thres)=1;
PredLabel(PredScore<Thres) =-1;

end

