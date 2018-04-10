% this script is used to compute the McNemar's test on harder task
Task1_1 = 'E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp01_00\CNvsMCI\Fix\OnTestSet\L1_1000\L2_0\L3_0';
Task1_2 = 'E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp12\CNvsMCI\Fix\Seg_3\OnTestSet\L1_0\L2_0.01\L3_5';
Task2_1 = 'E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp01_00\MCIsvsMCIc\Fix\OnTestSet\L1_1\L2_0\L3_0';
Task2_2 = 'E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp12\MCIsvsMCIc\Fix\Seg_3\OnTestSet\L1_0\L2_0.2\L3_5';
Task3_1 = 'E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp01_00\MCIvsAD\Fix\OnTestSet\L1_2\L2_0\L3_0';
Task3_2 = 'E:\MyProject\ZhuoSVM\Experiment\Revision_20170929_Exp12\MCIvsAD\Fix\Seg_3\OnTestSet\L1_0\L2_0.01\L3_5';

%% for Task 1£¬ CN vs MCI
TaskName='CN vs MCI';
Path1=fullfile(Task1_1,'TestResult.mat');
Path2=fullfile(Task1_2,'TestSet_Result.mat');
Struct1=importdata(Path1);
Struct2=importdata(Path2);
TrueLabel=Struct1.TrueLabelList;
Pred1=Struct1.PredLabelList;
Pred2=Struct2.PredLabelList;
[h,p,e1,e2] = testcholdout(Pred1,Pred2,TrueLabel);
disp('==========================')
Str=[TaskName,'  McNemar  ',num2str(p)];
disp(Str)
disp('+++++++++++++++++++++++++')
disp(sprintf('%08s  %08s  %08s  %08s','ACC','AUC','SPE','SEN'));
disp(sprintf('%08f  %08f  %08f  %08f',Struct1.accuracy, Struct1.AUC, Struct1.specificity,Struct1.sensitivity));
disp(sprintf('%08f  %08f  %08f  %08f',Struct2.accuracy, Struct2.AUC, Struct2.specificity,Struct2.sensitivity));
disp(' ')
disp(' ')


%% for Task 2£¬ MCIs vs MCIc
TaskName='MCIs vs MCIc';
Path1=fullfile(Task2_1,'TestResult.mat');
Path2=fullfile(Task2_2,'TestSet_Result.mat');
Struct1=importdata(Path1);
Struct2=importdata(Path2);
TrueLabel=Struct1.TrueLabelList;
Pred1=Struct1.PredLabelList;
Pred2=Struct2.PredLabelList;
[h,p,e1,e2] = testcholdout(Pred1,Pred2,TrueLabel);
disp('==========================')
Str=[TaskName,'  McNemar  ',num2str(p)];
disp(Str)
disp('+++++++++++++++++++++++++')
disp(sprintf('%08s  %08s  %08s  %08s','ACC','AUC','SPE','SEN'));
disp(sprintf('%08f  %08f  %08f  %08f',Struct1.accuracy, Struct1.AUC, Struct1.specificity,Struct1.sensitivity));
disp(sprintf('%08f  %08f  %08f  %08f',Struct2.accuracy, Struct2.AUC, Struct2.specificity,Struct2.sensitivity));
disp(' ')
disp(' ')


%% for Task 3£¬ MCI vs AD
TaskName='MCI vs AD';
Path1=fullfile(Task3_1,'TestResult.mat');
Path2=fullfile(Task3_2,'TestSet_Result.mat');
Struct1=importdata(Path1);
Struct2=importdata(Path2);
TrueLabel=Struct1.TrueLabelList;
Pred1=Struct1.PredLabelList;
Pred2=Struct2.PredLabelList;
[h,p,e1,e2] = testcholdout(Pred1,Pred2,TrueLabel);
disp('==========================')
Str=[TaskName,'  McNemar  ',num2str(p)];
disp(Str)
disp('+++++++++++++++++++++++++')
disp(sprintf('%08s  %08s  %08s  %08s','ACC','AUC','SPE','SEN'));
disp(sprintf('%08f  %08f  %08f  %08f',Struct1.accuracy, Struct1.AUC, Struct1.specificity,Struct1.sensitivity));
disp(sprintf('%08f  %08f  %08f  %08f',Struct2.accuracy, Struct2.AUC, Struct2.specificity,Struct2.sensitivity));
disp(' ')
disp(' ')
