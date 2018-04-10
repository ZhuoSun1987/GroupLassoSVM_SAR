function [ Cost ] = SparsityCost( W,SparsityOpt )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the cost of the sparsity term
%
%   Zhuo Sun  
%   start to work at  20160608



switch SparsityOpt.SparseType
    case 'Lasso'
        Cost=Lasso_Cost(W);
    case 'WeightedLasso'
        Cost=WeightedLasso_Cost(W,SparsityOption.FeatureWiseWeight);

    case 'GroupLasso'
        Cost=L1Lq_Cost(W,SparsityOpt.GroupLassoOpt);
    case 'FuseLasso'
        
    case 'SparseGroup'
        
    case 'TreeStructGroupLasso'

    case 'OverlapGroupLasso'


end





end

function [result]=Lasso_Cost(W)
result=sum(abs(W));
end

function [result]=WeightedLasso_Cost(W,FeatureWiseWeight)
result=sum(abs(W.*FeatureWiseWeight));
end

function [result]=L1Lq_Cost(W,GroupLassoOpt)
NormP=GroupLassoOpt.q;
GroupWeight=GroupLassoOpt.GroupWeight;
ROI        =GroupLassoOpt.ROI;  % the unique group index that we are interested
GroupLabel =GroupLassoOpt.GroupLabel; 
GroupIndPosListArray=GroupLassoOpt.GroupIndPosListArray;


[NormList]=cellfun(@(GroupIndPosList) SingleGroupNorm(W,GroupIndPosList,NormP),GroupIndPosListArray);
result=(GroupWeight')*NormList;

% % result=0;
% % for i=1:length(ROI)
% %     Label=ROI(i);
% %     result=GroupWeight9i)*norm(W(GroupLabel==Label),q);
% % end
end

function [Norm]=SingleGroupNorm(W,GroupIndPosList,NormP)
FeatVec=W(GroupIndPosList);
Norm=norm(FeatVec,NormP);
end


