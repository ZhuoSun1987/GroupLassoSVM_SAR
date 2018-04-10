function [  ] = parsave( SavePath,SaveVariable )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

X=SaveVariable;
save(SavePath,'X');

end

