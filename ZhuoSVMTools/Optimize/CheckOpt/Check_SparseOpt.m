function [ SparseOpt ] = Check_SparseOpt( SparseOpt )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used for the sparsity option
%
%   SparseOpt -> the option about the sparsity 
%
%   

if ~isfield(SparseOpt,'SparseType')
    SparseOpt.SparseType='Lasso';
end

if ~isfield(SparseOpt,'C_Or_R')
    SparseOpt.C_Or_R=2;
end


end

