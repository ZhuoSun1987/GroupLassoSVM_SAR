function [Result]= ConnectivityMatrix( SegmentMap,SegList,Connectivity )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to build the connectivity matrix 
%   SegList -> the segmenation label list of ROIs
%   
%
%   Zhuo Sun  2015-09-24
SegmentMap=squeeze(SegmentMap);
Binary=zeros(size(SegmentMap));

%%  generate the binary ROI
for i=1:length(SegList)
    Seg=SegList(i);
    Binary=Binary+(SegmentMap==Seg);
end


%%  give each voxel in the binary ROI an unique index, and this unique index is the 
BinaryLinear=Binary(:);
ROIPointNum=sum(BinaryLinear);

UniqueIndexMapLinear=zeros(size(BinaryLinear));
UniqueIndexMapLinear(BinaryLinear==1)=1:ROIPointNum;
UniqueIndexMap=reshape(UniqueIndexMapLinear,size(Binary));


%% compute a shift list
Dim=size(SegmentMap);
DimLength=length(Dim);

ShiftArray=ShiftListComputing(Connectivity,DimLength);
    % remove the cases that there is no shift
Dist=sum(ShiftArray.^2,2);
ZeroPos=find(Dist==0);
if ~isempty(ZeroPos)
    ShiftArray(ZeroPos,:)=[];
end


%%  Create the padded image
Dim=size(SegmentMap);
PadZeros=zeros(Dim+2);
DimLength=length(Dim);
PadIndex =zeros(Dim+2);
PadSeg   =zeros(Dim+2);
PadBinary=zeros(Dim+2);
if DimLength==3
    PadIndex(2:end-1,2:end-1,2:end-1) =UniqueIndexMap;
    PadSeg(2:end-1,2:end-1,2:end-1)   =SegmentMap;
    PadBinary(2:end-1,2:end-1,2:end-1)=Binary;    
end

if DimLength==2
    PadIndex(2:end-1,2:end-1) =UniqueIndexMap;
    PadSeg(2:end-1,2:end-1)   =SegmentMap;
    PadBinary(2:end-1,2:end-1)=Binary;        
end



%% find the pair of points (represented by its unique index)
SameRegionConnectPair=[];
SameRegionConnectDistSquareList=[];
DifRegionConnectPair =[];
DifRegionConnectDistSquareList =[];
ShiftNum=size(ShiftArray,1)
for i=1:ShiftNum
    if DimLength==3
        ShiftIndexMap =PadIndex(2+ShiftArray(i,1):end-1+ShiftArray(i,1),2+ShiftArray(i,2):end-1+ShiftArray(i,2),2+ShiftArray(i,3):end-1+ShiftArray(i,3));
        ShiftSegMap   =PadSeg(2+ShiftArray(i,1):end-1+ShiftArray(i,1),2+ShiftArray(i,2):end-1+ShiftArray(i,2),2+ShiftArray(i,3):end-1+ShiftArray(i,3));
        ShiftBinaryMap=PadBinary(2+ShiftArray(i,1):end-1+ShiftArray(i,1),2+ShiftArray(i,2):end-1+ShiftArray(i,2),2+ShiftArray(i,3):end-1+ShiftArray(i,3));
        
        SameLabelMatrix=(ShiftSegMap==SegmentMap) & (Binary==1);
        Point1=UniqueIndexMap(SameLabelMatrix(:)==1);
        Point2=ShiftIndexMap(SameLabelMatrix(:)==1);
        SameRegionConnectPair=[SameRegionConnectPair;[Point1,Point2]];
        SameRegionConnectDistSquareList=[SameRegionConnectDistSquareList;sum(ShiftArray(i,:).^2)*ones(length(Point1),1)];
        
        DiffLabelMatrix=(ShiftSegMap~=SegmentMap) & (Binary==1 & ShiftBinaryMap==1);
        Point1=UniqueIndexMap(DiffLabelMatrix(:)==1);
        Point2=ShiftIndexMap(DiffLabelMatrix(:)==1);
        DifRegionConnectPair=[DifRegionConnectPair;[Point1,Point2]];
        DifRegionConnectDistSquareList=[DifRegionConnectDistSquareList;sum(ShiftArray(i,:).^2)*ones(length(Point1),1)];
    end
    
    
    if DimLength==2
        ShiftIndexMap =PadIndex(2+ShiftArray(i,1):end-1+ShiftArray(i,1),2+ShiftArray(i,2):end-1+ShiftArray(i,2));
        ShiftSegMap   =PadSeg(2+ShiftArray(i,1):end-1+ShiftArray(i,1),2+ShiftArray(i,2):end-1+ShiftArray(i,2));
        ShiftBinaryMap=PadBinary(2+ShiftArray(i,1):end-1+ShiftArray(i,1),2+ShiftArray(i,2):end-1+ShiftArray(i,2));  
        
        SameLabelMatrix=(ShiftSegMap==SegmentMap) & (Binary==1);
        Point1=UniqueIndexMap(SameLabelMatrix(:)==1);
        Point2=ShiftIndexMap(SameLabelMatrix(:)==1);
        SameRegionConnectPair=[SameRegionConnectPair;[Point1,Point2]];
        SameRegionConnectDistSquareList=[SameRegionConnectDistSquareList;sum(ShiftArray(i,:).^2)*ones(length(Point1),1)];
        
        DiffLabelMatrix=(ShiftSegMap~=SegmentMap) & (Binary==1 & ShiftBinaryMap==1);
        Point1=UniqueIndexMap(DiffLabelMatrix(:)==1);
        Point2=ShiftIndexMap(DiffLabelMatrix(:)==1);
        DifRegionConnectPair=[DifRegionConnectPair;[Point1,Point2]];  
        DifRegionConnectDistSquareList=[DifRegionConnectDistSquareList;sum(ShiftArray(i,:).^2)*ones(length(Point1),1)];
    end
 
    
end


%%  create the connect matrix (sparse matrix) for both boundary (connect point pair on different segment) and in the same region
SameRegionConnectMatrix=sparse(SameRegionConnectPair(:,1),SameRegionConnectPair(:,2),ones([size(SameRegionConnectPair,1),1]),ROIPointNum,ROIPointNum);
SameRegionConnectDistMatrix=sparse(SameRegionConnectPair(:,1),SameRegionConnectPair(:,2),SameRegionConnectDistSquareList,ROIPointNum,ROIPointNum);

DiffRegionConnectMatrix=sparse(DifRegionConnectPair(:,1), DifRegionConnectPair(:,2), ones([size(DifRegionConnectPair,1),1]),ROIPointNum,ROIPointNum);
DiffRegionConnectDistMatrix=sparse(DifRegionConnectPair(:,1), DifRegionConnectPair(:,2), DifRegionConnectDistSquareList,ROIPointNum,ROIPointNum);
IndexImage=UniqueIndexMap;

%  save the result into a structure
Result.SameRegionConnectMatrix=SameRegionConnectMatrix;
Result.SameRegionConnectPair  =SameRegionConnectPair;
Result.SameRegionConnectDistSquareList=SameRegionConnectDistSquareList;
Result.DiffRegionConnectMatrix=DiffRegionConnectMatrix;
Result.DifRegionConnectDistSquareList=DifRegionConnectDistSquareList;
Result.ROIPointNum =ROIPointNum;
Result.IndexImage=IndexImage;
Result.Binary=Binary;


end

