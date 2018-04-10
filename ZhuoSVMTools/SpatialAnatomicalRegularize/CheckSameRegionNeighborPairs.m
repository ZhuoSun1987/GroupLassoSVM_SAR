function [  ] = CheckSameRegionNeighborPairs( Mask,Regions,Pairs,Connectivity)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   Pairs is a P*2 matrix, 

Dimlength=length(size(squeeze(Mask)));
Mask=squeeze(Mask);
%% build a relation between the feature index and the point linear index
MaskLinear=Mask(:);
PointIndex=find(Mask==1);
FeatureIndex=1:length(PointIndex);
LabelList=Regions(PointIndex);
PointNum=length(PointIndex);
%% Construct the L
PairNum=size(Pairs,1);
RowIndex=1:PairNum;
RowIndex=[RowIndex';RowIndex'];
ColIndex=[Pairs(:,1);Pairs(:,2)];
ValList=[ones(PairNum,1);-1*ones(PairNum,1)];
L=sparse(RowIndex,ColIndex,ValList);
%%
LabelDiffer=abs(L*LabelList);
%% to see if every pair is for the same region
if sum(LabelDiffer)~=0
    error('Some differ region points have links')
end

%% to see if every should be linked points have 
    %% construct a sparse matrix
    SparseMatrix=sparse(Pairs(:,1),Pairs(:,2),1,length(PointIndex),length(PointIndex));
    %% make the feature index map to the image space
MaskSize=size(Mask);    
Temp=zeros(size(MaskLinear));
Temp(MaskLinear~=0)=FeatureIndex;
FeatureIndexMap=reshape(Temp,size(Mask));
PointNum=length(PointIndex);
ShiftArray=ShiftListComputing(Connectivity,Dimlength);
ShiftNum=size(ShiftArray,1);
NumPerGroup=1000;
GroupNum=ceil(PointNum/NumPerGroup);
for G=1:GroupNum
    Start=(G-1)*NumPerGroup+1;
    End=min(PointNum,G*NumPerGroup);
    parfor i=Start:End
        if mod(i,1000)==0
            disp(['   Point=',num2str(i)]);
        end

        CurrentPoint=PointIndex(i);
        FeatureIndexCenterPoint=FeatureIndexMap(CurrentPoint);
        if Dimlength==2
            [x,y]=ind2sub(size(Mask),CurrentPoints);
            CenterPointSub=[x,y];
        end
        if Dimlength==3
            [x,y,z]=ind2sub(size(Mask),CurrentPoint);
            CenterPointSub=[x,y,z];
        end
        NeighbPointSubArray=repmat(CenterPointSub,[ShiftNum,1])+ShiftArray;
        [NeighbPointIndArray]=Sub2IndInsideImage(NeighbPointSubArray,size(Mask));

        for j=1:length(NeighbPointIndArray)

                if Regions(CurrentPoint)==Regions(NeighbPointIndArray(j))
                    FeatureIndexNeighbor=FeatureIndexMap(NeighbPointIndArray(j));
                    if SparseMatrix(FeatureIndexCenterPoint,FeatureIndexNeighbor)~=1
                        disp(['Mistake for point ( ',num2str(NeighbPointSubArray(j,:)),' ) and point ( ',num2str(CenterPointSub),' )' ])
                    end
                end

        end
    end
    disp(['Finish Group ',num2str(G)]);
end






end


function [InOrNot]=PointInImage(Point,MaskSize)
if length(Point,2)~=length(MaskSize)
    error('Point and mask should in the same dimensionality  (DimLength)');
else
    InOrNot=1;
    if sum(Point<1)>0
        InOrNot=0;
    end
    if sum(Point>MaskSize)>0
        InOrNot=0;
    end
end
end


function [PointIndexList]=Sub2IndInsideImage(PointSubArray,ImageSize)
PointNum=size(PointSubArray,1);
Dim=size(PointSubArray,2);
MaxArray=repmat(ImageSize,[PointNum,1]);
PointInside=sum(double(PointSubArray>=1)+double(PointSubArray<=MaxArray),2);
InsidePointSubArray=PointSubArray(PointInside==2*Dim,:);
switch Dim
    case 2
        PointIndexList=sub2ind(ImageSize,InsidePointSubArray(:,1),InsidePointSubArray(:,2));
    case 3
        PointIndexList=sub2ind(ImageSize,InsidePointSubArray(:,1),InsidePointSubArray(:,2),InsidePointSubArray(:,3));
    case 4
        PointIndexList=sub2ind(ImageSize,InsidePointSubArray(:,1),InsidePointSubArray(:,2),InsidePointSubArray(:,3),InsidePointSubArray(:,4));
    otherwise
        error('please update the code for other dimensionality')
end
end



