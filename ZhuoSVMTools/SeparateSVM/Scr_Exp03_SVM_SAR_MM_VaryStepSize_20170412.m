%   this script is used to compute ZhuoSVM, with Double direction line
%   search, the CAT12VBM for voxelwise feature
%
%   for group lasso based method, with SR
%
%   the varying part:  1) Whether to use Zscore,  2) use Grad Or Laplacian
%   3) use SAR generated from the brain structure or the Supervoxel


OutRoot0='F:\Zhuo\Project\ZhuoSVM\Experiment';
ExpName0='Exp03_VaryStep';
DataRoot0='F:\Zhuo\Project\ZhuoSVM\ZhuoSVMData';
ZscoreList=[1,0];
UseSLICSARList=[1,0];
UseSLICARSNameList={'OneSLIC','OneLA'};
UseGradOrLapList={'Grad','Lap'}
SegNameList={'Seg1','Seg2','Seg3'};
ZscoreNameList={'Zscore','NoZscore'};
SegNum=3;
SARName='SAR'; % 'SAR' for spatial-anatomical regularization or  "SR" for spatial regularization
Source='CAT12VBM';
RegularFolder=[];
SegPathList=cell(SegNum,1);
SegPathList{1}=fullfile(DataRoot0,'GuidedSLIC','ROISeg.nii.gz'); % seg0 is the anatomical structure
SegPathList{2}=fullfile(DataRoot0,'GuidedSLIC',Source,'Seg_5.nii.gz');
SegPathList{3}=fullfile(DataRoot0,'GuidedSLIC',Source,'Seg_10.nii.gz');

UseGradOrLap='Grad';
LLName    =[UseGradOrLap,'_LL.mat'];
NormLLName=[UseGradOrLap,'_Norm_LL.mat'];
LLPath    =fullfile(DataRoot0,'Regularizer',SARName,LLName);
NormLLPath=fullfile(DataRoot0,'Regularizer',SARName,NormLLName);
LL=importdata(LLPath);
L_LL=importdata(NormLLPath);

%% for the experiment
for G1=1:length(ZscoreList)
    Zscore=ZscoreList(G1);
    ZscoreName=ZscoreNameList{G1};
    %% set the zscore in the option
    if Zscore==1
        % set the option to enable zscore for both CV train and test
    else
        % set the option to disable zscore for both CV tain and test
    end
    OutFolder1=fullfile(OutRoot0,ExpName0,[Source,'_',ZscoreName]);
end
