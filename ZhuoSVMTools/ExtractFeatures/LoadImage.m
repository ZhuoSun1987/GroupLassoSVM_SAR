function [ Im ] = LoadImage( ImagePath )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%   
%   this funciton is used to load image into memory
%
%   Zhuo Sun  20160630

PointPos=strfind(ImagePath,'.')

LastPart=ImagePath(PointPos(end):end);

switch LastPart
    case '.nii'
        Nii=load_nii(ImagePath);
        Im=Nii.img;
    case '.mat'
        Im=importdata(ImagePath);
    case '.gz'
        if length(PointPos)>1
            if strcmp(ImagePath(PointPos(end-1):end),'.nii.gz')
                Nii=load_nii(ImagePath);
                Im=Nii.img;
            else
                error(['can not read file',ImagePath]);
            end
            
        else
            error(['can not read file',ImagePath]);
        end
    otherwise
        error(['can not read file',ImagePath]);
end
        
   
        


end

