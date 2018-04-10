% this script is used to extract feature matrix in the given subject groups
% and the user defined mask.
%
%   Currently, it is for the MINC gm map and the MINC segmentation on the
%   template image.
%
%   Zhuo Sun  20160619


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
DataRoot='/srv/lkeb-ig/NIP/zsun/MNI152SPMSVM';
GroupNameList={'ADTest_N3_Scaled','ADTrain_N3_Scaled','CNTest_N3_Scaled','CNTrain_N3_Scaled',......
    'MCICTest_N3_Scaled','MCICTrain_N3_Scaled','MCINCTest_N3_Scaled','MCINCTrain_N3_Scaled'};
ResultFolder='/home/zsun/ZhuoSVMTools/ExtractFeatures/MINC_Template/tal_clean_gm';
mkdir(ResultFolder);
MaskPath='/home/zsun/ZhuoSVMTools/ExtractFeatures/MINC_Template/Mask.nii.gz';
Nii=load_nii(MaskPath);
Mask=Nii.img;
SubPattern='adni_*_S_*_I*';
VoxelNum=sum(Mask(:)==1);
SubFileExtend='smooth/tal_clean_gm_V0_0000.nii.gz';


%%
GroupNum=length(GroupNameList);
for G=1:GroupNum
    GroupName=GroupNameList{G};
    disp(GroupName)
    GroupFolder=[DataRoot,separation,GroupName];
    Dir=dir([GroupFolder,separation,SubPattern]);
    SubNum=length(Dir);
    FeatureMatrix=zeros(SubNum,VoxelNum);
    for i=1:SubNum
        SubName=Dir(i).name;
        SubFolder=[GroupFolder,separation,SubName];
        FeatureFieldPath=[SubFolder,separation,SubFileExtend];
        Nii=load_nii(FeatureFieldPath);
        FeatureField=Nii.img;
        [ FeatVec ] = ExtractFeatVecFromVolume( FeatureField,Mask );
        FeatureMatrix(i,:)=FeatVec;
    end
    SavePath=[ResultFolder,separation,GroupName,'.mat'];
    save(SavePath,'FeatureMatrix')
end
    
    
    
    


