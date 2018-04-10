function [ BestValue,PredValues,OptParameters ] = HyperParameterInterp( Values, ParaArray,ToTestArray,HighOrLow,ToUsedIndexList )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to make interpolation of the Values
%
%   currently, it fit for at most 2D case 
%
%   z.sun 20170401

DimAll=length(ParaArray{1});
N=length(ParaArray);
N1=length(ToTestArray);
if nargin<4
    HighOrLow=1;
end
if nargin<5
    ToUsedIndexList=1:DimAll;
end
UseDimNum=length(ToUsedIndexList);
if UseDimNum>2
    error('Currently, not support for more than two dimensions');
end


TrainPosList=zeros(N,UseDimNum);
TestPosList =zeros(N1,UseDimNum);

%% get the points of the train and test values
for i=1:N
    TrainPosList(i,:)=ParaArray{i}(ToUsedIndexList);
end
for i=1:N1
    TestPosList(i,:)=ToTestArray{i}(ToUsedIndexList);
end


%% Do the interpolation 
Method='spline';
if UseDimNum==1
    [A1,ia,ic] = unique(TrainPosList);
    [A2,ia,ic] = unique(TestPosList);
    Values=Values(ia);
    NewTestArray=ToTestArray(ia);
    TestValues = interp1(TrainPosList(:,1),Values,TestPosList(:,1),Method);
end

if UseDimNum==2
    [A1,ia,ic] = unique(TrainPosList,'rows');
    [A2,ia,ic] = unique(TrainPosList,'rows');
    Values=Values(ia);
    NewTestArray=ToTestArray(ia);
    TestValues = interp2(A1(:,1),A1(:,2),Values,A2(:,1),A2(:,2),Method);
end
PredValues=TestValues;
%% find the best values and the corresponding Parameters
if HighOrLow==1
    BestValue=max(TestValues);   
end
if HighOrLow==2
    BestValue=min(TestValues);
end
Pos=find(TestValues==BestValue);
OptParameters=cell(length(Pos),1);
for i=1:length(Pos)
    OptParameters{i}=NewTestArray{Pos(i)};
end

end
