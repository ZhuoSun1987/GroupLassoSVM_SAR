function [ StdMap,MeanMap,NormalizedStdMap ] = StdOfMultipleWeightMap( WeightMapPathList,SaveFolder )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the Std map of multiple Weight map
%   
%   Zhuo Sun  2016-10-10


N=length(WeightMapPathList);
Nii=load_nii(WeightMapPathList{1});
WeightMap=squeeze(Nii.img);
ImSize=size(WeightMap);
VoxelNum=length(WeightMap(:));
Mat=zeros(N,VoxelNum);
for i=1:N
    Nii=load_nii(WeightMapPathList{i});
    WeightMap=squeeze(Nii.img);
    Mat(i,:)=WeightMap(:);
end

StdList=std(Mat);
MeanList=mean(Mat);
StdMap =reshape(StdMap,ImSize);
MeanMap=reshape(MeanList,ImSize);
NormalizedStdMap=StdMap./MeanMap;
NormalizedStdMap(StdMap==0)=0;

if nargin>1 & ~isempty(SaveFolder)
    if ~exist(SaveFolder,'dir')
        mkdir(SaveFolder)
    end
    
    Nii=make_nii(StdMap,[])
    save_nii(Nii,fullfile(SaveFolder,'StdMap.nii.gz'));
    Nii=make_nii(MeanMap,[])
    save_nii(Nii,fullfile(SaveFolder,'MeanMap.nii.gz'));
    Nii=make_nii(NormalizedStdMap,[])
    save_nii(Nii,fullfile(SaveFolder,'NormalizedStdMap.nii.gz'));
end


end

