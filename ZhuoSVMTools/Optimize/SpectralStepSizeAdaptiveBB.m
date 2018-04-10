function [ T,Ts,Tm ] = SpectralStepSizeAdaptiveBB( X,X_1,dFx,dFx_1,PreviousStepSize )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used as the spectral schemes from gradient descent,
%   proposed by Barzilai and Borwein [32], who model the function f as the
%   simple quadratic function  f(x) \approx \bar{f}(x)=(a/2)*\|x\|^2+<x,b>,
%   appear in paper "A field guide to forward-backward splitting with a FASTA impelemntation"
%   https://www.semanticscholar.org/paper/A-Field-Guide-to-Forward-Backward-Splitting-with-a-Goldstein-Studer/1a0eb7d571c6dded9265bbc506b6dcec4452ceb1/pdf
%   page 11 to 12, this implementation is on Equation (33)
%   
%   the original paper is J. Barzilai and J. M. Borwein, “Two-point step size gradient methods,” IMA J Numer Anal, vol. 8,
%   pp. 141–148, January 1988.
%
%
%   X is the current parameter and X_1 is the previous step parameter, its
%   size is [d,1]
%   dFx is the current parameter gradient and dFx_1 i the prevous step
%   parameter gradent, its size is [d,1]
%
%   T is the step size.
%
%   Zhuo Sun  20160602


LapX=X-X_1;
LapF=dFx-dFx_1;

LapXNorm=(LapX')*LapX;
LapFNorm=(LapX'*LapF);
CrossNorm=(LapX')*LapF;


Ts=LapXNorm/CrossNorm;
Tm=CrossNorm/LapFNorm;

if Tm<0 | Ts<0
    T=PreviousStepSize;
else

    if Tm/Ts>0.5
        T=Tm;
    else
        T=Ts-0.5*Tm;
    end
end




end

