%   this script is used to test the function  [ W,CostLoG ] = FISTA_SVM( W0,DataOpt,CostFuncOpt,OptimizeOpt,SparstOption)
%
%   Zhuo Sun  2016-06-13

%%
addpath('C:\Users\zsun\Desktop\MatlabTryNewFunc\Optimize\CheckOpt')
addpath('C:\Users\zsun\Desktop\MatlabTryNewFunc\SpatialAnatomicalApproximate')
addpath('C:\Users\zsun\Desktop\MatlabTryNewFunc\Sparsity')
addpath('C:\Users\zsun\Desktop\MatlabTryNewFunc\Optimize')

%%

W0=zeros(1001,1);
N=200;
d=1000;


%% set the data option
DataOpt.X=[rand(N,d),ones(N,1)];
DataOpt.Y=2*round(rand(N,1))-1;
DataOpt.Wx=ones(N,1);

%% set the cost function opetion
CostFuncOpt.LambdaList=[1,0,1,1];



%% set the Optimization option
OptimizeOpt.InitialStepSize=0.5;


%% set the SparseOption.
SparseOpt.SparseType='Lasso'

%% Check all the options
[ DataOpt,CostFuncOpt,OptimizeOpt,SparseOpt ] = Check_All( DataOpt,CostFuncOpt,OptimizeOpt,SparseOpt );


%% run the SVM computing
[ W,CostLoG ,StepsizeLoG,CostPartsLoG] = FISTA_SVM( W0,DataOpt,CostFuncOpt,OptimizeOpt,SparseOpt);