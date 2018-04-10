%   this script is used to make the selected mask and segmentation on the
%   MINC template itself segmentaiton.
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
SegPath='/srv/lkeb-ig/NIP/zsun/MNI152SPMSVM/OnTemplateItself/Sub/V00/lob_Nii/nl_clean_lob_Sub_V00.nii.gz';


ROIs=[];
RemoveROIs=[9,3,255,8,4,2,6]; % 9 and 3 are ventricle, 255 are outer tissue around brain

ResultFolder='/home/zsun/ZhuoSVMTools/ExtractFeatures/MINC_Template';
mkdir(ResultFolder);

%%
Nii=load_nii(SegPath);
Segmentation=double(squeeze(Nii.img));
[ Mask, ROISeg ] = GenerateMaskRemoveRegion( Segmentation,ROIs,RemoveROIs );
Nii=make_nii(Mask,[]);
save_nii(Nii,[ResultFolder,separation,'Mask.nii.gz'])
Nii=make_nii(ROISeg,[]);
save_nii(Nii,[ResultFolder,separation,'ROISeg.nii.gz']);

