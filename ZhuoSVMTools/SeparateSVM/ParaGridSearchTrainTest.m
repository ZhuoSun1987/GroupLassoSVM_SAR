function [ Result,AxisValues] = ParaGridSearchTrainTest( TrainX,TrainY,TestXArray,TestYArray,TestNameList,ParaArray,W0,Option,OutRoot )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to
%
%
%   z.sun 20170926

EvaluationNameList={'Acc','AUC','SEN','SPE','Recall'};
ModelEvalNameList={'VoxelSparisty','StructSparisty','WSquareAmpSum','MeanWsquareAmp'};
ParaOrder=length(ParaArray{1});
ParaNum=length(ParaArray);
TestNum=length(TestXArray);
MakeFolder(OutRoot);

%% doing the zscore normalization on the TrainX and each TestX
if  Option.CVZscore==1
    [TrainX,mu,std]=zscore(TrainX);
    TrainX(:,end)=1;
    for i=1:TestNum
        TestX=TestXArray{i};
        TestX=(Xtest-repmat(mu,[size(TestX,1),1]))./repmat(std,[size(TestX,1),1]);
        TestX(:,std==0)=0;
        TestX(:,end)=1;
        TestXArray{i}=TestX;
    end
end


%% for each specified parameter (vector length is ParaOrder), train on the TrainX,TrainY
TempTestArray=cell(ParaNum,1);
TempModelArray=cell(ParaNum,1);
parfor i=1:ParaNum
    LambdaList=ParaArray{i};
    FolderName=[];
    PD=length(LambdaList);
    for j=1:PD
        FolderName=fullfile(FolderName,['L',num2str(j),'_',num2str(LambdaList(j))]);
    end
    Folder1=fullfile(OutRoot,FolderName);
    MakeFolder(Folder1);
    WPath=fullfile(Folder1,'W.mat');
    EvalPath=fullfile(Folder1,'Eval.mat');
    if ~ exist(EvalPath,'file')
        if ~exist(WPath,'file')
            %% train the model
            [ PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrain,AUCTest,ModifyAcc,W ] = TrainTestEvaluateZhuoSVM_SingleLambdaList...
                (TrainX,TrainX,TrainY,TrainY,W0,LL,Folder1,LambdaList,Option );
        else
            W=importdata(WPath);
        end
       %% evaluate on the model, the voxel sparsity, group sparsity, 
       ModelEvalVec=ModelEval(W,Option);
       TempModelArray{i}=ModelEvalVec;
       %% do the prediction on each Test
       TempArray1=cell(TestNum,1);
       for TT=1:TestNum
           TestX=TestXArray{TT}; TestY=TestYArray{TT};
           % do the prediction
           Thres=0;
           [ PredLabel,Scores,AUC,ModifyAcc,UserDefThresAcc ] = Predict_LinearSVM( W,TestX,TestY,Thres ); 
            ShowFig1=0;
            auc = roc_curve(PredScoreTest,Ytest,ShowFig1); % plot ROC curve
            [EVAL] = Evaluate(Ytest,PredLabelTest);
    % %         Result.accuracy   =EVAL(1);
    % %         Result.sensitivity=EVAL(2);
    % %         Result.specificity=EVAL(3);
    % %         Result.precision  =EVAL(4);
    % %         Result.recall     =EVAL(5);
    % %         Result.f_measure  =EVAL(6);
    % %         Result.gmean      =EVAL(7);
    % %         Result.PredLabelList=PredLabelTest;
    % %         Result.TrueLabelList=Ytest;
    % %         Result.DeciList     =PredScoreTest;
    % %         Result.AUC          =auc;      
           % evaluation  -> need to be implement or find how it works in
           % previous work

           EvaluateResultVec=[EVAL(1),auc,Eval(2),Eval(3),Eval(5)];
           % fill the evaluations into a table
           TempArray1{TT}=EvaluateResultVec;
           
           AllResult
       end
       AllResult=[];
       AllResult.ModelEval=ModelEvalVec;
       AllResult.TestEval =TempArray1;
       parsave(EvalPath,AllResult);
    else
        AllResult=importdata(EvalPath);
        TempModelArray{i}=AllResult.ModelEval;
        TempArray1=AllResult.TestEval;
    end
    TempTestArray{i}=TempArray1;
end

    
%% from the result List Array type result into Table like matrix.
ParaMat=cell2mat(ParaArray);
SeparateParaList=cell(ParaOrder,1);
MatSize=zeros(1,ParaOrder);
for i=1:ParaOrder
    ParaI=sort(unique(ParaMat(:,i)));
    MatSize(i)=length(ParaI);
    SeparateParaList{i}=ParaI;
end
%% generating  AxisValues
AxisValues=cell(ParaOrder,1);
for i=1:ParaOrder
    ParaI=SeparateParaList{i};
    A1=cell(length(ParaI),1);
    for j=1:length(ParaI)
        A1{j}=num2str(ParaI(j));
    end
    NameThis=['Para_',num2str(i)];
    AxisValues{i}=A1;
end

AxisValues
Result=[];
Result.Model=[];
%% for the Model evaluation
ModelTable=cell2mat(TempModelArray);
for i=1:length(ModelEvalNameList)
    EvalName=ModelEvalNameList{i};
    EvalList=ModelTable(:,i);
    [Mat]= GridEvalListToMat(EvalList,ParaArray,SeparateParaList,GridSize);
    Result.Model=setfield(Result.Model,EvalName,Mat);
end

%% for the evaluation
Result.Test=[];
for TT=1:TestNum
    TestName=TestNameList{TT};
    AA=cell(ParaNum,1);
    parfor P=1:ParaNum
        AA{P}=TempTestArray{P}{TT};
    end
    AAMat=cell2mat(AA);
    EvalAAStruct=[];
    for EE=1:length(EvaluationNameList)
        EvalName=EvaluationNameList{EE};
        EvalList=AAMat(:,EE);
        [Mat]= GridEvalListToMat(EvalList,ParaArray,SeparateParaList,GridSize);
        EvalAAStruct=setfield(EvalAAStruct,EvalName,Mat);
    end
    Result.Test=setfield(Result.Test,TestName,EvalAAStruct);    
end










end


function [Mat]= GridEvalListToMat(EvalList,ParaArray,SeparateParaList,GridSize)
Mat=zeros(GridSize);
ParaNum=length(ParaArray);
ParaOrder=length(ParaArray{1});
parfor i=1:ParaNum
   ParaVec=ParaArray{i};
   [GridSub,GridIndex]=ParaVecToGridPosition(ParaVec,SeparateParaList,GridSize);
   Mat(GridIndex)=EvalList(i);
end
end

function [GridSub,GridIndex]=ParaVecToGridPosition(ParaVec,SeparateParaList,GridSize)
% SeparateParaList is a cell array,each element is a vector, already sorted
% from small to large.
% ParaVec is a vector, same length as the SeparateParaList
%
%   z.sun  20170926
D=length(GridSize);
GridSub=zeros(1,D);
for i=1:length(ParaVec)
    ind_i=find(SeparateParaList{i}==ParaVec(i));
    GridSub(i)=ind_i;
end
GridIndex=0;
G=GridSub;
switch D
    case 1
        GridIndex=GridSub(1);
    case 2
        GridIndex=sub2ind(GridSize,G(1),G(2));
    case 3
        GridIndex=sub2ind(GridSize,G(1),G(2),G(3));
    case 4
        GridIndex=sub2ind(GridSize,G(1),G(2),G(3),G(4));
    case 5
        GridIndex=sub2ind(GridSize,G(1),G(2),G(3),G(4),G(5));
    case 6
        GridIndex=sub2ind(GridSize,G(1),G(2),G(3),G(4),G(5),G(6));
    otherwise
        error(['currently, we do not support the Dimension  => ',num2str(D)])
end
end

function [Vec]=ModelEval(W,Option)
Vec=zeros(1,4);
% for the first evaluation, the voxel level sparsity
Vec(1)=sum(W~=0);
% for the second evalution, the group level sparsity
if isfield(Option,'GroupIndListArray')
    [NormList]=cellfun(@(GroupIndList) norm(W(GroupIndList),2),GroupIndListArray);
    Vec(2)=sum(NormList>0);
else
    Vec(2)=0;
end


% for the third  evalution, the sum of W square amplitude
Vec(3)=sum(W.^2);

% for the forth evalution, the mean of W square amplitude for selected 
Vec(4)=Vec(3)/Vec(1);
end