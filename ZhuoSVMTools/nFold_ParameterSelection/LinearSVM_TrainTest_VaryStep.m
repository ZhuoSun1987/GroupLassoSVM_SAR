function [PredScoreTest,PredLabelTest,PreScoreTrain,PredLabelTrian,AUCTest,ModifyAcc,W]...
    =LinearSVM_TrainTest_VaryStep(TrainFeature,TrainYList,TestFeature,TestYList,Lambda,SAAOpt,SparseOpt0,StepType)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to train a linear SVM model in Zhuo's SVM tool
%   with max margin (if Lambda>0);


%%
if isempty(Lambda) | nargin<5
    Lambda=0;
else
    Lambda=max(Lambda,0);
end
Dim=size(TrainFeature,2);
N=size(TrainFeature,1);
%% set the parameters of the Zhuo's SVM tool
    %% data option
DataOpt.X=TrainFeature;
DataOpt.Y=TrainYList;
DataOpt.Wx=ones(size(TrainYList));
DataOpt.Q=speye(Dim-1,Dim-1);
    %% compute the Lipschitz constant
[ L_X,Temp ] = ComputeLipschitz( DataOpt.X, [] );  
    %% for the cost function option.
CostFuncOpt.MCF='HingeLoss';
CostFuncOpt.MCL=2;



    %% for the optimization option
OptimizeOpt=[];   
OptimizeOpt.InitialStepSize=1;  % it will be updated for each experimetn
if isfield(SparseOpt0,'MaxIter')
    OptimizeOpt.MaxIter=SparseOpt0.MaxIter;
else
    OptimizeOpt.MaxIter=400;
end
OptimizeOpt.StepSizeType=StepType;
OptimizeOpt.MaxLineSearchNum=20;
OptimizeOpt.SmallRatio=0.2;
OptimizeOpt.LargeRatio=5;

    %% for the lambdalist
LambdaList=[1,0,Lambda,0];    
CostFuncOpt.LambdaList=LambdaList;
    
    %% for the Lipschitz constant
L_Q= 2;
LipSchitzConst=L_X/length(DataOpt.Y)+LambdaList(3)*L_Q;   
OptimizeOpt.InitialStepSize=1/LipSchitzConst;    

    %% for  SAA option
if nargin>=6 & ~isempty(SAAOpt) 
    if isfield(SAAOpt,'OnlySAA') & SAAOpt.OnlySAA==1
        %% for the lipschitz constant and step size
        L_Q=2*SAAOpt.L_LL;
        LipSchitzConst=L_X/length(DataOpt.Y)+LambdaList(3)*L_Q;   
        OptimizeOpt.InitialStepSize=1/LipSchitzConst;  
        %% for the quadratic term
        DataOpt.Q=SAAOpt.LL;
    else
        %% for the lipschitz constant and step size
        L_Q=2*(1+SAAOpt.Ratio*SAAOpt.L_LL);
        LipSchitzConst=L_X/length(DataOpt.Y)+LambdaList(3)*L_Q;   
        OptimizeOpt.InitialStepSize=1/LipSchitzConst;  
        %% for the quadratic term
        if ~isempty(SAAOpt.LL)
            DataOpt.Q=speye(Dim-1,Dim-1)+SAAOpt.Ratio*SAAOpt.LL;
        else
            DataOpt.Q=speye(Dim-1,Dim-1);
        end
    end
    
        
end
    %% for user defined sparsity 
if nargin>=7 & ~ isempty(SparseOpt0)
    SparseOpt=SparseOpt0;
    Lambda4=SparseOpt.Lambda4;
    LambdaList=[1,0,Lambda,Lambda4]; 
    CostFuncOpt.LambdaList=LambdaList;
else
    SparseOpt=[];
    Lambda4=0;
    LambdaList=[1,0,Lambda,Lambda4];
    CostFuncOpt.LambdaList=LambdaList;
end
    


%%  Initialize the SVM and train
 W0=zeros(Dim,1);
 [ DataOpt1,CostFuncOpt1,OptimizeOpt1,SparseOpt1 ] = Check_All( DataOpt,CostFuncOpt,OptimizeOpt,SparseOpt );
[ W,CostLoG,StepsizeLoG,CostPartsLoG ] = FISTA_SVM( W0,DataOpt1,CostFuncOpt1,OptimizeOpt1,SparseOpt1);


%% make predict
Thres=0;
    %% for test
[ PredLabel,Scores,AUC,ModifyAcc,UserDefThresAcc ] = Predict_LinearSVM( W,TestFeature,TestYList,Thres );
PredScoreTest=Scores;
PredLabelTest=PredLabel;
AUCTest=AUC;
ModifyAcc=ModifyAcc;
    %% for test
[ PredLabel,Scores,AUC,ModifyAcc,UserDefThresAcc ] = Predict_LinearSVM( W,TrainFeature,TrainYList,Thres );
PreScoreTrain=Scores;
PredLabelTrian=PredLabel;


end

