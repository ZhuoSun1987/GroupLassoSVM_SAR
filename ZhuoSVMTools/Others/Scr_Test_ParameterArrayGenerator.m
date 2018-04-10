%   this script is used to test the function 
% 
%   [ Array ] = ParameterArrayGenerator( ValueArray )

%% for str
ValueArray=cell(3,1);
ValueArray{1}={'A1','A2','A3'};
ValueArray{2}={'B1','B2'};
ValueArray{3}={'D1','D2','D3','D4'};
[ Array ] = ParameterArrayGenerator( ValueArray )


%% for real numbers
ValueArray=cell(3,1);
ValueArray{1}=[1,2,3]
ValueArray{2}=[10,20];
ValueArray{3}=[100,200,300,400];
[ Array ] = ParameterArrayGenerator( ValueArray )

%% mix of real number and strs
ValueArray=cell(3,1);
ValueArray{1}=[1,2,3]
ValueArray{2}=[10,20];
ValueArray{3}={'D1','D2','D3','D4'};
[ Array ] = ParameterArrayGenerator( ValueArray )