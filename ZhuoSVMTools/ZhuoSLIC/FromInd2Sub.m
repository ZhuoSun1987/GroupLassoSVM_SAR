function [ SubList ] = FromInd2Sub( IndList, Dim )
%UNTITLED16 Summary of this function goes here
%   Detailed explanation goes here

DimLength=length(Dim);
switch DimLength
    case 2
        [X1,X2]=ind2sub(Dim,IndList);
        SubList=[X1,X2];
    case 3
        [X1,X2,X3]=ind2sub(Dim,IndList);
        SubList=[X1,X2,X3];
    case 4
        [X1,X2,X3,X4]=ind2sub(Dim,IndList);
        SubList=[X1,X2,X3,X4];
    otherwise
        error('Mistakes...')
end        

end

