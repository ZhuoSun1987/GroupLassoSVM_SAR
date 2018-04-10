function [ NewCList ] = NormalCost( CList )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to normalize the cost list of each subject.
%
%   Zhuo Sun  20160602  (already tested)


%% check if every one is nonnegative
if sum(CList<0)>0
    error('All subject weight should be non negative')
end

%% doing the normalization
n=length(CList);
Sum=sum(CList);
NewCList=CList*n/Sum;


end