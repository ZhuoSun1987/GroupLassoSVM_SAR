%   this script is used to compute the Pearson correlation coefficient of
%   different task on the SPM gray matter 
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
ResultFolder0='/home/zsun/ZhuoSVMTools/PearsonCorrCoef/PearsonCCMap_GM';
mkdir(ResultFolder0);

%%
DataRoot='/srv/lkeb-ig/NIP/zsun/VBM_GSVM_SZ';
GroupNameList={'ADTrain_N3_Scaled','CNTrain_N3_Scaled','MCICTrain_N3_Scaled','MCINCTrain_N3_Scaled'};
SubPattern='mwc1adni_*_S_*_I*.nii';



%% load all the fields into memory
GroupArrayArray=cell(length(GroupNameList),1);
SubNumList=zeros(length(GroupNameList),1);
for G=1:length(GroupNameList)
    GroupName=GroupNameList{G};
    GroupFolder=[DataRoot,separation,GroupName];
    Dir=dir([GroupFolder,separation,SubPattern]);
    SubNum=length(Dir);
    disp([GroupName,'  Subject Number=',num2str(SubNum)]);
    FieldArray=cell(SubNum,1);
    parfor i=1:SubNum
        SubName=Dir(i).name;
        FeatureFieldPath=[GroupFolder,separation,SubName];
        Nii=load_nii(FeatureFieldPath);
        FeatureField=Nii.img;
        FieldArray{i}=FeatureField;
    end
    GroupArrayArray{G}=FieldArray;
    SubNumList(G)=SubNum;
end



%% AD Vs CN
FieldArray=[ GroupArrayArray{1}; GroupArrayArray{2}];
YList=[ones(SubNumList(1),1); -1*ones(SubNumList(2),1)];
[ FieldArray ] = ZscoreFieldArray( FieldArray );
[ R ] = FieldPearsonCorrCoef( FieldArray,YList );
Nii=make_nii(R,[]);
SavePath=[ResultFolder0,separation,'AD_CN.nii']
save_nii(Nii,SavePath)


%% CN vs MCIc
FieldArray=[ GroupArrayArray{2}; GroupArrayArray{3}];
YList=[ones(SubNumList(2),1); -1*ones(SubNumList(3),1)];
[ FieldArray ] = ZscoreFieldArray( FieldArray );
[ R ] = FieldPearsonCorrCoef( FieldArray,YList );
Nii=make_nii(R,[]);
SavePath=[ResultFolder0,separation,'MCIc_CN.nii']
save_nii(Nii,SavePath)

%% MCIC vs MCInc
FieldArray=[ GroupArrayArray{3}; GroupArrayArray{4}];
YList=[ones(SubNumList(3),1); -1*ones(SubNumList(4),1)];
[ FieldArray ] = ZscoreFieldArray( FieldArray );
[ R ] = FieldPearsonCorrCoef( FieldArray,YList );
Nii=make_nii(R,[]);
SavePath=[ResultFolder0,separation,'MCIc_MCInc.nii']
save_nii(Nii,SavePath)