function [ShiftArray]=ShiftListComputing(Connectivity,DimLength)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   Zhuo Sun  2015-09-24

ShiftArray=[];
DistSquare=[];
switch DimLength
    case 2
        switch Connectivity
            case 4
                DistSquare=1;
            case 8
                DistSquare=2;
            otherwise
                error('The connectivity is not proper')
        end
        [ ShiftArray ] = DistRelatedShift( DimLength,DistSquare )  ;  
    case 3
        switch Connectivity
            case 6
                DistSquare=1;
            case 18
                DistSquare=2;
            case 26
                DistSquare=3;
            otherwise
                error('The connectivity is not proper')
        end        
        [ ShiftArray ] = DistRelatedShift( DimLength,DistSquare )  ;  
    otherwise
        error('Currently, only 2D and 3D data');
end



end

