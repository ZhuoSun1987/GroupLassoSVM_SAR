function [ ] = PlotParaInflenceFigure( Table,AxisValues,OutFigureList )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%   Table is a ND matrix
%   AxisValues is from function [ Result,AxisValues] =
%   ParaGridSearchTrainTest(....)
%
%   due to in many case, some dimension of the Table has only one element,
%   so we do not plot it. Also, we can only show cases that has no more
%   than 2 dim non-residual dimension
%
%   z.sun  20170926


Size0=size(Table);
NonResDimIndex=find(Size0>1);
N=length(NonResDimIndex);
switch N
    case 1
        Value1=AxisValues{NonResDimIndex(1)};
        Data=squeeze(Table);
        Y=reshape(Data,[1,length(Data)]);
        X=1:length(Y);
        plot(X,Y,'--gs',...
            'LineWidth',2,...
            'MarkerSize',10,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor',[0.5,0.5,0.5]);
        set(gca,'XTick',X,'XTickLabel',Value1,'XTickLabelRotation',45);
        
    case 2
        ValueY=AxisValues{NonResDimIndex(1)};
        ValueX=AxisValues{NonResDimIndex(2)};
        Data=squeeze(Table);
        X=1:size(Data,2);
        Y=1:size(Data,1);
        imagesc(Data);
        set(gca,'XTick',X,'XTickLabel',ValueX,'XTickLabelRotation',45);
        set(gca,'YTick',X,'YTickLabel',ValueY,'YTickLabelRotation',45);
    otherwise
        error('Currently, we only select to plot 1D or 2D ')
end

%% save the figure
if nargin>2
   FigNum=length(OutFigureList);
   for i=1:FigNum
       FigPath=OutFigureList{i};
       [pathstr,name,ext]=fileparts(FigPath);
       if ~exist(pathstr,'dir')
           mkdir(pathstr);
       end
       if strcmp(ext,'.eps')
           saveas(gcf,FigPath,'epsc');
       else
           saveas(gcf,FigPath);
       end
   end
end

end

