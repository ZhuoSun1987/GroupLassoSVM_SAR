%   this script is used to make the selected mask and segmentation on the
%   SPM template itself segmentaiton.
%
%   Zhuo Sun  20160620


%%
CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end
s=matlabpool('size');
if s==0
    matlabpool open 8
end



%%
SegPath='/home/zsun/ZhuoSVMTools/TemplateSeg/ResultSPMSpace_Seg.nii';


ROIs=[];
RemoveROIs=[255]; % 9 and 3 are ventricle, 255 are outer tissue around brain

ResultFolder0='/home/zsun/ZhuoSVMTools/ExtractFeatures/SPM_Template';
mkdir(ResultFolder0);

%%
Nii=load_nii(SegPath);
Segmentation=double(squeeze(Nii.img));
[ Mask, ROISeg ] = GenerateMaskRemoveRegion( Segmentation,ROIs,RemoveROIs );
Nii=make_nii(Mask,[]);
save_nii(Nii,[ResultFolder0,separation,'Mask.nii.gz'])
Nii=make_nii(ROISeg,[]);
save_nii(Nii,[ResultFolder0,separation,'ROISeg.nii.gz']);


%%
DataRoot='/srv/lkeb-ig/NIP/zsun/VBM_GSVM_SZ';
GroupNameList={'ADTest_N3_Scaled','ADTrain_N3_Scaled','CNTest_N3_Scaled','CNTrain_N3_Scaled',......
    'MCICTest_N3_Scaled','MCICTrain_N3_Scaled','MCINCTest_N3_Scaled','MCINCTrain_N3_Scaled'};
ResultFolder='/home/zsun/ZhuoSVMTools/ExtractFeatures/SPM_Template/mwc1';
mkdir(ResultFolder);
MaskPath=[ResultFolder0,separation,'Mask.nii.gz'];
Nii=load_nii(MaskPath);
Mask=Nii.img;
SubPattern='mwc1adni_*_S_*_I*.nii';
VoxelNum=sum(Mask(:)==1);



%%
GroupNum=length(GroupNameList);
for G=1:GroupNum
    GroupName=GroupNameList{G};
    
    GroupFolder=[DataRoot,separation,GroupName];
    Dir=dir([GroupFolder,separation,SubPattern]);
    SubNum=length(Dir);
    disp([GroupName,'  Subject Number=',num2str(SubNum)]);
    FeatureMatrix=zeros(SubNum,VoxelNum);
    for i=1:SubNum
        SubName=Dir(i).name;
        FeatureFieldPath=[GroupFolder,separation,SubName];
        Nii=load_nii(FeatureFieldPath);
        FeatureField=Nii.img;
        [ FeatVec ] = ExtractFeatVecFromVolume( FeatureField,Mask );
        FeatureMatrix(i,:)=FeatVec;
    end
    SavePath=[ResultFolder,separation,GroupName,'.mat'];
    save(SavePath,'FeatureMatrix')
end

