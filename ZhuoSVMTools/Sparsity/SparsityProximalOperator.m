function [ W ] = SparsityProximalOperator( W,C_Or_R,Lambda,Stepsize,SparsityOpt )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the 
%
%   W => the variable which to make Proximal on.
%   C_Or_R  => Constraint or Regularization
%
%
%
%   Zhuo Sun  20160607  
%   updated 20160622 for the group lasso

if Lambda>0
    switch SparsityOpt.SparseType
        case 'Lasso'
            if C_Or_R==2  % the regularization
                % in Lasso, Lambda is a [1,1], The threshold is based on section
                % 2.1 of Amir Beck's FISTA SIAM 2009 paper
                if Lambda>0
                    Threshold=Stepsize*Lambda(1);
                    W(1:end-1)=SoftThreshold(W(1:end-1),Threshold);
                end
            end
            if C_Or_R==1 % the Constraint, using SLEP


            end
        case 'WeightedLasso'
            if C_Or_R==2  % the regularization
                if Lambda>0
                    Threshold=SparsityOption.FeatureWiseWeight*Stepsize*Lambda(1);
                    W(1:end-1)=SoftThreshold(W(1:end-1),Threshold);
                end
            end


        case 'GroupLasso'
            if C_Or_R==2  % regularization
                W(1:end-1) = GrouopLassoProximal( W(1:end-1),Lambda,Stepsize,SparsityOpt.GroupLassoOpt );
            else
                error('have not implement the constraint group lasso');
            end
            

        case 'FuseLasso'

        case 'SparseGroup'

        case 'TreeStructGroupLasso'

        case 'OverlapGroupLasso'


    end
else
    W1=W;
    W=W1;
end

end



function [W]=SoftThreshold(V,Threshold)
%   this function is the softthreshoding
%   V is the input vector, size is [n,1];
%   Threshold,  size is either 1 or [n,1];
%
%   Zhuo Sun,  tested  20160608

W=sign(V).*max(abs(V)-Threshold,0);


end

