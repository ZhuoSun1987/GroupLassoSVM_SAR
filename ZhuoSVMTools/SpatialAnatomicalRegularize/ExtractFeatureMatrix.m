function [ FeatureMatrix ] = ExtractFeatureMatrix( Root,Pat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function works for Zhiwei's project Lung Vessel Segmentation
%
%   ZhuoSun

CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end

Dir=dir([Root,separation,Pat]);
FeatureNum=length(Dir);
Feature1=importdata([Root,separation,Dir(1).name]);
Feature1=Feature1(:);
FeatureMatrix=zeros(FeatureNum,length(Feature1));
for i=1:FeatureNum
    Feature1=importdata([Root,separation,Dir(i).name]);
    Feature1=Feature1(:);
    FeatureMatrix(i,:)=Feature1;
end




end

