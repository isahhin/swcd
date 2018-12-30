#========================================================================================================================
# Python code for SWCD 2018 paper
# Copyright: Sahin Isik, 2018
#
# link: https://github.com/isahhin/swcd
# It is restricted to use for personal and scientific research purpose only
# No Warranty
#       (1) "As-Is". Unless otherwise listed in this agreement, this SOFTWARE PRODUCT is provided "as is," with all faults, defects, bugs, and errors.
#       (2 )No Warranty. Unless otherwise listed in this agreement.
# Please cite the following paper when used this code:
#   1.  S. Isik, K. Ozkan, S. Gunal, Omer N. Gerek, 
#   "SWCD: A sliding window and self-regulated learning based background updating method for change detection in videos", 
#   Journal Pattern Recognition, 2018
#========================================================================================================================

import os
import shutil
import subprocess
import sys
from scipy import misc
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as color_ope
import matplotlib.image as mpimg
import glob as glob
import colorsys as csys
import skimage.filters as filters_ope
import skimage.morphology as morp_ope
from  SceneChange import isSceneChange
from Distance import *
from GetsParameters import getsParameters_best

def main(datasetPath, binaryRootPath):    
  
    processFolder(datasetPath, binaryRootPath)

    if not os.path.exists(binaryRootPath):
         os.mkdir(binaryRootPath)
   
def getDirectories(path):
        return [file for file in os.listdir(path)
            if os.path.isdir(os.path.join(path, file))]
			
def processFolder(datasetPath, binaryRootPath):

    for category in getDirectories(datasetPath):
        
        if (category != 'baseline'):
		        continue
		
		
        categoryPath = os.path.join(datasetPath, category)
       
        if not os.path.exists(os.path.join(binaryRootPath, category)):
            os.mkdir(os.path.join(binaryRootPath, category))
        
        for video in getDirectories(categoryPath):

            if (video != 'office'):
                continue

               
            videoPath = os.path.join(categoryPath, video)
            print(videoPath)
            binaryPath = os.path.join(binaryRootPath, category, video)
            if not os.path.exists(binaryPath):
                os.mkdir(binaryPath)
                print(binaryPath)
                
            fileNameTest = os.path.join(videoPath, 'input', 'in000300.jpg')
            imgTest = misc.imread(fileNameTest)
            [H,W,ch] = imgTest.shape
            #W = imgTest.shape[1]
            #ch = imgTest.shape[2]
            #print(H,W,ch)


            #gets best parameters 
            [ R_lower, Med_P, R_scale] =  getsParameters_best(video);
            #R_lower = 35;
            #Med_P = 5;
            #R_scale = 0.1;

            N=35 #no of background frames

            # initialization of background set with first N frames
            Backgrounds = np.zeros( [H, W, N], dtype=np.float32)
     
            #allFiles = os.listdir(os.path.join(videoPath, 'input', '*.jpg'))
            allFiles = glob.glob(os.path.join(videoPath, 'input', '*.jpg'))
            for i in range(0,N):
                filename =  os.path.join(videoPath,'input',allFiles[i] )               
                frame=mpimg.imread(filename)    
                frame = color_ope.rgb_to_hsv(frame )
                frame=np.absolute(frame)         
                curFrame=frame[:,:,2]
                #[H,W] = curFrame.shape;                   
                Backgrounds[:,:,i] = np.float32(curFrame)
               
            T_lower = 2            # lower bound of T
            T_upper = 100000000    # upper bound of T
            R_incdec = 0.01        # steering control to maintain threshold
    
       
            R = R_lower*np.ones( [H, W], dtype=np.float32) # threshold parameter
            T = T_lower*np.ones( [H, W], dtype=np.float32)  # learning parameter
            v  = np.zeros( [H, W], dtype=np.float32)        # noise container parameter
            Xt  = np.zeros( [H, W], dtype=np.float32)

            Dmin = np.zeros( [H, W], dtype=np.float32)       # dynamic controller parameter, dmin 
            DminNorm = np.zeros( [H, W], dtype=np.float32)   # normalized version of dmin 
            meanDist = np.zeros( [H, W], dtype=np.float32)   # mean of historical distances 

            BW = np.zeros( [H, W], dtype=np.float32)
            BWprev = np.zeros( [H, W], dtype=np.float32)     #previous Binary image
            prevFrame = np.zeros( [H, W], dtype=np.float32)  #previousFrame
             

            #chck: Control parameter to ensure that whether scene changed or not
            #chck=0 scene not changed, otherwise changed    
            chck = 0  
            idx = 0 # index for updating background frames sequentially

            #post processing parameters for opening and closing 
            el1=morp_ope.diamond(1);
            el2=morp_ope.diamond(10);
            firstFrame = 1
            i = 0
            for file in allFiles:
                i = i + 1
                filename =  os.path.join(videoPath,'input',file)  
                #filename =  os.path.join(videoPath,'input\in000680.jpg') 
                [name, ext] = os.path.splitext(os.path.basename(filename))
                print(filename)
                frame=mpimg.imread(filename)    
                frame = color_ope.rgb_to_hsv(frame )
                frame=np.absolute(frame)         
                curFrame=frame[:,:,2]
                #[H,W] = curFrame.shape;
				
				#compute gradient distance with Tensor Analysis
                MB = np.mean(Backgrounds, axis=2)
                Gmag = getGradientDistance( curFrame, MB)
                Gmag = np.absolute(Gmag) 
  
                #get segmented image
                [BW, minDist] = getDist( Backgrounds, curFrame, Gmag, R, H, W, N)  

                BW = filters_ope.median(BW, morp_ope.square(Med_P))   
                BW = morp_ope.remove_small_objects(BW, 10, connectivity=8)
                BW = morp_ope.binary_opening(BW,el1)  
                BW = morp_ope.binary_closing(BW,el2)   
                BW = 1.0*BW
                BW1 = (BW)*255

                BW = np.array(BW)

                filename2 =  os.path.join(binaryPath, 'b'+name+'.PNG')
                #print(filename2)                 
                #imgplot = plt.imshow( BW1)
                #plt.show()
                #return
                misc.imsave(filename2, BW1)

                #update background frames as consecutive order, with sliding window way             
                p = 1/T
                Backgrounds[:,:,idx] = (1-p)*Backgrounds[:,:,idx] + (p)*curFrame

                idx=idx+1       
                if idx==N:
                   idx=0
                

                #update dynamic controller parameters, dmin and normalized dmin in paper       
                if i==firstFrame:
                    meanDist = minDist
                else:
                    meanDist = ((5-1)*meanDist+minDist)/5
                
                Dmin = meanDist*R_scale
                DminNorm = Dmin/(Dmin+1).max() # normalized version of dmin
                
                # monitoring bilinking pixels
                v[Xt==1] = v[Xt==1]+1
                v[Xt==0] = v[Xt==0]-0.1
                v[v<0] = 0

                #imgplot = plt.imshow( v )
                #plt.show()
     
                # update threshold parameter              
                R[R< Dmin]     = R[R< Dmin]+R_incdec*R[R<Dmin]
                R[R>=Dmin]     = R[R>=Dmin]-R_incdec*R[R>=Dmin]
                R[R<=R_lower]  = R_lower
                #imgplot = plt.imshow( R )
                #plt.show()

                # update learning parameter
                T[BW==1]      = T[BW==1]+1/(v[BW==1]*DminNorm[BW==1]+1)
                T[BW==0]      = T[BW==0]-(v[BW==0]+0.1)/(DminNorm[BW==0]+1)
                T[T<=T_lower] = T_lower  
                #imgplot = plt.imshow( T )
                #plt.show()

                #initialization of binary segmented previous frame and old previos frame
                if i==firstFrame:
                    BWprev=BW
                    prevFrame=curFrame
                else:
                    #catching blinking pixels to update v
                    Xt=1.0*np.logical_xor(BW, BWprev)
                    Xt[ np.where( (Xt==1) & (BW==1) ) ]=0


                    BWprev = BW
                
                if  (category == 'PTZ'): 
                    #check whether scene changed or not
                    if i>1:
                       [ chck, ref] = isSceneChange( prevFrame, curFrame, H, W)

                    #scene changed detected, then replace previous frame with ref
                    if chck==1:
                       Backgrounds[:,:,idx] = ref
                       prevFrame = ref
                       chck=0
                

if __name__ == "__main__":
    datasetPath = "D:/DATASETS/dataset2014/dataset";
    binaryRootPath = "D:/DATASETS/dataset2014/results/SWCD_2018_08_10";

    #datasetPath = "E:/School/DATASETS/BackgroundSubtraction/dataset2014/dataset";
    #binaryRootPath = "E:/School/DATASETS/BackgroundSubtraction/dataset2014/results/SWCD_2018_08_10";

    main(datasetPath, binaryRootPath)
