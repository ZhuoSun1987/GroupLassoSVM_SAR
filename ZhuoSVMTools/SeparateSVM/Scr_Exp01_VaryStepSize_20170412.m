%   this script is used to compute ZhuoSVM, with Double direction line
%   search, the CAT12VBM for voxelwise feature
%
%   for SVM+MM
%
%   the varying part:  1) Whether to use Zscore,  2) use Grad Or Laplacian
%   3) use SAR generated from the brain structure or the Supervoxel

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
%addpath('C:\Users\zhuo\OneDrive\Coding\nFold_ParameterSelection')

%% set the names
TuningResultName='GridSearchResult.mat';
GridSearchReportName='GridSearchReport.mat';
ReportOnTestName='ResultOnTest.mat';
TestResultName='TestResult.mat';
NewMeasureWeightList=[1,0,0,0,0,0,0,0];  % this is used to combine the precomputed measurement into a more complex measurement
CVNum=5;  % use 5-fold cross validation on the training set to tuning the parameter
FixRandSeed=1;  % fix the random seed, keep the same random dividing different time of run and run on different machine


OutRoot0=fullflie(PC_specifyRoot,'Experiment');
DataRoot0=fullfile(PC_specifyRoot,'ZhuoSVMData');
ExpName='Exp01_VaryStep';

ZscoreList=[1,0];
UseSLICSARList=[1,0];
UseSLICARSNameList={'OneSLIC','OneLA'};
UseGradOrLapList={'Grad','Lap'}
SegNameList={'Seg1','Seg2','Seg3'};
ZscoreNameList={'Zscore','NoZscore'};
SegNum=3;
SARName='SR'; % 'SAR' for spatial-anatomical regularization or  "SR" for spatial regularization
Source='CAT12VBM';
RegularFolder=[];
SegPathList=cell(SegNum,1);
SegPathList{1}=fullfile(DataRoot0,'GuidedSLIC','ROISeg.nii.gz'); % seg0 is the anatomical structure
SegPathList{2}=fullfile(DataRoot0,'GuidedSLIC',Source,'Seg_5.nii.gz');
SegPathList{3}=fullfile(DataRoot0,'GuidedSLIC',Source,'Seg_10.nii.gz');

ADTrainPath=fullfile(DataRoot,'VoxelWiseFeature',Source,'ADTrain_N3_Scaled.mat');  ADTrain=importdata(ADTrainPath);
CNTrainPath=fullfile(DataRoot,'VoxelWiseFeature',Source,'CNTrain_N3_Scaled.mat');  CNTrain=importdata(CNTrainPath);
ADTestPath =fullfile(DataRoot,'VoxelWiseFeature',Source,'ADTest_N3_Scaled.mat');   ADTest =importdata(ADTestPath);
CNTestPath =fullfile(DataRoot,'VoxelWiseFeature',Source,'CNTest_N3_Scaled.mat');   CNTest =importdata(CNTestPath);
Xtrain=[ADTrain;CNTrain]; Xtrain=[Xtrain,ones(size(Xtrain,1),1)];  Ytrain=[ones(size(ADTrain,1),1);-1*ones(size(CNTrain,1),1)];
Xtest =[ADTest ;CNTest];  Xtest =[Xtest ,ones(size(Xtest ,1),1)];  Ytest =[ones(size(ADTest,1) ,1);-1*ones(size(CNTest ,1),1)];
[ Dividing ] = CreateRandNfoldDividing(SubNum,CVNum,FixRandSeed );
%% for the experiment
for G1=1:length(ZscoreList)
    Zscore=ZscoreList(G1);
    ZscoreName=ZscoreNameList{G1};
    %% set the zscore in the option
    if Zscore==1
        % set the option to enable zscore for both CV train and test
        Option.CVZscore=1;
    else
        % set the option to disable zscore for both CV tain and test
        Option.CVZscore=0;
    end
    %%
    OutFolder1=fullfile(OutRoot0,ExpName,[Source,'_',ZscoreName]);
    MakeFolder(OutFolder1);
    CVTuningResultPath=fullfile(OutFolder1,TuningResultName);
    ReportOnTestPath=fullfile(OutFolder1,ReportOnTestName);
    ReportPath=fullfile(OutFolder1,GridSearchReportName);
    %% for the parameter CV training on the training set
    if ~exist(CVTuningResultPath,'file')
        Folder2=fullfile(OutFolder1,'GridSearchHyperParaTraining');
        MakeFolder(Folder2);
        [ CVResult ] = nFolder_ParaTuning_ZhuoSVM(X,Y,Dividing,Folder2,LambdaArray,Option);
        parsave(CVTuningResultPath,CVResult);
    else
        Str=['Already Grid Search Hyper-Paremeter ',ExpName,' ',[Source,'_',ZscoreName]];
        disp(Str)
        CVResult=importdata(CVTuningResultPath);
    end
    %% look for the optimal hyper parameters that 
end
