function [ GradAmp ] = GradientAmp( Image )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to compute the gradient amplitude for 2D/3D/4D..
%
%   Zhuo Sun   2016-03-27

if isnumeric(Image)

    Image=squeeze(Image);
    Dim=size(Image);
    DimLength=length(Dim);

    switch DimLength
        case 2
            [g1,g2]=gradient(Image);
            GradAmp=(g1.^2+g2.^2);


        case 3
            [g1,g2,g3]=gradient(Image);
            GradAmp=(g1.^2+g2.^2+g3.^2);
        case 4
            [g1,g2,g3,g4]=gradient(Image);
            GradAmp=(g1.^2+g2.^2+g3.^2+g4.^2);
        otherwise
            error('Currently, the dimension of the image is not supported');
    end
end

if iscell(Image) % in this case,  Image is a cell array
    ImNum=length(Image);
    GradAmp=zeros(size(Image{1}));
    DimLength=length(size(Image{1}));
    for i=1:ImNum
        Im=Image{i};
        switch DimLength
            case 2
                [g1,g2]=gradient(Im);
                GradAmp1=(g1.^2+g2.^2);


            case 3
                [g1,g2,g3]=gradient(Im);
                GradAmp1=(g1.^2+g2.^2+g3.^2);
            case 4
                [g1,g2,g3,g4]=gradient(Im);
                GradAmp1=(g1.^2+g2.^2+g3.^2+g4.^2);
            otherwise
                error('Currently, the dimension of the image is not supported');
        end        
        GradAmp=GradAmp+GradAmp1;
    end
end


end

