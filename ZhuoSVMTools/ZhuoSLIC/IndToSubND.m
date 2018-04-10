function [ PointPositions ] = IndToSubND(Dim,Ind)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   Zhuo Sun


DimLength=length(Dim);

switch DimLength
    case 2
        [x1,x2]=ind2sub(Dim,Ind);
        PointPositions=[x1,x2];
    case 3
        [x1,x2,x3]=ind2sub(Dim,Ind);
        PointPositions=[x1,x2,x3];
    case 4
        [x1,x2,x3,x4]=ind2sub(Dim,Ind);
        PointPositions=[x1,x2,x3,x4];
    otherwise
        error('No Supported dimension')
end



end

