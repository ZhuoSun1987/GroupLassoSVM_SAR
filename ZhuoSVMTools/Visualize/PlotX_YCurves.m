function [  ] = PlotX_YCurves( XMat,YMat,CurveNameList,TypeList )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to make plot of multiple curves 
%
%   Zhuo Sun  20161010


[N1,M1]=size(XMat);
[N2,M2]=size(YMat);
N3=length(CurveNameList);
CC=jet(N3);
if nargin<4 | isempty(TypeList)
    TypeList=cell(1,N3);
end

for i=1:N3
    X=XMat(i,:);
    Y=YMat(i,:);    
    C=CC(i,:);
    Type=TypeList{i};
    plot(X,Y,Type,'color',C);
    hold on
end

legend(CurveNameList)


end

