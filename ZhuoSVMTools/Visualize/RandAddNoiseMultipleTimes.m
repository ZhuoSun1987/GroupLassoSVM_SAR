function [FeatureMatrixArray]=RandAddNoiseMultipleTimes(FeatureMatrix,NoiseLevel,Times)
%
%   this funciton is used to randomly add random noise to the feature
%   matrix several times to generate a list of corruped feature
%
%   Zhuo Sun  2016-10-10

FeatureMatrixArray=cell(Times,1);
[N,D]=size(FeatureMatrix);
for i=1:Times
   Noise= NoiseLevel*rand(size(FeatureMatrix))-0.5*NoiseLevel;
   FeatureMatrix1=FeatureMatrix+Noise;
   FeatureMatrixArray{i}=FeatureMatrix1;  
end



end



