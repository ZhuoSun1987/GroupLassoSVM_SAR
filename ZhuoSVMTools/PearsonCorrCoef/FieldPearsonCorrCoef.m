function [ R ] = FieldPearsonCorrCoef( FieldArray,YList )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%
%   this fucntion is used to compute the Pearson Corrrelation Coefficient
%   of the list field
%
%   see webpage  http://www.socscistatistics.com/tests/pearson/
%
%   Zhuo Sun  20160620

N=length(FieldArray);
FieldSize=size(squeeze(FieldArray{1}));

MeanY=mean(YList);
StdY=std(YList);
MeanX=zeros(FieldSize);

for i=1:N
    MeanX=MeanX+FieldArray{i};
end
MeanX=MeanX/N;

Term1=zeros(FieldSize);
Term2=zeros(FieldSize);
Term3=0;

for i=1:N
    Term1=(FieldArray{i}-MeanX)*(YList(i)-MeanY)+Term1;
    Term2=(FieldArray{i}-MeanX).^2+Term2;
    Term3=(YList(i)-MeanY).^2+Term3;
end

R=Term1./((Term2.^0.5).*(Term3.^0.5));

R(isnan(R))=0;


end

