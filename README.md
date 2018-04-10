Spatial-Anatomical Regularized GroupLasso SVM (SAR_GL_SVM) toolbox  (version 0.1)
================================================

This toolbox integrates spatial-anatomical regularization and group sparsity into the linear SVM framework, and is created in Matlab.  The toolbox contains many related methods into a single framework: standard linear SVM, Lasso SVM, GroupLasso SVM，with various quadratic penalties. In addition, tools to facilitate cross-validation and hyper-parameter optimization are incorporated.

The detail definition of the cost function can be found in our under-review paper “Integrating Spatial-Anatomical Regularization and Structure Sparsity into SVM: Improving Interpretation of Alzheimer’s Disease Classification”.

The main function is “TrainAndTestModel”. It trains the model on the training set and tests it on the test set. The input parameters RegularizationMethod and SparsityMethod together define the learning method. The hyper parameters of this method are set via the option HyperParameters.
```
[Result1List] = TrainAndTestModel( Xtrain, Ytrain, ...
Xtest, Ytest, HyperParameters, RegularizationMethod, SparsityMethod, StepType, ResultFileName, OutputFolder)
```
The meaning of the input parameters are explained below:

* Xtrain and Ytrain are the feature matrix and output label of the training set, Ytrain and Ytest are the feature matrix and output label of the test set
* HyperParameters is a cell array, and each cell is a list of three hyper parameters (lambda_1, lambda_2 and lambda_3) defining one training-testing experiment. Multiple experiments can be defined by defining more entries in the array.
* RegularizationMethoddefines the SAR or SR regularization information.
* SparsityMethod defines the sparsity related cost, either use `lasso` or `group lasso`. If use group lasso, this structure also contains the grouping information.
* StepType,  defines how to decide the step size during optimization. It can be `Fix` or `LogDecay` or `Backtracking`, detail can be fould in function  `ProximalGradient`. 
* ResultFileName, OutputFolder: defines where to store the results, and the full path of the result file is  Path=fullfile(OutputFolder, ExpName,ResultFileName), where the ExpName is determined by the hyper-parameters used in current experiment.

If the user has no idea of which hyper-parameter to use, it is suggested to use three steps:
* Step 1,  use the training set to run  n-fold cross-validation to grid search the optimal hyper-parameters.
     Run “HyperParaTuning_CV_SVM”
* Step 2,  find the optimal hyper-parameter based on the result from Step 1.
    Run “ReportFromParaTuning”
* Step 3,  for the selected hyper-parameters, use the whole training set to learn a model and evaluate the performance using the test set.
Run “TrainAndTestModel”
```
Example
%% set the names
TuningResultName='GridSearchResult.mat';
GridSearchReportName='GridSearchReport.mat';
ReportOnTestName='ResultOnTest.mat';
TestResultName='TestResult.mat';
%% the hyper-parameter
Lambda1=[0];
Lambda2=[0.001,0.01,0.2,0.5,1,2,5,10];
Lambda3=[0.001,0.01,0.2,0.5,1,2,5,10];
ValueArray=cell(3,1);  ValueArray{1}=Lambda1;ValueArray{2}=Lambda2;ValueArray{3}=Lambda3;
[ LambdaArray ] = Mat2RowCell(ParameterArrayGenerator( ValueArray ));
 
%% set the options
SAROption0=[]
SAROption0.LL=LL;
SAROption0.L_LL=L_LL;
SAROption0.Zscore=1;
SparseOpt0=[]
SparseOpt0.CVZscore=1;
SparseOpt0.SparseType='GroupLasso';
SparseOpt0.C_Or_R=2;
SparseOpt0.MaxIter=1000;
q=2;  % for group lasso as L1_2 norm
%% Divide the training set into parts for CV
CVNum=5;  % use 5-fold cross validation on the training set to tuning the parameter
StepType=’Fix’
FixRandSeed=1;  % fix the random seed, keep the same random dividing different time of run and run on different machine
[ Dividing ] = CreateRandNfoldDividing(SubNum,CVNum,FixRandSeed );

RegularizationMethod = SAROption0;
SparsityMethod       = SparseOpt0;
%% CV for hyper parameters 
[ Result1]= HyperParaTuning_CV_SVM(Xtrain,Ytrain,Dividing, RegularizationMethod, SparsityMethod,OutFoldCV,LambdaArray,StepType);
save(CVResultPath, Result1);
%% generate the report for the grid search result,

NewMeasureWeightList=[]
[ OptimalParaList]=ReportFromParaTuning( CVResultPath,NewMeasureWeightList,ReportTxtPath );
%% train the model using the whole training set and then evalutate the performance on test set

[ResultListArray] = TrainAndTestModel (Xtrain,Ytrain, XtestArray,YtestArray, HyperParameters, RegularizationMethod, SparsityMethod, StepType, ResultFileName, OutputFolder)
```

Variation:
1.	Use lasso instead of group lasso. Simply set SparseOpt0.SparseType='Lasso'
2.	Use standard linear SVM without any sparsity.  Set the lambda_3=0.
3.	Do not use SAR or SR. Simply set lambda_2=0.




