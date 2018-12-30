from scipy import misc
import os as os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as color_ope
import matplotlib.image as mpimg
import glob as glob
import colorsys as csys
import skimage.filters as filters_ope
import skimage.morphology as morp_ope
from  skimage.exposure import equalize_hist
from scipy import ndimage, misc


def isSceneChange( prevFrame, curFrame, H, W):
    ref = np.zeros( [H, W], dtype=np.float32)

    #chck: Control parameter to ensure that whether scene changed or not
    #chck=0 scene not changed, chck=1 then a scene changing occured
    chck=0;

    #compute histogram equalization for current frame
    curFrame2 = equalize_hist(curFrame)
   
    #compute histogram equalization for previous frame
    prevFrame2 = equalize_hist(prevFrame)

    #compute frame's edge
    th = 10/255
    E1 = filters_ope.edges.sobel( curFrame2)>th
    E2 = filters_ope.edges.sobel( prevFrame2)>th

    E1 = np.float32(E1)
    E2 = np.float32(E2)    

    curFrame2 = np.float32(curFrame2)
    prevFrame2 = np.float32(prevFrame2)
    #MAED refers to mean absolute of edge difference
    MAED = np.abs(E1-E2);
    MAED = np.sum(MAED)/(H*W);
    #print('MAED', MAED)
    if MAED<0.1:
        chck=0
        return chck, ref
    
    #MAFD indicates the mean absolute of frame difference
    #imgplot = plt.imshow( curFrame2)
    #plt.show()
    curFrame2 = 255*curFrame2
    prevFrame2 = 255*prevFrame2
    MAFD = np.abs(curFrame2-prevFrame2)
    MAFD = np.sum(MAFD)/(H*W)
    #print('MAFD', MAFD)
    if MAFD<30:
        chck=0
        return chck, ref

    #compute frame's variance
    FV1 = np.var(curFrame)
    FV2 = np.var(prevFrame)
    
    #print('FV1', FV1)
    #print('FV2', FV2)
    #ADFV denotes the absolute difference of frame variance. 
    ADFV = np.abs(np.subtract(FV1, FV2));
    #print('ADFV', ADFV)
    if ADFV<2:
        chck=0
        return chck, ref

    chck = 1
    ref = curFrame
    return chck, ref




##test code of isSceneChanged
#f1 = os.path.join('in000002.jpg')
#Aimage = misc.imread(f1)
##Aimage = rgb2gray(Aimage) 
#HSV1 = color_ope.rgb_to_hsv(Aimage)

#f2 = os.path.join('in000355.jpg')
#Bimage = misc.imread(f2)
##Bimage = rgb2gray(Bimage)
#HSV2 = color_ope.rgb_to_hsv(Bimage)

#Aimage = HSV1[:,:,2]
#Bimage = HSV2[:,:,2]

#[H,W] = Aimage.shape;

#imgplot = plt.imshow( Aimage)
#plt.show()

#chck = 0;
#[chck, ref] =  isSceneChange( Aimage, Bimage, H, W)
#print(chck)

#imgplot = plt.imshow( ref )
#plt.show()
