%   this script is used to test the GradAll function 
%
%   Zhuo Sun  20160602

addpath('C:\Users\zsun\Desktop\MatlabTryNewFunc\Utl')

d=1000;
n=500;
p=700;


b=rand(1);
w=rand(d,1);

X=rand(n,d);
Y=2*round(rand(n,1))-1;
UseBias=1;
Cx=rand(n,1);
Cx= NormalCost( Cx );


A=rand(p,d);
Ma=2*rand(p,1);
Ca=rand(p,1);
Ca= NormalCost( Ca );

Q=cov(rand(d,2000)');

LambdaList=[1,1,1];
MisClassFunc='HingLoss';
MisClassSquare=2;
MisOrderFunc='HingLoss';
MisOrderSquare=2;

[ dW,dB ] = GradAll(w,b,X,Y,Cx,UseBias,A,Ca,Ma,Q,LambdaList,MisClassFunc,MisClassSquare,MisOrderFunc,MisOrderSquare )