function [ConnectedPairs,PairInstantNum,BoundListAll ] = SupervoxelGraph( SupervoxelMap,Connectivitiy, CountPairAppearNum )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   Input
%   SupervoxelMap,  it is an integar map, and assume that the supervoxel
%   index start from 1.
%
%   Connectivitiy -> for 2D, 4  or 8 (default),  for 3D 6 or 26 (default)
%
%
%
%

SupervoxelMap=squeeze(SupervoxelMap);
DimLength=length(size(SupervoxelMap));


%% check the connectivity
if nargin<2
    CountPairAppearNum=0;
    switch DimLength
        case 2
            Connectivitiy=8;
        case 3
            Connectivitiy=26;
        otherwise
            error('Current only support 2D and 3D images');
    end
else
    switch DimLength
        case 2
            if Connectivitiy~=4 & Connectivitiy~=8
                error('for 2D image, only 4 or 8 connectivity');
            end
        case 3
            if Connectivitiy~=6 & Connectivitiy~=26
                error('for 2D image, only 6 or 26 connectivity');
            end
        otherwise
            error('Current only support 2D and 3D images');
    end
end
if nargin<3
    CountPairAppearNum=0;
end

%% make the shiftList
[ShiftList]=ShiftListComputing(Connectivitiy,DimLength);


%% 
N=size(ShiftList,1);
BoundListAll=[];
ImageSize=size(SupervoxelMap);
PadLabel=zeros(ImageSize+2);
if DimLength==2
    PadLabel(2:end-1,2:end-1)=SupervoxelMap;
end
if DimLength==3
    PadLabel(2:end-1,2:end-1,2:end-1)=SupervoxelMap;
end



for i=1:N
    disp(['Shifting # ',num2str(i), '    ',num2str(ShiftList(i,:))])
    Shift=ShiftList(i,:);
    %% computed the shifted label image
    if DimLength==2
        ShiftLabel=PadLabel(2+Shift(1):end-1+Shift(1),2+Shift(2):end-1+Shift(2));
    end
    if DimLength==3
        ShiftLabel=PadLabel(2+Shift(1):end-1+Shift(1),2+Shift(2):end-1+Shift(2),2+Shift(3):end-1+Shift(3));
    end
    %%
    Linear=[ShiftLabel(:),SupervoxelMap(:)];
    IndList=ShiftLabel(:)~=SupervoxelMap(:);
    BoundListAll=[BoundListAll;Linear(IndList,:)];
end
    
    
%% from the BoundListAll to compute the connected pairs
UniqueList=unique(BoundListAll,'rows');


        
%% remove the pairs that contains 0 (indicate the background in the padding)
RemoveInd=UniqueList(:,1)==0 | UniqueList(:,2)==0;
UniqueList(RemoveInd,:)=[];

%% count the number of points for each neighbor pair
if CountPairAppearNum~=0
    PairNum=size(UniqueList,1);
    PairInstantNum=zeros(PairNum,1);
    parfor i=1:PairNum
        %if mod(i,1)==0
            disp(['Pair ==> ',num2str(i)])
        %end
        Pair=UniqueList(i,:);
        PairInstantNum(i)=sum(BoundListAll(:,1)==Pair(1)  & BoundListAll(:,2)==Pair(2));
    end
else
    PairInstantNum=[];
end
    
ConnectedPairs=UniqueList;






end

