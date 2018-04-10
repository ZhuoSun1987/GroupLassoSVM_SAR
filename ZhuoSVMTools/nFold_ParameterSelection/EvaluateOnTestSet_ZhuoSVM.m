function [ output_args ] = EvaluateOnTestSet_ZhuoSVM( Xtrain,Xtest,Ytrain,Ytest,LambdaArray,Folder,SAAOpt0,SparseOpt0,StepType )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
%
%   size of Xtrain is [N1,D+1], size of Xtest is [N2,D+1]
%   


% do the zscore normalization
[Xtrain,mu,std]=zscore(Xtrain);
Xtest=(Xtest-repmat(mu,[size(Xtest,1),1]))./repmat(std,[size(Xtest,1),1]);
Xtest(:,std==0)=0;
Xtrain(:,end)=1;
Xtest(:,end)=1;

%
N=length(LambdaArray);
ResultArray=cell(N,1);
FolderNameList=cell(N,1);

parfor i=1:N
    LambdaList=LambdaArray{i};
    % make the result folder
    FolderName=[];
    for LInd=1:length(LambdaList);
        FolderName=fullfile(FolderName,['L',num2str(LInd),'_',num2str(LambdaList(LInd))]);
    end
    FolderNameList{i}=FolderName;
    Folder1=fullfile(Folder,FolderName);
    if ~exist(Folder1,'dir')
        mkdir(Folder1);
    end
    ResultMapPath  =fullfile(Folder1,'WeightVec.mat');
    ClassResultPath=fullfile(Folder1,'ClassResult.mat');
    if exist(ResultMapPath,'file') & exist(ClassResultPath,'file')
        Result=importdata(ClassResultPath);
    else
        t1=clock;
        SparseOpt=SparseOpt0;
        SparseOpt.Lambda4=LambdaList(3);
        SparseOpt.C_Or_R=2;
        SAAOption=SAAOption0;
        Lambda=0;
        if LambdaList(1)>0
            Lambda=LambdaList(1);
            if LambdaList(2)>0
                SAAOption.Ratio=LambdaList(2)/LambdaList(1);
            else
                % only the max margin
                SAAOption.Ratio=0;
            end
        else
            Lambda=LambdaList(2);
            if LambdaList(2)>0
                SAAOption.OnlySAA=1;
            else
                Lambda=0
            end
        end
        [PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrian,AUCTest,ModifyAcc,W]...
            =LinearSVM_TrainTest_VaryStep(Xtrain,Ytrain,Xtest,Ytest,Lambda,SAAOption,SparseOpt,StepType);
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
        Result.DeciList     =DeciList;
        Result.AUC          =auc;
        parsave(ResultMapPath,W);
        parsave(ClassResultPath,Result);
        t2=clock;
        str=['Compute ',FolderName, ' from ',datestr(t1),' to ',datestr(t2),' takes ',num2str(etime(t2,t1)),' second']
    end
    ResultArray{i}=Result;
end


str=sprintf('%20s  %8s  %8s  %8s  %8s  %8s  %8f  %8s  %8s','Parameter','Acc','AUC','Sen','Spe','Precision''recall','f_meas','gmean');
disp(str);
for i=1:N
    FolderName=FolderNameList{i};
    Result=ResultArray{i}
    AUC=Result.AUC;
    Acc=Result.accuracy;
    Sen=Result.sensitivity;
    Spe=Result.specificity;
    precision=Result.precision;
    recall=Result.recall;
    f=    Result.f_measure;
    gmean=Result.gmean;
    Str=sprintf('%20s  %8f  %8f  %8f  %8f  %8f  %8f  %8f  %8f',FolderName,Acc,AUC,Sen,Spe,precision,recall,f,gmean);
    disp(Str);
end
    


end

