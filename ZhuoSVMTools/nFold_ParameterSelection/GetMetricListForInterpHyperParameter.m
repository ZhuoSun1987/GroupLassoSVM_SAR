function [ ValueMatrix,ValueList,SpecifyColList ] = GetMetricListForInterpHyperParameter( RootFolder,ResultFileName,WeightList,ValueArray,SpecifiedIndex,OtherColInd,OtherColSet )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

[ ParaNameMatrix,SpecifyColList ] = GetResultPathMatrix(ValueArray,SpecifiedIndex,OtherColInd,OtherColSet );
ValueMatrix=zeros(size(ParaNameMatrix));
MatSize=size(ParaNameMatrix);
N=prod(MatSize);

parfor i=1:N
    FilePath=fullfile(RootFolder,ParaNameMatrix(i),ResultFileName);
    A=importdata(FilePath);
    %% 
    Values=GetValuesFromResultStruct(A);
    ValueMatrix(i)=ComputeMetric(Values,WeightList);
end

end

function [Values ]=GetValuesFromResultStruct(ResultStruct)
% the result structure has several fields, each fields is for one
% evaluation of mutiple experiments.
FieldNameList={'accuracy','AUC','sensitivity','specificity','precisionList','recallList','gmeanList','fList'};
Mat=zeros(ExpNum,length(FieldNameList));
for i=1:length(FieldNameList)
    List=getfield(ReportStruct,FieldNameList{i});
    Mat(:,i)=List;
end
end