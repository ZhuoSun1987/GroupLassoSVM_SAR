function [ M ] = SpatialAnatomyScoreApproximateMatrix( ConnectIndexPairList,ConnectedPairSquareDistList,ROIPointNum,X,KernelType,KernelParameter,OptWeightList )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the approximate matrix (graph Laplacian
%   matrix) for the spatial-anatomical regularization
%
%   the input ConnectIndexPairList,ConnectedPairSquareDistList ROIPointNum is generated
%   by the function   [Result]= ConnectivityMatrix( SegmentMap,SegList,Connectivity )
% 
%   X is a feature matrix size=[V,d], V is the voxel
%
%
%   Zhuo Sun  2016-01-13


%%
PairNum=size(ConnectIndexPairList,1);
if length(ConnectedPairSquareDistList)~=PairNum
    error('Input size do not fit');
end

%% construct the sparse pairwise  dis-similarity penalty matrix A -> size=[PairNum,]

    %% compute the weight for each pair
if nargin <5
    KernelType='Uniform';
end
WeightList=zeros(PairNum,1);
if ~isempty(KernelType)
    switch KernelType
        case 'Uniform'
            WeightList=ones(PairNum,1);        
        case 'Linear'
            if nargin<6
                KernelParameter.LinearScale=1;
            end
            WeightList=KernelParameter.LinearScale*ConnectedPairSquareDistList;

        case 'Gaussian'
            if nargin<6
                KernelParameter.GaussScale=1;
                KernelParameter.GaussStd=1;
            end
            WeightList=KernelParameter.GaussScale*exp(ConnectedPairSquareDistList/KernelParameter.GaussStd);

        otherwise
            error(['Non-defined KernelType -> ', KernelType ])
    end
else  % use the pre-defined OptWeightList
    WeightList=OptWeightList;
end

    %% Compute the sparse pairwise  dis-similarity penalty matrix A -> size=[PairNum,]
    A=sparse([1:PairNum,1:PairNum],[ConnectIndexPairList(:,1);ConnectIndexPairList(:,1)],[WeightList; -1*WeightList],PairNum,ROIPointNum);

    %% Compute the equavilent matrix M=(A*X)^t *( A*X)
    AX=A*X;
    M=(AX' )*AX;

 
end

