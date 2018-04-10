function [ PathList ] = FindFilesInFolder( Folder,MatchPatList )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   This funciton is used to find all the files that meet the required
%
%   MatchPatList is a cell array, each element is a string
%
%   Zhuo Sun 20161011


N=length(MatchPatList);
PathList={};
for i=1:N
    Pat=MatchPatList{i};
    Dir=dir(fullfile(Folder,Pat));
    for j=1:length(Dir)
        FilePath=fullfile(Folder,Dir(j).name);
        PathList=[PathList;FilePath];
    end
end



end

