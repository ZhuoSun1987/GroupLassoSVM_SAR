%   this script is used to compute ZhuoSVM, with Double direction line
%   search, the CAT12VBM for voxelwise feature
%
%   for group lasso based method, with SAR
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
addpath('C:\Users\szsyh\OneDrive\Coding\nFold_ParameterSelection')


%%
OutRoot0='E:\MyProject\ZhuoSVM\Experiment';
ExpName0='Exp12_FixStep_Iter1000';
DataRoot0='E:\MyProject\ZhuoSVM\ZhuoSVMData';
ZscoreList=[1,0];
ZscoreNameList={'Zscore','NoZscore'};

UseSLICSARList=[1];
UseSLICARSNameList={'OnSLIC'};
UseGradOrLapList={'Grad'};%,'Lap'};
SegNameList={'Seg1','Seg2','Seg3'};
SegNum=3;
SARName='SAR'; % 'SAR' for spatial-anatomical regularization or  "SR" for spatial regularization
Source='CAT12VBM';
RegularFolder=[];
SegPathList=cell(SegNum,1);
SegPathList{1}=fullfile(DataRoot0,'GuidedSLIC','ROISeg.nii.gz'); % seg0 is the anatomical structure
SegPathList{2}=fullfile(DataRoot0,'GuidedSLIC',Source,'Seg_5.nii.gz');
SegPathList{3}=fullfile(DataRoot0,'GuidedSLIC',Source,'Seg_10.nii.gz');
q=2;
MaskPath=fullfile(DataRoot0,'VoxelWiseFeature','Mask.nii.gz');
Nii=load_nii(MaskPath);
Mask=double(Nii.img);

%% set the option
Option0.MaxIter=1000;
Option0.StepSize=0.001;
Option0.FistaOrIsta=1;
Option0.SVMNorm=2;
Option0.ComputeCost=0;
Option0.W_ChangeNormLimit=1e-10;
Option0.W_ChangeRatioLimit=1e-10;
% GroupNum   =length(GroupIndListArray);
% GroupWeightList=reshape(GroupWeight,[1,GroupNum]);
Option0.StepIncreaseRatio=5;
Option0.StepDecreaseRatio=0.2;
Option0.MaxLineSearchStep=20;
Option0.MinIter=10;
Option0.CostConvRatio=0.001;
Option0.Print=0;
Option0.q=2;
Option0.StepType='Fix';
Option0.SparseType='GroupLasso';
Option0.Dividing=[];
CVNum=5; FixRandSeed=1;

StructOption0=[];
StructOption0.NewMeasureWeightList=[1,0,0,0,0,0,0,0]; % this is used to combine the precomputed measurement into a more complex measurement
StructOption0.ToUsedIndexList=[2,3];

%% for the lambdas for grid search
Lambda1=[0];
Lambda2=[0.001,0.01,0.1,0.5,1,2,5,10];
Lambda3=[0.0001,0.001,0.01,0.1,0.5,1,2,5,10];
ValueArray=cell(3,1);  ValueArray{1}=Lambda1;ValueArray{2}=Lambda2;ValueArray{3}=Lambda3;
[ LambdaArray ] = Mat2RowCell(ParameterArrayGenerator( ValueArray ));

%% the lambda for interpolation
Lambda1=[0];
Lambda2=[0.001:0.001:0.009,0.01:0.01:0.19,0.2:0.1:1,2:10];
Lambda3=[0.0001:0.0001:0.0009,0.001:0.001:0.009,0.01:0.01:0.19,0.2:0.1:1,2:10];
ValueArray=cell(3,1);  ValueArray{1}=Lambda1;ValueArray{2}=Lambda2;ValueArray{3}=Lambda3;
[ TestParaArray ] = Mat2RowCell(ParameterArrayGenerator( ValueArray ));



%% load the data
ADTrainPath=fullfile(DataRoot0,'VoxelWiseFeature',Source,'ADTrain_N3_Scaled.mat');  ADTrain=importdata(ADTrainPath);
CNTrainPath=fullfile(DataRoot0,'VoxelWiseFeature',Source,'CNTrain_N3_Scaled.mat');  CNTrain=importdata(CNTrainPath);
ADTestPath =fullfile(DataRoot0,'VoxelWiseFeature',Source,'ADTest_N3_Scaled.mat');   ADTest =importdata(ADTestPath);
CNTestPath =fullfile(DataRoot0,'VoxelWiseFeature',Source,'CNTest_N3_Scaled.mat');   CNTest =importdata(CNTestPath);
Xtrain=[ADTrain;CNTrain]; Xtrain=[Xtrain,ones(size(Xtrain,1),1)];  Ytrain=[ones(size(ADTrain,1),1);-1*ones(size(CNTrain,1),1)];
Xtest =[ADTest ;CNTest];  Xtest =[Xtest ,ones(size(Xtest ,1),1)];  Ytest =[ones(size(ADTest,1) ,1);-1*ones(size(CNTest ,1),1)];
Option0.Dividing=CreateRandNfoldDividing(length(Ytrain),CVNum,FixRandSeed );
%% for the experiment
for G1=1:length(ZscoreList)
    Zscore=ZscoreList(G1);
    ZscoreName=ZscoreNameList{G1};
    Option=Option0;
    %% set the zscore in the option
    if Zscore==1
        % set the option to enable zscore for both CV train and test
        Option.CVZscore=1;
        Option.TrainTestZscore=1;
    else
        % set the option to disable zscore for both CV tain and test
        Option.CVZscore=0;
        Option.TrainTestZscore=0;
    end
    for G2=1:length(UseGradOrLapList)
        UseGradOrLap=UseGradOrLapList{G2};
        LLName    =[UseGradOrLap,'_LL.mat'];
        NormLLName=[UseGradOrLap,'_Norm_LL.mat'];
        for G3=1:length(UseSLICSARList)
            UseSLICSAR=UseSLICSARList(G3);
            UseSLICARSName=UseSLICARSNameList{G3};
            L_LL=[];
            for G4=1:length(SegNameList)
                SegName=SegNameList{G4};
                %% load the LL and Norm_LL into memory
                if UseSLICSAR==0
                    LLPath    =fullfile(DataRoot0,'Regularizer',SARName,LLName);
                    NormLLPath=fullfile(DataRoot0,'Regularizer',SARName,NormLLName);
                    LL=importdata(LLPath);
                    L_LL=importdata(NormLLPath);
                else
                    LLPath    =fullfile(DataRoot0,'SLIC_SAR',SegName,LLName);
                    NormLLPath=fullfile(DataRoot0,'SLIC_SAR',SegName,NormLLName);
                    LL=importdata(LLPath);
                    L_LL=importdata(NormLLPath);
                end
                
                %% load the segmentation
                SegImPath=SegPathList{G4};
                Nii=load_nii(SegImPath);
                SegIm=Nii.img;
                %% get the group information
                ROI=[];
                [ GroupLassoOpt] = Mask_SegToGroupInf( Mask,SegIm,ROI,q );
                GroupIndexList=GroupLassoOpt.GroupLabel;
                %% update the Option
                Option.L_LL=L_LL;
                Option.GroupIndListArray=GroupLassoOpt.GroupIndPosListArray;
                Option.GroupWeightList=GroupLassoOpt.GroupWeight;
                %% get the output folder
                OutFolder1=fullfile(OutRoot0,ExpName0,[Source,'_',ZscoreName,'_',UseGradOrLap,'_',SARName,UseSLICARSName,'_',SegName]);
                if ~exist(OutFolder1)
                    mkdir(OutFolder1);
                end
             
                %% do the computation
                W0=zeros(size(Xtrain,2),1);
                StructOption=StructOption0;
                StructOption.ExpName=fullfile(ExpName0,[Source,'_',ZscoreName,'_',SARName,UseSLICARSName,'_',SegName]);
                DoExperiment20170416( Xtrain,Xtest,Ytrain,Ytest,OutFolder1,LambdaArray,TestParaArray,W0,LL,Option,StructOption );
            end
        end
    end
end
