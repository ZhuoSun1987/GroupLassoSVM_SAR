function [ ] = DoingPlotParameterInfluence( PlotFolder,ResultMatrixStruct, AxisValues,FormatList)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
%   this function is used to plot figures to reflect the influence of
%   parameter on various type of evalution on the test and on the models
%   ResultMatrixStruct, AxisValues are from function[ Result,AxisValues] = ParaGridSearchTrainTest(...)
%

%% doing the plot


% for the model
A1=ResultMatrixStruct.Model;
FieldNameList=fieldnames(A1);
ModelPlotFolder=fullfile(PlotFolder,'Model');
MakeFolder(ModelPlotFolder);
for FF=1:length(FieldNameList)
    FieldName=FieldNameList{FF};
    PathList=SaveNameDiffFormatPathList(ModelPlotFolder,FieldName,FormatList );
    Mat=getfield(A1,FieldName);
    PlotParaInflenceFigure( Mat,AxisValues,PathList );
end

%% for the test eval
A1=ResultMatrixStruct.Test;
TestNameList1=fieldnames(A1);
TestPlotFolder=fullfile(PlotFolder,'Test');
for TT=1:length(TestNameList1)
    TestName=TestNameList1{TT};
    ThisTestPlotFolder=fullfile(TestPlotFolder,TestName);
    MakeFolder(ThisTestPlotFolder);
    A2=getfield(A1,TestName);
    EvalNameList1=fieldnames(A2);
    for EE=1:length(EvalNameList1)
        EvalName=EvalNameList1{EE};
        PathList=SaveNameDiffFormatPathList(ThisTestPlotFolder,EvalName,FormatList );
        Mat=getfield(A2,EvalName);
        PlotParaInflenceFigure( Mat,AxisValues,PathList );
    end
end

end

