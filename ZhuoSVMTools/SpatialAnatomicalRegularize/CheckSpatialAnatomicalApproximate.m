function [] = CheckSpatialAnatomicalApproximate( Segmentation, ROIs,TestResult,ThresDist )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to test the output of spatial anatomical
%   approximation sparse matrix.
%
%   Zhuo Sun  20160613

Segmentation=squeeze(Segmentation);
Mask=zeros(size(Segmentation));
Size=size(Mask);

%% make the mask, that include all the ROIs
for i=1:length(ROIs)
    SegInd=ROIs(i);
    Mask=Mask+double(Segmentation==SegInd);
end

%% fill the elements in the mask with index in the feature vector 
IndMat=zeros(size(Mask));
IndMat(Mask(:))=1:sum(Mask(:)==1);

%% From the image to the result
for i=1:




%% From the result to the image
    %% for the same ROI
SamePair=
SamePairNum=size(SamePair,1);
disp('Result To Image,  same ROI')
parfor i=1:SamePairNum
    P1=SamePair(i,1);
    P2=SamePair(i,2);
    IndAll_1=IndAllList(P1);
    IndAll_2=IndAllList(P2);
    Seg1=Segmentation(IndAll_1);
    Seg2=Segmentation(IndAll_2);
    Sub1=ind2sub(Size,IndAll_1);
    Sub2=ind2sub(Size,IndAll_2);
    if Seg1~=Seg2 | sum((Sub1-Sub2).^2)<ThresDist
        disp(['  Error in Point Pair', num2str(P1),' and ',num2str(P2) ]);
    end
end
        
    %% for the Differ ROI
SamePair=
SamePairNum=size(SamePair,1);
disp('Result To Image,  Differ ROI')

parfor i=1:SamePairNum
    P1=SamePair(i,1);
    P2=SamePair(i,2);
    IndAll_1=IndAllList(P1);
    IndAll_2=IndAllList(P2);
    Seg1=Segmentation(IndAll_1);
    Seg2=Segmentation(IndAll_2);
    Sub1=ind2sub(Size,IndAll_1);
    Sub2=ind2sub(Size,IndAll_2);
    if Seg1==Seg2 | sum((Sub1-Sub2).^2)<ThresDist
        disp(['  Error in Point Pair', num2str(P1),' and ',num2str(P2) ]);
    end
end
        












end

