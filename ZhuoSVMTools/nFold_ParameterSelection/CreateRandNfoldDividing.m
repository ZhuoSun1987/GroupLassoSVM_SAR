function [ Dividing ] = CreateRandNfoldDividing(SubNum,n,FixRandSeed )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

   if nargin<5 
       FixRandSeed=1;
   end
   if FixRandSeed==1
       rng('default');
   end
   NewOrder=randperm(SubNum);
   Dividing=cell(n,1);
   StepFloor=floor(SubNum/n);
   Remind=SubNum-n*StepFloor;
   End=0;
   Start=0;
   for i=1:n
      if i<=Remind
          Step=StepFloor+1;
      else
          Step=StepFloor;
      end
      Start=End+1;
      End  =Start+Step-1;
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

