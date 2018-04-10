function [ ] = ReplaceSplineOrder( InputPath,OutputPath )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%
  
fid1 = fopen(InputPath);
fid2 = fopen(OutputPath,'w')

tline = fgetl(fid1);
while ischar(tline)
    disp(tline)
    if ~isempty(strfind(tline,'FinalBSplineInterpolationOrder'))
        tline='(FinalBSplineInterpolationOrder 0)';
    end
    fprintf(fid2,'%s',tline)
    fprintf(fid2,'\n')
    tline = fgetl(fid1);
    
end

fclose(fid1);
fclose(fid2);

end

