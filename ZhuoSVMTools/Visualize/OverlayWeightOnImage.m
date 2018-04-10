function [  ] = OverlayWeightOnImage( Image,WeightMap, WeightLimit,TransparentList,WeightColorMap,ColorMapRange,Mask0,SavePath,bins )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%
%   WeightMap and Image are 2D image of the same size
%   WeightLimit is a [K,2] matrix, each 
%   
%   if give the SavePath, save it as .png, .eps (epsc), fig
%
%   WeightColorMap is a [K,1] cell array or [1,1] cell array that define
%   the colormap of each Weight Limit regions
%
%   Zhuo Sun  20160804



Size1=size(Image);
Size2=size(WeightMap);
if ~isequal(Size1,Size2)
    error('Image and Weight should be the same size')
end

%% 
if nargin<9 | isempty(bins);
    bins=size(colormap,1);
end

%% the relation between teh given WeightLimit and the WeightColorMap and the TransparentList
K1=size(WeightLimit,1);
K2=length(WeightColorMap);
K3=length(TransparentList);

if K2==1
    WeightColorMap=repmat(WeightColorMap,1,K1);
else
    if K2 ~=K1
        WeightColorMap=repmat(WeightColorMap(1),1,K1);
    end
end
if K3==1
    TransparentList=repmat(TransparentList,1,K1);
else
    if K2 ~=K1
        TransparentList=repmat(TransparentList(1),1,K1);
    end
end


%% Deal with the gray scale image



%% the overall max and min in all the WeightLimit
MaxAll=max(WeightLimit(:));
MinAll=min(WeightLimit(:));


%% make the mask (which is shown for the WeightMap )based on the WeightLimit
MaskAll=zeros(Size1);
for i=1:K1
    Max=max(WeightLimit(i,:));
    Min=min(WeightLimit(i,:));
    MaskAll=MaskAll+double(WeightMap>=Min  &  WeightMap<=Max).*Mask0;
end
if K2~=K1 | K1==1
    % normalize the grayscale image to make a gray RGB image
    imshoMin=min(Image(:));
    Max=max(Image(:));
    Min=min(Image(:));
    GrayRGB=ind2rgb(int16(Image),gray);
    imagesc(WeightMap)
    eval(['colormap ', WeightColorMap{1}])
    colorbar
    cbh=colorbar;   
    hold on
    h=imshow(GrayRGB,[])   
    hold off
    AlphaMap=(1-MaskAll)*TransparentList(1);
    set(h,'AlphaData',AlphaMap)  
    caxis([MinAll,MaxAll])
    
    
    
% %     %% construct the overall cmap
% %     cmap=[gray(bins);GenerateColorMap(WeightColorMap{1},bins)];
% %     CminGray=min(Image(:));
% %     CmaxGray=max(Image(:));
% %     CminWeight=MinAll;
% %     CmaxWeight=MaxAll;
% %     %% the idx for gray image and the weight image
% %     idx_Gray  =min(bins,round((bins-1)*(Image-CminGray)/(CmaxGray-CminGray))+1);
% %     idx_Weight=min(bins,round((bins-1)*(WeightMap-CminWeight)/(CmaxWeight-CminWeight))+1)+bins;
% %     %% combine the gray image idx and weight image idx 
% %     idx=idx_Gray.*(1-MaskAll)+idx_Weight.*MaskAll;
% %     %% create the new image data
% %     Im0=Image.*(1-MaskAll)+WeightMap.*MaskAll;
% %     
% %     %% show the image based on the CData
% %     figure;
% %     h=imshow(Image,[]);
% % % %     set(h,'CData',idx);
% % % %     colormap(cmap)
% %     freezeColors(h)
% %     %% show the weight map
% %     hold on 
% %     h1=imshow(MaskAll.*WeightMap,[])
% %     colormap(WeightColorMap{1})
% %     set(h1, 'AlphaData', MaskAll*TransparentList(1));
% %     
% %     %% show the color bar
% %     caxis([Min, Max])
% %     h2=colorbar;
    
    
else
    % normalize the grayscale image to make a gray RGB image
    imshoMin=min(Image(:));
    Max=max(Image(:));
    Min=min(Image(:));
    GrayRGB=ind2rgb(int16(Image),gray);
    imagesc(WeightMap)
    eval(['colormap ', WeightColorMap{1}])
    colorbar
    cbh=colorbar;   
    hold on
    h=imshow(GrayRGB,[])   
    hold off
    AlphaMap=(1-MaskAll)*TransparentList(1);
    set(h,'AlphaData',AlphaMap)  
    caxis([MinAll,MaxAll])    
% %     for i=1:K1 
% %         Max=max(WeightLimit(i,:));
% %         Min=min(WeightLimit(i,:));
% %         Mask=double(WeightMap>=Min  &  WeightMap<=Max);
% %         %% compute the AlphaIm
% %         AlphaIm=MaskAll*TransparentList(i);
% %         hold on
% %         
% %     end
        
end

    







%% save the result image
if nargin==7
    %set(gca,'position',[0 0 1 1],'units','normalized')
    set(gca,'LooseInset',get(gca,'TightInset'));
    saveas(gcf,[SavePath,'.png'])
    saveas(gcf,[SavePath,'.fig'])
    saveas(gcf,[SavePath,'.eps'],'epsc')
end



end


function [Result]=GenerateColorMap(MapName,bins)
if nargin<2
    bins=64;
else
    bins=round(abs(bins));
end

switch MapName
    case 'jet'
        Result=colormap(jet(bins));
    case 'hsv'
        Result=colormap(hsv(bins));
    case 'hot'
        Result=colormap(hot(bins));
    case 'cool'
        Result=colormap(cool(bins));
    case 'spring'
        Result=colormap(spring(bins));
    case 'autumn'
        Result=colormap(autumn(bins));
    case 'winter'
        Result=colormap(winter(bins));
    case 'gray'
        Result=colormap(gray(bins));
    case 'bone'
        Result=colormap(bone(bins));
    case 'copper'
        Result=colormap(copper(bins));
    case 'pink'
        Result=colormap(pink(bins));
    case 'lines'
        Result=colormap(lines(bins));
        
    otherwise
        error(['The given input colormap <',MapName, '> is not defined'])
end
end


