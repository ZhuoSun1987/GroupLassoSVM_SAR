function [ ] = SparsityVsAccuracyCurves( SparsityMat,AccuracyMat,CurveNameList,TypeList )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   
%   Zhuo Sun  2016-10-10

XMat=SparsityMat;
YMat=AccuracyMat;

PlotX_YCurves( XMat,YMat,CurveNameList,TypeList );
title('Sparisty vs Accuracy');
xlabel('Sparsity');
ylabel('Accuracy');



end

