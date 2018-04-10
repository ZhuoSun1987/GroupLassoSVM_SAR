function [ W ] = SVMWeightCloseFormSolution( X, Y )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is based on teh formulat (2) of paper 
%   Bron E E, Smits M, Niessen W J, et al. Feature Selection Based on the 
%   SVM Weight Vector for Classification of Dementia[J]. IEEE journal of 
%   biomedical and health informatics, 2015, 19(5): 1617-1626.
%   and paper B. Gaonkar and C. Davatzikos, “Analytic estimation of statistical significance
%   maps for support vector machine based multi-variate image
%   analysis and classification.” Neuroimage, vol. 78, pp. 270–283, 2013
%
%   ZhuoSun  20160801


%%
[n1,d1]=size(X);
[n2,d2]=size(Y);

if n1~=n2
    error('Feature and label do not match in size');
else
    %% first, compute the K, which is defined in equation (2) of the first paper
    J=ones(n1,1);
    XXT=X*(X');
    K=(X')*(inv(XXT)+inv(XXT)*J*inv((-1*J')*inv(XXT)*J)*(J')*inv(XXT));
    W=K*Y;
    W=W';
end
    



end

