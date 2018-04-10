function [ Result ] = nFold_ZhuoSVM_TrainingSet( X,Y,Dividing,Lambda,SAAOption,SparseOpt,FolderRoot,FolderName,StepType)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to run Zhuo's SVM on training data with n-fold
%   cross-validation to select the optimal parameters
%
%   z.sun 20170306

Folder1=fullfile(FolderRoot,FolderName);
if ~exist(Folder1,'dir')
    mkdir(Folder1);
end
SavePath=fullfile(Folder1,'Result.mat');
if nargin<9 | isempty(StepType)
    StepType='Fix';
end
FoldNum=length(Dividing);
TrueLabelList=[];
PredLabelList=[];
PredScoreList=[];

if ~exist(SavePath,'file')
    t1=clock;
   for j=1:FoldNum
        SelectInd=j;
        [ Xtrain,Xtest,YTrain,YTest,Dividing1 ]= nFold_DivideData( X,Y,Dividing,SelectInd );
        % do the zscore normalization
        if  ~isfield(SparseOpt,'CVZscore') | SparseOpt.CVZscore==1
            [Xtrain,mu,std]=zscore(Xtrain);
            Xtest=(Xtest-repmat(mu,[size(Xtest,1),1]))./repmat(std,[size(Xtest,1),1]);
            Xtest(:,std==0)=0;
            Xtrain(:,end)=1;
            Xtest(:,end)=1;
        end
        
        
        [PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrian,AUCTest,ModifyAcc,W]...
            =LinearSVM_TrainTest_VaryStep(Xtrain,YTrain,Xtest,YTest,Lambda,SAAOption,SparseOpt,StepType);
        TrueLabelList=[TrueLabelList;reshape(YTest,[length(YTest),1])];
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

function auc = roc_curve(deci,label_y,ShowFig)
	[val,ind] = sort(deci,'descend');
	roc_y = label_y(ind);
	stack_x = cumsum(roc_y == -1)/sum(roc_y == -1);
	stack_y = cumsum(roc_y == 1)/sum(roc_y == 1);
	auc = sum((stack_x(2:length(roc_y),1)-stack_x(1:length(roc_y)-1,1)).*stack_y(2:length(roc_y),1));

        %Comment the above lines if using perfcurve of statistics toolbox
        %[stack_x,stack_y,thre,auc]=perfcurve(label_y,deci,1);
    if ShowFig==1
        plot(stack_x,stack_y);
        xlabel('False Positive Rate');
        ylabel('True Positive Rate');
        title(['ROC curve of (AUC = ' num2str(auc) ' )']);
    end
end

% [PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrian,AUCTest,ModifyAcc,W]...
%     =LinearSVM_TrainTest(TrainFeature,TrainYList,TestFeature,TestYList,Lambda,SAAOption,SparseOpt); % this function need to be implemented