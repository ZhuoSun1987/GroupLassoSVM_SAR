function [ DataOpt ] = Check_DataOpt( DataOpt )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to check the DataOpt
%
%   DataOpt.X  for the labeled subject feature matrix, size is [n,d+1]
%   where n is the subject number, d is the real feature length, d=1
%   because of the possible bias term.  if the last column is ones(n,1), it
%   include bias, if last column is zeros(n,1), it has no bias
%   DataOpt.Y  for hte labels of labeled term. size is [n,1] can be {-1,1}
%   DataOpt.Wx  the weight of each labeled subject, it should be normalized
%   before this function
%   DataOpt.A  for the pairwise different feature, size is [p,d+1], the
%   last column should be zeros(p,1)
%   DataOpt.Ma  the margin of each order pair 
%   DataOpt.Wa  the weight of each order pair
%   DataOpt.Q  is a SPD matrix or possible 
%   DataOpt.FeatureNormal  if it is 1, normalize the data using zscore.
%
%   Zhuo Sun

N=0;
D=0;

%% feature length of DataOpt.X and DataOpt.A
if isfield(DataOpt,'X') & isfield(DataOpt,'A')
    if size(DataOpt.X,2) ==size(DataOpt.A,2)
        D=size(DataOpt.X,2);
    else
        error('DataOpt.X and DataOpt.A do not match in size')
    end
end

if isfield(DataOpt,'X') & ~isfield(DataOpt,'A')
    D=size(DataOpt.X,2);
end
    
if ~isfield(DataOpt,'X') & isfield(DataOpt,'A')
    D=size(DataOpt.A,2);
end   
    
if ~isfield(DataOpt,'X') & ~isfield(DataOpt,'A')
    error('No Data is given')
end    

%% size Q and feature length
if ~isfield(DataOpt,'Q')
    DataOpt.Q=speye(D-1);
else
    [m,n]=size(DataOpt.Q);
    if m~=n
        error('DataOpt.Q should be a square matrix (Also should be SPD)')
    else
        if m~=D-1 
            error('size of DataOpt.Q and given feature do not match')
        end
    end
end

%% N and P
if isfield(DataOpt,'X')
    if length(DataOpt.Y)~=size(DataOpt.X,1)
        error('DataOpt.X and DataOpt.Y not match in size');
    end
    if ~isfield(DataOpt,'Wx')
        DataOpt.Wx=ones(size(DataOpt.Y));
    else
        if ~isequal(size(DataOpt.Wx),size(DataOpt.Y))
            error('DataOpt.Wx is not proper size')
        else
            DataOpt.Wx=NormalCost( DataOpt.Wx );
        end
    end
end

if isfield(DataOpt,'A')
    if ~isfield(DataOpt,'Wa')
        DataOpt.Wa=ones(size(DataOpt.A,1),1);
    else
        if length(DataOpt.Wa)~=size(DataOpt.A,1)
            error('DataOpt.Wa is not proper size')
        else
            DataOpt.Wa=NormalCost( DataOpt.Wa );
        end
    end
    
    if ~isfield(DataOpt,'Ma')
        DataOpt.Ma=0.01*ones(size(DataOpt.A,1),1);
    else
        if length(DataOpt.Ma)~=size(DataOpt.A,1)
            error('DataOpt.Ma is not proper size')
        else
            DataOpt.Ma=NormalCost( DataOpt.Ma );
        end
    end
end


%% for the Normalize of data feature
if ~isfield(DataOpt,'FeatureNormal') | DataOpt.FeatureNormal==1
    if isfield(DataOpt,'A')
       Temp=DataOpt.A(:,1:end-1);
       Temp=zscore(Temp);
       DataOpt.A(:,1:end-1)=Temp;
    end
    if isfield(DataOpt,'X')
       Temp=DataOpt.X(:,1:end-1);
       Temp=zscore(Temp);
       DataOpt.X(:,1:end-1)=Temp;
    end    
end

end

