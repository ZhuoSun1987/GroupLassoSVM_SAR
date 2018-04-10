%   this script use liblinear to make train test on the 

Ver=version;
if str2num(Ver)<8
    % when the version<8, we need to manually start the matlabpool for
    % parfor
    s = matlabpool('size')
    if s==0  %  which mean current matlabpool is closed
        matlabpool open
    end
end
%% addpath
PC_specifyRoot='E:\MyProject\ZhuoSVM';
% for home PC, it is E:\MyProject\ZhuoSVM
% for Gisela01, it is  /srv/lkeb-ig/NIP/zsun/ZhuoSVM_New/
% for Yuchuan PC, it is 'F:\Zhuo\Project\ZhuoSVM';
CodeRoot='E:\MyProject\ZhuoSVM\ZhuoSVMTools';
addpath(genpath(CodeRoot));
addpath('C:\Users\szsyh\OneDrive\Coding\nFold_ParameterSelection')
addpath('E:\Tools\liblinear-2.11\matlab')

%%
OutRoot0='E:\MyProject\ZhuoSVM\Experiment';
ExpName0='Exp00_liblinear';
DataRoot0='E:\MyProject\ZhuoSVM\ZhuoSVMData';
ZscoreList=[1,0];
ZscoreNameList={'Zscore','NoZscore'};
SourceList={'SPM','CAT12VBM'}
Lambda2=[0.001,0.01,0.1,0.5,1,2,5,10];
CList=10.^(-5:0.5:3);
setting=' -s 5';
for G0=1:length(SourceList)
    Source=SourceList{G0}
    ADTrainPath=fullfile(DataRoot0,'VoxelWiseFeature',Source,'ADTrain_N3_Scaled.mat');  ADTrain=importdata(ADTrainPath);
    CNTrainPath=fullfile(DataRoot0,'VoxelWiseFeature',Source,'CNTrain_N3_Scaled.mat');  CNTrain=importdata(CNTrainPath);
    ADTestPath =fullfile(DataRoot0,'VoxelWiseFeature',Source,'ADTest_N3_Scaled.mat');   ADTest =importdata(ADTestPath);
    CNTestPath =fullfile(DataRoot0,'VoxelWiseFeature',Source,'CNTest_N3_Scaled.mat');   CNTest =importdata(CNTestPath);
    Xtrain=[ADTrain;CNTrain]; Xtrain=[Xtrain,ones(size(Xtrain,1),1)];  Ytrain=[ones(size(ADTrain,1),1);-1*ones(size(CNTrain,1),1)];
    Xtest =[ADTest ;CNTest];  Xtest =[Xtest ,ones(size(Xtest ,1),1)];  Ytest =[ones(size(ADTest,1) ,1);-1*ones(size(CNTest ,1),1)];

    accListArray=cell(2,1);
    for G1=1:length(ZscoreList)
        Folder1=fullfile(OutRoot0,ExpName0,ZscoreNameList{G1});
        mkdir(Folder1);
        if ZscoreList(G1)==1
            [X1,mu,std]=zscore(Xtrain);
            X2=(Xtest-repmat(mu,[size(Xtest,1),1]))./repmat(std,[size(Xtest,1),1]);
            X2(:,std==0)=0;
            X1(:,end)=1;
            X2(:,end)=1;
        else
            X1=Xtrain;
            X2=Xtest;
        end
        AccList=zeros(length(Lambda2),1);
        for i=1:length(CList)
% %             C=1/Lambda2(i);
            C=CList(i);
            %% call liblinear
            model = train(Ytrain, sparse(X1), ['-c ',num2str(C),setting]);
            [predict_label, accuracy, dec_values] = predict(Ytest, sparse(X2), model); % test the training data
            AccList(i)=accuracy(1);
        end
        accListArray{G1}=AccList;
    end
    
    X=1:length(CList);
    XLabelList=cell(size(X));
    for i=1:length(X)
        XLabelList{i}=num2str(CList(i));
    end
    figure
    plot(accListArray{1},'r')
    hold on
    plot(accListArray{2},'g')
    legend(ZscoreNameList)
    xticks(X)
    xticklabels(XLabelList)
    xtickangle(45)
    title(Source)
end

