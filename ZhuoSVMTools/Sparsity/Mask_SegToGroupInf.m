function [ GroupLassoOpt] = Mask_SegToGroupInf( Mask,Seg,ROI,q )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to generate the group lasso related group
%   information for the given mask and segmentation.
%
%   q is the L1_Lq norm
%
%   Zhuo Sun 20160622

GroupLassoOpt=[];
LinMask=Mask(:);
LinSeg =Seg(:);
SegMask=LinSeg(LinMask==1);
if isempty(GroupLassoOpt) | nargin<3
    ROI=unique(SegMask);
else
    ROIAll=unique(SegMask);
    ROI=intersect(ROI,ROIAll);
end

VoxelNumList=zeros(length(ROI),1);
GroupIndPosListArray=cell(length(ROI),1);
for i=1:length(ROI)
    VoxelNumList(i)=sum(SegMask==ROI(i));
    GroupIndPosListArray{i}=find(SegMask==ROI(i));
end

MeanVoxelNum=sum(VoxelNumList)/length(ROI);

GroupLassoOpt.ROI=ROI;
GroupLassoOpt.GroupLabel=SegMask;
GroupLassoOpt.GroupWeight=(VoxelNumList/MeanVoxelNum).^(1/q);
GroupLassoOpt.q=q;
GroupLassoOpt.GroupIndPosListArray=GroupIndPosListArray;

end