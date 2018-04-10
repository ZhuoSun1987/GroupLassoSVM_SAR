function [ StdPos,StdNeg,NormalMap ] = ComputeStdFromStructSparsityWeightMap( WeightMap )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   Zhuo Sun  2016-10-10

WeightLine=WeightMap(:);
WeightPositive=WeightLine(WeightLine>0);
WeightNegative=WeightLine(WeightLine<0);
StdPos=(sum(WeightPositive.^2)/length(WeightPositive))^0.5;
StdNeg=(sum(WeightNegative.^2)/length(WeightNegative))^0.5;

if StdPos>0
    PosMap=WeightMap/StdPos.*double(WeightMap>0);
else
    PosMap=zeros(size(WeightMap));
end
if StdNeg>0
    NegMap=WeightMap/StdNeg.*double(WeightMap<0);
else
    NegMap=zeros(size(WeightMap));
end

NormalMap=NegMap+PosMap;



    



end

