function [SelectParameter,BestValue ] = HyperParaSelect( RootFolder,ResultFileName,...
WeightList,ValueArray,SpecifiedIndex,OtherColInd,OtherColSet,ToTestArray,ToUsedIndexList )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
%
%   WeightList is used to generate the new metric as a weighted sum of
%   standard metric
%
%

%% first, prepare for the  interplation

[ ValueMatrix,ValueList,SpecifyColList ] =...
 GetMetricListForInterpHyperParameter( RootFolder,ResultFileName,WeightList,ValueArray,SpecifiedIndex,OtherColInd,OtherColSet );

%% do the interpolation to find the optimal hyper parameters
HighOrLow=1;
[ BestValue,OptParameters ] = HyperParameterInterp( Values, ParaArray,ToTestArray,HighOrLow,ToUsedIndexList );
SelectParameter=OptParameters;
end

