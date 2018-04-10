function [ OptimalParaArray] = ReportFromParaTuning( ReportPath,SumWeights,ReportTxtPath )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%

ReportStruct=importdata(ReportPath);
FolderList=ReportStruct.FolderList;
Save=0;
if nargin>2 & ~isempty(ReportTxtPath)
    Save=1;
    fid=fopen(ReportTxtPath,'w');
end

FieldNameList={'AccList','AUCList','SenList','SpeList','precisionList','recallList','gmeanList','fList'}
NameList={'Accuracy','AUC','Sensitivity','Specificity','percision','Recall','gmean','f_measure'}
% for each measurements
for i=1:length(FieldNameList)
    List=getfield(ReportStruct,FieldNameList{i});
    Max=max(List);
    Pos=find(List==Max);
    disp('===================')
    str=['Best ',NameList{i},' = ',num2str(Max)];
    disp(str);
    if Save==1
        fprintf(fid,'%s','===================')
        fprintf(fid,'\n');
        fprintf(fid,'%s',str);
        fprintf(fid,'\n');
    end
    for i=1:length(Pos)
        str=['  ',FolderList{Pos(i)}];
        disp(str);
        fprintf(fid,'%s',str);
        fprintf(fid,'\n');
    end
    disp('  ');
    disp('  ');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
end


ExpNum=length(FolderList);
Mat=zeros(ExpNum,length(FieldNameList));
for i=1:length(FieldNameList)
    List=getfield(ReportStruct,FieldNameList{i});
    Mat(:,i)=List;
end
NewMeasure=Mat*reshape(SumWeights,length(SumWeights),1);
MaxNewMeasure=max(NewMeasure);
Pos=find(NewMeasure==MaxNewMeasure);
OptimalParaArray=cell(length(Pos),1);
str=['The optimal new measurement result is ',num2str(MaxNewMeasure)]
disp(str)
if Save==1
    fprintf(fid,'%s',str);
    fprintf(fid,'\n');
end
for i=1:length(Pos)
    OptimalParaArray{i}=ReportStruct.LambdaArray{Pos(i)};
    str=['  ',FolderList{Pos(i)}];
    disp(str);
    if Save==1
        fprintf(fid,'%s',str);
        fprintf(fid,'\n');
    end
end

if Save==1
    fclose(fid);
end



end

