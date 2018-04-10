function [ResultList ] = TrainTestEvaluateZhuoSVM_ParaArray(Xtrain,Xtest,Ytrain,Ytest,W0,LL,FolderRoot,ParaArray,Option )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to learn a model on the fully training set and
%   evalutate using the test set, for a list of parameters.
%
%   z.sun 
Save=1;
if  Option.TrainTestZscore==1
    [Xtrain,mu,std]=zscore(Xtrain);
    Xtest=(Xtest-repmat(mu,[size(Xtest,1),1]))./repmat(std,[size(Xtest,1),1]);
    Xtest(:,std==0)=0;
    Xtrain(:,end)=1;
    Xtest(:,end)=1;
end

ParaNum=length(ParaArray{1});
ExpNum=length(ParaArray);
[ L_X,Temp ] = ComputeLipschitz( Xtrain, [] ); 
L_LL=Option.L_LL;
ResultList=cell(ExpNum,1);
FolderList=cell(ExpNum,1);
parfor i=1:ExpNum
    LambdaList=ParaArray{i};
    FolderName=[];
    PD=length(LambdaList);
    for j=1:PD
        FolderName=fullfile(FolderName,['L',num2str(j),'_',num2str(LambdaList(j))]);
    end
    FolderList{i}=FolderName;
    Folder1=fullfile(FolderRoot,FolderName);
    MakeFolder(Folder1);
    %%?set the initial stepsize
    Option1=Option;
    L_Q=L_LL*2*LambdaList(2)+LambdaList(1)*2;
    LipSchitzConst=2*L_X/size(Xtrain,1)+L_Q;
    InitStepsize=1/LipSchitzConst;
    Option1.StepSize=InitStepsize;
    
    %% 
    ExpSavePath1=fullfile(Folder1,'Model.mat');
    ExpSavePath2=fullfile(Folder1,'TestResult.mat');
    if exist(ExpSavePath1,'file') & exist(ExpSavePath2,'file')
        Str=['Already Compute model and Evaluate for ',FolderName];
        disp(Str);
        Result=importdata(ExpSavePath2);
        ResultList{i}=Result;
    else
        %% compute the model
        [ PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrain,AUCTest,ModifyAcc,W ] = TrainTestEvaluateZhuoSVM_SingleLambdaList...
        (Xtrain,Xtest,Ytrain,Ytest,W0,LL,Folder1,LambdaList,Option );
        ShowFig1=0;
        auc = roc_curve(PredScoreTest,Ytest,ShowFig1); % plot ROC curve
        [EVAL] = Evaluate(Ytest,PredLabelTest);
        Result.accuracy   =EVAL(1);
        Result.sensitivity=EVAL(2);
        Result.specificity=EVAL(3);
        Result.precision  =EVAL(4);
        Result.recall     =EVAL(5);
        Result.f_measure  =EVAL(6);
        Result.gmean      =EVAL(7);
        Result.PredLabelList=PredLabelTest;
        Result.TrueLabelList=Ytest;
        Result.DeciList     =PredScoreTest;
        Result.AUC          =auc;
        %% 
        ResultList{i}=Result;
        parsave(ExpSavePath1,W)
        parsave(ExpSavePath2,Result);
    end
end

%% 
str=sprintf('%20s  %8s  %8s  %8s  %8s  %8s  %8s  %8s  %8s','Parameter','Acc','AUC','Sen','Spe','Precise','recall','fmeas','gmean');
disp(str);
if Save==1
    fid=fopen(fullfile(FolderRoot,'Reporting.txt'),'w');
    fprintf(fid,'%s',str);
    fprintf(fid,'\n');
end
for i=1:ExpNum
    FolderName=FolderList{i};
    Result=ResultList{i};
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
    if Save==1
        fprintf(fid,'%s',Str);
        fprintf(fid,'\n');
    end
end
if Save==1
    fclose(fid);
end

end


function auc = roc_curve(deci,label_y,ShowFig)
	[val,ind] = sort(deci,'descend');
	roc_y = label_y(ind);
	stack_x = cumsum(roc_y == -1)/sum(roc_y == -1);
	stack_y = cumsum(roc_y == 1)/sum(roc_y == 1);
	auc = sum((stack_x(2:length(roc_y),1)-stack_x(1:length(roc_y)-1,1)).*stack_y(2:length(roc_y),1))

        %Comment the above lines if using perfcurve of statistics toolbox
        %[stack_x,stack_y,thre,auc]=perfcurve(label_y,deci,1);
    if ShowFig==1
        plot(stack_x,stack_y);
        xlabel('False Positive Rate');
        ylabel('True Positive Rate');
        title(['ROC curve of (AUC = ' num2str(auc) ' )']);
    end
end

function [EVAL] = Evaluate(ACTUAL,PREDICTED)
% This fucntion evaluates the performance of a classification model by 
% calculating the common performance measures: Accuracy, Sensitivity, 
% Specificity, Precision, Recall, F-Measure, G-mean.
% Input: ACTUAL = Column matrix with actual class labels of the training
%                 examples
%        PREDICTED = Column matrix with predicted class labels by the
%                    classification model
% Output: EVAL = Row matrix with all the performance measures


idx = (ACTUAL()==1);

p = length(ACTUAL(idx));
n = length(ACTUAL(~idx));
N = p+n;

tp = sum(ACTUAL(idx)==PREDICTED(idx));
tn = sum(ACTUAL(~idx)==PREDICTED(~idx));
fp = n-tn;
fn = p-tp;

tp_rate = tp/p;
tn_rate = tn/n;

accuracy = (tp+tn)/N;
sensitivity = tp_rate;
specificity = tn_rate;
precision = tp/(tp+fp);
recall = sensitivity;
f_measure = 2*((precision*recall)/(precision + recall));
gmean = sqrt(tp_rate*tn_rate);

EVAL = [accuracy sensitivity specificity precision recall f_measure gmean];
end

