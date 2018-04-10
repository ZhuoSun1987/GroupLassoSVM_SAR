function [ NonZeroGroupNum ] = NonZeroGroup( W, GroupIndexList )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%   where W do not contains the bias term
%   
%   GroupIndexList is the same size as W, and it only contains positive
%   integars
%   
%   Zhuo Sun   20160804


GroupIndUniq=sort(unique(GroupIndexList));
GroupNum=length(GroupIndUniq);
NonZeroGroupNum=0;
for i=1: GroupNum
    Index=GroupIndUniq(i);
    if sum(abs(W(GroupIndexList==Index)))>0
        NonZeroGroupNum=NonZeroGroupNum+1;
    end
end





end