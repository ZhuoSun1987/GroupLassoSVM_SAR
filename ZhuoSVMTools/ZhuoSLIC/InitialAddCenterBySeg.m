function [ NewIndList,NewSubList,NewSegList ] = InitialAddCenterBySeg( Segment,CurrentClusterCenterLabelList )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to add cluster center accoding to the
%   segmentation, for the guided SLIC initialization.
%
%   This function is used to add cluster center when initilized by the grid
%   miss center inside some region.
%
%   Currently, it support for 2D and 3D images
%
%   Zhuo?Sun  20160327

Dim=size(Segment);
DimLength=size(Dim);
LabelSeg=unique(Segment(:));
CurrentLebels=unique(CurrentClusterCenterLabelList);

LinSeg=Segment(:);

MissLabel=setdiff(LabelSeg,CurrentLebels);
NewIndList=[];
NewSubList=[];
NewSegList=[];
for i=1:MissLabel
    BW0=Segment==MissLabel(i);
    CC=bwconncomp(BW0);
    ObjNum=CC.NumObjects;
    for j=1:ObjNum
        if DimLength==2
            [x1,x2]=ind2sub(CC.PixelIdxList{j});
            Mean=mean([x1,x2]);
            DistList=sum((repmat(Mean,length(x1))-[x1,x2]).^2,2);
            P=find(DistList==min(DistList));
            OptX1=x1(P(1));
            OptX2=x2(P(1));
            Ind=sub2ind(Dim,OptX1,OptX2);
            NewSubList=[NewSubList;[OptX1,OptX2]];
            NewIndList=[NewIndList;Ind];
            NewSegList=[NewSegList;MissLabel(i)];
        end
        if DimLength==3
            [x1,x2,x3]=ind2sub(CC.PixelIdxList{j});
            Mean=mean([x1,x2,x3]);
            DistList=sum((repmat(Mean,length(x1))-[x1,x2,x3]).^2,2);
            P=find(DistList==min(DistList));
            OptX1=x1(P(1));
            OptX2=x2(P(1));
            OptX3=x3(P(1));
            Ind=sub2ind(Dim,OptX1,OptX2,OptX3);
            NewSubList=[NewSubList;[OptX1,OptX2,OptX3]];
            NewIndList=[NewIndList;Ind];
            NewSegList=[NewSegList;MissLabel(i)];
        end
    end






end

