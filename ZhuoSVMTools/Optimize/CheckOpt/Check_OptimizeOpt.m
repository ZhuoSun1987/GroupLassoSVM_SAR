function [ OptimizeOpt ] = Check_OptimizeOpt( OptimizeOpt )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to check the 
%
%   OptimizeOpt.MaxIter => Max iteration
%   OptimizeOpt.LargeRatio => ratio that increase the step size
%   OptimizeOpt.SmallRatio => ratio that decrease the step size
%   OptimizeOpt.StepSizeType => it can be fix stepsize,
%   logDecay,Backtracking and two direction tracking.
%   OptimizeOpt.LogDecayOpt  => the option of LogDecay function
%   OptimizeOpt.stopvarj =>  cost variation threshold for stoping
%   OptimizeOpt.stopvarx =>  x variation threshold for stopingst 
%   OptimizeOpt.ProxType => the type of proximal gradient descent method, including
%   FISTA, ISTA, MFISTA,FASTA
%   OptimizeOpt.InitialStepSize  first stepsize guass
%
%   

if ~isfield(OptimizeOpt,'MaxIter')
    OptimizeOpt.MaxIter=200;
end

if ~isfield(OptimizeOpt,'LargeRatio')
    OptimizeOpt.LargeRatio=2;
else
    if OptimizeOpt.LargeRatio<=1
        OptimizeOpt.LargeRatio=2;
    end
end

if ~isfield(OptimizeOpt,'SmallRatio')
    OptimizeOpt.SmallRatio=0.5;
else
    if OptimizeOpt.SmallRatio>=1
        OptimizeOpt.SmallRatio=0.5;
    end
end

if ~isfield(OptimizeOpt,'StepSizeType')
    OptimizeOpt.StepSizeType='TwoDirectSearch';
end

if ~isfield(OptimizeOpt,'stopvarj') 
    OptimizeOpt.stopvarj =1e-30;
end

if ~isfield(OptimizeOpt,'stopvarx') 
    OptimizeOpt.stopvarx =1e-8;
end

if ~ isfield(OptimizeOpt,'InitialStepSize')
    OptimizeOpt.InitialStepSize=1;
end
if ~isfield(OptimizeOpt,'ProxType')
    OptimizeOpt.ProxType='FISTA';
end

if ~isfield(OptimizeOpt,'MaxLineSearchNum')
    OptimizeOpt.MaxLineSearchNum=10;
end

if ~isfield(OptimizeOpt,'ShowIter')
    OptimizeOpt.ShowIter=0;
end
end

