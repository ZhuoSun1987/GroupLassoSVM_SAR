function [ L, NormL ] = GraphLaplacianFromPairs( Pairs, PairWeight, FeatureSize )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this fucntion is used to construct the graph laplacian matrix based on
%   the pairs.
%
%   Pair is a P*2 matrix
%
%   Zhuo Sun  20160816


if nargin==1
    FeatureSize=max(Pairs(:));
    PairNum=size(Pairs,1);
    PairWeight =ones(PairNum,1);
end
if nargin==2
    FeatureSize=max(Pairs(:));
end



%% construct the sparse graph matrix
A=sparse(Pairs(:,1),Pairs(:,2),PairWeight,FeatureSize,FeatureSize);

%% construct the sparse diagnoal matrix
Ind=(1:FeatureSize)';
SumList=sum(A,2);
D=sparse(Ind,Ind,SumList,FeatureSize,FeatureSize);


%% compute the Graph Laplacian
L=D-A;

%% compute the norlaized graph Laplacain
D_RootInv=sparse(Ind,Ind,1./(SumList.^0.5),FeatureSize,FeatureSize);
NormL=D_RootInv*L*D_RootInv;



end
