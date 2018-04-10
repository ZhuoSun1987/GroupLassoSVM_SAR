%   this script is used to extend the optimal models from each
%   regularized cost function to the parameter vs accuracy and sparisity
%   plot and also make prediction on the large-scale dataset
%
%   z.sun  20170930

%% addpath
addpath('C:\Users\szsyh\OneDrive\Coding\nFold_ParameterSelection')
CodeRoot='E:\MyProject\ZhuoSVM\ZhuoSVMTools';
addpath(genpath(CodeRoot));


%% set input
FeatureRoot='E:\MyProject\ZhuoSVM\ZhuoSVMData\VoxelWiseFeature\CAT12VBM';
ExpNum=13;
ExpRoot='E:\MyProject\ZhuoSVM\Experiment';
ModelName='Model.mat';
ExpOptModelList=cell(ExpNum,1);ExpNameList=cell(ExpNum,1);
ExpOptModelList{1}='Exp_001\CAT12VBM\Fix\OnTestSet\L1_1000\L2_0\L3_0';                     ExpNameList{1}='Baseline';
ExpOptModelList{3}='Exp_002\CAT12VBM\Fix\OnTestSet\L1_0\L2_0.1\L3_0';                      ExpNameList{3}='SVM_SR';
ExpOptModelList{2}='Exp_003\CAT12VBM\Fix\OnTestSet\L1_0\L2_0.01\L3_0';                     ExpNameList{2}='SVM_SAR';
ExpOptModelList{4}='Exp_005\CAT12VBM\Fix\OnTestSet\L1_0\L2_0\L3_0.001';                    ExpNameList{4}='LassoSVM';
ExpOptModelList{5}='Exp_006\CAT12VBM\Fix\OnTestSet\L1_10\L2_0\L3_0.2';                     ExpNameList{5}='LassoSVM_MM';
ExpOptModelList{6}='Exp_008\CAT12VBM\Fix\OnTestSet\L1_0\L2_0.5\L3_0.1';                    ExpNameList{6}='LassoSVM_SR';
ExpOptModelList{7}='Exp_007\CAT12VBM\Fix\OnTestSet\L1_0\L2_0.01\L3_0.001';                 ExpNameList{7}='LassoSVM_SAR';
ExpOptModelList{8}='Exp_010\CAT12VBM\Fix\Seg_3\OnTestSet\L1_0\L2_0\L3_0.01';                     ExpNameList{8}='GLSVM';
ExpOptModelList{9}='Exp_011\CAT12VBM\Fix\Seg_3\OnTestSet\L1_0.01\L2_0\L3_0.01';                  ExpNameList{9}='GLSVM_MM';

ExpOptModelList{10}='Exp_013\CAT12VBM\Fix\Seg_3\OnTestSet\L1_0\L2_5\L3_0.2';               ExpNameList{10}='GLSVM_SR_acSLIC';
ExpOptModelList{11}='Exp_012_1000Iter\CAT12VBM\Fix\Seg_3\OnTestSet\L1_0\L2_0.5\L3_0.01';   ExpNameList{11}='GLSVM_SAR_acSLIC';
ExpOptModelList{12}='Exp_StandSLIC_GroupLassoSVM_SAR_1000Iter\CAT12VBM\Fix\Seg_1\OnTestSet\L1_0\L2_0.01\L3_0.01';  ExpNameList{12}='GLSVM_SAR_SLIC';
ExpOptModelList{13}='Exp_012_1000Iter\CAT12VBM\Fix\Seg_1\OnTestSet\L1_0\L2_0.01\L3_5';     ExpNameList{13}='GLSVM_SAR_S';



% % ExpOptModelList{3}='Exp_013\CAT12VBM\Fix\Seg_3\OnTestSet\L1_0\L2_5\L3_0.2';               ExpNameList{3}='GL_SR_acSLIC';
% % ExpOptModelList{3}='Exp_013\CAT12VBM\Fix\Seg_3\OnTestSet\L1_0\L2_5\L3_0.2';               ExpNameList{3}='GL_SR_acSLIC';

%.....%

%% set the input traning data, testing data and large scale data
TrainPosPath=fullfile(FeatureRoot,'ADTrain_N3_Scaled.mat');
TestPosPath =fullfile(FeatureRoot,'ADTest_N3_Scaled.mat');
TrainNegPath=fullfile(FeatureRoot,'CNTrain_N3_Scaled.mat');
TestNegPath =fullfile(FeatureRoot,'CNTest_N3_Scaled.mat');
LargePosPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','AD_InADNIButNotCuingnetTrain.mat');
LargeNegPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','CN_InADNIButNotCuingnetTrain.mat');
TrainPos=importdata(TrainPosPath);      TestPos=importdata(TestPosPath);
TrainNeg=importdata(TrainNegPath);      TestNeg=importdata(TestNegPath);
LargePos=importdata(LargePosPath);      
LargeNeg=importdata(LargeNegPath);


TrainMat=[TrainPos;TrainNeg];  TrainLabel=[ones(size(TrainPos,1),1); -1*ones(size(TrainNeg,1),1)];  TrainMat=[TrainMat,ones(size(TrainMat,1),1)];
TestMat =[TestPos ;TestNeg ];  TestLabel =[ones(size(TestPos ,1),1); -1*ones(size(TestNeg ,1),1)];  TestMat =[TestMat ,ones(size(TestMat ,1),1)];
LargeMat=[LargePos;LargeNeg];  LargeLabel=[ones(size(LargePos,1),1); -1*ones(size(LargeNeg,1),1)];  LargeMat=[LargeMat,ones(size(LargeMat,1),1)];

XArray=cell(3,1);  XArray{1}=TrainMat;    XArray{2}=TestMat;    XArray{3}=LargeMat;
YArray=cell(3,1);  YArray{1}=TrainLabel;  YArray{2}=TestLabel;  YArray{3}=LargeLabel;

PredTestLabelList =cell(ExpNum,1);
PredLargeLabelList=cell(ExpNum,1);
PredTestPerfList  =cell(ExpNum,1);
PredLargePerfList =cell(ExpNum,1);




%% for Train, Test and LargeMat, make prediction and recode the result
DatasetNameList={'Train','Test','LargeScale'}
PredLabelList=cell(3,1);
PredScoreList=cell(3,1);
SPACE=' ';
TitleStr=sprintf('%20s%8s%8s%8s%8s','ExpName','Acc','AUC','SPE','SEN');

for i=1:3
    X=XArray{i};  Y=YArray{i};
    disp('')
    disp('========================================')
    disp(['======',DatasetNameList{i},'======='])
    disp('========================================')
    disp(TitleStr)
    %% zscore the features
    [Xtrain,mu,std]=zscore(TrainMat);
    Xtest=(X-repmat(mu,[size(X,1),1]))./repmat(std,[size(X,1),1]);
    Xtest(:,std==0)=0;
    Xtrain(:,end)=1;
    Xtest(:,end)=1;
    %%
    PredYMat    =zeros(length(ExpOptModelList),length(Y));
    PredScoreMat=zeros(length(ExpOptModelList),length(Y));
    for E=1:length(ExpOptModelList)
        ExpName=ExpNameList{E};
        ModelPath=fullfile(ExpRoot,ExpOptModelList{E},'Model.mat');
        W=importdata(ModelPath);
        if length(W)==size(Xtest,2)-1
            Xtest1=Xtest(:,1:end-1);
        end
        if length(W)==size(Xtest,2)
            Xtest1=Xtest;
        end
        if length(W)>size(Xtest,2) | length(W)<size(Xtest,2)-1
            error('Dimension Problem')
        end
       %% make prediction
       Thres=0;
       [ PredLabel,Scores,AUC,ModifyAcc,UserDefThresAcc ] = Predict_LinearSVM( W,Xtest1,Y,Thres );
       PredYMat    (E,:)=PredLabel;
       PredScoreMat(E,:)=Scores;
       %% compute the evaluation
        ShowFig1=0;
        auc = roc_curve(Scores,Y,ShowFig1); % plot ROC curve
        [EVAL] = Evaluate(Y,PredLabel);
        acc=EVAL(1);
        sen=EVAL(2);
        spe=EVAL(3);
    
       %% print out the results
       acc=acc*100; auc=auc*100; spe=spe*100;  sen=sen*100;
        ExpStr=sprintf('%20s%8.1f%8.1f%8.1f%8.1f',ExpName,acc,auc,spe,sen);
        disp(ExpStr)
       
    end
    PredLabelList{i}=PredYMat;
    PredScoreList{i}=PredScoreMat;
end

%% use the predicted label to make test and 
disp('===Test on the predicted label,  Testset =====')
PMatrix=zeros(ExpNum);
TrueLabel=YArray{2};

PredTestLabelList=PredLabelList{2};

for i=1:ExpNum
    for j=i+1:ExpNum
        Pred_i=PredTestLabelList(i,:)';
        Pred_j=PredTestLabelList(j,:)';
        [h,p,e1,e2] = testcholdout(Pred_i,Pred_j,TrueLabel);
        PMatrix(i,j)=p;
        PMatrix(j,i)=p;
    end
end
disp(PMatrix);

disp('===Test on the predicted label,  Large scale set =====')
PMatrix=zeros(ExpNum);
TrueLabel=YArray{3};
PredLargeLabelList=PredLabelList{3};
for i=1:ExpNum
    for j=i+1:ExpNum
        Pred_i=PredLargeLabelList(i,:)';
        Pred_j=PredLargeLabelList(j,:)';
        [h,p,e1,e2] = testcholdout(Pred_i,Pred_j,TrueLabel);
        PMatrix(i,j)=p;
        PMatrix(j,i)=p;
    end
end
disp(PMatrix);





%% do the prediction for each experiment
for i=1:ExpNum
   %% load model
   ModelPath=fullfile(ExpRoot,ExpOptModelList{i},ModelName);
   W=importdata(ModelPath);
   %% make prediction on the test
   TrueLabel=TestLabel;
   PredLabel=[];
   PredPerformanceList=[];
   PredTestLabelList{i}=PredLabel;
   PredTestPerfList{i} =PredPerformanceList;
   %% make prediction on the Large-scale dataset
   TrueLabel=LargeLabel;
   PredLabel=[];
   PredPerformanceList=[];
   PredLargeLabelList{i}=PredLabel;
   PredLargePerfList{i} =PredPerformanceList; 
end

%% print out the result
PerfNameList={'Acc','AUC','SEN','SPE'};
Title='ExpName';
Row0=sprintf('%20s','ExpName');
for i=1:length(PerfNameList)
    Row0=[Row0,sprintf('%8s',PerfNameList{i})];
end

disp('====Performance in test set=======')
disp(Row0);
for i=1:ExpNum
    Row1=sprintf('%20s',ExpNameList{i});
    for j=1:length(PerfNameList)
        Row1=[Row1,sprintf('%4s%02.1f','',PredPerformanceList{i}(j)*100)];
        disp(Row1);
    end
end

disp('====Performance in Large scale set=======')
disp(Row0);
for i=1:ExpNum
    Row1=sprintf('%20s',ExpNameList{i});
    for j=1:length(PerfNameList)
        Row1=[Row1,sprintf('%4s%02.1f','',PredPerformanceList{i}(j)*100)];
        disp(Row1);
    end
end


%% use the predicted label to make test and 
disp('===Test on the predicted label,  Testset =====')
PMatrix=zeros(ExpNum);
TrueLabel=TestLabel;
for i=1:ExpNum
    for j=i+1:ExpNum
        Pred_i=PredTestLabelList{i};
        Pred_j=PredTestLabelList{j};
        [h,p,e1,e2] = testcholdout(Pred_i,Pred_j,TrueLabel);
        PMatrix(i,j)=p;
        PMatrix(j,i)=p;
    end
end
disp(PMatrix);

disp('===Test on the predicted label,  Large scale set =====')
PMatrix=zeros(ExpNum);
TrueLabel=LargeLabel;
for i=1:ExpNum
    for j=i+1:ExpNum
        Pred_i=PredLargeLabelList{i};
        Pred_j=PredLargeLabelList{j};
        [h,p,e1,e2] = testcholdout(Pred_i,Pred_j,TrueLabel);
        PMatrix(i,j)=p;
        PMatrix(j,i)=p;
    end
end
disp(PMatrix);
