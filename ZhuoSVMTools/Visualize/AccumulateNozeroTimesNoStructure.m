function [ AccuMap ] = AccumulateNozeroTimesNoStructure( FeatureMapPathList,SaveRoot )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to accumulate the feature selected times
%
%   Zhuo Sun 2016-10-10


MapNum=length(FeatureMapPathList);
Nii=load_nii(FeatureMapPathList{1});
Im=squeeze(Nii.img);
AccuMap=zeros(size(Im));

for i=1:MapNum
    Nii=load_nii(FeatureMapPathList{i});
    Im=squeeze(Nii.img);
    AccuMap=Im0+double(Im~=0);
end

if nargin>1 & ~isempty(SaveRoot)
    if ~exist(SaveRoot,'dir')
        mkdir(SaveRoot);
    end
    Nii=make_nii(AccuMap,[]);
    save_nii(Nii,fullfile(SaveRoot,'AccuMap.nii.gz'))
end

end

