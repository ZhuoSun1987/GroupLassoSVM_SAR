%   this script is used to copy useful result into a separate folder
%
%   Zhuo Sun 2016-10-11

CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end

%%
ResultRoot='/srv/lkeb-ig/NIP/zsun/ZhuoSVMTool/SpatialAnatoimcalApproxGroupLassoSVM/AD_CN_mwc1';
Pattern1='Exp*';
Pattern2='Seg*'
MatchPatList={'*.mat','*.jpg','*.fig','*.eps','*.nii','*.nii.gz'};
OutRoot0='/srv/lkeb-ig/NIP/zsun/ZhuoSVMTool/SpatialAnatoimcalApproxGroupLassoSVM/OnlySummary'
mkdir(OutRoot0)
Dir1=dir(fullfile(ResultRoot,Pattern1));


%%
for i=1:length(Dir1)
    Name1=Dir1(i).name;
    Folder1=fullfile(ResultRoot,Name1);
    [ PathList ] = FindFilesInFolder( Folder1,MatchPatList );
    if ~isempty(PathList)
        OutFolder=[OutRoot0,separation,Name1];
        mkdir(OutFolder);
        CopyFileListToFolder( OutFolder,PathList );
    else
        Dir2=dir([Folder1,separation,Pattern2]);
        for j=1:length(Dir2)
            Name2=Dir2(j).name;
            Folder2=fullfile(Folder1,Name2);
            [ PathList ] = FindFilesInFolder( Folder2,MatchPatList );
            if ~isempty(PathList)
                OutFolder=[OutRoot0,separation,Name1,separation,Name2];
                mkdir(OutFolder);
                CopyFileListToFolder( OutFolder,PathList );   
            end
        end
    end
end