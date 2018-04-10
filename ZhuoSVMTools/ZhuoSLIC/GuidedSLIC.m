function [ ClusterMap,CenterPos ] = GuidedSLIC( ImageList,Seg,GridNumList,NeighbourList, MaxIter,Option)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   GridNumList => the number of uniform grid in each direction 
%   NeighbourList ==> the initial neighbor List of initally search for
%   local neigbor minimal gradient amplitude point
%      
%   ZhuoSun

Image=squeeze(ImageList{1});
Seg  =squeeze(Seg);
Dim=size(Image);
Dim2=size(Seg);
if ~isequal(Dim,Dim2)
    error('the size of image and segmentation is not equal')
end
DimLength=length(Dim);

ImNum=length(ImageList);
%% 
if length(GridNumList)==1
    GridNumList=GridNumList*ones(1,DimLength);
else
    if length(GridNumList) ~= DimLength
        error('size of GridNumList is not proper');
    end
end

GridSize=round(Dim./(GridNumList+1));
WithCentrOrNot=1;
ShiftList1=PositionShift(2*GridSize,WithCentrOrNot );  % with center 
ShiftList2=PositionShift(2*GridSize,0 );               % without center

disp(['Regular grid size ==>', num2str(GridSize)])
if length(NeighbourList)==1
    NeighbourList=NeighbourList*ones(1,DimLength);
else
    if length(NeighbourList) ~= DimLength
        error('size of NeighbourList is not proper');
    end
end

%% the uniform grid points, without considering the local minimal gradient neighbor
Grid1DArray=cell(DimLength,1);
for i=1:DimLength
    Grid1DArray{i}=round(GridSize(i)*((1:GridNumList(i))'));
end

PosList=zeros(prod(GridNumList),DimLength);
for i=1:DimLength
    
    Before=prod(GridNumList(1:i-1));
  
    After =prod(GridNumList(i+1:end));
    
    Part1=repmat(reshape(Grid1DArray{i},[1,length(Grid1DArray{i})]),[After,1]);
    PosList(:,i)=repmat(Part1(:),[Before,1]);
end



%% Compute the gradient amplitude field 
GradAmp=GradientAmp( ImageList );
WithCentrOrNot=1;
ShiftList0 = PositionShift( ones(DimLength,1),WithCentrOrNot );
%% for the local neighbor of minimial gradient amplitude points of each uniform grid point
IncludeCenter=1;
NeigbList=ones(DimLength,1);
for i=1:size(PosList,1)
    GridPoint=PosList(i,:);
    
    [NInd,NPoint]=NeigbInsidePointIndex(GridPoint,Dim,ShiftList0);
    
    MinGradAmp=min(GradAmp(NInd));
    ListInd=find(GradAmp(NInd)==MinGradAmp);
    
    if length(ListInd)==1
        PosList(i,:)=NPoint(ListInd,:);
    else
        SpatialDistList=sum((NPoint(ListInd,:)-repmat(PosList(i,:),[length(ListInd),1])).^2,2);
        OptInd=ListInd(find(SpatialDistList==min(SpatialDistList),1,'first'));
        PosList(i,:)=NPoint(OptInd,:);
    end
end


%% Check if some ROIs in the segmentation has no initial cluster center, if so add center for such ROIs
[ CenterInd ] = SubToIndND( Dim,PosList );
AllSegLabel=unique(Seg(:));
AllCenterLabel=unique(Seg(CenterInd));
NoCenterROI=setdiff(AllCenterLabel,AllCenterLabel) ;
for i=1:length(NoCenterROI)
    Label=NoCenterROI(i);
    Ind=find(Seg==Label);
    Points=IndToSubND(Dim,Ind);
    MeanPoint=round(mean(Points));
    if Seg(MeanPoint)==Label
        PosList=[PosList;MeanPoint];
    else
        DistList=sum((Points-repmat(MeanPoint,[size(Points,1),1])).^2,2);
        MinDist=min(DistList);
        OptPos=find(DistList==MinDist);
        PosList=[PosList;Points(OptPos(1),:)];
    end
end
disp(['Initilizationi with ', num2str(size(PosList,1)) ,' Initial cluster centers'])

%% iterative solve the problem
CenterList=PosList;

ClusterLabelList=[1:size(PosList,1)]';
CenterIndList=SubToIndND(Dim,CenterList);
CenterLabelList=Seg(CenterIndList);
CenterIntenseList=zeros(size(PosList,1),ImNum);
for i=1:ImNum
    CenterIntenseList(:,i)=ImageList{i}(CenterIndList);
end
HasUnlabelComponnet=1;
ClusterMap=-1*ones(Dim);
DistMap=inf*ones(Dim);
KeepIter=1;
Iter=0;
PreClusterMap=ClusterMap;
DirectNormVector=reshape(1./(GridSize.^2),[DimLength,1]);

while KeepIter
    Iter=Iter+1;
    t=clock;
    disp(['    Iteration ==> ',num2str(Iter), '  StartTime==> ',datestr(t)]);
    for C=1:size(CenterList,1)
        Center=CenterList(C,:);
        [NInd,NPoint]=NeigbInsidePointIndex(Center,Dim,ShiftList1);
        %% compute the cost of each neighbor point (in the 2*S earch region) to the current center
        SpatialDistList=((NPoint-repmat(Center,[length(NInd),1])).^2)*DirectNormVector;
        IntenseDistList=zeros(length(NInd),1);
        for i=1:ImNum
            IntenseDistList=sum((ImageList{i}(NInd)-CenterIntenseList(C,i)).^2,2);
        end
        LabelDistList=zeros(length(NInd),1);
        LabelDistList(Seg(NInd)~=CenterLabelList(C))=inf;
        if Option.Type==1 % adaptive
            SpaMax=max(SpatialDistList);
            IntMax=max(IntenseDistList);
            DistList=LabelDistList+SpatialDistList/SpaMax+IntenseDistList/IntMax;
        else   % people set a 'm'
            DistList=IntenseDistList+SpatialDistList*(Option.m^2)+LabelDistList;
        end
        NCostList=DistMap(NInd);
        DistMap(NInd(NCostList>DistList))=DistList(NCostList>DistList);
        ClusterMap(NInd(NCostList>DistList))=ClusterLabelList(C);       
    end
    
    
    %% check if it reach max iter or converge
    if Iter>=MaxIter
        KeepIter=0;
        disp('End....   reach the max iteration')
    end
    
    DifSum=sum(ClusterMap(:)~=PreClusterMap(:));
    if sum(DifSum)==0 % & sum(ClusterMap(:)==-1)==0
        KeepIter=0;
        disp('End....   clustering converge')
    else
        disp(['   Number of points change label = ',num2str(DifSum)])
    end
    %%  Update the Clusters and previous cluster map
    PreClusterMap=ClusterMap;
    [CenterList,CenterIndList,CenterIntenseList]=CluterToUpdateCenter(ClusterMap,ImageList); 
    
    
    %% Check if there is unlabeled componentes
    BW=(ClusterMap==-1);
    disp(['   number of unlabeled points =', num2str(sum(BW(:)==1)),' Current ClusterNum ',num2str(size(CenterList,1))])
% %     Nii=make_nii(double(BW),[]);
% %     save_nii(Nii,['BW_Iter_',num2str(Iter,'%04d'),'.nii.gz'])
    AddCenters=[];
    if sum(BW(:))>0
        % some unlabeled components
        CC=bwconncomp(BW);
        for j=1:CC.NumObjects
            ComponentSub=FromInd2Sub(CC.PixelIdxList{j},Dim);  %?%
            Mean=round(mean(ComponentSub));
            Dist=sum((ComponentSub-repmat(Mean,[size(ComponentSub,1),1])).^2,2);
            if min(Dist)==0
                NewCenter=Mean;
                AddCenters=[AddCenters;NewCenter];
            else
                OptInd=find(Dist==min(Dist));
                NewCenter=ComponentSub(OptInd,:);
                AddCenters=[AddCenters;NewCenter];
            end
        end          
    end
    if ~isempty(AddCenters)
        disp(['   Add # ',num2str(size(AddCenters,1)),' cluster centers'])
        AddCenters
    end
    
    %% add the new cluster centers into the already exist centers
    if ~isempty(AddCenters)
        CenterList=[CenterList;AddCenters];
        CurrentMaxClusteLabel=max(ClusterLabelList);
        ClusterLabelList=[ClusterLabelList; [CurrentMaxClusteLabel+1:CurrentMaxClusteLabel+size(AddCenters)]'];
        AddCenterIndList=SubToIndND(Dim,AddCenters);
        CenterLabelList=[CenterLabelList;Seg(AddCenterIndList)];
        AddCenterIntensityList=zeros(length(AddCenterIndList),ImNum);
        for i=1:ImNum
            AddCenterIntensityList(:,i)=ImageList{i}(AddCenterIndList);
        end
        CenterIntenseList=[CenterIntenseList;AddCenterIntensityList];
    end


    
end

CenterPos=CenterList;


%%  this part is used to refine the clustering the keep the continuity of the supervoxel
if ~isfield(Option,'Refine')
    Option.Refine=1;
end

if Option.Refine==1
    Connectivity=Option.Connectivity;
    UseParallel=1;
    [ClusterMap] =RefineCluster(ClusterMap,Seg,Connectivity, UseParallel);

    ShortImageList=cell(1,1);
    ShortImageList{1}=ImageList{1};

    [CenterList,CenterIndList,CenterIntenseList]=CluterToUpdateCenter(ClusterMap,ShortImageList);
end

end

