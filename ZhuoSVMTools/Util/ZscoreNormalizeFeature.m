function [ Train,Test ] = ZscoreNormalizeFeature( Train, Test )
%UNTITLED17 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to normalize the Train and Test features/
%
%   Zhuo Sun  20160621



[Train,mu,sigma]=zscore(Train);


[TestN,TestD]=size(Test);
Test=(Test-repmat(mu,[TestN,1]))./repmat(sigma,[TestN,1]);
Test(:,sigma==0)=0;



end

