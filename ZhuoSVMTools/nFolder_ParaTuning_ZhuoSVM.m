function [ ReportStruct ] = nFolder_ParaTuning_ZhuoSVM(X,Y,W0,Dividing,FolderRoot,LambdaArray,LL,Option)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%   this funciton is used to compute the result using different parameter
%   and make a report
%   Lambda(1) the weight of max margin,  Lambda(2) the weight of SAR,
%   lambda(3) the weight of sparsity
%
%   LambdaArray is a cell array, and each cell is a parameter combination
%
%   FolderRoot is the root folder for the classification result



PD=length(LambdaArray{1});
N =length(LambdaArray);


AccList=zeros(N,1);
AUCList=zeros(N,1);
SenList=zeros(N,1);
SpeList=zeros(N,1);
recallList=zeros(N,1);
gmeanList=zeros(N,1);
fList=zeros(N,1);
FolderList=cell(N,1);
precisionList=zeros(N,1);

if ~exist(FolderRoot,'dir')
    mkdir(FolderRoot);
end

ReportPath=fullfile(FolderRoot,'ReportStruct.mat');
t1=clock;
% compute the result from different parameters
if ~exist(ReportPath,'file')
    parfor i=1:N
        LambdaList=LambdaArray{i};
        % generate folder name
        FolderName=[];
        for j=1:PD
            FolderName=fullfile(FolderName,['L',num2str(j),'_',num2str(LambdaList(j))]);
        end
        FolderList{i}=FolderName;
        

        % computing
        ResultFolder=fullfile(FolderRoot,FolderName);
        MakeFolder( ResultFolder );
        [ Result ] = nFoldCrossValidata_ZhuoSVM_TrainingSet( X,Y,W0,Dividing,LambdaList,LL,ResultFolder,FolderName,Option);
        %
        AccList(i)=Result.accuracy;
        AUCList(i)=Result.AUC;
        SenList(i)=Result.sensitivity;
        SpeList(i)=Result.specificity;
        recallList(i)=Result.recall;
        gmeanList(i)=Result.gmean;
        precisionList(i)=Result.precision;
        fList(i)=Result.f_measure;
    end

    ReportStruct=[];
    ReportStruct.AccList=AccList;
    ReportStruct.AUCList=AUCList;
    ReportStruct.SenList=SenList;
    ReportStruct.SpeList=SpeList;
    ReportStruct.precisionList=precisionList;
    ReportStruct.recallList=recallList;
    ReportStruct.gmeanList=gmeanList;
    ReportStruct.fList=fList;
    ReportStruct.FolderList=FolderList;
    ReportStruct.LambdaArray=LambdaArray;
end
t2=clock;
disp(['Start from ',datestr(t1),' to ',datestr(t2),' time cost ',num2str(etime(t2,t1)),' seconds'])


end

