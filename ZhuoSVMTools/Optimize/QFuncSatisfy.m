function [ Satisfy,Cost_NewW,Q_Cost ] = QFuncSatisfy(NewW,OldW,Grad_OldW,StepSize, CostW,X,Y,Cx,A,Ma,Ca,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to compute the Q function for the line search
%   conditions.
%
%
%   Zhuo Sun  2016-06-06
UseBias=1;
[ SumCost,CostList ] = CostAll(NewW(1:end-1),NewW(end),X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare,SparstOption );
Cost_NewW=SumCost;

FirstTerm =(NewW-OldW).*Grad_OldW;
SecondTerm=(NewW-OldW).^2;
Q_Cost=Costsum(FirstTerm(:))+(1/StepSize)*0.5*sum(SecondTerm(:));

if Cost_NewW>Q_Cost
    Satisfy=-1
else
    Satisfy=1;
end
    



end

