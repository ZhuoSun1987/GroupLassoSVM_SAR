function [ KeepIter ] = Stopping( W,W_1,CostLoG,Iter,OptimizeOpt )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   This function is used to check if the function converge or should stop
%
%   Zhuo Sun

KeepIter=1;
            %% if Stop
            if Iter>=OptimizeOpt.MaxIter 
                KeepIter=0;
                disp(['Max number of iteration reached,  at iteration_',num2str(Iter)]);
            end
            if CostLoG(Iter+1)~=0
                if abs(CostLoG(Iter+1)-CostLoG(Iter))/abs(CostLoG(Iter))<=OptimizeOpt.stopvarj
                    disp(['DeltaJ convergence,  at iteration_',num2str(Iter)]);
                    KeepIter=0;
                end
            else
                KeepIter=0;
                disp('Overall Cost function is zero');
            end
            if max(abs(W(:)-W_1(:)))/sum(abs(W(:)))<=OptimizeOpt.stopvarx
                disp(['Delta x convergence,  at iteration_',num2str(Iter)]);
                KeepIter=0;
            end


end

