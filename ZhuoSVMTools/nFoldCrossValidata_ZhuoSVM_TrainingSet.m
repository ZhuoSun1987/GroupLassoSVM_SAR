function [ Result ] = nFoldCrossValidata_ZhuoSVM_TrainingSet( X,Y,W0,Dividing,LambdaList,LL,ResultFolder,FolderName,Option)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to compute a n-folder cross-validation on the
%   training set
%
%   z.sun

MakeFolder(ResultFolder);
StepType=Option.StepType;
SavePath=fullfile(ResultFolder,'Result.mat');
FoldNum=length(Dividing);
TrueLabelList=[];
PredLabelList=[];
PredScoreList=[];


%%  detect if the SVM function is hte SARSVM or LassoSARSVM or GroupLassoSARSVM
if sum(LambdaList>=0)<3
    error('Each Lambda should be non negative');
end
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

%%
dd=size(X,2);
if isempty(W0)
    W0=zeros(dd,1);
end
L_LL=Option.L_LL;
q=Option.q;



%% compute the CV on the training set
if ~exist(SavePath,'file')
    t1=clock;
    for j=1:FoldNum
        SelectInd=j;
        [ Xtrain,Xtest,Ytrain,Ytest,Dividing1 ]= nFold_DivideData( X,Y,Dividing,SelectInd );
        %% do the zscore normalization
        if  Option.CVZscore==1
            [Xtrain,mu,std]=zscore(Xtrain);
            Xtest=(Xtest-repmat(mu,[size(Xtest,1),1]))./repmat(std,[size(Xtest,1),1]);
            Xtest(:,std==0)=0;
            Xtrain(:,end)=1;
            Xtest(:,end)=1;
        end
        %% update some of the option
        Option1=Option;
        [ L_X,Temp ] = ComputeLipschitz( Xtrain, [] ); 
        L_Q=L_LL*2*LambdaList(2)+LambdaList(1)*2;
        LipSchitzConst=2*L_X/size(Xtrain,1)+L_Q;
        InitStepsize=1/LipSchitzConst;
        Option1.StepSize=InitStepsize;
        %% do the learning
        W=[];
        switch StepType
            case 'Fix'
                if CostType==1 % no sparsity
                    [ W,LOG ] = L2SVM_SAR_Fix( Xtrain,Ytrain,W0,LL,LambdaList,Option1 );
                end
                if CostType==2
                    [ W,LOG ] = L2SVM_Lasso_SAR_Fix( Xtrain,Ytrain,W0,LL,LambdaList,Option1 );
                end
                if CostType==3
                    [ W,LOG ] = L2SVM_GroupLasso_SAR_Fix(Xtrain,Ytrain,W0,Option1.GroupIndListArray,Option1.GroupWeightList,LL,LambdaList,q,Option );
                end
                
            case 'Vary'
                if CostType==1 % no sparsity
                    [ W,LOG ] = L2SVM_SAR_VaryStepSize( Xtrain,Ytrain,W0,LL,LambdaList,Option1 );
                end
                if CostType==2
                    [ W,LOG ] = L2SVM_Lasso_SAR_VaryStepSize( Xtrain,Ytrain,W0,LL,LambdaList,Option1 );
                end
                if CostType==3
                    [ W,LOG ] = L2SVM_GroupLasso_SAR_VaryStepSize(Xtrain,Ytrain,W0,Option1.GroupIndListArray,Option1.GroupWeightList,LL,LambdaList,q,Option );
                end                
            otherwise
                error(['Wrong StepType:  ',StepType])
        end
        %% do the evaluation
        [ PredScoreTest,PredLabelTest ] = ZhuoLinearSVM_Pred(W,Xtest);
        TrueLabelList=[TrueLabelList;reshape(Ytest,[length(Ytest),1])];
        PredLabelList=[PredLabelList;reshape(PredLabelTest,[length(PredLabelTest),1])];
        PredScoreList=[PredScoreList;reshape(PredScoreTest,[length(PredScoreTest),1])];
    end
    %% evaluate
    ShowFig1=0;
    auc = roc_curve(PredScoreList,TrueLabelList,ShowFig1); % plot ROC curve
    [EVAL] = Evaluate(TrueLabelList,PredLabelList);
    Result.accuracy   =EVAL(1);
    Result.sensitivity=EVAL(2);
    Result.specificity=EVAL(3);
    Result.precision  =EVAL(4);
    Result.recall     =EVAL(5);
    Result.f_measure  =EVAL(6);
    Result.gmean      =EVAL(7);
    Result.PredLabelList=PredLabelList;
    Result.TrueLabelList=TrueLabelList;
    Result.DeciList     =PredScoreList;
    Result.AUC          =auc;
    EVAL(8)=auc;
    parsave(SavePath,Result)
    t2=clock;
    str=['Compute ',FolderName, ' from ',datestr(t1),' to ',datestr(t2), ' takes ',num2str(etime(t2,t1)),' s'];
    disp(str)
else
    Str=['Already computed,',FolderName];
    disp(Str)
    Result=importdata(SavePath);
end



end

