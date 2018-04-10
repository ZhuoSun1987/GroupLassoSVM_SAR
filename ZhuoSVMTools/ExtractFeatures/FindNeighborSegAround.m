function [ SegList ] = FindNeighborSegAround( Binary,Seg )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
%
%   ZhuoSun  20160630



%% check the size of the two input
Binary=squeeze(Binary);
Seg   =squeeze(Seg);

if ~ isequal(size(Seg),size(Binary))
    error('two input should be the same size');
end

%% first make the dilation of the binary image
SE = strel('square', 3)
bw2 = imdilate(Binary,se);


%% find the outer boundary points
OuterBoundary=double(bw2)-double(Binary);

%% 
LinSeg=Seg(:);
LinOutBound=OuterBoundary(:);
SegList=LinSeg(LinOutBound==1);


end

