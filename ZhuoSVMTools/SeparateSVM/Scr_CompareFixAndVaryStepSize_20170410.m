%   this script is used to compute the CV hyperparameter tunning, for the
%   baseline experiment, LinearSVM+MM
%
%   z.sun 20170330

Ver=version;
if str2num(Ver)<8
    % when the version<8, we need to manually start the matlabpool for
    % parfor
    s = matlabpool('size')
    if s==0  %  which mean current matlabpool is closed
        matlabpool open
    end
end
%% addpath
PC_specifyRoot='E:\MyProject\ZhuoSVM';
% for home PC, it is E:\MyProject\ZhuoSVM
% for Gisela01, it is  /srv/lkeb-ig/NIP/zsun/ZhuoSVM_New/
% for Yuchuan PC, it is 'F:\Zhuo\Project\ZhuoSVM';
CodeRoot='E:\MyProject\ZhuoSVM\ZhuoSVMTools';
addpath(genpath(CodeRoot));
addpath('C:\Users\szsyh\OneDrive\Coding\nFold_ParameterSelection')
%addpath('C:\Users\zhuo\OneDrive\Coding\nFold_ParameterSelection')


%% set the input and output
InRoot0=fullfile(PC_specifyRoot,'ZhuoSVMData');
OutRoot0=fullfile(PC_specifyRoot,'Experiment');
% mkdir(OutRoot0);
DataRoot=InRoot0;
% OutRoot1=fullfile(OutRoot0,ExpName);
% mkdir(OutRoot1)
SAR_LL_Path  =fullfile(InRoot0,'Regularizer','SAR','Grad_LL.mat');
SAR_L_LL_Path=fullfile(InRoot0,'Regularizer','SAR','Grad_Norm_LL.mat');
LL  =importdata(SAR_LL_Path);
L_LL=importdata(SAR_L_LL_Path);
MaskPath=fullfile(InRoot0,'VoxelWiseFeature','Mask.nii.gz');
Nii=load_nii(MaskPath);
Mask=double(Nii.img);


%%
Source  ='CAT12VBM';
SegName ='Seg1';
G3=3;
ADTrainPath=fullfile(DataRoot,'VoxelWiseFeature',Source,'ADTrain_N3_Scaled.mat');  ADTrain=importdata(ADTrainPath);
CNTrainPath=fullfile(DataRoot,'VoxelWiseFeature',Source,'CNTrain_N3_Scaled.mat');  CNTrain=importdata(CNTrainPath);
ADTestPath =fullfile(DataRoot,'VoxelWiseFeature',Source,'ADTest_N3_Scaled.mat');   ADTest =importdata(ADTestPath);
CNTestPath =fullfile(DataRoot,'VoxelWiseFeature',Source,'CNTest_N3_Scaled.mat');   CNTest =importdata(CNTestPath);
Xtrain=[ADTrain;CNTrain]; Xtrain=[Xtrain,ones(size(Xtrain,1),1)];  Ytrain=[ones(size(ADTrain,1),1);-1*ones(size(CNTrain,1),1)];
Xtest =[ADTest ;CNTest];  Xtest =[Xtest ,ones(size(Xtest ,1),1)];  Ytest =[ones(size(ADTest,1) ,1);-1*ones(size(CNTest ,1),1)];
SegPathList=cell(3,1);
SegPathList{1}=fullfile(InRoot0,'GuidedSLIC','ROISeg.nii.gz'); % seg0 is the anatomical structure
SegPathList{2}=fullfile(InRoot0,'GuidedSLIC',Source,'Seg_5.nii.gz');
SegPathList{3}=fullfile(InRoot0,'GuidedSLIC',Source,'Seg_10.nii.gz');
Nii=load_nii(SegPathList{G3});
SegIm=Nii.img;

DD=size(Xtrain,2)-1;
LambdaList=[0,0.5,0.01];
[Xtrain,M,Std]=zscore(Xtrain); Xtrain(:,end)=1;
q=2;

%% load the group information from the segment
ROI=[];
[ GroupLassoOpt] = Mask_SegToGroupInf( Mask,SegIm,ROI,q );
GroupIndListArray=GroupLassoOpt.GroupIndPosListArray;
GroupWeight=GroupLassoOpt.GroupWeight;
GroupIndexList=GroupLassoOpt.GroupLabel;
%GroupLassoOpt.GroupWeight=ones(size(GroupLassoOpt.GroupWeight));
% SparsityOpt00=SparseOpt0;
% SparsityOpt00.GroupLassoOpt=GroupLassoOpt;

[ L_X,Temp ] = ComputeLipschitz( Xtrain, [] ); 
L_Q=L_LL*2*LambdaList(2)+LambdaList(1)*2
LipSchitzConst=2*L_X/size(Xtrain,1)+L_Q;
if LambdaList(2)>0
    Q=LambdaList(2)*LL+LambdaList(1)*speye(DD);
else
    Q=LambdaList(1);
end
InitStepsize=1/LipSchitzConst;





X=Xtrain; Y=Ytrain;
Option.MaxIter=1000;
Option.StepSize=InitStepsize;
Option.FistaOrIsta=1;
Option.SVMNorm=2;
Option.ComputeCost=1;
Option.W_ChangeNormLimit=1e-5;
Option.W_ChangeRatioLimit=1e-30;
GroupNum   =length(GroupIndListArray);
GroupWeightList=reshape(GroupWeight,[1,GroupNum]);
Option.StepIncreaseRatio=5;
Option.StepDecreaseRatio=0.2;
Option.MaxLineSearchStep=20;
Option.MinIter=10;
Option.CostConvRatio=0.001;

q=2
W0=zeros(DD+1,1);

%% doing the fix step size (FISTA)
Option1=Option;
[ W1,LOG1 ] = L2SVM_GroupLasso_SAR_Fix( X,Y,W0,GroupIndListArray,GroupWeightList,LL,LambdaList,q,Option1 );

%% doing the vary step size  (FISTA)
Option2=Option;
Option2.Print=1;
[ W2,LOG2 ] = L2SVM_GroupLasso_SAR_VaryStepSize( X,Y,W0,GroupIndListArray,GroupWeightList,LL,LambdaList,q,Option2 );

%% doing the ISTA fix step size
Option3=Option;
Option3.FistaOrIsta=2;
[ W3,LOG3 ] = L2SVM_GroupLasso_SAR_Fix( X,Y,W0,GroupIndListArray,GroupWeightList,LL,LambdaList,q,Option3 );
%% doing FISTA, without proximal , fix stepsize
Option4=Option
[ W4,LOG4 ] = L2SVM_SAR_Fix( X,Y,W0,LL,LambdaList,Option );


%%?Compare the iteratives
figure
plot(LOG1.AfterProxCost(:,4),'r')
hold on
plot(LOG2.AfterProxCost(:,4),'g')
hold on 
plot(LOG3.AfterProxCost(:,4),'b')
hold on
plot(LOG4.AfterProxCost(:,4),'k')

legend({'Fix StepSize FISTA','Vary StepSize FISTA','Fix StepSize ISTA','FixStep FISTA,no prox'})
title('Cost with iteration')

figure
plot(LOG2.StepSizeList)


% %     for G1=1:length(SourceList)
% %     Source=SourceList{G1};
% %     %% load the features that specified by the source
% %     ADTrainPath=fullfile(DataRoot,'VoxelWiseFeature',Source,'ADTrain_N3_Scaled.mat');  ADTrain=importdata(ADTrainPath);
% %     CNTrainPath=fullfile(DataRoot,'VoxelWiseFeature',Source,'CNTrain_N3_Scaled.mat');  CNTrain=importdata(CNTrainPath);
% %     ADTestPath =fullfile(DataRoot,'VoxelWiseFeature',Source,'ADTest_N3_Scaled.mat');   ADTest =importdata(ADTestPath);
% %     CNTestPath =fullfile(DataRoot,'VoxelWiseFeature',Source,'CNTest_N3_Scaled.mat');   CNTest =importdata(CNTestPath);
% %     Xtrain=[ADTrain;CNTrain]; Xtrain=[Xtrain,ones(size(Xtrain,1),1)];  Ytrain=[ones(size(ADTrain,1),1);-1*ones(size(CNTrain,1),1)];
% %     Xtest =[ADTest ;CNTest];  Xtest =[Xtest ,ones(size(Xtest ,1),1)];  Ytest =[ones(size(ADTest,1) ,1);-1*ones(size(CNTest ,1),1)];
% %     
% %     SegPathList=cell(3,1);
% %     SegPathList{1}=fullfile(InRoot0,'GuidedSLIC','ROISeg.nii.gz'); % seg0 is the anatomical structure
% %     SegPathList{2}=fullfile(InRoot0,'GuidedSLIC',Source,'Seg_5.nii.gz');
% %     SegPathList{3}=fullfile(InRoot0,'GuidedSLIC',Source,'Seg_10.nii.gz');
% %     SubNum=size(Xtrain,1);
% %     [ Dividing ] = CreateRandNfoldDividing(SubNum,CVNum,FixRandSeed );
% %     %%
% %     for G2=1:length(StepTypeList)
% %         StepType=StepTypeList{G2};
% %         OutRoot2=fullfile(OutRoot1,Source,StepType);
% %         if ~exist(OutRoot2,'dir');   mkdir(OutRoot2); end
% %         for G3=1:length(SegPathList)
% %             Nii=load_nii(SegPathList{G3});
% %             SegIm=Nii.img;
% %             %% load the group information from the segment
% %             ROI=[];
% %             [ GroupLassoOpt] = Mask_SegToGroupInf( Mask,SegIm,ROI,q );
% %             GroupIndexList=GroupLassoOpt.GroupLabel;
% %             %GroupLassoOpt.GroupWeight=ones(size(GroupLassoOpt.GroupWeight));
% %             SparsityOpt00=SparseOpt0;
% %             SparsityOpt00.GroupLassoOpt=GroupLassoOpt;
% %             OutRoot3=fullfile(OutRoot2,['Seg_',num2str(G3)]);
% %             if ~exist(OutRoot3,'dir');   mkdir(OutRoot3); end
% %             CVTuningResultPath=fullfile(OutRoot3,TuningResultName);
% %             ReportOnTestPath=fullfile(OutRoot3,ReportOnTestName);
% %             ReportPath=fullfile(OutRoot3,GridSearchReportName);
% %             %% for this grid search on CV-training set
% %             if ~exist(ReportOnTestPath,'file')
% %                 if ~exist(CVTuningResultPath,'file')
% %                     % do the hyper-parameter grid search
% %                     OutRoot4=fullfile(OutRoot3,'GridSearchHyperParaTraining');
% %                     if ~exist(OutRoot4,'dir');   mkdir(OutRoot4); end
% %                     [ Result3 ] = ParaTuning_CV_ZhuoSVM( Xtrain,Ytrain,Dividing,SAAOption0,SparsityOpt00,OutRoot4,LambdaArray,StepType);
% %                     parsave(CVTuningResultPath,Result3);
% %                 else
% %                     Str=['Already Grid Search Hyper-Paremeter ',ExpName,' ',Source,' ',StepType];
% %                     disp(Str)
% %                     Result3=importdata(CVTuningResultPath);
% %                 end
% %             end
% %             %% look for the optimal hyper parameter
% %             if ~exist(ReportPath,'file')
% %                 %% generate the report for the grid search result,
% %                 ReportTxtPath=fullfile(OutRoot3,'DetailReport.txt');
% %                 [ OptimalParaList] = ReportFromParaTuning( CVTuningResultPath,NewMeasureWeightList,ReportTxtPath );
% %                 parsave(ReportPath,OptimalParaList);
% %             else
% %                 Str=['Already Hyper-Paremeter Report ',ExpName,' ',Source,' ',StepType];
% %                 disp(Str)
% %                 OptimalParaList=importdata(ReportPath);
% %             end
% %             
% %             
% %             %% train the model using the whole training set and then evalutate the performance on test set
% %             if ~exist(ReportOnTestPath,'file')
% %                 OutRoot4=fullfile(OutRoot3,'OnTestSet');
% %                 if ~exist(OutRoot4,'dir'); mkdir(OutRoot4); end
% %                 [Result1List] = ZhuoSVM_onParaArray_VaryStep(Xtrain,Ytrain,...
% %                     Xtest,Ytest,OptimalParaList,SAAOption0,SparsityOpt00,StepType,TestResultName,OutRoot4);
% %                 parsave(ReportOnTestPath,Result1List);
% %             else
% %                 Str=['Already work on Testset ',ExpName,' ',Source,' ',StepType];
% %                 disp(Str)
% %                 FinalResult=importdata(ReportOnTestPath);
% %             end
% %             disp('===========================================')
% %             disp(['Finish   ',ExpName,' ',Source,' ',StepType,' Seg_',num2str(G3)])
% %             disp('===========================================')
% %             disp(' ')
% %             disp('  ')
% %         end
% %     end
% % end
% % 
% % 
% % 
