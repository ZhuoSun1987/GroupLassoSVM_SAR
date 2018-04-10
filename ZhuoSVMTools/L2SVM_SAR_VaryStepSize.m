function [ W,LOG ] = L2SVM_SAR_VaryStepSize( X,Y,W0,GroupIndListArray,GroupWeightList,LL,LambdaList,q,Option )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to make the group lasso SAR SVM (square
%   hingeloss), also with varying step size, in two direction search.
%
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
StepIncreaseRatio=Option.StepIncreaseRatio;
StepDecreaseRatio=Option.StepDecreaseRatio;
MaxLineSearchStep=Option.MaxLineSearchStep;
MinIter    =Option.MinIter;
CostConvRatio=Option.CostConvRatio;



%% the initial of FISTA
W_1=W0;
t_1=1;
StepSize_1=StepSize;
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
StepSizeList=zeros(MaxIter,1);

ThresholdList=num2cell(StepSize*reshape(GroupWeightList,[length(GroupWeightList),1])*LambdaList(3));
Print=0;
if isfield(Option,'Print') & Option.Print==1
    Print=1;
end
if Print==1
    Str=sprintf('%6s%12s%12s%12s%12s%20s%12s','Iter','Cost','GradNorm','StepSize','SearchStep','DeOrInCrease','nonzeros');
    disp(Str);
end
%% compute the cost for the initialize
CostSubjects=max(0,1-(X*W).*Y);
Cost1=mean(CostSubjects.^SVMNorm);
Cost2=0;
if NeedQPart==1
    Cost2=(W(1:end-1)')*Q*W(1:end-1);
end
Cost3=0;
CostW=Cost1+Cost2;
Str=sprintf('%6s%12f%12f%12f%12f%20s%12d',num2str(0),CostW,0,StepSize,0,' ',sum(W==0));
disp(Str);

%% iteratively update
for Iter=1:MaxIter
    %% compute the gradient and the cost at the current position W.
    CostSubjects=max(0,1-(X*W).*Y);
    Cost1=mean(CostSubjects.^SVMNorm);
    Grad=reshape(-2*Y.*CostSubjects,[1,N])*X/N;
    Grad=Grad';
    Cost2=0;
    if NeedQPart==1
        Grad2=2*Q*W(1:end-1);
        Grad(1:end-1)= Grad(1:end-1)+Grad2;
        Cost2=(W(1:end-1)')*Q*W(1:end-1);
    end
    CostW=Cost1+Cost2;
    SmoothCostW=Cost1+Cost2;
    AfterProxiamlCostList(Iter,:)=[Cost1,Cost2,0,CostW];
    %% compute the F and Q function at current stepsize
    %% see if we should increase or descrease the stepsize
    % first, gradient descent
    DescentW=W-Grad*StepSize;
    % second, compute the F and Q function at the current extimated ProxW
    CostSubjects=max(0,1-(X*DescentW).*Y);
    Cost1ProxW=mean(CostSubjects.^SVMNorm);
    Cost2ProxW=0;
    if NeedQPart==1
        Cost2ProxW=(DescentW(1:end-1)')*Q*DescentW(1:end-1);
    end
    QFun_ProxW=SmoothCostW+Grad'*(ProxW-W)+(ProxW-W)'*(ProxW-W)/(2*StepSize);
    F_ProxW   =Cost1ProxW+Cost2ProxW;
    % third,decide if we should increase or decrease the stepsize
    InOrDeCrease=[];
    ChangeRatio=[];
    Direct=[];
    if F_Q_Satisfy(F_ProxW,QFun_ProxW) % satisfy a condition
        InOrDeCrease=1;
        ChangeRatio=StepIncreaseRatio;
        Direct='Increase';
    else
        InOrDeCrease=2;
        ChangeRatio=StepDecreaseRatio;
        Direct='Decrease';
    end
    ProxW_1=DescentW;
    StepSize_1=StepSize;
    
    %% along the increase or decrease direction, find the optimal stepsize
    for L=1:MaxLineSearchStep
        StepSize=StepSize*ChangeRatio;
        DescentW=W-Grad*StepSize;
        % this cell function will update the ProxW, which is a global variable
        % second, compute the F and Q function at the current extimated ProxW
        CostSubjects=max(0,1-(X*DescentW).*Y);
        Cost1ProxW=mean(CostSubjects.^SVMNorm);
        Cost2ProxW=0;
        if NeedQPart==1
            Cost2ProxW=(DescentW(1:end-1)')*Q*DescentW(1:end-1);
        end
 
        QFun_ProxW=SmoothCostW+Grad'*(ProxW-W)+(ProxW-W)'*(ProxW-W)/(2*StepSize);
        F_ProxW   =Cost1ProxW+Cost2ProxW;
        if F_Q_Satisfy(F_ProxW,QFun_ProxW)
            if InOrDeCrease==1
                StepSize=StepSize*ChangeRatio;
                ProxW_1=DescentW;
                StepSize_1=StepSize;
            else
                break;
            end
        else
            if InOrDeCrease==1
                DescentW=ProxW_1;
                StepSize=StepSize_1;
                break;
            else
                StepSize=StepSize*ChangeRatio;
            end
        end
        if StepSize<Option.StepSize
            StepSize=StepSize/ChangeRatio;
            break;
        end
    end
    if Print==1
        GradNorm=norm(Grad);
        Str=sprintf('%6s%12f%12f%12f%12s%20s%12d',num2str(Iter),F_ProxW,GradNorm,StepSize,num2str(L),Direct,sum(ProxW==0));
        disp(Str);
    end
    StepSizeList(Iter)=StepSize;
    %% do the FISTA or ISTA
    if FISTAOrISTA==1
        t=0.5*(1+(1+4*t_1^2)^0.5);
        W=W_1+(DescentW-W_1)*(t_1-1)/t;
        t_1=t;
    else
        W=DescentW;
    end
    
    %% Check if converge in W
    if Iter>MinIter
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
            LOG.StepSizeList=StepSizeList(1:Iter,:);
            break;
        end
        if WDiffNorm/NormW <=W_ChangeRatioLimit
            disp(['At Iter ',num2str(Iter,'%06d'),' W change ratio converge, ',num2str(Ratio),'<',num2str(W_ChangeRatioLimit)] );
            LOG=[];
            LOG.BeforeProxCost=BeforeProxiamlCostList(1:Iter,:);
            LOG.AfterProxCost =AfterProxiamlCostList (1:Iter,:);
            LOG.NonZeroFeature=ComputeNonZeroVoxel(W(1:end-1));
            LOG.StepSizeList=StepSizeList(1:Iter,:);
            break;
        end
        CostDecreaseRatio=(AfterProxiamlCostList(Iter-1,4)-AfterProxiamlCostList(Iter,4))/AfterProxiamlCostList(Iter-1,4);
        if abs(CostDecreaseRatio)<=CostConvRatio
            disp(['At Iter ',num2str(Iter,'%06d'),' Cost decrease ratio converge, ',num2str(CostDecreaseRatio),'<',num2str(CostConvRatio)] );
            LOG=[];
            LOG.BeforeProxCost=BeforeProxiamlCostList(1:Iter,:);
            LOG.AfterProxCost =AfterProxiamlCostList (1:Iter,:);
            LOG.NonZeroFeature=ComputeNonZeroVoxel(W(1:end-1));
            LOG.StepSizeList=StepSizeList(1:Iter,:);
            break;
        end
        if Iter==MaxIter
            disp(['Reach Max Iteration ',num2str(MaxIter)])
            LOG=[];
            LOG.BeforeProxCost=BeforeProxiamlCostList(1:Iter,:);
            LOG.AfterProxCost =AfterProxiamlCostList (1:Iter,:);
            LOG.NonZeroFeature=ComputeNonZeroVoxel(W(1:end-1));
            LOG.NonZeroRegion =ComputeNonZeroRegion(W,GroupIndListArray,q);
            LOG.StepSizeList=StepSizeList(1:Iter,:);
        end
        
    end
    %% save to the previous state
    W_1=W;
    
end


end


function [N]=ComputeNonZeroVoxel(W)
N=sum(W~=0)
end
function [N]=ComputeNonZeroRegion(W,GroupIndListArray,q)
[NormList]=cellfun(@(GroupIndList) norm(W(GroupIndList),q),GroupIndListArray);
N=sum(NormList~=0);
end

function [Satisfy]=F_Q_Satisfy(Fcost,Qcost)
%   this function is used to check if the Q function and S function satisfy
%   the requirement of the
Satisfy=Fcost<=Qcost;
end