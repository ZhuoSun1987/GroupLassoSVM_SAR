function [ WNew ] = GrouopLassoProximal( W,Lambda,StepSize,GroupLassoOpt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   this fucntion is used to compute the proximal operator on group lasso
%   penalty L1-Lq norm
%
%   Zhuo Sun  20160622

% % WNew=W;
% % ThresList=StepSize*GroupLassoOpt.GroupWeight*Lambda;
% % q=GroupLassoOpt.q;
% % for i=1:length(GroupLassoOpt.ROI)
% %     WPart=W(GroupLassoOpt.GroupLabel==GroupLassoOpt.ROI(i));
% %     NormPart=norm(WPart,q);
% %     if NormPart>ThresList(i)
% %         WPart=(1-ThresList(i)/NormPart).*WPart;
% %         WNew(GroupLassoOpt.GroupLabel==GroupLassoOpt.ROI(i))=WPart;
% %     else
% %         WNew(GroupLassoOpt.GroupLabel==GroupLassoOpt.ROI(i))=0;
% %     end
% % end

%% rewrite using the cell function to accelerate, 20170324

global WnewGroupLasso
ThresholdList=num2cell(StepSize*GroupLassoOpt.GroupWeight*Lambda);
WnewGroupLasso=zeros(size(W));
NormP=GroupLassoOpt.q;
GroupIndPosListArray=GroupLassoOpt.GroupIndPosListArray;
cellfun(@(x,y) SingleGroupLassoThres(W,x,y,NormP),GroupLassoOpt.GroupIndPosListArray,ThresholdList);

WNew=WnewGroupLasso;



end


function []=SingleGroupLassoThres(W,GroupIndPosList,Thres,NormP)
global WnewGroupLasso
FeatVec=W(GroupIndPosList);
Norm0=norm(FeatVec,NormP);
if Norm0>Thres
    FeatVecNew=FeatVec*(Norm0-Thres)/Norm0;
    WnewGroupLasso(GroupIndPosList)=FeatVecNew;
end
end

