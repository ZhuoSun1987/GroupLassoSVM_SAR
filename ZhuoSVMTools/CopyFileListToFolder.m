function [  ] = CopyFileListToFolder( Folder,FilePathList )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   Zhuo Sun 2016-10-11

if ~ exist(Folder,'dir')
    mkdir(Folder)
end

N=length(FilePathList);
for i=1:N
    File=FilePathList{i};
    copyfile(File,Folder);
end

end

