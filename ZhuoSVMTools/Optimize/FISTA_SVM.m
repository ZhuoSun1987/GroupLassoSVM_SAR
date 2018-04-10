function [ W,CostLoG,StepsizeLoG,CostPartsLoG ] = FISTA_SVM( W0,DataOpt,CostFuncOpt,OptimizeOpt,SparstOption)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function implement the FISTA framework on Zhuo's SVM cost function
%
%   W0 => initial guass of the parameter, size is [d+1,1], the last element
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
%   SparstOption -> the option about the sparsity 
%   .
%
%   SparseOption.GroupLassoOpt-> if it use GroupLasso, it is the related
%
%   Zhuo Sun

a=0;
a_1=1;
W_1=W0;
W=W0;
Z=W0;
StepSize=OptimizeOpt.InitialStepSize;

Pre_StepSize=OptimizeOpt.InitialStepSize;
CostLOG=zeros(OptimizeOpt.MaxIter+1,1);
CostPartLoG=zeros(OptimizeOpt.MaxIter+1,4);
StepsizeLoG=zeros(OptimizeOpt.MaxIter+1,1);
CostPartsLoG=[];

StepsizeLoG(1)=Pre_StepSize;
KeepIter=1;
Iter=0;
C_Or_R=SparstOption.C_Or_R;
Lambda=CostFuncOpt.LambdaList(4);
[SumCost,CostParts]=CostAll(W0,DataOpt,CostFuncOpt,SparstOption);  % to be implemented;
CostPartsLoG=[CostPartsLoG;CostParts'];
CostLoG(1)=SumCost;
% [ SumCost,CostList ] = CostAll(W,b,X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption );
switch OptimizeOpt.ProxType
    case 'FISTA'
        while KeepIter
            Iter=1+Iter;           
            CostSmoothW=CostPartsLoG(Iter,1:3)*CostFuncOpt.LambdaList(1:3);
            %% compute the line search gradient descent one step proximal
            [W,Cost,CostParts,StepSize]=ProximalGradient(Z,CostSmoothW,StepSize,DataOpt,CostFuncOpt,OptimizeOpt,SparstOption);
            if OptimizeOpt.ShowIter==1
                disp(['Iteration Num=',num2str(Iter,'%04d')])
                disp(['Zero elments in W = ',num2str(sum(W==0))])
            end
            CostLoG(Iter+1)=Cost; 
            CostPartsLoG=[CostPartsLoG;CostParts'];
          
            StepsizeLoG(Iter+1)=StepSize;
%             [SumCost,CostParts]=CostAll(W,DataOpt,CostFuncOpt,SparstOption); 
%             CostPartsLoG=[CostPartsLoG;CostParts'];
            %[ StepSize_Result,W_Result,Cost_ResultW ] = ProximalGradientOneStep( W,b,CostW,Pre_StepSize,X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare ,SparstOption,OptimizeOpt )
           
            %% update the FISTA state, compute the Z adn update a_1 and W_1
            a=0.5*(1+(1+4*a_1*a_1)^0.5);
            Z=W+(W-W_1)*(a_1-1)/a;
            a_1=a;
            
            %% if need to stop
            if Iter>4
                [ KeepIter ] = Stopping( W,W_1,CostLoG,Iter,OptimizeOpt );
            end
            W_1=W;
        end
        
        
    case 'ISTA'
        while KeepIter
            Iter=1+Iter;
            CostW=CostLoG(Iter);
             %% compute the line search gradient descent one step proximal
            [W,Cost,CostParts,StepSize]=ProximalGradient(W,CostW,StepSize,DataOpt,CostFuncOpt,OptimizeOpt,SparstOption);
            CostLoG(Iter+1)=Cost; 
            CostPartsLoG=[CostPartsLoG;CostParts'];
            [SumCost,CostParts]=CostAll(W,DataOpt,CostFuncOpt,SparstOption); 
            if OptimizeOpt.ShowIter==1
                disp(['Iteration Num=',num2str(Iter,'%04d')])
                disp(['Zero elments in W = ',num2str(sum(W==0))])
            end
%             CostPartsLoG=[CostPartsLoG;CostParts']; 
            %% if need to stop
            if Iter>4
                [ KeepIter ] = Stopping( W,W_1,CostLoG,Iter,OptimizeOpt );
            end
            W_1=W;
        end
    case 'MFISTA'  % monotone FISTA
        while KeepIter
            Iter=1+Iter;
            CostW=CostLoG(Iter);
             %% compute the line search gradient descent one step proximal
            [WW,Cost,StepSize]=ProximalGradient(Z,CostW,StepSize,DataOpt,CostFuncOpt,OptimizeOpt,SparstOption);
            CostLoG(Iter+1)=Cost; 
            
            %% to find the min between {Cost(WW),Cost(W_1)} and the minimal will be W
            Cost_WW =CostAll(WW ,DataOpt,CostFuncOpt,OptimizeOpt,SparstOption);
            Cost_W_1=CostAll(W_1,DataOpt,CostFuncOpt,OptimizeOpt,SparstOption);
            if Cost_WW>Cost_W_1
                W=W_1; 
            else
                W=WW;
            end 
            [SumCost,CostParts]=CostAll(W,DataOpt,CostFuncOpt,SparstOption); 
            CostPartsLoG=[CostPartsLoG;CostParts'];
            CostLoG(Iter+1)=SumCost;
            %% update the FISTA state, compute the Z adn update a_1 and W_1
            a=0.5*(1+(1+4*a1*a_1)^0.5);
            Z=W+(W-W_1)*(a_1-1)/a+(a_1/a)*(WW-W);
            a_1=a;
            if OptimizeOpt.ShowIter==1
                disp(['Iteration Num=',num2str(Iter,'%04d')])
                disp(['Zero elments in W = ',num2str(sum(W==0))])
            end
                
            %% if need to stop
            if Iter>4
                [ KeepIter ] = Stopping( W,W_1,CostLoG,Iter,OptimizeOpt );
            end
            W_1=W;
        end
    case 'FASTA'
        disp('Currently, the FASTA algorithm is not fully understand and implemented')
        KeepIter=0;
        while KeepIter
            Iter=1+Iter;
            CostW=CostLoG(Iter);
            
            %% if need to stop
            if Iter>4
                [ KeepIter ] = Stopping( W,W_1,CostLoG,Iter,OptimizeOpt );
            end
        end
    otherwise
        disp([OptimizeOpt.ProxType,'  is not defined currently'])
        
end


end

