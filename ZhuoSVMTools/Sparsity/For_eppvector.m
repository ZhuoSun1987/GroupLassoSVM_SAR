function [ ResultVector,ProjVector,BackMap ] = For_eppvector( Vector, GroupLabel,GroupROI,WeightList,q )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to prepare the data for the mex file eppvector
%   and run this mex 
%
%   it need the SLEP toolbox,  currently, we use the SLEP 4.1 from Jieping
%   Ye
%
%   Vector => a n*1 vector,
%   GroupLabel => a n*1 vector, each element is a integar to indicate the
%                 group this element belongs to. 
%   GroupROI => a list of integars that we are interested in. If it is
%   empty, we interested in all the groups. The size is [G,1] if it is
%   empty, then the default size G is length(unique(GroupLabel)).
%
%   WeightList is a [G,1] vector, each one is a parameter for the threshold
%   for a group.
%
%   q is the norm of the group lasso L_{1-q} norm
%
%   Zhuo Sun   20160607



%% check the GroupROI
if isempty(GroupROI)
    GroupROI=unique(GroupLabel);
end
GroupNum=length(GroupROI);

%% transfer the non-continous distribute GroupLabel into continous distributed ones
NewVector=[];
BackMap=[];
ind=zeros(GroupNum+1,1);
ind(1)=0;
for i=1:GroupNum
    GroupInd=GroupROI(i);
    FeatureInd=find(GroupLabel==GroupInd);
    NewVector=[NewVector;Vector(FeatureInd)];
    BackMap  =[BackMap  ;FeatureInd];
    ind(i+1)=ind(i)+length(FeatureInd);
end

%% use the eppvector mex
k=GroupNum;
n=length(NewVector);
ProjVector=eppVector(NewVector, ind, k, n, WeightList, q);
 
%% back the project vector back into the origianl index position
ResultVector=Vector;
ResultVector(BackMap)=ProjVector;
end

