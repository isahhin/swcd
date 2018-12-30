
function [T11,T12,T22,EigD_1,EigD_2,X1,X2,Y1,Y2] = tensor_analysis(im,ww)

%disp('Doing Tensor analysis')

[H,W,CH] = size(im);

T11 = zeros(H,W);
T12 = zeros(H,W);
T22 = zeros(H,W);


%[gx,gy,gxx,gxy,gyy] = CalculateGradients(im(:,:,channel),0);
[gx,gy] = imgradientxy(im,'sobel' );
T11 = T11 + gx.^2;
T22 = T22 + gy.^2;
T12 = T12 + gx.*gy;

T11 = filter2(ww,T11,'same');
T22 = filter2(ww,T22,'same');
T12 = filter2(ww,T12,'same');



% find eignen values
% 1 is lower , 2 is higher
ImagPart = sqrt((T11 - T22).^2 + 4*(T12.^2));
EigD_1 = (T22 + T11 - ImagPart)/2.0;
EigD_2 = (T22 + T11 + ImagPart)/2.0;


% find eigen-vector
% lower eigen value v(:,1) EigD_1
X1 = ones(H,W);
X2 = zeros(H,W);

TH_LOW = 0;
idx = find(abs(T12) > TH_LOW);
X2(idx) = -(T11(idx)-EigD_1(idx))./T12(idx);
idx = find(abs(T12) <= TH_LOW & (T11 >0 | T22 >0));

nn = size(idx,1);
for kk = 1:nn
    idx_current = idx(kk);
    [ii,jj] = ind2sub([H W],idx_current);
    Wmat = [T11(ii,jj) T12(ii,jj);T12(ii,jj) T22(ii,jj);];
    [v,d] = eig(Wmat);
    X1(idx_current) = v(1,1);
    X2(idx_current) = v(2,1);
end
nn = sqrt(X1.^2 + X2.^2);
X1 = X1./nn;
X2 = X2./nn;
clear idx

Y1 = -X2;
Y2 = X1;

%disp('Done...')


