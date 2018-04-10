function [ ] = SparsityVsAccuracySingleCurve( SparsityMat,AccuracyMat)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   
%   Zhuo Sun  2016-10-10


S=SparsityMat(:);
A=AccuracyMat(:);
Mat=[S,A];
Mat=sortrows(Mat,2);
X=Mat(:,1);
Y=Mat(:,2);
plot()

PlotX_YCurves( XMat,YMat,CurveNameList,TypeList );
title('Sparisty vs Accuracy');
xlabel('Sparsity');
ylabel('Accuracy');



end