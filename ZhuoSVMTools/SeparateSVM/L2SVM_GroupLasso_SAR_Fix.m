function [ W,LOG ] = L2SVM_GroupLasso_SAR_Fix( X,Y,W0,GroupIndListArray,GroupWeightList,LL,LambdaList,q,Option )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to make the group lasso SAR SVM (square
%   hingeloss)
%   size(X)=[N,D+1], size(Y)=[N,1];  size(LL)=sparse matrix [D,D];
%   q the norm of groups, typically, it is 2 for L1L2 norm
%   z.sun

[N,dd]=size(X);
D=dd-1;
MaxIter    =Option.MaxIter;
StepSize   =Option.StepSize;
FISTAOrISTA=Option.FistaOrIsta;
SVMNorm    =Option.SVMNorm;
NeedCost   =Option.ComputeCost;
W_ChangeNormLimit  = Option.W_ChangeNormLimit;
W_ChangeRatioLimit = Option.W_ChangeRatioLimit;
GroupNum   =length(GroupIndListArray);
GroupWeightList=reshape(GroupWeightList,[1,GroupNum]);
MinIter    =Option.MinIter;
CostConvRatio=Option.CostConvRatio;

%global ProxW
%% the initial of FISTA
W_1=W0;
t_1=1;

%% make the quadratic cost term
Q=[];
NeedQPart=1;
if LambdaList(1)>0 & LambdaList(2)>0
    Q=LambdaList(1)*speye(D)+LambdaList(2)*LL;
end
if LambdaList(1)<=-0 & LambdaList(2)>0
    Q=LambdaList(2)*LL;
end
if LambdaList(1)>0 & LambdaList(2)<=0
    Q=LambdaList(1);
end 
if LambdaList(1)<=0 & LambdaList(2)<=0
    NeedQPart=0;
end 
%% 
W=W0;
BeforeProxiamlCostList=zeros(MaxIter,4);
AfterProxiamlCostList =zeros(MaxIter,4);

ThresholdList=num2cell(StepSize*reshape(GroupWeightList,[length(GroupWeightList),1])*LambdaList(3));
for Iter=1:MaxIter
    %% compute the gradient
    % the hingeloss term
    CostSubjects=max(0,1-(X*W).*Y);
    if NeedCost==1
        Cost1=mean(CostSubjects.^SVMNorm);
    end
    Grad=reshape(-2*Y.*CostSubjects,[1,N])*X/N;
    Grad=Grad';
    Cost2=0;
    if NeedQPart==1
        Grad2=2*Q*W(1:end-1);
        Grad(1:end-1)= Grad(1:end-1)+Grad2;
        if NeedCost==1
            Cost2=(W(1:end-1)')*Q*W(1:end-1);
        end
    end
    if NeedCost==1
       [NormList]=cellfun(@(GroupIndList) norm(W(GroupIndList),q),GroupIndListArray); 
       Cost3=GroupWeightList*NormList;
       AfterProxiamlCostList(Iter,:)=[Cost1,Cost2,LambdaList(3)*Cost3,Cost1+Cost2+LambdaList(3)*Cost3];
    end
    % gradient descent
    DescentW=W-Grad*StepSize;
    ProxW=DescentW;
    %% compute the cost before projection
    if NeedCost==1
        % the hingeloss term
        CostSubjects=max(0,1-(X*DescentW).*Y);
        Cost1=mean(CostSubjects.^SVMNorm);
        Grad=reshape(-2*Y.*CostSubjects,[1,N])*X/N;
        Cost2=0;
        if NeedQPart==1
            Cost2=(DescentW(1:end-1)')*Q*DescentW(1:end-1);
        end
        
        [NormList]=cellfun(@(GroupIndList) norm(W(GroupIndList),q),GroupIndListArray);
        Cost3=GroupWeightList*NormList;
        BeforeProxiamlCostList(Iter,:)=[Cost1,Cost2,LambdaList(3)*Cost3,Cost1+Cost2+LambdaList(3)*Cost3];
    end

    
    %% do the proximal (group lasso)
    MatArr=cell(length(ThresholdList),1);
    [MatArr]=cellfun(@(x,y) SingleGroupLassoThres(DescentW,x,y,q),GroupIndListArray,ThresholdList,'UniformOutput',0);
    W_ToIndex=cell2mat(MatArr);
    ProxW(W_ToIndex(:,2))=W_ToIndex(:,1);
    
    %% do the FISTA or ISTA
    if FISTAOrISTA==1
        t=0.5*(1+(1+4*t_1^2)^0.5);
        W=W_1+(ProxW-W_1)*(t_1-1)/t;
        t_1=t;
    else
        W=ProxW;
    end
    
    %% Check if converge in W
    if Iter> MinIter   
        WDiffNorm=norm(W-W_1);
        NormW=norm(W);
        Ratio=WDiffNorm/NormW;
        if WDiffNorm <= W_ChangeNormLimit
            disp(['At Iter ',num2str(Iter,'%06d'),' W change Norm converge, ',num2str(WDiffNorm),'<',num2str(W_ChangeNormLimit)] );
            LOG=[];
            LOG.BeforeProxCost=BeforeProxiamlCostList(1:Iter,:);
            LOG.AfterProxCost =AfterProxiamlCostList (1:Iter,:);
            LOG.NonZeroFeature=ComputeNonZeroVoxel(W(1:end-1));
            LOG.NonZeroRegion =ComputeNonZeroRegion(W,GroupIndListArray,q);
            break;
        end
        if WDiffNorm/NormW <=W_ChangeRatioLimit
           disp(['At Iter ',num2str(Iter,'%06d'),' W change ratio converge, ',num2str(Ratio),'<',num2str(W_ChangeRatioLimit)] ); 
           LOG=[];
           LOG.BeforeProxCost=BeforeProxiamlCostList(1:Iter,:);
           LOG.AfterProxCost =AfterProxiamlCostList (1:Iter,:);
           LOG.NonZeroFeature=ComputeNonZeroVoxel(W(1:end-1));
           LOG.NonZeroRegion =ComputeNonZeroRegion(W,GroupIndListArray,q);
           break;
        end
        CostDecreaseRatio=(AfterProxiamlCostList(Iter-1,4)-AfterProxiamlCostList(Iter,4))/AfterProxiamlCostList(Iter-1,4);
        if CostDecreaseRatio<=CostConvRatio
            disp(['At Iter ',num2str(Iter,'%06d'),' Cost decrease ratio converge, ',num2str(CostDecreaseRatio),'<',num2str(CostConvRatio)] );
            LOG=[];
            LOG.BeforeProxCost=BeforeProxiamlCostList(1:Iter,:);
            LOG.AfterProxCost =AfterProxiamlCostList (1:Iter,:);
            LOG.NonZeroFeature=ComputeNonZeroVoxel(W(1:end-1));
            break;
        end
        if Iter==MaxIter
            disp(['Reach Max Iteration ',num2str(MaxIter)])
            LOG=[];
            LOG.BeforeProxCost=BeforeProxiamlCostList(1:Iter,:);
            LOG.AfterProxCost =AfterProxiamlCostList (1:Iter,:);
            LOG.NonZeroFeature=ComputeNonZeroVoxel(W(1:end-1));
            LOG.NonZeroRegion =ComputeNonZeroRegion(W,GroupIndListArray,q);
        end
    end
    
    %% save to the previous state
    W_1=W;
    
end







end

function [Mat]=SingleGroupLassoThres(W,GroupIndPosList,Thres,NormP)
% Mat is a N*2 matrix, first col is the new value and the second it the
% indexlist

D=length(GroupIndPosList);
Mat=zeros(D,2);
Mat(:,2)=GroupIndPosList;
FeatVec=W(GroupIndPosList);
Norm0=norm(FeatVec,NormP);
if Norm0>Thres
    FeatVecNew=FeatVec*(Norm0-Thres)/Norm0;
    Mat(:,1)=FeatVecNew;
    %ProxW(GroupIndPosList)=FeatVecNew;
end
end

function [N]=ComputeNonZeroVoxel(W)
    N=sum(W~=0)
end
function [N]=ComputeNonZeroRegion(W,GroupIndListArray,q)
    [NormList]=cellfun(@(GroupIndList) norm(W(GroupIndList),q),GroupIndListArray);
    N=sum(NormList~=0);
end
