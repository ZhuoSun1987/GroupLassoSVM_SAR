function [ ] = MakeFolder( Folder )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if ~exist(Folder,'dir')
    mkdir(Folder);
end

end

