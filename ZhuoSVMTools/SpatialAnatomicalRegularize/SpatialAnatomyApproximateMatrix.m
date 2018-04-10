function [ M ] = SpatialAnatomyApproximateMatrix( ConnectIndexPairList,ConnectedPairSquareDistList,ROIPointNum,KernelType,KernelParameter,OptWeightList )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the approximate matrix (graph Laplacian
%   matrix) for the spatial-anatomical regularization
%
%   the input ConnectIndexPairList,ConnectedPairSquareDistList ROIPointNum is generated
%   by the function   [Result]= ConnectivityMatrix( SegmentMap,SegList,Connectivity )
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
if nargin <4
    KernelType='Uniform';
end
WeightList=zeros(PairNum,1);
if isempty(KernelType)
    switch KernelType
        case 'Uniform'
            WeightList=ones(PairNum,1);        
        case 'Linear'
            if nargin<5
                KernelParameter.LinearScale=1;
            end
            WeightList=KernelParameter.LinearScale*ConnectedPairSquareDistList;

        case 'Gaussian'
            if nargin<5
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
A=sparse([1:PairNum,1:PairNum],[ConnectIndexPairList(:,1);ConnectIndexPairList(:,1)],[WeightList; -1*WeightList],ROIPointNum,ROIPointNum);

    %% Compute the equavilent matrix M=A^t * A
M=(A' )*A;

 
end

