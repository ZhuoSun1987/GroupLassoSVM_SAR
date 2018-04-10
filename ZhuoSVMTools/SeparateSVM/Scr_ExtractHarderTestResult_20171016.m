%   this script is used to extract classification result from harder test
%   and plot the Parameter Vs acc and Parameter vs Sparsity 
%
%   z.sun 20171016



ResultBaseRoot0='E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp01';
ResultProposeRoot='E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp12';
TestNameList={'CNvsMCI','MCIsvsMCIc','MCIvsAD'};
TitleStr=sprintf('%30s%8s%8s%8s%8s','Parameter','Acc','AUC','SPE','SEN');
%% the ParaArray for base method and proposed methods
Lambda1=[10^(-5),10^(-4),10^(-3),10^(-2),10^(-1),0.2,0.5,1,2,5,10,100,1000,10000];
Lambda2=[0];
Lambda3=[0];
ParaArray1=cell(3,1);
ParaArray1{1}=Lambda1;
ParaArray1{2}=Lambda2;
ParaArray1{3}=Lambda3;
Size1=[length(ParaArray1{1}),length(ParaArray1{2}),length(ParaArray1{3})];

Lambda1=[0];
Lambda2=[0.001,0.01,0.2,0.5,1,2,5,10];
Lambda3=[0.001,0.01,0.2,0.5,1,2,5,10];
ParaArray2=cell(3,1);
ParaArray2{1}=Lambda1;
ParaArray2{2}=Lambda2;
ParaArray2{3}=Lambda3;
Size2=[length(ParaArray2{1}),length(ParaArray2{2}),length(ParaArray2{3})];

%%
for EE=1:length(TestNameList)
    TestName=TestNameList{EE};
    disp('============================')
    disp(['==== ',TestName,' ===='])
    disp('============================')
    %% for the baseline methods
% % %     ResultRoot1=fullfile(ResultBaseRoot0,TestName,'Fix','OnTestSet');
% % %     AllMat1=cell(Size1);  AccMat1=zeros(Size1); ParaMat1=cell(Size1);
% % %     for i1=1:length(ParaArray1{1})
% % %         for i2=1:length(ParaArray1{2})
% % %             for i3=1:length(ParaArray1{3})
% % %                 ParaName=fullfile(['L1_',num2str(ParaArray1{1}(i1))],['L2_',num2str(ParaArray1{2}(i2))],['L3_',num2str(ParaArray1{3}(i3))]);
% % %                 ResultRoot2=fullfile(ResultRoot1,ParaName);
% % %                 Path=fullfile(ResultRoot2,'TestResult.mat');
% % %                 AA=importdata(Path);
% % %                 AllMat1{i1,i2,i3}=AA; ParaMat1{i1,i2,i3}=ParaName;
% % %                 AccMat1(i1,i2,i3)=AA.accuracy;
% % %             end
% % %         end
% % %     end
% % %     Max=max(AccMat1(:));
% % %     Pos=find(AccMat1==Max);
% % %     disp('    baseline ');
% % %     disp(TitleStr);
% % %     for i=1:length(Pos)
% % %         AA=AllMat1{Pos(i)};
% % %         acc=AA.accuracy*100;   auc=AA.AUC*100; sen=AA.sensitivity*100; spe=AA.specificity*100;
% % %         ParaName=ParaMat1{Pos(i)};
% % %         DataStr=sprinf('%30s%8.1f%8.1f%8.1f%8.1f',ParaName,acc,auc,spe,sen);
% % %         disp(DataStr);
% % %     end
    %% for the proposed methods
    ResultRoot1=fullfile(ResultProposeRoot,TestName,'Fix','Seg_3','OnTestSet');
    AllMat2=cell(Size2); AccMat2=zeros(Size2); ParaMat2=cell(Size2);
    for i1=1:length(ParaArray2{1})
        for i2=1:length(ParaArray2{2})
            for i3=1:length(ParaArray2{3})
                ParaName=fullfile(['L1_',num2str(ParaArray2{1}(i1))],['L2_',num2str(ParaArray2{2}(i2))],['L3_',num2str(ParaArray2{3}(i3))]);
                ResultRoot2=fullfile(ResultRoot1,ParaName);
                Path=fullfile(ResultRoot2,'TestSet_Result.mat');
                AA=importdata(Path); 
                AllMat2{i1,i2,i3}=AA; ParaMat2{i1,i2,i3}=ParaName;
                AccMat2(i1,i2,i3)=AA.accuracy;
            end
        end
    end
    Max=max(AccMat2(:));
    Pos=find(AccMat2==Max);
    disp('    Proposed  ');
    disp(TitleStr);
    for i=1:length(Pos)
        AA=AllMat2{Pos(i)};
        acc=AA.accuracy*100;   auc=AA.AUC*100; sen=AA.sensitivity*100; spe=AA.specificity*100;
        ParaName=ParaMat2{Pos(i)};
        DataStr=sprintf('%30s%8.1f%8.1f%8.1f%8.1f',ParaName,acc,auc,spe,sen);
        disp(DataStr);
    end
end

