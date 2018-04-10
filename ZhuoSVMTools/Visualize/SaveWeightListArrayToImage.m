function [ ] = SaveWeightListArrayToImage( WList,Mask,Folder,UseParallel )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to save a stack of Weight list (save as a cell
%   array) into several nifty files.
%
%   Zhuo Sun 2016-10-10

N=length(WList);
if ~exist(Folder,'dir')
    mkdir(Folder);
end
if nargin<4
    UseParallel=1;
end
if UseParallel==1
    parfor i=1:N
        Weight=WList{i};
        [ WeightMap ] = SaveWeightMap( Weight(1:end-1), Mask );
        Nii=make_nii(WeightMap,[]);
        save_nii(Nii,fullfile(Folder,['WeightMap',num2str(i),'.nii.gz']));
    end
else
    for i=1:N
        Weight=WList{i};
        [ WeightMap ] = SaveWeightMap( Weight(1:end-1), Mask );
        Nii=make_nii(WeightMap,[]);
        save_nii(Nii,fullfile(Folder,['WeightMap',num2str(i),'.nii.gz']));
    end    
end

end

