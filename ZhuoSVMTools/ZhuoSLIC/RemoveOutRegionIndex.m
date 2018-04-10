function [ IndexList ] = RemoveOutRegionIndex( CenterPos,ShiftList,Dim )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is designed to give the index of neighbor points the
%   given center position. and to deal with cases that the neighbor points
%   is outside of the region
%
%   Zhuo Sun   2016-03-27

DimLength=size(Dim);

%%  generate the position list of all the Neighbor points
NeigborPos=repmat(CenterPos,[size(ShiftList,1),1])+ShiftList;

%%  remove the points that outside the region
N=size(ShiftList,1);
OutsideList=find(sum(NeighborPos<ones(N,DimLength) + NeighborPos>repmat(Dim,[N,1]),2)>0);
NeigborPos(OutsideList,:)=[];

%%  
if DimLength==2
   IndexList=sub2ind(Dim,NeigborPos(:,1),NeigborPos(:,2)); 
    
end

if DimLength==3
   IndexList=sub2ind(Dim,NeigborPos(:,1),NeigborPos(:,2),NeigborPos(:,3));   
end



end

