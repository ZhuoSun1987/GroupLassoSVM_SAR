function [Values ]=GetValuesFromResultStruct(ResultStruct,NewWeightVector)
% the result structure has several fields, each fields is for one
% evaluation of mutiple experiments.
%
%   ResultStruct is the the result structure from the CV tuning on training
%   
%


FieldNameList={'AccList','AUCList','SenList','SpeList','precisionList','recallList','gmeanList','fList'};
ExpNum=length(getfield(ResultStruct,FieldNameList{1}));
Mat=zeros(ExpNum,length(FieldNameList));
for i=1:length(FieldNameList)
    List=getfield(ResultStruct,FieldNameList{i});
    Mat(:,i)=List;
end
Values=Mat*reshape(NewWeightVector,[length(NewWeightVector),1]);
end