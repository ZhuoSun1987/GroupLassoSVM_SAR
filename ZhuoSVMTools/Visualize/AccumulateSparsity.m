function [ Accumulate ] = AccumulateSparsity( WeightMapPathList,SavePath )
%UNTITLED17 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to accumulate the non-zeros terms
%
%   Zhuo Sun  20160904

Nii=load_nii(WeightMapPathList{1});
Im=squeeze(Nii.img);
Accumulate=zeros(size(Im));
ImNum=length(WeightMapPathList);
for i=1:ImNum
    Nii=load_nii(WeightMapPathList{i});
    Im=squeeze(Nii.img);
    Im=double(Im~=0);
    Accumulate=Accumulate+Im;
end

if nargin<2
    Nii=make_nii(Accumulate,[]);
    save_nii(Nii,SavePath);
end




end