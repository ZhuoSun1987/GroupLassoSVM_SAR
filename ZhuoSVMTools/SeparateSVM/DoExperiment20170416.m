function [  ] = DoExperiment20170416( Xtrain,Xtest,Ytrain,Ytest,OutRoot0,ParaArray,TestParaArray,W0,LL,Option,StructOption )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function do several things, 
%   First, it will do do CV on the training set, for the given parameters,
%   result is saved in ../GridSearchHyperParaTraining
%   Second, based on the result of first step, find the optimal parameter
%   among the given parameters.
%   Third, based on the result of step 2, do the training on the whole
%   training set, and then test on the test set, result is saved in ./OnTestSet
%   Fourth, based on the result of step 1, do the interpolation on
%   parameter, and find the optimal hyperparameter in the interplated
%   space,by function  [ BestValue,PredValues,OptParameters ] = HyperParameterInterp( Values, ParaArray,ToTestArray,HighOrLow,ToUsedIndexList )
%   Fifth, similar to step 3, do the computation in the interpolated
%   hyperparameter space.
%   
%   z.sun 20170416

TuningResultName='GridSearchResult.mat';
GridSearchReportName='GridSearchReport.mat';
ReportOnTestName='ResultOnTest.mat';
TestResultName='TestResult.mat';
ParaInterpTestReportName='ResultOnTest_InterpPara.mat';
IntepParaListName='InterpParaList.mat'

NewMeasureWeightList=StructOption.NewMeasureWeightList;
ExpName             =StructOption.ExpName;
ToUsedIndexList     =StructOption.ToUsedIndexList;
Dividing            =Option.Dividing;

%% Step 1
Folder1=fullfile(OutRoot0,'GridSearchHyperParaTraining');
MakeFolder(Folder1);
CVTuningResultPath=fullfile(OutRoot0,TuningResultName);
if ~exist(CVTuningResultPath,'file')
    %% do the CV tuning on training set
    [ ResultStep1 ] = nFolder_ParaTuning_ZhuoSVM(Xtrain,Ytrain,W0,Dividing,Folder1,ParaArray,LL,Option);
    parsave(CVTuningResultPath,ResultStep1)
else
    Str=['Already Grid Search Hyper-Paremeter ',ExpName];
    disp(Str)
    ResultStep1=importdata(CVTuningResultPath);
end
%% Step 2  look for the optimal hyper parameter
ReportPath=fullfile(OutRoot0,GridSearchReportName);
if ~exist(ReportPath,'file')
    %% generate the report for the grid search result,
    ReportTxtPath=fullfile(OutRoot0,'DetailReport.txt');
    [ OptimalParaList] = ReportFromParaTuning( CVTuningResultPath,NewMeasureWeightList,ReportTxtPath );
    parsave(ReportPath,OptimalParaList);
else
    Str=['Already Hyper-Paremeter Report ',ExpName];
    disp(Str)
    OptimalParaList=importdata(ReportPath);
end

%% Step 3  train the model using the whole training set and then evalutate the performance on test set
ReportOnTestPath=fullfile(OutRoot0,ReportOnTestName);
if ~exist(ReportOnTestPath,'file')
    OutRoot1=fullfile(OutRoot0,'OnTestSet');
    MakeFolder(OutRoot1);
    [ResultList ] = TrainTestEvaluateZhuoSVM_ParaArray(Xtrain,Xtest,Ytrain,Ytest,W0,LL,OutRoot1,OptimalParaList,Option );
    parsave(ReportOnTestPath,ResultList);
    copyfile(fullfile(OutRoot1,'Reporting.txt'),fullfile(OutRoot1,'OnRealTestGrid.txt'));
    delete(fullfile(OutRoot1,'Reporting.txt'));
    
else
    Str=['Already work on Parameter Interpolation ',ExpName];
    disp(Str)
    FinalResult=importdata(ReportOnTestPath);
end

%% Step 4, Hyper-parameter interpolation
% % ReportOnInterpPara=fullfile(OutRoot0,IntepParaListName);
% % OptimalInterpParaList=[];
% % if ~exist(ReportOnInterpPara,'file')
% %     CVTuningResult=importdata(CVTuningResultPath);
% %     [Values ]=GetValuesFromResultStruct(CVTuningResult,StructOption.NewMeasureWeightList);
% %         
% %     HighOrLow=1;
% %     [ BestValue,PredValues,OptParameters ] = HyperParameterInterp( Values,ParaArray,TestParaArray,HighOrLow,ToUsedIndexList );
% %     OptimalInterpParaList=OptParameters;
% % else
% %     Str=['Already interpolate parameter ',ExpName];
% %     disp(Str)
% %     OptimalInterpParaList=importdata(ReportOnInterpPara);
% % end

%% Step 5, do the step 3 again, on the OptimalInterpParaList
% % ReportOnTestInterpParaPath=fullfile(OutRoot0,ParaInterpTestReportName);
% % if ~exist(ReportOnTestInterpParaPath,'file')
% %     OutRoot1=fullfile(OutRoot0,'OnTestSet');
% %     MakeFolder(OutRoot1);
% %     [ResultList ] = TrainTestEvaluateZhuoSVM_ParaArray(Xtrain,Xtest,Ytrain,Ytest,W0,LL,OutRoot1,OptimalInterpParaList,Option );
% %     parsave(ReportOnTestPath,Result1List);
% %     copyfile(fullfile(OutRoot1,'Reporting.txt'),fullfile(OutRoot1,'OnRealInterpGrid.txt'));
% %     delete(fullfile(OutRoot1,'Reporting.txt'));
% % else
% %     Str=['Already work on Testset in interped parameter ',ExpName];
% %     disp(Str);
% % end
end

