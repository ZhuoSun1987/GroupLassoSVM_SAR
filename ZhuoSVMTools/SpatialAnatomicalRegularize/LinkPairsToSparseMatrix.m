function [ L,LL ] = LinkPairsToSparseMatrix( SparsePairs, PairProper,PairProperToAmplifyOpt,PairWeightList,FeatureSize )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%
%   SparsePairs is a P*2 matrix, each row is a pair [i,j]    
%   PairProper  is a P*1 vector, or P*1 cell Array
%
%   Zhuo Sun  20160620


%% compute the L,  size(L)=[P,d]
P=size(SparsePairs,1);
RowIndexList=[1:P]';



if isempty(PairWeightList)
    PairWeightList=PairWeightComputing(PairProper,PairProperToAmplifyOpt,P);
else
    if length(PairWeightList)~=P
        error('size do not match');
    end
end


Rows=[RowIndexList;RowIndexList];
Cols=[SparsePairs(:,1);SparsePairs(:,2)];
Vals=[PairWeightList; -1*PairWeightList];

L=sparse(Rows,Cols,Vals,P,FeatureSize);

%% compute the LL
LL=(L')*L;

end


function  [PairWeightList]  =PairWeightComputing(PairProper,PairProperToAmplifyOpt,P)

if isempty(PairProperToAmplifyOpt)
    PairWeightList=ones(P,1);
else
    switch PairProperToAmplifyOpt.Type
        case 'linear'
            if isfield(PairProperToAmplifyOpt,'SlopeConstant')
                PairWeightList=PairProper*abs(PairProperToAmplifyOpt.SlopeConstant);
            else
                PairWeightList=PairProper;
            end
        case 'gaussian'
            if isfield(PairProperToAmplifyOpt,'Std')
               std=abs(PairProperToAmplifyOpt.Std);
            else
               std=1;
            end
            if isfield(PairProperToAmplifyOpt,'SlopeConstant')
                SlopeConstant=abs(PairProperToAmplifyOpt.SlopeConstant);
            else
                SlopeConstant=1;
            end    
            PairWeightList=SlopeConstant*normrnd(PairProper,0,std);
        case 'constant'
             if isfield(PairProperToAmplifyOpt,'SlopeConstant')
                PairWeightList=ones(P,1)*abs(PairProperToAmplifyOpt.SlopeConstant);
            else
                PairWeightList=ones(P,1);
             end
        otherwise
            error(['not defined the Type',PairProperToAmplifyOpt.Type])
    end
end

end



% W=30*rand(4,1)
% A=[1,-1,0,0;0,0,1,-1;0,0,-1,1;-1,1,0,0];
% AA=A'*A
% Cost=zeros(21,1);
% Cost(1)=W' *AA*W;
% Stepsize=0.3;
% for i=1:20
%     W=W-Stepsize*AA*W;
%     Cost(i+1)=W' *AA*W;
% end


