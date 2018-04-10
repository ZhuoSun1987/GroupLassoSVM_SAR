function [NInd,ShiftPoints]=NeigbInsidePointIndex(Center,Dim,ShiftList)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to remove the neigbor points that are outside of
%   the image range
%
%   Zhuo Sun

DimLength=length(Dim);
ShiftNum=size(ShiftList,1);
ShiftPoints=repmat(Center,[ShiftNum,1])+ShiftList;

OutInd=sum([ShiftPoints<1,ShiftPoints>repmat(Dim,[ShiftNum,1])],2)>0;
ShiftPoints(OutInd,:)=[];

switch DimLength
    case 2    
        NInd=sub2ind(Dim,ShiftPoints(:,1),ShiftPoints(:,2));
    case 3
        NInd=sub2ind(Dim,ShiftPoints(:,1),ShiftPoints(:,2),ShiftPoints(:,3));
    case 4
        NInd=sub2ind(Dim,ShiftPoints(:,1),ShiftPoints(:,2),ShiftPoints(:,3),ShiftPoints(:,4));
    otherwise
        error('the given dimension is not supported')
end






end

