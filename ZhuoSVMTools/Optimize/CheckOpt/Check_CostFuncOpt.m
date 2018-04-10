function [ CostFuncOpt ] = Check_CostFuncOpt( CostFuncOpt )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%   
%   this function is used to check the FuncOpt that used in Zhuo's SVM
%
%   CostFuncOpt.MCF -> misclassification function
%   CostFuncOpt.MCL -> misclassification function L loss (Misclassification^L)
%   CostFuncOpt.MOF -> misorder function 
%   CostFuncOpt.MOL -> misorder function L loss 
%   CostFuncOpt.LambdaList -> is a [4,1] vector, contains weight of
%
%   Zhuo Sun  20160613


if ~isfield(CostFuncOpt,'MCF')
    CostFuncOpt.MCF='HingeLoss';
end

if ~isfield(CostFuncOpt,'MCL')
    CostFuncOpt.MCL=2;
end

if ~isfield(CostFuncOpt,'MOF')
    CostFuncOpt.MOF='HingeLoss';
end

if ~isfield(CostFuncOpt,'MCL')
    CostFuncOpt.MOL=2;
end

if ~isfield(CostFuncOpt,'LambdaList')
    CostFuncOpt.LambdaList=[1,0,1,1];
else
    if length(CostFuncOpt.LambdaList)==4
        CostFuncOpt.LambdaList=reshape(CostFuncOpt.LambdaList,[4,1]);
    else
        error('CostFuncOpt.LambdaList should be a [4,1] vector')
    end
end


end

