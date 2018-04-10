function [ LabelInf ] = ExtractGroupInformation( Mask, Segment )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%   this function is used to extract the group label information under the
%   mask.
%
%   ZhuoSun 20160621

Mask    =squeeze(Mask);
Segment =squeeze(Segment);
MaskLinear=Mask(:);
SegmentLinear=Segment(:);

LabelInf=SegmentLinear(MaskLinear==1);


end

