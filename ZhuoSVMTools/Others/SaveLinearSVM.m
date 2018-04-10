function [  ] = SaveLinearSVM(SaveFolder,PredScores,PredLabels,TrueLabels,AUCTest)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   zhuo sun  20160802

%% decide the current operation system and the separation term
CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end

%% 
if exist(SaveFolder,'dir');
    mkdir(SaveFolder);
end


%% compute the measurement
stats = confusionmatStats(TrueLabels,PredLabels);
% stats.accuracy = (TP + TN)/(TP + FP + FN + TN) ; the average accuracy is returned
% stats.precision = TP / (TP + FP)                  % for each class label
% stats.sensitivity = TP / (TP + FN)                % for each class label
% stats.specificity = TN / (FP + TN)                % for each class label
% stats.recall = sensitivity                        % for each class label
% stats.Fscore = 2*TP /(2*TP + FP + FN)            % for each class label

%% save the result 
parsave([SaveFolder,separation,'accuracy.mat'],stats.accuracy);
parsave([SaveFolder,separation,'precision.mat'],stats.precision)
parsave([SaveFolder,separation,'sensitivity.mat'],stats.sensitivity );
parsave([SaveFolder,separation,'specificity.mat'],stats.specificity);
parsave([SaveFolder,separation,'Fscore.mat'],stats.Fscore);
parsave([SaveFolder,separation,'AUC.mat'],AUCTest);
parsave([SaveFolder,separation,'PredScores.mat'],PredScores);
parsave([SaveFolder,separation,'PredLabels.mat'],PredLabels);
end

