function [ DataOpt,CostFuncOpt,OptimizeOpt,SparseOpt ] = Check_All( DataOpt,CostFuncOpt,OptimizeOpt,SparseOpt )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to check all the options.
%
%   Zhuo Sun  20160613

[ DataOpt   ]   = Check_DataOpt(DataOpt);
[ SparseOpt ]   = Check_SparseOpt( SparseOpt );
[ OptimizeOpt ] = Check_OptimizeOpt( OptimizeOpt );
[ CostFuncOpt ] = Check_CostFuncOpt( CostFuncOpt );
end

