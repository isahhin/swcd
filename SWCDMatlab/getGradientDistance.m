function [Ap_color] = getGradientDistance(Aimage, Bimage)

% zero padding for 2D integration
PAD = 10;
Aimage = padarray(Aimage,[PAD PAD],0,'both');
Bimage = padarray(Bimage,[PAD PAD],0,'both');
[H,W,CH] = size(Aimage);

% disp('Finding cross diffusion tensor')

sigma = 1.5; %gaussian smoothing parameter 
ss = floor(6*sigma); %gaussian window size
if(ss<=3)
    ss = 3;
end
% gaussian kernel for smoothing
ww = fspecial('gaussian',ss,sigma);


% Tensor analysis
[~,~,~,~,EigD_2,X1,X2,Y1,Y2] = TensorAnalysis(Bimage,ww);
[~,~,~,~,EigD_2_2,~,~,~,~] = TensorAnalysis(Aimage,ww);

clear T11_2 T12_2 T22_2 X1_2 X2_2 Y1_2 Y2_2 T11 T12 T22

% L1 = mu2 , L2 = mu1 of paper
% initially set to 1,1 to retain all edges in image A
L1 = ones(H,W);
L2 = ones(H,W);


% if there is an edge in Bimage, set mu1 = 0. mu2 = 1 to remove that edge
% from image A
idx = EigD_2 > 100;
L2(idx) = 0;
clear idx

% if both A and B are homogeneous
idx = EigD_2_2 < 100;
L1(idx) = 0;
L2(idx) = 0;
clear idx

% Get cross diffusion tensor terms
D11 = L1.*(X1.^2) + L2.*(Y1.^2);
D12 = L1.*(X1.*X2) + L2.*(Y1.*Y2);
D22 = L1.*(X2.^2) + L2.*(Y2.^2);

clear X1 X2 Y1 Y2

%Calculate Gradients
[gx,gy] = imgradientxy(Aimage,'sobel' );

%Apply cross diffusion tensor termsto gradients
gx1 = (D11.*gx + D12.*gy);
gy1 = (D12.*gx + D22.*gy);
Ap_color1= sqrt((gx1).^2 + (gy1).^2);
clear gx gy gx1 gy1 

%Calculate Gradients
[gx,gy] = imgradientxy(Bimage,'sobel' );

%Apply cross diffusion tensor terms to gradients
gx1 = (D11.*gx + D12.*gy);
gy1 = (D12.*gx + D22.*gy);
Ap_color2= sqrt((gx1).^2 + (gy1).^2);
clear gx gy gx1 gy1 
Ap_color=Ap_color1-Ap_color2;

% remove zero padding
Ap_color = Ap_color(PAD+1:end-PAD,PAD+1:end-PAD,:);


end
