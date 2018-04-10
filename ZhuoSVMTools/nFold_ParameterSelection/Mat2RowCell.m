function [ Array ] = Mat2RowCell( Matrix )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

[R,C]=size(Matrix);
Array=cell(R,1);
for i=1:R
    Array{i}=Matrix(i,:);
end

end

