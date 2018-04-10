function [ ] = FindDatasetInformationADNI( Table,ImageIDList,ImageIDPos,CenterPos,GenderPos,AgePos,ScorePos)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to generate the report for the datast informaiton
%   as report in Cuingnet's NeuroImage paper.
%
%   Table is from the ADNI downloaded data summary csv table and then load
%   into matlab memory and remove the title part
%   ImageIDList, is an cell array, each cell is a string that contains the image ID, 
%   in some case, if each row is for one subject, then this cell array can
%   contains subID.
%   CenterPos, GenderPos,AgePos, ScorePos, are column index of the related
%   inforamtion
%
%   z.sun 20170920


[N,M]=size(Table);
S=length(ImageIDList);
%% step 1, extract the useful rows from the table
AllIDs=Table(:,ImageIDPos);
if isnumeric( AllIDs{1})
    %% convert it to str
    for i=1:S
       AllIDs{i}=num2str(AllIDs{i});
    end  
end
if isnumeric(ImageIDList{1})
    % convert it to str
    ImageIDList{i}=num2str(ImageIDList{i});
end

FindIndex=zeros(S,1);
for i=1:S
    Index=find(AllIDs,ImageIDList{i});
    if isempty(Index)
        disp(['Find no matching rows for ID ',ImageIDList{i}])
    else
        FindIndex{i}=Index;
    end
end

%%  for Age
if ~isempty(AgePos) & AgePos~=0
    AllAges=Table(:,AgePos );
    if isstr(AllAges{1})
        AllAges=cellfun(@str2num,AllAges);
    end
    SelectAges=AllAges(FindIndex);
    Mean=nanmean(SelectAges); Std=nanstd(SelectAges); Min=nanmin(SelectAges); Max=nanmax(SelectAges);
    ReportStr=['Age Mean£º ',num2str(Mean),'  Std:',num2str(Std), '  [',num2str(Min),',',num2str(Max),']'];
    disp(ReportStr);
end
%%  for Center
if ~isempty(CenterPos) & CenterPos~=0
    AllCenters=Table(:,CenterPos );
    if isnumeric(AllCenters{1})
         AllCenters=arrayfun(@num2str,AllCenters,'UniformOutput',false)
    end
    SelectCenters=AllCenters(FindIndex);
    CenterNum=length(unique(SelectCenters))
    ReportStr=['Ceneter number£º ',num2str(CenterNum)];
    disp(ReportStr);
end
%% for gender
if ~isempty(GenderPos) & GenderPos~=0
    AllGenders=Table(:,GenderPos );
    SelectGenders=AllGenders(FindIndex);
    GenderNum=length(unique(SelectGenders));
    UniqueGender=unique(SelectGenders);
    ReportStr=['Ceneter number£º '];
    disp(ReportStr);
    for i=1:GenderNum
        GG=UniqueGender{i};
        NN=length(find(strcmp(SelectGenders,GG)))
        ReportStr=['   ',GG,':  ',num2str(NN)];
        disp(ReportStr);
    end
end
        
    
%% for score 
AllGenders=Table(:,GenderPos);
AllScoreArray=cell(length(ScorePos),1);
for i=1:length(ScorePos)
    AllScore=Table(:,ScorePos(i));
    SelectScore=AllScore(FindIndex);
    if isstr(SelectScore(1))
        SelectScore=cellfun(@str2num,SelectScore);
    end
    Mean=nanmean(SelectScore); Std=nanstd(SelectScore); Min=nanmin(SelectScore); Max=nanmax(SelectScore);
    ReportStr=['Score ',num2str(i),' Mean£º ',num2str(Mean),'  Std:',num2str(Std), '  [',num2str(Min),',',num2str(Max),']'];
    disp(ReportStr);
end




end

