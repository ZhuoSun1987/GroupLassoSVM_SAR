function [ ShiftList ] = DistRelatedShift( DimLength,DistSquare )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   Zhuo Sun  2015-09-24

MaxShift=floor(DistSquare^ 0.5);
Var=2*MaxShift+1;
VarValueList=[-1*MaxShift:MaxShift];
AllPossible=zeros(Var^DimLength,DimLength);

for i=1:DimLength
    RepTime=Var^(i-1);
    RepNum=Var^(DimLength-i);
    Unit=zeros(Var^(DimLength-i+1),1);
    for j=1:Var
        Unit(1+(j-1)*RepNum:j*RepNum,1)=VarValueList(j);
    end
    
    for j=1:RepTime
        AllPossible(1+(j-1)*length(Unit):j*length(Unit),i)=Unit;
    end
end



AllPossibleDistSquare=sum(AllPossible.^2,2);
ThrowAway=(AllPossibleDistSquare>DistSquare) + (AllPossibleDistSquare==0);


ShiftList=AllPossible;
ShiftList(ThrowAway==1,:)=[];
end

