function [ Cost,StdList,StdMap,MeanList,MeanMap, NormalizedStd,NormalizedStdMap] = GraphNodeMeanStdMap( Pairs,Mask,WeighMap,SaveFolder )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
%
%   Pairs is a P*2 matrix, P is the number of undirected pairs
%
%   Mask is used to extract the features and map the weight to the image
%   space. It is a binary image
%
%   


MaskLine=Mask(:)>0;
WeighMapLine=WeighMap(:);
WeightList=WeighMapLine(MaskLine);
WeightListCol=reshape(WeightList,[length(WeightList),1]);
VariableNum=length(WeightList);

Pairs1=[Pairs,[Pairs(:,2),Pairs(:,1)];repmat(reshape(1:VariableNum,[VariableNum,1]),[1,2])];

Weight1=WeightListCol(Pairs1(:,1));
Weight2=WeightListCol(Pairs1(:,2));

WeightArray=cell(VariableNum,1);
StdList=zeros(VariableNum,1);
MeanList=zeros(VariableNum,1);
NormalizedStd=zeros(VariableNum,1);

Cost=sum((Weight1-Weight2).^2);

for i=1:VariableNum
    Ind=find(Pairs1(:,1)==i);
    WLocal=WeightList(Ind,2);
    WeightArray{i}=WLocal;
    StdList(i)=std(WLocal);
    MeanList(i)=mean(WLocal);
    if StdList(i)>0
        NormalizedStd(i)=StdList(i)/WeightList(i);
    else
        NormalizedStd(i)=0;
    end    
end

StdMap          =ListToMap(StdList,Mask);
MeanMap         =ListToMap(StdList,Mask);
NormalizedStdMap=ListToMap(NormalizedStd,Mask);

if nargin>3 & ~isempty(SaveFolder)
    if ~exist(SaveFolder,'dir')
        mkdir(SaveFolder)
    end
    Nii=make_nii(StdMap,[]);
    save_nii(Nii,fullfile(SaveFolder,'StdMap.nii.gz'))
    Nii=make_nii(MeanMap,[]);
    save_nii(Nii,fullfile(SaveFolder,'MeanMap.nii.gz'))
    Nii=make_nii(NormalizedStdMap,[]);
    save_nii(Nii,fullfile(SaveFolder,'NormalizedStdMap.nii.gz'))
end


end


function [Map]= ListToMap(List,Mask)
Map=zeors(size(Mask));
MaskLine=Mask(:)~=0;
Map(MaskLine)=List;
end
