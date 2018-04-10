function [ Ind ] = SubToIndND( Dim,Sub )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

DimLength=length(Dim);
switch DimLength
    case 2
        Ind=sub2ind(Dim,Sub(:,1),Sub(:,2));
    case 3
        Ind=sub2ind(Dim,Sub(:,1),Sub(:,2),Sub(:,3));
    case 4
        Ind=sub2ind(Dim,Sub(:,1),Sub(:,2),Sub(:,3),Sub(:,4));
    otherwise
        error('Wrong dim')
end


end

