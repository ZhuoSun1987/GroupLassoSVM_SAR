function [Result1List] = ZhuoSVM_onParaArray_VaryStep(Xtrain,Ytrain,...
    Xtest,Ytest,ParaArray,SAAOpt0,SparseOpt0,StepType,ResultName,Folder0)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   20170328


ParaNum=length(ParaArray);
PD=length(ParaArray{1});
Result1List=cell(ParaNum,1);
% do the zscore
if ~isfield(SAAOpt0,'Zscore') || SAAOpt0.Zscore==1
    [Xtrain,mu,std]=zscore(Xtrain);
    Xtest=(Xtest-repmat(mu,[size(Xtest,1),1]))./repmat(std,[size(Xtest,1),1]);
    Xtest(:,std==0)=0;
    Xtrain(:,end)=1;
    Xtest(:,end)=1;
end
%% if need to save and create the Folder0
if nargin>9 & ~isempty(Folder0)
    Save=1;
end
if Save==1
    if ~exist(Folder0,'dir')
        mkdir(Folder0);
    end
end

%%
FolderNameList=cell(ParaNum,1);
parfor i=1:ParaNum
    LambdaList=ParaArray{i};
    FolderName=[];
    for j=1:PD
        FolderName=fullfile(FolderName,['L',num2str(j),'_',num2str(LambdaList(j))]);
    end
    FolderNameList{i}=FolderName;
    Folder1=fullfile(Folder0,FolderName);
    if Save==1 & ~exist(Folder1,'dir')
        mkdir(Folder1);
    end
    ResultPath1=fullfile(Folder1,ResultName);
    if ~exist(ResultPath1,'file')
        %% modify the options
            %% for the SparseOpt
        SparseOpt=SparseOpt0;
        SparseOpt.Lambda4=LambdaList(3);
        SparseOpt.C_Or_R=2;
            %% for the SAAOpt
        SAAOption=SAAOpt0;
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
                Lambda=0;
                SAAOption.Ratio=0;
            end
        end        
        
        
        %% compute the model
        [PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrain,AUCTest,ModifyAcc,W]...
            =LinearSVM_TrainTest_VaryStep(Xtrain,Ytrain,Xtest,Ytest,Lambda,SAAOption,SparseOpt,StepType);
        %% evaluate
%         ShowFig1=0;
%         auc = roc_curve(PredScoreTest,PredScoreTest,ShowFig1); % plot ROC curve
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
        Result1List{i}=Result;
        if Save==1
            parsave(fullfile(Folder1,'Model.mat'),W);
            parsave(ResultPath1,Result);
        end
    else
        Result=importdata(ResultPath1);
        Result1List{i}=Result;
    end
end

%% print and save the report 
str=sprintf('%20s  %8s  %8s  %8s  %8s  %8s  %8s  %8s  %8s','Parameter','Acc','AUC','Sen','Spe','Precise','recall','fmeas','gmean');
disp(str);
if Save==1
    fid=fopen(fullfile(Folder0,'Reporting.txt'),'w');
    fprintf(fid,'%s',str);
    fprintf(fid,'\n');
end
for i=1:ParaNum
    FolderName=FolderNameList{i};
    Result=Result1List{i};
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
