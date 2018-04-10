function [ FeatVec ] = ExtractFeatVecFromVolume( FeatureField,Mask )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to extract feature vector under the mask
%
%   Zhuo Sun  20160619


FeatureField=squeeze(FeatureField);
Mask        =squeeze(Mask);

if ~isequal(size(FeatureField),size(Mask));
    error('Two input should be equal size');
else
    F_Line=FeatureField(:);
    M_Line=Mask(:);
    FeatVec=F_Line(M_Line==1);
end




end

