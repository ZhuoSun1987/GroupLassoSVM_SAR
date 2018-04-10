function [Limits]=CropMaskWithBoundary(Binary,Margin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to find the margined bounding box limits
%
%
%   Zhuo Sun  20160630

FullSize=size(Binary);
DimLength=length(FullSize);

indx=find(Binary~=0);

switch DimLength
    case 1
        A=Index;        
    case 2
        [x1,x2]=ind2sub(FullSize,index);
        A=[x1,x2];
        
    case 3
        [x1,x2,x3]=ind2sub(FullSize,index);
        A=[x1,x2,x3];
    case 4
        [x1,x2,x3,x4]=ind2sub(FullSize,index);
        A=[x1,x2,x3,x4];
    case 5
        [x1,x2,x3,x4,x5]=ind2sub(FullSize,index);
        A=[x1,x2,x3,x4,x5];
    otherwise
        error(['Currently, can not use this dimensionality, but you can easily increase the dimensionality it can works on'])
end
    

Max=max(A);
Min=min(A);
UpLimit=min(FullSize,Max+Margin);
LowLimit=max(ones(1,DimLength),Min-Margin);
Limits=[LowLimit;UpLimit];



end

