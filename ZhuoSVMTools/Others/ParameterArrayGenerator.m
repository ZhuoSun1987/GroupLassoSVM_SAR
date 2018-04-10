function [ Array ] = ParameterArrayGenerator( ValueArray )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   ValueArray is a cell array and each cell is a vector [1,N_i] of different
%   values of the same parameter.
%
%   Zhuo Sun  20160803

N=length(ValueArray);
ValueNumList=zeros(1,N);

%% check if Array is a cell array or a matrix
UseCellArray=0;
for i=1:N
    Base=ValueArray{i};
    ValueNumList(i)=length(Base);
    if iscell(Base)
        UseCellArray=1;
    end
end

if UseCellArray==1
    Arrray=cell(prod(ValueNumList),N);
else
    Array=zeros(prod(ValueNumList),N);
end
%% filling the Array
for i=1:N
    Base=ValueArray{i};
    N_i=length(Base);
    BeforeNum=prod(ValueNumList(1:i-1));
    AfterNum =prod(ValueNumList(i+1:end));
    %% example
    %  A={'A','C' ,'D'}
    %  A=repmat(A,4,1)
    %  B= A(:);

    Mat=repmat(reshape(Base,[1,N_i]),AfterNum,1);
    Vec=Mat(:);
    if  UseCellArray==1
        if iscell(Base)
            Array(:,i)=repmat(Vec,BeforeNum,1);
        else
            Array(:,i)=num2cell(repmat(Vec,BeforeNum,1));
        end
    else
        Array(:,i)=repmat(Vec,BeforeNum,1);
    end
end
    

    

end


