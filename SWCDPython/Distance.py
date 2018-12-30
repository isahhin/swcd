import numpy as np;
from scipy.ndimage.filters import gaussian_filter
from TensorAnalysis import tensor_analysis
import matplotlib.colors as color_ope
import matplotlib.pyplot as plt
from TensorAnalysis import matlab_style_gauss2D
import os as os
from scipy import ndimage, misc
import colorsys 
import math



def rgb2gray(rgb):
    r, g, b = rgb[:,:,0], rgb[:,:,1], rgb[:,:,2]
    gray = 0.2989 * r + 0.5870 * g + 0.1140 * b

    return gray

def applyCrossGradients(im, D11, D12, D22):
    #Apply cross diffusion tensor termsto gradients
    #Calculate Gradients
    gx = ndimage.sobel(im, axis=1);
    gy = ndimage.sobel(im, axis=0);
    gx1 = (D11*gx + D12*gy)
    gy1 = (D12*gx + D22*gy)
    Ap_color= np.sqrt( np.power(gx1,2) + np.power(gy1,2))

    return Ap_color

# Inputs : 
#         Aimage is current frame 
#         Bimage is previous frame
# Outputs: 
#         Ap_color is gradient distance after applying cross projection tensors 
def getGradientDistance( Aimage, Bimage):
    PAD = 10;
    Aimage = np.pad(Aimage,(PAD, PAD),'edge')
    Bimage = np.pad(Bimage,(PAD, PAD),'edge')
    [H,W] = Bimage.shape

    sigma = 1.5  #gaussian smoothing parameter 
    ss = np.floor(6*sigma) #gaussian window size
    if(ss<=3):
       ss = 3

    ww = matlab_style_gauss2D((ss,ss),sigma)
    [EigD_2, X1, X2, Y1, Y2] = tensor_analysis(Bimage,ww)
    [EigD_2_2, X1_2, X2_2, Y1_2, Y2_2] = tensor_analysis(Aimage,ww)

    del X1_2, X2_2, Y1_2, Y2_2

    # L1 = mu2 , L2 = mu1 of paper
    # initially set to 1,1 to retain all edges in image A
    L1 = np.ones( [H, W], dtype=np.float32)
    L2 = np.ones( [H, W], dtype=np.float32)

    # if there is an edge in Bimage, set mu1 = 0. mu2 = 1 to remove that edge
    # from image A
    idx = np.where(EigD_2 > 100)
    L2[idx] = 0
    del idx

    # if both A and B are homogeneous
    idx = np.where( EigD_2_2 < 100 ) 
    L1[idx] = 0
    L2[idx] = 0
    del idx

    L1 = np.array(L1)
    L2 = np.array(L2)

    # Get cross diffusion tensor terms
    D11 = L1*np.power(X1,2) + L2*np.power(Y1, 2)
    D12 = L1*np.multiply(X1,X2) +  L2*np.multiply(Y1,Y2)
    D22 = L1*np.power(X2,2) + L2*np.power(Y2, 2)


    
    Ap_color1 = applyCrossGradients(Aimage, D11, D12, D22)
    Ap_color2 = applyCrossGradients(Bimage, D11, D12, D22)
    Ap_color = np.subtract(Ap_color1, Ap_color2)
    Ap_color = Ap_color[PAD:-1-PAD+1, PAD:-1-PAD+1 ]

    return Ap_color;

# Inputs : 
#         Backgrounds is background lists keeps N historical backgrounds  
#         IM is processed image
#         Gmag is gradient magnitude computed with tensor analysis
#         R is threshold map
#         H is height of IM
#         W is width of IM
#         N is count background images
# Outputs: 
#         BW is binary segmented image
#         minDist is minimum distance called as Dmin in paper 	
def getDist( Backgrounds, IM, Gmag, R, H, W, N):
    sumBW = np.zeros( [H, W], dtype=np.float32)
    minDist=1000*np.ones( [H, W], dtype=np.float32);

    for j in range(N):
        dist=( np.abs( np.subtract(Backgrounds[:,:,j],IM) ) + Gmag );
        minDist[np.where(dist<minDist)] = dist[np.where(dist<minDist)];

        BW = 1.0*np.logical_and( (dist>=R) , (np.abs( np.subtract(Backgrounds[:,:,j],IM)) >5 )  );
        #print(BW.shape)
        sumBW=sumBW+BW;
   
    #imgplot = plt.imshow( sumBW)
    #plt.show()
    BW = 1.0*(sumBW>N-1)


    return BW, minDist;



##test code of getGradientDistance
#f1 = os.path.join('in000001.jpg')
#Aimage = misc.imread(f1)
##Aimage = rgb2gray(Aimage) 
#HSV1 = color_ope.rgb_to_hsv(Aimage)

#f2 = os.path.join('in001000.jpg')
#Bimage = misc.imread(f2)
##Bimage = rgb2gray(Bimage)
#HSV2 = color_ope.rgb_to_hsv(Bimage)

#Aimage = HSV1[:,:,2]
#Bimage = HSV2[:,:,2]

#imgplot = plt.imshow( Bimage)
#plt.show()


#Ap_color =  getGradientDistance( Aimage, Bimage)

#print(Ap_color.shape)
#print(Aimage.shape)
#imgplot = plt.imshow( Ap_color)
#plt.show()

