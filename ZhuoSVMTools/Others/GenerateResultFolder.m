function [ ResultFolder ] = GenerateResultFolder( Root, ParaNameArray,ValueArray )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to generate a folder that contains the result of
%   the certain parameter setting
%
%   Zhuo Sun  20160803

CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end

Str=Root;
N=length(ParaNameArray);
ParaValueStr=[];
for i=1:N
    ParaName =ParaNameArray{i};
    if isnumeric(ValueArray)
        ParaValue=ValueArray(i);
        ParaValueStr=num2str(ParaValue);
    end
    
    if iscell(ValueArray)
        ParaValue=ValueArray{i}
        if isstr(ParaValue)
            ParaValueStr=ParaValue;
        end
        if isnumeric(ParaValue)
            ParaValueStr=num2str(ParaValue);
        end
    end
    Str=[Str,separation,ParaName,'_',ParaValueStr];
end
    
ResultFolder=Str;


end

