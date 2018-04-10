function [CropBinary]=CropImage(Binary,Limits)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


FullSize=size(Binary);
DimLength=length(FullSize);
CropBinary=[];
Str='CropBinary=Binary(';
for i=1:DimLength
    Str=[Str,num2str(Limits(1,i)),':',num2str(Limits(2,i))];
    if i<DimLength
        Str=[Str,','];
    else
        Str=[Str,');'];
    end
end
eval(Str);




end

