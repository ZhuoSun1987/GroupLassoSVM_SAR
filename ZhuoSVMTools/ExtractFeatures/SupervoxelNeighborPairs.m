function [ Pairs,IndexList0 ] = SupervoxelNeighborPairs( SuperVoxel,Mask, UseParallel )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to find the neighbourhood pairs of the given
%   supervoxels.  Also, this connect pair extraction only consider the
%   supervoxels inside the mask region
%
%   Mask is a binary mask
%
%   this function can use parfor to improve the time
%
%   Zhuo Sun  20160630

Mask=squeeze(double(Mask~=0));
SuperVoxel=squeeze(SuperVoxel);

if ~isequal(size(SuperVoxel),size(Mask))
    error('size of the two input do not match');
else
    SuperVoxel=double(SuperVoxel).*double(Mask);
    IndexList=unique(SuperVoxel(:));
    ZeroPos=find(IndexList==0);
    if ~ isempty(ZeroPos)
        IndexList(ZeroPos)=[];
    end
end

IndexList0=IndexList;
SuperVoxelNum=length(IndexList);

%% Change the index of labeled segmentation
SuperVoxel0=SuperVoxel;
SuperVoxel=zeros(size(SuperVoxel0));
for i=1:SuperVoxelNum
    Index=IndexList0(i);
    SuperVoxel=SuperVoxel+double(i)*double(SuperVoxel0==Index);
end



%% construct the neighbor pairs
if nargin<3
    UseParallel=0;
end

if UseParallel==0
    Pairs=[];
    for i=1:SuperVoxelNum
        ROI=IndexList(i);
        Binary=double(SuperVoxel==ROI);
        Limits=CropMaskWithBoundary(Binary,1); 
        CropBinary=CropImage(Binary,Limits); 
        CropSeg   =CropImage(SuperVoxel,Limits); 
        [ BoundarySegList ] = FindNeighborSegAround( CropBinary,CropSeg );
        UniqueN=unique(BoundarySegList);
        ZeroPos=find(UniqueN==0);
        if ~ isempty(ZeroPos)
            UniqueN(ZeroPos)=[];
        end
        BoundPointCountList=zeros(size(UniqueN));
        for j=1:length(UniqueN)
            BoundPointCountList(j)=length(BoundarySegList==UniqueN(j));
        end
        Pairs=[Pairs;[ROI,UniqueN,BoundPointCountList]];    
    end    
    
else
    PairArray=cell(SuperVoxelNum,1);
    parfor i=1:SuperVoxelNum
        ROI=IndexList(i);
        Binary=double(SuperVoxel==ROI);
        Limits=CropMaskWithBoundary(Binary,1); 
        CropBinary=CropImage(Binary,Limits); 
        CropSeg   =CropImage(SuperVoxel,Limits); 
        [ BoundarySegList ] = FindNeighborSegAround( CropBinary,CropSeg );
        UniqueN=unique(BoundarySegList);
        ZeroPos=find(UniqueN==0);
        if ~ isempty(ZeroPos)
            UniqueN(ZeroPos)=[];
        end
        BoundPointCountList=zeros(size(UniqueN));
        for j=1:length(UniqueN)
            BoundPointCountList(j)=length(BoundarySegList==UniqueN(j));
        end
        PairArray{i}=[ROI,UniqueN,BoundPointCountList];    
    end
    Pairs=[];
    for i=1:SuperVoxelNum
        Pairs=[Pairs;PairArray{i}];
    end    
end
    








end

