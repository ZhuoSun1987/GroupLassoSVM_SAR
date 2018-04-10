function [ PointList ] = PositionShift( NeighborList,WithCentrOrNot )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%

PointNum=prod(2*NeighborList+1);
DimLength=length(NeighborList);
PointList=zeros(PointNum,DimLength);
DirctNumList=2*NeighborList+1;
for i=1:DimLength
    Before=prod(DirctNumList(1:i-1));
    After =prod(DirctNumList(i+1:end));
    A=repmat([-1*NeighborList(i):NeighborList(i)],[After,1]);
    PointList(:,i)=repmat(A(:),[Before,1]);
end


if WithCentrOrNot==0
    DistList=sum(PointList.^2,2);
    Pos=find(DistList==0);
    PointList(Pos,:)=[];
end

end

