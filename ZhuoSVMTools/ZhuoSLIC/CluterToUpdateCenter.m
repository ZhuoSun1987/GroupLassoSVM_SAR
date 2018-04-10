function [CenterPos,CenterInd,CenterIntenList]=CluterToUpdateCenter(ClusterMap,ImageList)
%   this function is used to update the cluster center based on the current
%   supervoxel
%
%   for the current unlabeled point (not clustered to any supervoxel), its
%   label is -1
%
%   Zhuo Sun  20160329

Dim=size(ClusterMap);
ImNum=length(ImageList);

LabelList=unique(ClusterMap(:));
LabelList=sort(LabelList);
if LabelList(1)==-1
    LabelList(1)=[];
end
LabelNum=length(LabelList);
CenterIntenList=zeros(LabelNum,ImNum);
CenterPos=[];
for i=1:LabelNum
    Label=LabelList(i);
    Ind=find(ClusterMap==Label);
    Sub=IndToSubND(Dim,Ind);
    for j=1:ImNum
        CenterIntenList(i,j)=mean(ImageList{j}(Ind));
    end
    MeanSub=[];
    if size(Sub,1)>1
        MeanSub=round(mean(Sub));
    else
        MeanSub=(Sub);
    end
    
    if ClusterMap(SubToIndND(Dim,MeanSub))==Label
        CenterPos=[CenterPos;MeanSub];
    else
        DistList=sum((Sub-repmat(mean(Sub),[size(Sub,1),1])).^2,2);
        MinDis=min(DistList);
        MinDisPos=find(DistList==MinDis);
        MinDisPos=MinDisPos(1);
        CenterPos=[CenterPos;Sub(MinDisPos,:)];
    end
end

CenterInd=SubToIndND(Dim,CenterPos);
        
    




end 