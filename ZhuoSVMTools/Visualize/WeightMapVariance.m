function [ Std,Mean ] = WeightMapVariance( WeightMapPathList,Mask)
%UNTITLED18 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to compute the variance of weight map (of the
%   nonzeros components).
%
%   Zhuo Sun 20161004

MaskLine=Mask(:);
VoxelNum=sum(MaskLine~=0);
ImNum=length(WeightMapPathList);
Mat=nan*ones(ImNum,VoxelNum);

for i=1:ImNum
    Nii=load_nii(WeightMapPathList{i});
    WeightMap=squeeze(Nii.img);
    WeightLin=WeightMap(:);
    WeightList=WeightLin(MaskLine~=0);
    WeightList(WeightList==0)=nan;
    Mat(i,:)=WeightList;
end

Std =nanstd(Mat);
Mean=nanmean(Mat);



end
