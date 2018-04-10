function [ StdList,MeanList ] = SAP_Std_Computing(Pairs,WeightList,MaxNeighbor)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the mean and std of a point in its
%   same structure neighbors
%
%   Pairs is a [P*2] matrix,
%
%   Zhuo Sun  20161004

N=length(WeightList);
Mat=nan*ones(MaxNeighbor,N);

MeanList=zeros(N,1);
StdList =zeros(N,1);

Pairs=[Pairs;[Pairs(:,2),Pairs(:,1)]];
Pairs=sortrows(Pairs,1);

Pairs1=Pairs(:,1);
Pairs2=Pairs(:,2);

parfor i=1:N
    Inds=find(Pairs1);
    Max=max(Inds);  Min=min(Inds);
    Num=Max-Min+1;
    Ind2s=Pairs2(Min:Max);
    Neighbors=WeightList(Ind2s);
    All=[WeightList(i); reshape(Neighbors,[Num,1])];
    StdList(i) =std(All);
    MeanList(i)=mean(All);
end






end