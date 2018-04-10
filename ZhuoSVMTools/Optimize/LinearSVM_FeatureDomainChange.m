function [ W,b ] = LinearSVM_FeatureDomainChange( DataOpt,Lambda,CostOpt,LInv )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the simplified Zhuo's SVM model (only
%   misclassification part and quadratic part) using the feature domain
%   transfer method, similar to Remi Cuingnet's TPAMI2013 paper.
%
%   this function need to use the Liblinear toolbox
%
%   Zhuo Sun   20160627


%% first understand the input and set the parameters for liblinear
LiblinearStr=[];
if strcmp(CostOpt.MCF,'HingeLoss')
    if CostOpt.MCL==2
        LiblinearStr=[LiblinearStr, ' -s 2'];
    end
    
    if CostOpt.MCL==1
        LiblinearStr=[LiblinearStr, ' -s 3'];
    end
    
    
end
if strcmp(CostOpt.MCF,'Logistic')  
    if CostOpt.MCL==1
        LiblinearStr=[LiblinearStr, ' -s 0'];
    else
        error('Logistic regression in liblinear only support L1 cost')
    end
end


C=1/Lambda;
LiblinearStr=[LiblinearStr, ' -c ',num2str(C)];


Q=DataOpt.Q;
[d1,d2]=size(Q);

if d1~=d2
    error('DataOpt.Q should be a sparse square matrix');
end

d0=size(DataOpt.X,2);
if d0==d1
    X=DataOpt.X;
else
    if d0==d1+1
        X=DataOpt.X(:,1:end-1);
        LiblinearStr=[LiblinearStr, ' -B  1 '];

    else
        error('dimension of DataOpt.X and DataOpt.Q do not match');
    end
end

if nargin<4 | isempty(LInv)
    L=chol(Q);
    LInv=inv(L);
end

NewX=(LInv*(X'))';
Y=DataOpt.Y;

b=0;
%%  train the liblinear SVM model in the feature domain NewX=LInv*X and parameter domain u=L*W;
model = train(Y, sparse(X) , LiblinearStr);
u=model.w(1:end-1);
u=reshape(u,[d1,1]);
b=model.w(end);

%%  Map the parameter u back to W space


W=LInv*u;






end

