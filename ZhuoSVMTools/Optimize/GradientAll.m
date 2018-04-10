function [dW]=GradientAll(W,DataOpt,CostFuncOpt)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the gradient of the differentiable
%   term of Zhuo's SVM model.
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
%   

dW=zeros(size(W));
%%  for the MisClass term
if CostFuncOpt.LambdaList(1)>0
    n=size(DataOpt.Y,1);
    switch CostFuncOpt.MCF
        case 'HingeLoss'
           dW0=Grad_HingLoss(DataOpt.X,DataOpt.Y,DataOpt.Wx,ones(n,1),W,CostFuncOpt.MCL); 
        case 'Logistic'
           dW0=Grad_Logistic(DataOpt.X,DataOpt.Y,DataOpt.Wx,ones(n,1),W,CostFuncOpt.MCL); 
        case 'LeastSquare'
           dW0=Grad_LeastSquare(DataOpt.X,DataOpt.Y,DataOpt.Wx,ones(n,1),W,CostFuncOpt.MCL);
        otherwise
            error([CostFuncOpt.MCF ,' is not defined']);
    end
    dW=dW+CostFuncOpt.LambdaList(1)*dW0;
end


%%  for the MisOrder term
if CostFuncOpt.LambdaList(2)>0
    p=size(A,1);
    switch CostFuncOpt.MOF
        case 'HingeLoss'
           dW0=Grad_HingLoss(DataOpt.A,ones(p,1),DataOpt.WA,DataOpt.Ma,W,CostFuncOpt.MOL);           
        case 'Logistic'
           dW0=Grad_Logistic(DataOpt.A,ones(p,1),DataOpt.WA,DataOpt.Ma,W,CostFuncOpt.MOL);       
        case 'LeastSquare'
           dW0=Grad_LeastSquare(DataOpt.A,ones(p,1),DataOpt.WA,DataOpt.Ma,W,CostFuncOpt.MOL);       
        otherwise
            error([CostFuncOpt.MOF ,' is not defined']);
    end
    dW=dW+CostFuncOpt.LambdaList(2)*dW0;
end


%% for the Quadratic term
if CostFuncOpt.LambdaList(3)>0
    dW0=2*DataOpt.Q*W(1:end-1);
    dW=dW+CostFuncOpt.LambdaList(3)*[dW0;0];
end


end



function [ dW ] = Grad_HingLoss( X,Y,C,Ma,W,Order )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the gradient of hingeloss function
%
%   X size [n,d+1]
%   Y size [n,1]
%   C size [n,1], C should be normalized, so that sum(C)=n and C is
%   non-negative numbers
%   
%   Zhuo Sun  2016-06-02

n=length(Y);
Mistake=max(0, Ma-Y.*(X*W));

SumGrad=((Order*(Mistake.^(Order-1)).*(-Y).*C)'*X)';
dW=SumGrad/n;






end


