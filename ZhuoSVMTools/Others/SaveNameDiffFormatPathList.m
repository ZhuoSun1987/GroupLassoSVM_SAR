function [ FullPathList ] = SaveNameDiffFormatPathList(Folder,Name,FormatList )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
N=length(FormatList);
FullPathList=cell(N,1);
for i=1:N
   format=FormatList{i};
   FullPathList{i}=fullfile(Folder,[Name,format]);
end

end

