function [ StepSize_Result,W_Result,Cost_ResultW ] = OneStepGradDescent( W,b,CostW,Pre_StepSize,X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare ,SparstOption,OptimizeOpt )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the one step gradient descent with
%   different (by user choice) stepsize decision type
%
%   CostW is the cost of function at W
%
%   Zhuo


Direction=0;  % if increase stepsize,Direction=1;  if decrease stepsize, Direction=-1;

    %% compute the gradient
    [ dW,dB ] = GradAll(W,b,X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare );
    Grad_OldW=[dW;dB];
    %% do the stepsize Decision
    switch OptimizeOpt.StepSizeType
        case 'Fix'
            Stepsize0=OptimizeOpt.InitialStepSize;
        case 'LogDecay'
            Stepsize0=OptimizeOpt.InitialStepSize* LogDecayFactor(Iter,OptimizeOpt.LogDecayOpt);
        case 'Backtracking'
            T=OptimizeOpt.InitialStepSize;
            KeepSearch=1;
            SearchInd=0;
                    
            while KeepSearch
                SearchInd=SearchInd+1;
                [ SatisfyQFun_T,Cost_NewW_T,Q_Cost_T ]  = QFuncSatisfy(W-T*Grad,OldW,  Grad_OldW,T,   CostW,X,Y,Cx,A,Ma,Ca,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption );
                if SatisfyQFun_T==1
                    KeepSearch=0;
                    Cost_ResultW=Cost_NewW_T;
                    StepSize_Result=T;    
                else
                    T=T*OptimizeOpt.SmallRatio;     
                end
                if SearchInd ==OptimizeOpt.MaxLineSearchNum
                    KeepSearch=0;
                    Cost_ResultW=Cost_NewW_T;
                    StepSize_Result=StepSize;                
                end
                
            end
        case 'TwoDirectSearch'
            T_L=Pre_StepSize*OptimizeOpt.LargeRatio;
            T_S=Pre_StepSize*OptimizeOpt.SmallRatio;
            T=Pre_StepSize;
            %% compute the Q function on T_L,T,T_S, to see if it satisfy the condition (when it satisfy, it is 1)
            CostW=CostLoG(Iter);
            [ SatisfyQFun_T,Cost_NewW_T,Q_Cost_T ]       = QFuncSatisfy(W-T*Grad,OldW,  Grad_OldW,T,   CostW,X,Y,Cx,A,Ma,Ca,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption );
            [ SatisfyQFun_T_L,Cost_NewW_T_L,Q_Cost_T_L ] = QFuncSatisfy(W-T_L*Grad,OldW,Grad_OldW,T_L, CostW,X,Y,Cx,A,Ma,Ca,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption );
            [ SatisfyQFun_T_S,Cost_NewW_T_S,Q_Cost_T_S ] = QFuncSatisfy(W-T_S*Grad,OldW,Grad_OldW,T_S, CostW,X,Y,Cx,A,Ma,Ca,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption );
            if SatisfyQFun_T==1 & SatisfyQFunc_T_L==1 & SatisfyQFunc_T_S==1
                StepSize_Pre=T_L;
                Direction=1;
                StepRatio=OptimizeOpt.LargeRatio;
            end
            if SatisfyQFun_T_L==-1 & SatisfyQFunc_T==1 & SatisfyQFunc_T_S==1
                StepSize0=T;
            end
            if SatisfyQFun_T_L==-1 & SatisfyQFunc_T==-1 & SatisfyQFunc_T_S==1
                StepSize0=T_S;
            end
            if SatisfyQFun_T_L==-1 & SatisfyQFunc_T==-1 & SatisfyQFunc_T_S==-1
                StepSize_Pre=T_S;
                Direction=-1;
                StepRatio=OptimizeOpt.SmallRatio;
            end    
            %% do the iterative 
            if Direction~=0
                KeepSearch=1;
                SearchInd=0;
                
                while KeepSearch 
                    SearchInd=SearchInd+1;
                    StepSize=StepSize_Pre*StepRatio;                    
                    %% compute the Q function on current stepsize
                    [ SatisfyQ,Cost_NewW_T,Q_Cost_T ]       = QFuncSatisfy(W-StepSize*Grad_OldW, Grad_OldW,StepSize, CostW,X,Y,Cx,A,Ma,Ca,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption );
                    %% 
                    if Direction==-1
                        if SatisfyQ==1
                            KeepSearch=0;
                            StepSize0=StepSize;
                            Cost_ResultW=Cost_NewW_T;
                        else
                            StepSize_Pre=StepSize;
                        end
                    end
                    if Direction==1
                        if SatisfyQ==-1
                            KeepSearch=0;
                            StepSize0=StepSize_Pre;
                        else
                           Cost_ResultW=Cost_NewW_T;
                            StepSize_Pre=StepSize;
                        end
                    end
                    if SearchInd==OptimizeOpt.MaxLineSearchNum
                        KeepSearch=0;
                        Cost_ResultW=Cost_NewW_T;
                        StepSize0=StepSize;                
                    end
                end
            end               
        otherwise
            error([OptimizeOpt.StepSizeType, ' is not defined yet for the step size determination']);
    end
    W_all=W-Grad_OldW*StepSize0;  
    StepSize_Result=StepSize0;
    W_Result=W_all;


end

