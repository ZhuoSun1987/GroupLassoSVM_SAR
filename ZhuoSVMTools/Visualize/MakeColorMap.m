function [  ] = MakeColorMap( ColorMapNameStr,bins )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


switch ColorMapNameStr
    case 'jet'
        colormap(jet(bins))
    case 'hsv'
        colormap(hsv(bins))
    case 'hot'
        colormap(hot(bins))
    case 'cool'
        colormap(cool(bins))
    case 'spring'
        colormap(spring(bins))
    case 'summer'
        colormap(summer(bins))
    case 'autumn'
        colormap(autumn(bins))
    case 'winter'
        colormap(winter(bins))
    case 'gray'
        colormap(gray(bins))
    case 'bone'
        colormap(bone(bins))
    case 'copper'
        colormap(copper(bins))
    case 'pink'
        colormap(pink(bins))
    case 'lines'
        colormap(lines(bins))    
    otherwise
        error(['the input colormap=> ',ColorMapNameStr,' is not defined'])
end
        
        
        
        
        
        
        
        
        
        
        
        
end

