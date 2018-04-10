%   this script is used to extract the results and make plot of accuracy
%   and structure sparsity  with different parameters


PC_specifyRoot='E:\MyProject\ZhuoSVM';
% for home PC, it is E:\MyProject\ZhuoSVM
% for Gisela01, it is  /srv/lkeb-ig/NIP/zsun/ZhuoSVM_New/
% for Yuchuan PC, it is 'F:\Zhuo\Project\ZhuoSVM';
CodeRoot='E:\MyProject\ZhuoSVM\ZhuoSVMTools';
addpath(genpath(CodeRoot));

%%
Root0='E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp12\CNvsAD\Fix\Seg_3\OnTestSet';
Lambda1=[0];
Lambda2=[0.001,0.01,0.2,0.5,1,2,5,10];
Lambda3=[0.001,0.01,0.2,0.5,1,2,5,10];
ParaArray2=cell(3,1);
ParaArray2{1}=Lambda1;
ParaArray2{2}=Lambda2;
ParaArray2{3}=Lambda3;
Size2=[length(ParaArray2{1}),length(ParaArray2{2}),length(ParaArray2{3})];

%% for the segmentation
MaskPath='E:\MyProject\ZhuoSVM\ZhuoSVMData\GuidedSLIC\Mask.nii.gz';
Nii=load_nii(MaskPath); Mask=squeeze(Nii.img);
SegPath='E:\MyProject\ZhuoSVM\ZhuoSVMData\GuidedSLIC\CAT12VBM\Seg_10.nii.gz';
Nii=load_nii(SegPath); SegIm=squeeze(Nii.img);

ROI=[];q=2;
[ GroupLassoOpt] = Mask_SegToGroupInf( Mask,SegIm,ROI,q );
GroupIndPosListArray=GroupLassoOpt.GroupIndPosListArray;



AccMat           =zeros(Size2);
for i1=1:length(ParaArray2{1})
    for i2=1:length(ParaArray2{2})
        for i3=1:length(ParaArray2{3})
            ParaName=fullfile(['L1_',num2str(ParaArray2{1}(i1))],['L2_',num2str(ParaArray2{2}(i2))],['L3_',num2str(ParaArray2{3}(i3))]);
            Root1=fullfile(Root0,ParaName);
            Path1=fullfile(Root1,'TestSet_Result.mat');
            Path2=fullfile(Root1,'Model.mat');
            AA=importdata(Path1);
            Acc=AA.accuracy;
            AccMat(i1,i2,i3)=Acc;
            W=importdata(Path2);
            W=W(1:end-1);
          %%
        end
    end
end


%% for the structure sparsity 
StructSparsityMat=zeros(Size2);
ModelPathMat=cell(Size2);
for i1=1:length(ParaArray2{1})
    for i2=1:length(ParaArray2{2})
        for i3=1:length(ParaArray2{3})
            ParaName=fullfile(['L1_',num2str(ParaArray2{1}(i1))],['L2_',num2str(ParaArray2{2}(i2))],['L3_',num2str(ParaArray2{3}(i3))]);
            Root1=fullfile(Root0,ParaName);
            Path1=fullfile(Root1,'TestSet_Result.mat');
            Path2=fullfile(Root1,'Model.mat');
            ModelPathMat{i1,i2,i3}=Path2;
        end
    end
end

N1=prod(Size2);
LL=zeros(N1,1);
parfor i=1:N1
   Path=ModelPathMat{i};
   W=importdata(Path);
   W=W(1:end-1);
   [SelectStructNum]=SelectedStructNum(W,GroupIndPosListArray);
   LL(i)=SelectStructNum;
end
StructSparsityMat=reshape(LL,Size2);      
            
            
            
function [SelectStructNum]=SelectedStructNum(W,GroupIndPosListArray)
NonZeroList=zeros(length(GroupIndPosListArray),1);
for i=1:length(GroupIndPosListArray)
    A1=W(GroupIndPosListArray{i});
    A2=sum(A1.^2);
    NonZeroList(i)=A2>0;
end
SelectStructNum=sum(NonZeroList);

end
