function [ dW ] = Grad_HingLoss( X,Y,C,Ma,W,Order )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the gradient of hingeloss function
%
%   X size [n,d+1]
%   Y size [n,1]
%   C size [n,1], C should be normalized, so that sum(C)=n and C is
%   non-negative numbers
%   
%   Zhuo Sun  2016-06-02

n=length(Y);
Mistake=max(0, Ma-Y.*(X*W));

SumGrad=((Order*(Mistake.^(Order-1)).*(-Y).*C)'*X)';
dW=SumGrad/n;






end

