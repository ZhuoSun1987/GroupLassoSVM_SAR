function [ Xtrain,Xtest,YTrain,YTest,Dividing ] = nFold_DivideData( X,Y,Dividing,SelectInd,FixRandSeed )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to divide the dataset into training and testing
%   part in a n-fold cross-validation
%
%   z.sun 20170303

Num=size(X,1);

%% if no sepecified dividing is given, create it
if isscalar(Dividing)
   % only give n, but do not specify the dividing Pattern
   n=Dividing;
   if nargin<5 
       FixRandSeed=1;
   end
   if FixRandSeed==1
       rng('default');
   end
   NewOrder=randperm(Num);
   Dividing=cell(n,1);
   StepFloor=floor(Num/n);
   Remind=Num-n*StepFloor;
   End=0;
   Start=0;
   for i=1:n
      if i<=Remind
          Step=StepFloor+1;
      else
          Step=StepFloor;
      end
      Start=End+1;
      End  =Start+Step;
      struct=[];
      TrainIndList=NewOrder;
      TestIndList=NewOrder(Start:End);
      TrainIndList(Start:End)=[];
      TestIndList=sort(TestIndList);
      TrainIndList=sort(TrainIndList);
      struct.TrainInd=TrainIndList;
      struct.TestInd =TestIndList;
      Dividing{i}=struct; 
   end  
end

%% extract the train and test feature and label
n=length(Dividing);
if nargin<4 | isempty(SelectInd)
    Xtrain=cell(n,1); Xtest=cell(n,1);
    YTrain=cell(n,1); YTest=cell(n,1);
    for i=1:n
        SelectInd=i;
        TrainIndList=Dividing{SelectInd}.TrainInd;
        TestIndList =Dividing{SelectInd}.TestInd;
        Xtrain{i}=X(TrainIndList,:);
        Xtest{i} =X(TestIndList ,:);
        YTrain{i}=Y(TrainIndList,:);
        YTest{i} =Y(TestIndList ,:);
    end
    
else
    TrainIndList=Dividing{SelectInd}.TrainInd;
    TestIndList =Dividing{SelectInd}.TestInd;
    Xtrain=X(TrainIndList,:); 
    Xtest =X(TestIndList ,:);
    YTrain=Y(TrainIndList,:);
    YTest =Y(TestIndList ,:);
end

end

