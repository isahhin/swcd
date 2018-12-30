import numpy as np;
from scipy.ndimage.filters import gaussian_filter
from scipy.ndimage.filters import convolve
import matplotlib.pyplot as plt
from scipy import ndimage, misc
import os
from numpy import linalg as LA
import matplotlib.colors as color_ope
import colorsys
from scipy import signal

def matlab_style_gauss2D(shape=(3,3),sigma=0.5):
    """
    2D gaussian mask - should give the same result as MATLAB's
    fspecial('gaussian',[shape],[sigma])
    """
    m,n = [(ss-1.)/2. for ss in shape]
    y,x = np.ogrid[-m:m+1,-n:n+1]
    h = np.exp( -(x*x + y*y) / (2.*sigma*sigma) )
    h[ h < np.finfo(h.dtype).eps*h.max() ] = 0
    sumh = h.sum()
    if sumh != 0:
        h /= sumh
    return h

def rgb2gray(rgb):
    r, g, b = rgb[:,:,0], rgb[:,:,1], rgb[:,:,2]
    gray = 0.2989 * r + 0.5870 * g + 0.1140 * b

    return gray

def ind2sub(array_shape, ind):
    ind[ind < 0] = -1
    ind[ind >= array_shape[0]*array_shape[1]] = -1
    rows = (ind.astype('int') / array_shape[1])
    cols = ind # array_shape[1]
    return (rows, cols)

def tensor_analysis(im,ww):
#=========================================================
# # Copyright: Amit Agrawal, 2006
# http://www.umiacs.umd.edu/~aagrawal/
# Permitted for personal use and research purpose only
# Refer to the following citation:
#   1.  A. Agrawal, R. Raskar and R. Chellappa, "Edge Suppression by Gradient Field Transformation Using Cross-Projection Tensors", 
#   IEEE Conference on Computer Vision and Pattern Recognition (CVPR) 2006
#   2.  A. Agrawal,  R. Raskar,  Shree K. Nayar &  Y. Li,  "Removing Photography Artifacts using Gradient Projection and 
#       Flash-Exposure Sampling",  ACM Transactions on Graphics (Proceedings of  SIGGRAPH) 2005  
#=========================================================
       
    [H,W] = im.shape

    T11 = np.zeros( [H, W], dtype=np.float32)
    T12 = np.zeros( [H, W], dtype=np.float32)
    T22 = np.zeros( [H, W], dtype=np.float32)
 
    gx = ndimage.sobel(im, axis=1);
    gy = ndimage.sobel(im, axis=0);

    #imgplot = plt.imshow( np.uint8(gx))
    #plt.show()
    #imgplot = plt.imshow( np.uint8(gy))
    #plt.show()


    T11 = T11 + np.power(gx, 2) 
    T22 = T22 + np.power(gy, 2) 
    T12 = T12 + np.multiply(gx, gy)

    T11 = signal.convolve2d(T11, np.rot90(ww,2), mode='valid')
    T22 = signal.convolve2d(T22, np.rot90(ww,2), mode='valid')
    T12 = signal.convolve2d(T12, np.rot90(ww,2), mode='valid')
    
    #imgplot = plt.imshow( T11)
    #plt.show()

    T11 = np.array(T11)
    T22 = np.array(T22)
    T12 = np.array(T12)

    # find eigen values
    # 1 is lower , 2 is higher
    ImagPart = np.sqrt(np.power( T11 - T22, 2) + 4*(T12*T12) );
    EigD_1 = (T22 + T11 - ImagPart)/2.0;
    EigD_2 = (T22 + T11 + ImagPart)/2.0;


    # find eigen-vector
    # lower eigen value v(:,1) EigD_1
    X1 = np.ones( [H, W], dtype=np.float32)
    X2 = np.zeros( [H, W], dtype=np.float32)

    EigD_1 = np.array(EigD_1)
    EigD_2 = np.array(EigD_2)

    TH_LOW = 0.0
    idx = np.where((np.abs(T12)>TH_LOW))
    X2[idx] = -np.divide((T11[idx]-EigD_1[idx]), T12[idx])  

    #imgplot = plt.imshow( (np.abs(T12)<=TH_LOW))
    #plt.show()

    idx = np.where( (np.abs(T12) <= TH_LOW) & ( (T11 > 0) | (T22 > 0) ) )
    #idx = (  (np.abs(T12) <= TH_LOW) & ( (T11 > 0) | (T22 > 0) ) ).nonzero()
    
    nn = len(idx[0]);
    #print(nn)

    
    for kk in  range(nn):
  
        ii = idx[0][kk]
        jj = idx[1][kk]       
       
        Wmat = [ [ T11[ii,jj], T12[ii,jj] ], [ T12[ii,jj], T22[ii,jj] ] ]
        v, d = LA.eig(Wmat)
        X1[ii][jj] = v[0];
        X2[ii][jj] = v[1];

    nn = np.sqrt(np.power(X1, 2) + np.power(X2, 2))
    X1 = X1/nn;
    X2 = X2/nn;
    del idx

    Y1 = -X2;
    Y2 = X1;
    #print(im.shape)    
    #print(T11.shape)
    return EigD_2, X1, X2, Y1, Y2

##this the test code
#fileNameTest = os.path.join('black.png')
#im = misc.imread(fileNameTest)
#im = rgb2gray(im)    

#ss=3
#sigma = 1.5
#ww = matlab_style_gauss2D((ss,ss),sigma)

#[EigD_2, X1, X2, Y1, Y2] = tensor_analysis(im, ww)

#imgplot = plt.imshow( (X1))
#plt.show()

#imgplot = plt.imshow( (X2))
#plt.show()

#imgplot = plt.imshow( (Y1))
#plt.show()
#imgplot = plt.imshow( (Y2))
#plt.show()
