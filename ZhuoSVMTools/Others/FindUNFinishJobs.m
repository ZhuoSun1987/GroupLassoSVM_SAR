function [ UnFinishList,TimeList ] = FindUNFinishJobs( Root, ParaNameList,ParaValueArray, FinishPattern,StartFile )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to find the jobs that are not finished.
%   
%   each job has it own folder, and if it is not finished, there have no
%   .mat file as default result files or user specified FinishPattern.
%
%   Zhuo Sun  20160805


% decide the current operation system and the separation term
CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end

%% the parameter array
[ ParaArray ] = ParameterArrayGenerator( ParaValueArray );
N=size(ParaArray,1);

%%
if nargin<4
    FinishPattern='*.mat';
end

%% 
Dir=dir(StartFile);
Begintime=datenum(Dir(1).date);


%% one by one check if it is finished (or at least have generate some result)
UnFinishList={};
TimeList={};
for i=1:N
    ParaVector=ParaArray(i,:);
    [ Folder1 ] = GenerateResultFolder( Root, ParaNameList,ParaVector );
    Dir=dir([Folder1,separation,FinishPattern]);
    if length(Dir)<1
       UnFinishList=[UnFinishList;strrep(Folder1,Root, ' Parameter=> ')  ];
    else
        TimeList=[TimeList;[strrep(Folder1,Root, ' Parameter=> ') ,'   ',Dir(1).date]];
        if Begintime>=datenum(Dir(1).date) %isempty(strfind(Dir(1).date,'10-Aug-2016'))  Begintime>datenum(Dir(1).date);
            UnFinishList=[UnFinishList;[strrep(Folder1,Root, ' Parameter= ') ,'    =>', Dir(1).date]];
        end
    end
end

disp('========================================================')
disp(['Root => ',Root])
disp([num2str(length(UnFinishList)),' jobs not finished, listed below: '])
for i=1:length(UnFinishList)
    disp( ['   ', UnFinishList{i}]);
end
disp(' ')

end

