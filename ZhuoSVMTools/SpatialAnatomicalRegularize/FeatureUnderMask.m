function [ FeatureVector ] = FeatureUnderMask( FeatureField,Mask )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to extract the feature vector from a feature
%   field under the mask
%
%   Mask should be a binary matrix
%
%   Zhuo Sun   20160613

FeatureField=squeeze(FeatureField);
Mask=squeeze(Mask);
FeatureField=FeatureField(:);
Mask=Mask(:);
if isequal(size(Mask),size(FeatureField))
    FeatureVector=FeatureField(Mask);
else
   error('the FeatureField and Mask should be the size size') 
    
end



end

