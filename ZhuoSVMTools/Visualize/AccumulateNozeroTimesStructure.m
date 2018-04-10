function [ AccuMap ] = AccumulateNozeroTimesStructure( FeatureMapPathList,Segment)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to accumulate the feature selected times
%
%   Zhuo Sun 2016-10-10


MapNum=length(FeatureMapPathList);
Nii=load_nii(FeatureMapPathList{1});
Im=squeeze(Nii.img);
AccuMap=zeros(size(Im));
SegIndList=sort(unique(Segment(:)));
if SegIndList(1)==0
    SegIndList(1)=[];
end
SegLine=Segment(:);

for i=1:MapNum
    Nii=load_nii(FeatureMapPathList{i});
    WeightMap=squeeze(Nii.img);
    WeightMapLine=WeightMap(:);
    AppearIm=zeros(size(WeightMap));
    for j=1:length(SegIndList)
        Ind=SegIndList(j);
        if sum(abs(WeightMapLine(SegLine==Ind)))>=0
            AppearIm(SegLine==Ind)=1;
        end
    end
    AccuMap=Im0+AppearIm;
end


end

