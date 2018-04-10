function [ CostSmooth ] = QFunc( W0,W1,Gradf_W0,StepSize,Cost_W0, SparseOpt )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%
%   W0 and W1 are previous and current variable , have the same size
%   Gradf_W0 is the gradient vector at point W0;
%
%   this function is used to comtpute the Q function defined in Amir Beck's
%   FISTA SIAM 2009 paper, Equation 2.5
%
%   Cost_W0 is the smooth part of the cost function at previous point W0
%
%   Zhuo Sun, update 20170330 to correct the missing sqarsity cost in the 



%%  compute the differentiable term second order approximation
ZeroOrder =Cost_W0; % the cost for the smooth part
Differ=W1-W0;
FirstOrder=(Differ')*Gradf_W0;
SecondOrder=sum(Differ.^2)/(2*StepSize);

%% compute the cost of sparsity
SparseCost=0;
if SparseOpt.Lambda4>0
    SparseCost=SparseOpt.Lambda4*SparsityCost( W(1:end-1),SparseOpt );
end

%% Differentiable Terms cost
CostSmooth=ZeroOrder+FirstOrder+SecondOrder+SparseCost;
%%
end

