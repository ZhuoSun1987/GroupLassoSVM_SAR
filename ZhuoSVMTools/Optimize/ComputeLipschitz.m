function [ L_X,L_Q ] = ComputeLipschitz( X, Q )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the lipschitz constant (a relax one)
%   or equal weight supervised data X, and the SPD regularization matrix Q
%
%   Related cost term  = hingeloss (X)+ Lambda* W' *Q*W
%
%
%   ZhuoSun 20160622

L_X=0;
L_Q=0;
if ~isempty(X)
    [n,d]=size(X);
    if n>d
        L_X=norm(X'*X);
    else
        L_X=norm(X*(X'));
    end
end


if  ~isempty(Q)
    [V,D]=eigs(Q,1);
    L_Q=D;
end
    

end

