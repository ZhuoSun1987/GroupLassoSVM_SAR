function [ClusterMap] =RefineCluster(ClusterMap,Seg,Connectivity, UseParallel)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to refine the segmentation
%   to keep the continuity of the supervoxel clustering while also not
%   cross the boundary of the segmentation
%   
%   Zhuo Sun   20160331


Dim=size(ClusterMap);
DimLength=length(Dim);
if nargin<2
    Seg=ones(Dim);
end
if nargin<3
    if DimLength<=3
        Connectivity=3^DimLength-1;
    else
        Connectivity=conndef(DimLength,'maximal');
    end
end
if nargin<4
    UseParallel=1;
end

ClusterNum=length(unique(ClusterMap));
ClusterLabelList=unique(ClusterMap);
IndList1=cell(ClusterNum,1);
BW0=ones(Dim);
if UseParallel==1
   s=matlabpool('size');
   if s==0
       matlabpool open
   end
   CPUNum=matlabpool('size');
   %% select the max component of each cluster
   parfor i=1:ClusterNum
       Label=ClusterLabelList(i);
       CC=bwconncomp(ClusterMap==Label,Connectivity);
       CompNum=CC.NumObjects;
       if CompNum==1
           IndList1{i}=CC.PixelIdxList{1};
       else
           PixNumLength=zeros(CompNum,1);
           for j=1:CompNum
               PixNumLength(j)=length(CC.PixelIdxList{j});
           end
           OptPos=find(PixNumLength==max(PixNumLength));
           IndList1{i}=CC.PixelIdxList{OptPos(1)};
       end
   end
   IndList2=[];
   for i=1:ClusterNum
       IndList2=[IndList2;IndList1{i}];
   end
   BW0(IndList2)=0;
   CC=bwconncomp(BW0,Connectivity);
   LeftCompNum=CC.NumObjects
   NewClusterPartArray=cell(LeftCompNum,1);
   NewClusterIndArray =cell(LeftCompNum,1);
   
   for i=1:LeftCompNum
      Ind=CC.PixelIdxList{i}; 
      Sub=IndToSubND(Dim,Ind);
      if size(Sub,1)==1
          Min=Sub;   
          Max=Sub;
      else
          Min=min(Sub);
          Max=max(Sub);
      end
      Min=max([Min-1;ones(1,DimLength)]);
      Max=min([Max+1;Dim]);
      switch DimLength
          case 2
              ClusterPart=ClusterMap(Min(1):Max(1),Min(2):Max(2));
              SegPart    =Seg(Min(1):Max(1),Min(2):Max(2));
              UnClearPart=BW0(Min(1):Max(1),Min(2):Max(2));
          case 3
              SegPart    =Seg(Min(1):Max(1),Min(2):Max(2),Min(3):Max(3));
              ClusterPart=ClusterMap(Min(1):Max(1),Min(2):Max(2),Min(3):Max(3));
              UnClearPart=BW0(Min(1):Max(1),Min(2):Max(2),Min(3):Max(3));
          case 4
              SegPart    =Seg(Min(1):Max(1),Min(2):Max(2),Min(3):Max(3),Min(4):Max(4));
              ClusterPart=ClusterMap(Min(1):Max(1),Min(2):Max(2),Min(3):Max(3),Min(4):Max(4));
              UnClearPart=BW0(Min(1):Max(1),Min(2):Max(2),Min(3):Max(3),Min(4):Max(4));
          otherwise 
              error('Unsupported dimension')
      end
      ClearClusterPart=double(ClusterPart).*double(1-UnClearPart);
      ClusterPartLin=ClusterPart(:);
     
      ClearLabelList=unique(ClusterPartLin(logical(1-UnClearPart(:))));
      ClearLabelNum=length(ClearLabelList);
      UnClearPointNum=sum(UnClearPart(:));
      if ClearLabelNum==1
          NewLabelList=ClearLabelList(1)*ones(UnClearPointNum,1);
      else
      
          
          NewLabelList=-1*ones(UnClearPointNum,1);
          CostList    =inf*ones(UnClearPointNum,1);
          for j=1:ClearLabelNum
              ClearLabel=ClearLabelList(j);
              ClearLabelSeg=SegPart(find(ClusterPartLin==ClearLabel,1,'first'));
              BWPart=ClearClusterPart==ClearLabel;
              DistMap=bwdist(BWPart);
              DistUnClearPointList=DistMap(logical(UnClearPart(:)));
              SegUpClearPointList =SegPart(logical(UnClearPart(:)));
              DistUnClearPointList(SegUpClearPointList ~=ClearLabelSeg )=inf;
              NewLabelList(DistUnClearPointList<CostList)=ClearLabel;
              CostList(DistUnClearPointList<CostList)=DistUnClearPointList(DistUnClearPointList<CostList);
          end
      end
      if sum(NewLabelList==-1)>0
          error(['Still some point is not proper refined...', ' For Left region ',num2str(i) ])
      else
%           disp(['finish correct left part ',num2str(i)])
      end
          
      
      NewClusterPartArray{i}=NewLabelList;
      IndPart=find(UnClearPart==1);
      SubPart=IndToSubND(size(UnClearPart),IndPart);
      SubAll=SubPart+repmat(Min,[size(SubPart,1),1])-1;
      IndAll =SubToIndND(Dim,SubAll);
      NewClusterIndArray{i}=IndAll;
   end
   NewClusterAll=[];
   NewIndAll    =[];
   for i=1:LeftCompNum
       NewClusterAll=[NewClusterAll;NewClusterPartArray{i}];
       NewIndAll    =[NewIndAll;NewClusterIndArray{i}];
   end
   ClusterMap(NewIndAll)=NewClusterAll;
       
 
   
   
   
   
    
    
    
    
else
    disp('Currently, only the parallel version availabel')
    
    
end






end

