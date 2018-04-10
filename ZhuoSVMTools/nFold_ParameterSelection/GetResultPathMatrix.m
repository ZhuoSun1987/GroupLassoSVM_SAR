function [ ParaNameMatrix,SpecifyColList ] = GetResultPathMatrix(ValueArray,SpecifiedIndex,OtherColInd,OtherColSet )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%
%   ValueArray is a N*1 cell array, each cell is the values of one
%   parameter
%
%
%   
SpecifiedIndex=sort(SpecifiedIndex);
N1=length(SpecifiedIndex);  % the compact number of parameters
N2=length(ValueArray);  % the total number of parameter
NumList=zeros(N1,1);
CompactValueArray=cell(N1,1);
for i=1:N1
    NumList(i)=length(ValueArray{SpecifiedIndex(i)});
    CompactValueArray{i}=ValueArray{SpecifiedIndex(i)};
end
ParaNameMatrix=cell(NumList);
SpecifyColList=zeros(prod(NumList),N1);
SpecifyColList=ParameterArrayGenerator( CompactValueArray );


%% filling each parameter
AllParaValueList=zeros(prod(NumList),N2);

if iscell(OtherColSet)
    % in this case, the missing col value is explicitly specified
    for i=1:length(OtherColInd)
        AllParaValueList(:,OtherColInd(i))=OtherColSet{i};
    end
end
if isvector(OtherColSet)
    for i=1:length(OtherColInd)
         AllParaValueList(:,OtherColInd(i))=AllParaValueList(:,OtherColSet(i));
    end
end
% if OtherColSet is empty, the missing col is zeros


%% filling in the result folder path
for i=1:prod(NumList)
    LambdaList=AllParaValueList(i,:);
    FolderName=[];
    for j=1:N2
        FolderName=fullfile(FolderName,['L',num2str(j),'_',num2str(LambdaList(j))]);
    end
    ParaNameMatrix{i}=FolderName;
end


end

