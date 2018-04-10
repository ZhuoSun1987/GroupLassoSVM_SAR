function [ dW,dB ] = GradAll(w,b,X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the gradient of Zhuo's cost function
%   (only the differentiable term)
%
%   f(X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,w,b)=LambdaList(1)*MisClass(X,Y,Cx,Usebias)
%    +LambdaList(2)*MisOrder(A,Ca,Ma)+w'*Q*w+Sparse(w)
%
%   Inputs
%   W=> the weights of each feature, size is [d,1]
%   b=>  the bias parameter
%   X=> the feature data of the supervised term, size is [n,d];
%   Y=> the label of the supervised term, size is [n,1];
%   Cx=>  the weight of each subject in the supervised term,size is [n,1];
%   UseBias=>  if it is 0, [X,0] and no bias is used, else, [X,1] use bias term 
%   A=>  the feature matrix of the order constrain term, size is [p,d]
%   Ca=> the weigth of each pair, size is [p,1];
%   Ma=> the margin of pairwise order constraint, size is [p,1], all positive
%   Q=>  the quadratic term.  a SPD matrix , size is [d,d], if d is large, Q
%   should be a sparse matrix;
%   LambdaList=> a [3,1] vector, each element is non-negative number.
%   MisClassFunc=> the cost function of misClassification
%   MisClassSquare=> the order (square order) of the misClassification function
%   MisOrderFunc=> the cost function of misOrder
%   MisOrderSquare=> the square order of misOrder
%
%
%   Output
%   dW is the gradient of the cost function on W, size is [d,1];
%   dB is the gradient of the cost function on b, size is [1,1];
%   
%   Zhuo Sun  20160602  (it works, but not sure about whether it is
%   correct)


dW=zeros(size(w));
dB=0;

%%  for the MisClass term
if LambdaList(1)>0
    n=size(Y,1);
    switch MisClassFunc
        case 'HingLoss'
           dW0=Grad_HingLoss([X,UseBias*ones(n,1)],Y,Cx,ones(n,1),[w;b],MisClassSquare); 
        case 'Logistic'
           dW0=Grad_Logistic([X,UseBias*ones(n,1)],Y,Cx,[w;b]); 
        case 'LeastSquare'
           dW0=Grad_LeastSquare([X,UseBias*ones(n,1)],Y,Cx,[w;b]);
        otherwise
            error([MisClassFunc ,' is not defined']);
    end
    dW=dW+LambdaList(1)*dW0(1:end-1,1);
    dB=LambdaList(1)*dW0(end);
end


%%  for the MisOrder term
if LambdaList(2)>0
    p=size(A,1);
    switch MisOrderFunc
        case 'HingLoss'
           dW0=Grad_HingLoss(A,ones(p,1),Ca,Ma,w,MisOrderSquare); 
        case 'Logistic'
           dW0=Grad_Logistic(A,ones(p,1),Ca,w); 
        case 'LeastSquare'
           dW0=Grad_LeastSquare(A,ones(p,1),Ca,w); 
        otherwise
            error([MisClassFunc ,' is not defined']);
    end
    dW=dW+LambdaList(3)*dW0;
end


%% for the Quadratic term
if LambdaList(3)>0
    dW0=2*Q*w;
    dW=dW+LambdaList(3)*dW0;
end


end



