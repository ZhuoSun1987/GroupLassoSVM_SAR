function [ PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrain,AUCTest,ModifyAcc,W ] = TrainTestEvaluateZhuoSVM_SingleLambdaList...
    (Xtrain,Xtest,Ytrain,Ytest,W0,LL,Folder,LambdaList,Option )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   z.sun

CostType=0;
if LambdaList(3)>0
    SparseType=Option.SparseType;
    switch SparseType
        case 'GroupLasso'
            CostType=3;
        case 'Lasso'
            CostType=2;
        otherwise
            error(['Wrong SparseType:  ',SparseType]);
    end
else
    CostType=1;
end
MakeFolder(Folder);
%% do the learning
W=[];
StepType=Option.StepType;
switch StepType
    case 'Fix'
        if CostType==1 % no sparsity
            [ W,LOG ] = L2SVM_SAR_Fix( Xtrain,Ytrain,W0,LL,LambdaList,Option );
        end
        if CostType==2
            [ W,LOG ] = L2SVM_Lasso_SAR_Fix( Xtrain,Ytrain,W0,LL,LambdaList,Option );
        end
        if CostType==3
            [ W,LOG ] = L2SVM_GroupLasso_SAR_Fix(Xtrain,Ytrain,W0,Option.GroupIndListArray,Option.GroupWeightList,LL,LambdaList,Option.q,Option );
        end
        
    case 'Vary'
        if CostType==1 % no sparsity
            [ W,LOG ] = L2SVM_SAR_VaryStepSize( Xtrain,Ytrain,W0,LL,LambdaList,Option );
        end
        if CostType==2
            [ W,LOG ] = L2SVM_Lasso_SAR_VaryStepSize( Xtrain,Ytrain,W0,LL,LambdaList,Option );
        end
        if CostType==3
            [ W,LOG ] = L2SVM_GroupLasso_SAR_VaryStepSize(Xtrain,Ytrain,W0,Option.GroupIndListArray,Option.GroupWeightList,LL,LambdaList,Option.q,Option );
        end
    otherwise
        error(['Wrong StepType:  ',StepType])
end
%% do the evaluation
Thres=0;
[ PredLabel,Scores,AUC,ModifyAcc,UserDefThresAcc ] = Predict_LinearSVM( W,Xtest,Ytest,Thres );
PredScoreTest=Scores;
PredLabelTest=PredLabel;
AUCTest=AUC;
ModifyAcc=ModifyAcc;
[ PredLabel,Scores,AUC,ModifyAcc,UserDefThresAcc ] = Predict_LinearSVM( W,Xtrain,Ytrain,Thres );
PreScoreTrain=Scores;
PredLabelTrain=PredLabel;

end

