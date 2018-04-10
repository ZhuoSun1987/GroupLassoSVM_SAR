function [  ] = parsave( SavePath,SaveVar )
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here

X=SaveVar;
save(SavePath,'X');

end

