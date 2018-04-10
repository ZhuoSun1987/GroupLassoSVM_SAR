function [ NewFieldArray ] = ZscoreFieldArray( FieldArray )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
%
%   ZhuoSun


N=length(FieldArray);
FieldSize=size(squeeze(FieldArray{1}));
VoxelNum=prod(FieldSize);
MAT=zeros(N,VoxelNum);


for i=1:N
    Im=squeeze(FieldArray{i});
    Vec=Im(:);
    Mat(i,:)=Vec;
end


[Mat,Mu,Std]=zscore(Mat);

NewFieldArray=cell(N,1);

for i=1:N
    Vec=Mat(i,:);
    NewFieldArray{i}=reshape(Vec,FieldSize);
end

end

