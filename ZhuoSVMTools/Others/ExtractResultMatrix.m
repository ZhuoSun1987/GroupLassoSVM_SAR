function [  ] = ExtractResultMatrix( NameArray,ValueArray,PropertyArray,Ind,RootFolder,ResultFolder )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
%   this funciton is used to extract the structured folder and single value
%   in each property file.  each file is a .mat file and it contains a
%   scalar
%   
%   Zhuo Sun   20160802

%%  parallel and operating system
s = matlabpool('size')
if s==0  %  which mean current matlabpool is closed
    matlabpool open 
end
    % decide the current operation system and the separation term
CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end

if ~exist(ResultFolder,'dir')
    mkdir(ResultFolder)
end


NameNum=length(NameArray);
PropertyNum=length(PropertyArray);
ValueNumList=zeros(1,length(ValueArray));
for i=1:length(ValueArray)
    ValueNumList(i)=length(ValueArray{i});
end
TotalNum=prod(ValueNumList);
DimLength=NameNum;

for P=1:PropertyNum
    Property=PropertyArray{P};
    if length(NameArray)==1
        Mat=zeros(ValueNumList,1);
    else
        Mat=zeros([ValueNumList]);
    end
    Size=size(Mat);
    Lin=Mat(:);
    for ind=1:TotalNum
        X0=cell(1,DimLength);
        [X0{:}]=ind2sub(Size,ind);
        [ResultPath]=ParaSub2Path(X0,NameArray,ValueArray,Property,RootFolder);
        disp(ResultPath)
        A=importdata(ResultPath);
        Lin(ind)=A(Ind);
    end
    Mat=reshape(Lin,size(Mat));
     
    parsave([ResultFolder,separation,Property,'.mat'],Mat); 
    
    %% save the figures
    if length(NameArray)==2
         figure
        h=imagesc(Mat)
        colormap jet
        colorbar
        xlabel(NameArray{2})
        ylabel(NameArray{1})
        if iscell(ValueArray{2})
            set(gca,'Xtick',1:ValueNumList(2),'XTickLabel',ValueArray{2})
        else
            set(gca,'Xtick',1:ValueNumList(2),'XTickLabel',mat2cell(ValueArray{2}))
        end
        if iscell(ValueArray{1})
            set(gca,'Ytick',1:ValueNumList(1),'YTickLabel',ValueArray{1})
        else
            set(gca,'Ytick',1:ValueNumList(1),'YTickLabel',mat2cell(ValueArray{1}))
        end
        title(Property)
       
    end
    if length(NameArray)==1
         figure
        h=plot([1:length(Mat)],Mat');
        xlabel(NameArray{1})
        ylabel(Property)
        if iscell(ValueArray{1})
            set(gca,'Xtick',1:ValueNumList(1),'XTickLabel',ValueArray{1})
        else
            set(gca,'Xtick',1:ValueNumList(1),'XTickLabel',mat2cell(ValueArray{1}))
        end
    end
    MaxValue=max(Mat(:));
    MinValue=min(Mat(:));
    title([Property,'  ',num2str(MinValue)  '  to  ',num2str(MaxValue)])
% %     set(gca,'LooseInset',get(gca,'TightInset'));
    iptsetpref('ImshowBorder','tight');
    saveas(gcf,[ResultFolder,separation,Property,'.fig']);
    saveas(gcf,[ResultFolder,separation,Property,'.jpg']);
    saveas(gcf,[ResultFolder,separation,Property,'.eps'],'epsc');
    close all
end
    





end

function [ResultPath]=ParaSub2Path(SubArray,NameArray,ValueArray,PropertyName,RootFolder)

% decide the current operation system and the separation term
CurrentSystem=computer;
if isempty(strfind( CurrentSystem,'WIN'))
    separation='/';
else
    separation='\';
end


DimLength=length(SubArray);
Str=[RootFolder];
for i=1:DimLength
    Str=[Str,separation,NameArray{i},'_',num2str(ValueArray{i}(SubArray{i}))];
end
ResultPath=[Str,separation,PropertyName,'.mat'];
end