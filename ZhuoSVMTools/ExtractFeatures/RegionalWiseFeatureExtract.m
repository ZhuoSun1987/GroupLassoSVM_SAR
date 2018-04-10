function [ Sum, Mean, Std, ROIList ] = RegionalWiseFeatureExtract( SegMask,ROIList, FeatureMapList )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   Mask is a 2D/3D matrix, the same size as each image in the
%   FeatureMapList.
%   ROIList,   a list of index of ROIs that need to be analysed
%   FeatureMapList: A list of path of Nii, or Nii.gz or .mat
%   
%   Zhuo Sun  20160630

s=matlabpool('size');
if s==0
    matlabpool open 
end



SegMask=squeeze(SegMask);
SegSize=size(SegMask);
LinearSeg=SegMask(:);
ImageNum=length(FeatureMapList)

if isempty(ROIList)
    ROIList=unique(SegMask(:));
    ZeroPos=find(ROIList==0);
    if ~isempty(ZeroPos)
        ROIList(ZeroPos)=[];
    end
end
ROIList=ROIList(:);
ROINum=length(ROIList);

Sum =zeros(ImageNum,ROINum);
Mean=zeros(ImageNum,ROINum);
Std =zeros(ImageNum,ROINum);

parfor i=1:ImageNum
    [ Im ] = LoadImage( FeatureMapList{i} );
    Im=squeeze(Im);
    SubMeanVec=zeros(1,ROINum);
    SubStdVec =zeros(1,ROINum);
    SubSumVec =zeros(1,ROINum);
    if isequal(SegSize,size(Im))
        
        LinearFea=Im(:);
        for j=1:ROINum
            ROI=ROIList(j);
            Vec=LinearFea(LinearSeg==ROI);
            SubMeanVec(j)=mean(Vec);
            SubStdVec (j)=std(Vec);
            SubSumVec (j)=sum(Vec);
        end
        Mean(i,:)=SubMeanVec;
        Std (i,:)=SubStdVec; 
        Sum (i,:)=SubSumVec; 
    else
        error(['size of the SegMask do not match the input image ==> ',FeatureMapList{i}])
    end
end
    




end

