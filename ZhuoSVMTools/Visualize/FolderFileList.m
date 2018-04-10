function [ PathList ] = FolderFileList( Folder, MatchPattern )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to generate a list of file path that in the
%   given folder and match the user speficied MatchPattern
%
%   Zhuo Sun  20161010

FullPath=fullfile(Folder,MatchPattern);
DIR=dir(FullPath);
N=length(Dir)
PathList=cell(N,1);
for i=1:N
    PathList{i}=fullfile(Folder,DIR(i).name);
end

end

