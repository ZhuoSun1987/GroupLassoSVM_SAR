% this script is used to make classification of the 
PC_specifyRoot='E:\MyProject\ZhuoSVM';
% for home PC, it is E:\MyProject\ZhuoSVM
% for Gisela01, it is  /srv/lkeb-ig/NIP/zsun/ZhuoSVM_New/
% for Yuchuan PC, it is 'F:\Zhuo\Project\ZhuoSVM';
CodeRoot='E:\MyProject\ZhuoSVM\ZhuoSVMTools';
addpath(genpath('C:\Users\szsyh\OneDrive\Coding\nFold_ParameterSelection'))
addpath(genpath(CodeRoot));
InRoot0=fullfile(PC_specifyRoot,'ZhuoSVMData');
%% set the input, output
OutRoot='E:\MyProject\ZhuoSVM\Experiment\Exp_Revision';
MakeFolder(OutRoot);
%% set the general options and specify the option for each experiment
ExpNameList={'LinearSVM','GroupLassoSARSVM'}
OptionArray=cell(length(ExpNameList),1);

%%
TuningResultName='GridSearchResult.mat';
GridSearchReportName='GridSearchReport.mat';
ReportOnTestName='ResultOnTest.mat';
TestResultName='TestResult.mat';
%% set the segmentation, the SAR
SegPath=fullfile(InRoot0,'GuidedSLIC',Source,'Seg_10.nii.gz');
LL_Path=fullfile(InRoot0,'Regularizer','SAR','Grad_LL.mat');
LL_NormPath=fullfile(InRoot0,'Regularizer','SAR','Grad_Norm_LL.mat');
LL=importdata(LL_Path);
L_LL=importdata(LL_NormPath);
%% begin setting the general option
Option0=[]; 
Option0.MaxIter=1000;
Option0.StepSize=0.001;
Option0.FistaOrIsta=1;
Option0.SVMNorm=2;
Option0.ComputeCost=0;
Option0.W_ChangeNormLimit=1e-10;
Option0.W_ChangeRatioLimit=1e-10;
Option0.StepIncreaseRatio=5;
Option0.StepDecreaseRatio=0.2;
Option0.MaxLineSearchStep=20;
Option0.MinIter=10;
Option0.CostConvRatio=0.001;
Option0.Print=0;
Option0.q=2;
Option0.StepType='Fix';



%% begin setting option for the first experimetn
Option1=Option0;




    %% begin setting option for the second experiment, group lasso SAR SVM
Option2=Option0;
Nii=load_nii(SegPath);



OptionArray{1}=Option1;  OptionArray{2}=Option2;


%% set the ParaArrayArray for two experiment
ParaArrayArray=cell(2,1);
% for baseline SVM 
Lambda1=[0.0001,0.001,0.01,0.1,0.5,1,2,5,10];
Lambda2=[0];
Lambda3=[0];
ValueArray=cell(3,1);  ValueArray{1}=Lambda1;ValueArray{2}=Lambda2;ValueArray{3}=Lambda3;
[ LambdaArray ] = Mat2RowCell(ParameterArrayGenerator( ValueArray ));
ParaArrayArray{1}=LambdaArray;
% for the group lasso SAR SVM
Lambda1=[0];
Lambda2=[0.001,0.01,0.1,0.5,1,2,5,10];
Lambda3=[0.0001,0.001,0.01,0.1,0.5,1,2,5,10];
ValueArray=cell(3,1);  ValueArray{1}=Lambda1;ValueArray{2}=Lambda2;ValueArray{3}=Lambda3;
[ LambdaArray ] = Mat2RowCell(ParameterArrayGenerator( ValueArray ));
ParaArrayArray{2}=LambdaArray;


%% some other setting
CVNum=5;FixRandSeed=1;
%% set the feature path
TestNum=4;
TestNameList={'CNvsAD','CNvsMCI','MCIvsAD','MCIsvsMCIc'}
TestStructArray=cell(TestNum,1);
FeatureRoot=fullfile(InRoot0,'VoxelWiseFeature','CAT12VBM')
% for CN vs AD
TestStructStruct0=[];
TestStructStruct0.TrainPosPath=fullfile(FeatureRoot,'CNTrain_N3_Scaled.mat');
TestStructStruct0.TestPosPath =fullfile(FeatureRoot,'CNTest_N3_Scaled.mat');
TestStructStruct0.TrainNegPath=fullfile(FeatureRoot,'ADTrain_N3_Scaled.mat');
TestStructStruct0.TestNegPath =fullfile(FeatureRoot,'ADTest_N3_Scaled.mat');
TestStructStruct0.LargePosPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','Normal.mat');
TestStructStruct0.LargeNegPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','AD.mat');
TestStructArray{1}=TestStructStruct0;
% for CN vs MCI
TestStructStruct0=[];
TestStructStruct0.TrainPosPath=fullfile(FeatureRoot,'CNTrain_N3_Scaled.mat');
TestStructStruct0.TestPosPath =fullfile(FeatureRoot,'CNTest_N3_Scaled.mat');
TestStructStruct0.TrainNegPath=fullfile(FeatureRoot,'MCITrain.mat');
TestStructStruct0.TestNegPath =fullfile(FeatureRoot,'MCITest.mat');
TestStructStruct0.LargePosPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','Normal.mat');
TestStructStruct0.LargeNegPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','MCI.mat');
TestStructArray{2}=TestStructStruct0;
% for MCI vs AD
TestStructStruct0=[];
TestStructStruct0.TrainPosPath=fullfile(FeatureRoot,'MCITrain.mat');
TestStructStruct0.TestPosPath =fullfile(FeatureRoot,'MCITest.mat');
TestStructStruct0.TrainNegPath=fullfile(FeatureRoot,'ADTrain_N3_Scaled.mat');
TestStructStruct0.TestNegPath =fullfile(FeatureRoot,'ADTest_N3_Scaled.mat');
TestStructStruct0.LargePosPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','MCI.mat');
TestStructStruct0.LargeNegPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','AD.mat');
TestStructArray{3}=TestStructStruct0;
% for MCIs vs MCIc
TestStructStruct0=[];
TestStructStruct0.TrainPosPath=fullfile(FeatureRoot,'MCITrain.mat');
TestStructStruct0.TestPosPath =fullfile(FeatureRoot,'MCITest.mat');
TestStructStruct0.TrainNegPath=fullfile(FeatureRoot,'ADTrain_N3_Scaled.mat');
TestStructStruct0.TestNegPath =fullfile(FeatureRoot,'ADTest_N3_Scaled.mat');
% TestStructStruct0.LargePosPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','MCI.mat');
% TestStructStruct0.LargeNegPath=fullfile(FeatureRoot,'ADNI1_Annual_2Yr_1.5T_1729_CAT12','AD.mat');
TestStructArray{4}=TestStructStruct0;

%% for different Test
for TT=1:TestNum
    TestName=TestNameList{TT};
    disp(['===Test name: ',TestName,'====='])
    %% load the features
    TestStructStruct0=TestStructArray{TT};
    TrainPosMatPath=TestStructStruct0.TrainPosPath;
    TrainNegMatPath=TestStructStruct0.TrainNegPath;
    TestPosMatPath =TestStructStruct0.TestPosPath ;
    TestNegMatPath =TestStructStruct0.TestNegPath ;
    TrainPosMat=importdata(TrainPosMatPath);  TrainNegMat=importdata(TrainNegMatPath);
    TestPosMat =importdata(TestPosMatPath);   TestNegMat=importdata(TestNegMatPath);
    LargePosMat=[];LargeNegMat=[];
    if isfield(TestStructStruct0,'LargePosPath') & ~isempty(TestStructStruct0.LargePosPath)...
            & isfield(TestStructStruct0,'LargePosPath') & ~isempty(TestStructStruct0.LargePosPath)
        LargePosMatPath=TestStructStruct0.LargePosPath;
        LargeNegMatPath=TestStructStruct0.LargeNegPath;
        LargePosMat=importdata(LargePosMatPath);  LargeNegMat=importdata(LargeNegMatPath); 
    else
        LargePosMat=[];                           LargeNegMat=[];
    end
    TrainMat=[TrainPosMat;TrainNegMat]; TrainLabel=[ones(size(TrainPosMat,1),1);-1*ones(size(TrainNegMat,1),1)];
    TestMat =[TestPosMat ;TestNegMat ]; TestLabel =[ones(size(TestPosMat ,1),1);-1*ones(size(TestNegMat ,1),1)];
    LargeMat=[LargePosMat;LargeNegMat]; LargeLabel=[ones(size(LargePosMat,1),1);-1*ones(size(LargeNegMat,1),1)];  
    %% set the CV dividing for the training set
    Dividing=CreateRandNfoldDividing(length(TrainLabel),CVNum,FixRandSeed );
    % set the initial W0
    W0=[];
    %% set the output
    TestOutRoot=fullfile(OutRoot,TestName);
    mkdir(TestOutRoot);
    %% for different Experiment, classification model
    for EE=1:length(ExpNameList)
         ExpName=ExpNameList{EE};
         t1=clock;
         disp(['===Test name: ',TestName,' ExpName ',ExpName,'''====='])
         ExpOutRoot=fullfile(TestOutRoot,ExpName);
         ParaArray=ParaArrayArray{EE};
         Option=OptionArray{EE};
         Option.Dividing=Dividing;
         mkdir(ExpOutRoot);
         %% do the experiment, Step 1, CV on the training set and give the optimal parameter,do the experiment, 
         % and Step 2, doing the training using all training set with the
         % optimal parameter and evaluate on the test set.
         % the result is save in a .txt file to recode the report
         TestParaArray=[];
% % %          DoExperiment20170416( TrainMat,TestMat,TrainLabel,TestLabel,ExpOutRoot,ParaArray,TestParaArray,W0,LL,Option,StructOption );
                  
         
         %% do the Experiment, Step 3, for all the parameter (grid search), train on the whole set, and then use the model to make prediction on both test and large set
         TrainTestFolder=fullfile(ExpOutRoot,'TrainTestEval');
         MakeFolder(TrainTestFolder);
         TrainTestResultPath=fullfile(TrainTestFolder,'ResultMatArray.mat');
         AxisValuepath      =fullfile(TrainTestFolder,'AxisValues.mat');
         if ~exist(TrainTestResultPath,'file')
             TestXArray=[];TestYArray=[];
             if isempty(LargeMat)
                 TestXArray=cell(1,1);TestXArray{1}=TestMat;
                 TestYArray=cell(1,1);TestYArray{1}=TestLabel;
             else
                 TestXArray=cell(2,1);TestXArray{1}=TestMat;  TestXArray{2}=TestMat;
                 TestYArray=cell(2,1);TestYArray{1}=TestLabel;TestYArray{2}=LargeLabel;
             end
% % %              [ Result,AxisValues] = ParaGridSearchTrainTest( TrainX,TrainY,TestXArray,TestYArray,TestNameList,ParaArray,W0,Option,OutRoot );
% % %              parsave(AxisValuepath      ,AxisValues);
% % %              parsave(TrainTestResultPath,Result)
             
         end
% % %          ResultMatrixStruct=importdata(TrainTestResultPath);
% % %          AxisValues        =importdata(AxisValuepath);
         
        %% doing the plot
        pause(10)
        PlotFolder=fullfile(TrainTestFolder,'Plot');
        FormatList={'.fig','.jpg','.pdf'};
% % %         DoingPlotParameterInfluence( PlotFolder,ResultMatrixStruct, AxisValues,FormatList);
         t2=clock;
         disp(['===Test name: ',TestName,' ExpName ',ExpName,' from ',datestr(t1),' to ',datestr(t2),'====='])
    end
    
end






    
    
    






