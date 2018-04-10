function [W,CostNewW,CostParts,StepSize]=ProximalGradient(W0,CostSmooth_W,StepSize,DataOpt,CostFuncOpt,OptimizeOpt,SparseOption)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here%
%
%   this function is used to compute the proximal gradient descent
%   operation in Zhuo's SVM toolbox.
%    
%   this function can be integrated into some proximal gradient descent
%   framework, such as ISTA, FISTA, Monotone FISTA......
%
%   W0 => initial guass of the parameter, size is [d+1,1], the last element
%   of the vector is the bias term.
%
%   CostSmoothW is the smooth part of the cost functin evaluated at point W
%
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
%   SparstOption -> the option about the sparsity 
%
%
%   Zhuo Sun


%% compute the gradient
dW=GradientAll(W0,DataOpt,CostFuncOpt);
C_Or_R=SparseOption.C_Or_R;
Lambda=CostFuncOpt.LambdaList(4);
IntialStepSize=StepSize;
%% Find the stepsize
switch OptimizeOpt.StepSizeType
    case 'Fix'
        Stepsize=OptimizeOpt.InitialStepSize;
        W=W0-StepSize*dW;
        [ W ] = SparsityProximalOperator( W,C_Or_R,Lambda,Stepsize,SparseOption );
        [ CostNewW,CostParts ] =CostAll(W,DataOpt,CostFuncOpt,SparseOption);
    case 'LogDecay'
        Stepsize0=OptimizeOpt.InitialStepSize* LogDecayFactor(Iter,OptimizeOpt.LogDecayOpt);
        W=W0-StepSize*dW;
        [ W ] = SparsityProximalOperator( W,C_Or_R,Lambda,Stepsize,SparseOption );
        [ CostNewW,CostParts ] =CostAll(W,DataOpt,CostFuncOpt,SparseOption);
    case 'Backtracking'
            T=OptimizeOpt.InitialStepSize;  % in general case, the given step size should be OptimizeOpt.InitialStepSize, 
                         %so that each time backtracking line search start from the same stepsize
            KeepSearch=1;
            SearchInd=0;
                    
            while KeepSearch
                SearchInd=SearchInd+1;
                W=W0-T*dW;
                [ W ] = SparsityProximalOperator( W,C_Or_R,Lambda,T,SparseOption );
                [ Cost_NewW_T,CostPartsNewW ] =CostAll(W,DataOpt,CostFuncOpt,SparseOption);
                [ CostQSmooth ] = QFunc( W0,W,dW,T,CostSmooth_W );
                
                if sum(CostPartsNewW(1:end-1).*CostFuncOpt.LambdaList(1:3)) >  CostQSmooth
                    T=T*OptimizeOpt.SmallRatio;     
                else 
                    KeepSearch=0;
                    CostNewW=Cost_NewW_T;
                    StepSize=T;
                    CostParts=CostPartsNewW;
                    disp(['     LineSearch Iter=',num2str(SearchInd),'   StepSize=',num2str(T)  ])
                end
                if SearchInd ==OptimizeOpt.MaxLineSearchNum
                    KeepSearch=0;
                    CostNewW=Cost_NewW_T;
                    StepSize=T;
                    CostParts=CostPartsNewW;
                    disp(['     Max LineSearch Iter=',num2str(SearchInd),'   StepSize=',num2str(T)  ])
                end
                
            end
    case 'TwoDirectSearch'
            StepSizeMin=OptimizeOpt.InitialStepSize;
            DecreaseOrIncrease=0;
            %% first, compute the current step, if it is fit the Q func
            [ Cost_W0,  CostParts_W0 ]   =CostAll(W0,  DataOpt,CostFuncOpt,SparseOption);
            SmoothCostW0=sum(CostParts_W0(1:end-1).*CostFuncOpt.LambdaList(1:3)); 
            W1=W0-StepSize*dW; % do the gradient descent
            W1=SparsityProximalOperator( W1,C_Or_R,Lambda,StepSize,SparseOption );            
            QCostW1=QFunc( W0,W1,dW,StepSize,SmoothCostW0, SparseOption );
            [ Cost_W1,  CostParts_W1 ]   =CostAll(W1,  DataOpt,CostFuncOpt,SparseOption);
            StepSize0=StepSize;
            if Cost_W1<=QCostW1
                DecreaseOrIncrease=2;
            else
                DecreaseOrIncrease=1;
            end
            if DecreaseOrIncrease==1
                % Decrease the stepsize
                for Iter=1:OptimizeOpt.MaxLineSearchNum
                    StepSize=StepSize*OptimizeOpt.SmallRatio;
                    if StepSize<=StepSizeMin
                        % compute the W1 at this time
                        StepSize=StepSizeMin;
                        W=SparsityProximalOperator( W0-StepSize*dW,C_Or_R,Lambda,StepSize,SparseOption );  
                        [ CostNewW,  CostParts ]   =CostAll(W1,  DataOpt,CostFuncOpt,SparseOption);          
                    else
                        W=SparsityProximalOperator( W0-StepSize*dW,C_Or_R,Lambda,StepSize,SparseOption );  
                        QCostW1=QFunc( W0,W1,dW,StepSize,SmoothCostW0, SparseOption );
                        [ CostNewW,  CostParts ]   =CostAll(W1,  DataOpt,CostFuncOpt,SparseOption);
                        if Cost_W1<=QCostW1
                            break;
                        end
                    end

                end
            else
                % increase the stepsize
                for Iter=1:OptimizeOpt.MaxLineSearchNum
                    StepSize=StepSize*OptimizeOpt.LargeRatio;
                    % compute the W1 at this time
                    W1=SparsityProximalOperator( W0-StepSize*dW,C_Or_R,Lambda,StepSize,SparseOption );   
                    QCostW1=QFunc( W0,W1,dW,StepSize,SmoothCostW0, SparseOption );
                    [ Cost_W1,  CostParts_W1 ]   =CostAll(W1,  DataOpt,CostFuncOpt,SparseOption);
                    if Cost_W1>QCostW1
                       % when it happen, the stepsize is too large, so we
                       % need the previous step result
                       StepSize=StepSize/OptimizeOpt.LargeRatio;
                       W=SparsityProximalOperator( W0-StepSize*dW,C_Or_R,Lambda,StepSize,SparseOption );  
                       [ CostNewW,  CostParts ]   =CostAll(W1,  DataOpt,CostFuncOpt,SparseOption);
                       %  return of this funciton :  W,CostNewW,CostParts,StepSize
                       break;
                    end
                end
            end
            
            
            
% %             T_L=StepSize*OptimizeOpt.LargeRatio;
% %             T_S=StepSize*OptimizeOpt.SmallRatio;
% %             T=StepSize;
% %             W_T  =W0-T*dW;
% %             W_T_L=W0-T_L*dW;
% %             W_T_S=W0-T_S*dW;
% %             [ W_T ]   = SparsityProximalOperator( W_T,  C_Or_R,Lambda,T,SparseOption );
% %             [ W_T_L ] = SparsityProximalOperator( W_T_L,C_Or_R,Lambda,T_L,SparseOption );
% %             [ W_T_S ] = SparsityProximalOperator( W_T_S,C_Or_R,Lambda,T_S,SparseOption );
% %             [ Cost_W_T,  CostParts_W_T ]   =CostAll(W_T,  DataOpt,CostFuncOpt,SparseOption);
% %             [ Cost_W_T_L,CostParts_W_T_L ] =CostAll(W_T_L,DataOpt,CostFuncOpt,SparseOption);
% %             [ Cost_W_T_S,CostParts_W_T_S ] =CostAll(W_T_S,DataOpt,CostFuncOpt,SparseOption);
% %             [ CostQSmooth_W_T  ] = QFunc( W0,W_T,  dW,T,  CostSmooth_W );
% %             [ CostQSmooth_W_T_L] = QFunc( W0,W_T_L,dW,T_L,CostSmooth_W );
% %             [ CostQSmooth_W_T_S] = QFunc( W0,W_T_S,dW,T_S,CostSmooth_W );
% %             %% see if it satisfy the line search condition on stepsize T, T_L,T_S
% %             if sum(CostParts_W_T(1:end-1).*CostFuncOpt.LambdaList(1:3))  >  CostQSmooth_W_T
% %                 SatisfyQFun_T=0;
% %             else
% %                 SatisfyQFun_T=1;
% %             end
% %             if sum(CostParts_W_T_L(1:end-1).*CostFuncOpt.LambdaList(1:3))> CostQSmooth_W_T_L
% %                 SatisfyQFun_T_L=0;
% %             else
% %                 SatisfyQFun_T_L=1;
% %             end
% %             if sum(CostParts_W_T_S(1:end-1).*CostFuncOpt.LambdaList(1:3)) >  CostQSmooth_W_T_S
% %                 SatisfyQFun_T_S=0;
% %             else
% %                 SatisfyQFun_T_S=1;
% %             end
% %             
% %             %% compute the Q function on T_L,T,T_S, to see if it satisfy the condition (when it satisfy, it is 1)
% %             if SatisfyQFun_T==1 & SatisfyQFun_T_L==1 & SatisfyQFun_T_S==1
% %                 StepSize_Pre=T_L;
% %                 Direction=1;  % increase stepsize 
% %                 StepRatio=OptimizeOpt.LargeRatio;
% %             end
% %             if SatisfyQFun_T_L==0 & SatisfyQFun_T==1 & SatisfyQFun_T_S==1
% %                 StepSize=T;
% %                 W=W_T;
% %                 CostNewW=Cost_W_T;
% %                 CostParts=CostParts_W_T;
% %             end
% %             if SatisfyQFun_T_L==0 & SatisfyQFun_T==0 & SatisfyQFun_T_S==1
% %                 StepSize=T_S;
% %                 W=W_T_S;
% %                 CostNewW=Cost_W_T_S;
% %                 CostParts=CostParts_W_T_S;
% %             end
% %             if SatisfyQFun_T_L==0 & SatisfyQFun_T==0 & SatisfyQFun_T_S==0
% %                 StepSize_Pre=T_S;
% %                 Direction=-1; % decrease stepsize 
% %                 StepRatio=OptimizeOpt.SmallRatio;
% %             end    
% %             %% do the iterative 
% %             if Direction~=0
% %                 KeepSearch=1;
% %                 SearchInd=0;
% %                 if Direction==1
% %                     disp(['Direction=> increase,  Intial Stepsize = ',num2str(IntialStepSize)])
% %                 else
% %                     disp(['Direction=> decrease,  Intial Stepsize = ',num2str(IntialStepSize)])
% %                 end
% %                 
% %                 while KeepSearch 
% %                     SearchInd=SearchInd+1;
% %                     T=StepSize_Pre*StepRatio;
% %                     W_T=W0-T*dW;
% %                     W_T = SparsityProximalOperator( W_T,C_Or_R,Lambda,T,SparseOption );
% %                     %% compute the Q function on current stepsize
% %                     [ Cost_W_T,  CostParts_W_T ]   =CostAll(W_T,  DataOpt,CostFuncOpt,SparseOption);
% %                     [ CostQSmooth_W_T  ] = QFunc( W0,W_T,  dW,T,  CostSmooth_W );
% %                     if sum(CostParts_W_T(1:end-1).*CostFuncOpt.LambdaList(1:3))  >  CostQSmooth_W_T
% %                         SatisfyQFun_T=0;
% %                     else
% %                         SatisfyQFun_T=1;
% %                     end
% %                     
% %                     disp(['     LineSearch Iter=',num2str(SearchInd),'   StepSize=',num2str(T)  ])
% %                     %% 
% %                     
% %                     if Direction==-1  % decrease stepsize 
% %                         if SatisfyQFun_T==1
% %                             KeepSearch=0;
% %                             StepSize=T;
% %                             W=W_T;
% %                             CostNewW=Cost_W_T;
% %                             CostParts=CostParts_W_T;
% %                         else
% %                             StepSize_Pre=T;
% %                         end
% %                     end
% %                     if Direction==1  % increase stepsize 
% %                         if SatisfyQFun_T==-1
% %                             KeepSearch=0;
% %                             StepSize=StepSize_Pre;
% %                             W=W0-StepSize*dW;
% %                             W= SparsityProximalOperator( W,C_Or_R,Lambda,StepSize,SparseOption );
% %                             [ Cost_W_T,  CostParts_W_T ]   =CostAll(W,  DataOpt,CostFuncOpt,SparseOption);
% %                             CostNewW=Cost_W_T;
% %                             CostParts=CostParts_W_T;
% %                         else
% %                            StepSize_Pre=StepSize;
% %                         end
% %                     end
% %                     if SearchInd==OptimizeOpt.MaxLineSearchNum
% %                         KeepSearch=0;
% %                         StepSize=T; 
% %                         W=W_T;
% %                         CostNewW=Cost_W_T;
% %                         CostParts=CostParts_W_T;
% %                     end
% %                 end
% %             end               
    otherwise
            error([OptimizeOpt.StepSizeType, ' is not defined yet for the step size determination']);
end









end

