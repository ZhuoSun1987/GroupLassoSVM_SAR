function [ Result ] = RepeatWeightVectorSummary( WList )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   WList is a cell array
%
%   Zhuo Sun  20160906

N=length(WList);
D=length(WList{1});

Matrix=zeros(N,D);

for i=1:N
    Matrix(i,:)=WList{i};
end


Result.Mean=mean(Matrix);
Result.std =std(Matrix);
Result.NonZero=sum(Matrix ~=0);




end

