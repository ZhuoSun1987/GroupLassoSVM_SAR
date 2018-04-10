function [ WeightMap ] = SaveWeightMap( WeightVector, ROIMask )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to convert the vector Wegiht list size =[d,1]
%   into a image space, whose ROI mask has d nonzero points.
%
%   it is closely related to funciton  [ FeatVec ] = ExtractFeatVecFromVolume( FeatureField,Mask )
%
%
%   [ FeatVec ] = ExtractFeatVecFromVolume( FeatureField,Mask )
%   FeatureField=squeeze(FeatureField);
%   Mask        =squeeze(Mask);
% 
%   if ~isequal(size(FeatureField),size(Mask));
%       error('Two input should be equal size');
%   else
%       F_Line=FeatureField(:);
%       M_Line=Mask(:);
%       FeatVec=F_Line(M_Line==1);
%   end
%   end
%
%   Zhuo Sun  201606027


PointNum=sum(ROIMask(:)~=0);
d=length(WeightVector);
if PointNum~=d
    error('WeightVector and the mask do not match in size');
else
    WeightMapLinear=zeros(size(ROIMask(:)));
    WeightMapLinear(ROIMask(:)~=0)=WeightVector;
    WeightMap=reshape(WeightMapLinear,size(ROIMask));
end







end

