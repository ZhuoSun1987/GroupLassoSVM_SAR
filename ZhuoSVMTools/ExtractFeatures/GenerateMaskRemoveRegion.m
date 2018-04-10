function [ Mask, ROISeg ] = GenerateMaskRemoveRegion( Segmentation,ROIs,RemoveROIs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   ZhuoSun  20160619


Segmentation=squeeze(Segmentation);
Mask=zeros(size(Segmentation));
ROISeg=zeros(size(Segmentation));

if isempty(ROIs)
    if isempty(RemoveROIs)
        Mask=double(Segmentation ~=0);
        ROISeg=Segmentation;
    else
        Mask=double(Segmentation ~=0);
        for i=1:length(RemoveROIs)
            Mask(Segmentation==RemoveROIs(i))=0;
        end
        ROISeg=Mask.*Segmentation;
    end
else
    if isempty(RemoveROIs)
        for i=1:length(ROIs)
            Mask=Mask+double(Segmentation==ROIs(i));
        end
        ROISeg=Mask.*Segmentation;
    else
        ROIs=setdiff(ROIs,RemoveROIs );
        for i=1:length(ROIs)
            Mask=Mask+double(Segmentation==ROIs(i));
        end
        ROISeg=Mask.*Segmentation;
    end
end

end

