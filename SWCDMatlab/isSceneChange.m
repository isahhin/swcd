function [ chck, ref] = isSceneChange( prevFrame, curFrame, H, W )
ref = zeros(H,W);

%chck: Control parameter to ensure that whether scene changed or not
%chck=0 scene not changed, chck=1 then a scene changing occured
chck=0;

%compute histogram equalization for current frame
curFrame2 = histeq(uint8(curFrame));
curFrame2 = double(curFrame2);

%compute histogram equalization for previous frame
prevFrame2 = histeq(uint8(prevFrame));
prevFrame2 = double(prevFrame2);

%compute frame's edge
E1 = edge( curFrame2,'sobel', 10);
E2 = edge(prevFrame2,'sobel', 10);
E1 = double(E1);
E2 = double(E2);

%MAED refers to mean absolute of edge difference
MAED=abs(E1-E2);
MAED=sum(MAED(:))/(H*W);
if MAED<0.1
    chck=0;
    return;
end

%MAFD indicates the mean absolute of frame difference 
MAFD=abs(curFrame2-prevFrame2);
MAFD=sum(MAFD(:));
MAFD=MAFD/(H*W);
if MAFD<30
    chck=0;
    return;
end

%compute frame's variance
FV1=var(curFrame2(:));
FV2=var(prevFrame2(:));

%ADFV denotes the absolute difference of frame variance. 
ADFV = abs(FV1-FV2);

if ADFV<2
    chck=0;
    return;
end

chck=1;

ref = curFrame;


end

