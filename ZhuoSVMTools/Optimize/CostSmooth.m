function [ SumCost,CostParts ] =CostSmooth(W,DataOpt,CostFuncOpt) 
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the cost of smooth parts in Zhuo's SVM model at the
%   given paremeter W
%
%   W => initial guass of the parameter, size is [d+1,1], the last element
%   of the vector is the bias term.
%   
%   OptimizeOpt.MaxIter => Max iteration
%   OptimizeOpt.LargeRatio => ratio that increase the step size
%   OptimizeOpt.SmallRatio => ratio that decrease the step size
%   OptimizeOpt.StepSizeType => it can be fix stepsize,
%   logDecay,Backtracking and two direction tracking.
%   OptimizeOpt.LogDecayOpt  => the option of LogDecay function
%   OptimizeOpt.stopvarj =>  cost variation threshold for stoping
%   OptimizeOpt.ProxType => the type of proximal gradient descent method, including
%   FISTA, ISTA, MFISTA,FASTA
%
%   DataOpt.X  for the labeled subject feature matrix, size is [n,d+1]
%   where n is the subject number, d is the real feature length, d=1
%   because of the possible bias term.  if the last column is ones(n,1), it
%   include bias, if last column is zeros(n,1), it has no bias
%   DataOpt.Y  for hte labels of labeled term. size is [n,1] can be {-1,1}
%   DataOpt.Wx  the weight of each labeled subject, it should be normalized
%   before this function
%   DataOpt.A  for the pairwise different feature, size is [p,d+1], the
%   last column should be zeros(p,1)
%   DataOpt.Ma  the margin of each order pair 
%   DataOpt.Wa  the weight of each order pair
%   DataOpt.Q  is a SPD matrix or possible 
%
%   CostFuncOpt.MCF -> misclassification function
%   CostFuncOpt.MCL -> misclassification function L loss (Misclassification^L)
%   CostFuncOpt.MOF -> misorder function 
%   CostFuncOpt.MOL -> misorder function L loss 
%   CostFuncOpt.LambdaList -> is a [4,1] vector, contains weight of
%   Misclassification funciton, misorder function, Quadratic function and
%   sparsity function
%
%   Zhuo Sun  20160608




CostParts=zeros(3,1);
%%  for the MisClass term
if CostFuncOpt.LambdaList(1)>0
    n=size(DataOpt.Y,1);
    switch CostFuncOpt.MCF
        case 'HingLoss'
           Cost=Cost_HingLoss(DataOpt.X,DataOpt.Y,DataOpt.Wx,ones(n,1),W,CostFuncOpt.MCL); 
        case 'Logistic'
           Cost=Cost_Logistic(DataOpt.X,DataOpt.Y,DataOpt.Wx,ones(n,1),W,CostFuncOpt.MCL); 
        case 'LeastSquare'
           Cost=Cost_LeastSquare(DataOpt.X,DataOpt.Y,DataOpt.Wx,ones(n,1),W,CostFuncOpt.MCL);
        otherwise
            error([CostFuncOpt.MCF ,' is not defined']);
    end
    CostParts(1)=Cost;
end


%%  for the MisOrder term
if CostFuncOpt.LambdaList(2)>0
    p=size(A,1);
    switch CostFuncOpt.MOF
        case 'HingLoss'
           Cost=Cost_HingLoss(DataOpt.A,ones(p,1),DataOpt.WA,DataOpt.Ma,W,CostFuncOpt.MOL);           
        case 'Logistic'
           Cost=Cost_Logistic(DataOpt.A,ones(p,1),DataOpt.WA,DataOpt.Ma,W,CostFuncOpt.MOL);       
        case 'LeastSquare'
           Cost=Cost_LeastSquare(DataOpt.A,ones(p,1),DataOpt.WA,DataOpt.Ma,W,CostFuncOpt.MOL);       
        otherwise
            error([CostFuncOpt.MOF ,' is not defined']);
    end
    CostParts(2)=Cost;
end


%% for the Quadratic term
if CostFuncOpt.LambdaList(3)>0
    Cost=(W')*DataOpt.Q*w;
    CostParts(3)=Cost;
end



%% compute the sum of all the terms
SumCost=sum(CostParts.* CostFuncOpt.LambdaList(1:3));



end



function [Cost,MisClassNum]=Cost_HingLoss(X,Y,Wx,Ma,W,FunctionNorm)

N=length(Y);
Mistake=max(0, Ma-Y.*(X*W));
MisClassNum=sum(find(Mistake>0));

Cost=sum(Wx.*(Mistake.^FunctionNorm))/N;

end

