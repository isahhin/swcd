%========================================================================================================================
% Matlab code for SWCD 2018 paper
% Copyright: Sahin Isik, 2018
%
% link: https://github.com/isahhin/swcd
% It is restricted to use for personal, educational scientific research purpose only
# for commercial use please contact author
% No Warranty
%       (1) "As-Is". Unless otherwise listed in this agreement, this SOFTWARE PRODUCT is provided "as is," with all faults, defects, bugs, and errors.
%       (2 )No Warranty. Unless otherwise listed in this agreement.
# Please cite the following paper when used this code:
#   1.  Işık, Şahin, Kemal Özkan, Serkan Günal, and Ömer Nezih Gerek. 
#   "SWCD: a sliding window and self-regulated learning-based background updating method for change detection in videos." 
#   Journal of Electronic Imaging 27, no. 2 (2018): 023002.
#========================================================================================================================


clear
clc
close all
addpath('MatlabCodeStats2014');

warning('off','all')
iptsetpref('ImshowBorder','tight')

datasetPath    =  'B:\DATASETS\dataset2014\dataset';
binaryRootPath =  'B:\DATASETS\dataset2014\results\SWCD_N35_Fnew';


categoryList = filesys('getFolders', datasetPath);
for strCategory = categoryList,

   category = strCategory{1};
    

%     if  strcmp(category, 'badWeather') == 1 
%         
%     else
%         continue;
%     end

    categoryPath = fullfile(datasetPath, category);    
    filesys('mkdir', fullfile(binaryRootPath, category));
    videoList = filesys('getFolders', categoryPath);

firstFrame=1;
for strVideo = videoList,
    video = strVideo{1};
    videoPath = fullfile(categoryPath, video);
    %txt_filename = fullfile(videoPath,'temporalROI.txt');
  

    if  strcmp(video, 'zoomInZoomOut') == 1  || strcmp(video, 'twoPositionPTZCam') == 1 || strcmp(video, 'library') == 1 ...
        || strcmp(video, 'turbulence0') == 1 || strcmp(video, 'turbulence1') == 1 || strcmp(video, 'park') == 1 ...
        || strcmp(video, 'winterDriveway') == 1
    
    video
    else
          continue;
    end

    %read the number of training numbers for processed class
    allFiles = dir([videoPath, '\input\*.jpg']);  
    frame_test = imread( [videoPath,'\input\in000310.jpg'] );
    H = size(frame_test,1);
    W = size(frame_test,2);
    ch = size(frame_test,3);
   
    binaryPath = fullfile(binaryRootPath, category, video);
    filesys('mkdir', fullfile(binaryPath));
         
     % gets best parameters 
    [ R_lower, Med_P, R_scale] = getsParameters_best_new(video);   
    

    N=35; %no of background frames 
   
    % initialization of background set with first N frames
    Backgrounds = single( zeros( H,W, N) );
    Backgrounds = (Backgrounds);
    for i=1:N
        filename = strcat( [videoPath,'/input/'],allFiles(i).name );
        [pathstr, name, ext] = fileparts(filename);   
        frame = imread(filename);     
        frame = rgb2hsv(frame);
        frame=abs(frame.*255);         
        curFrame=frame(:,:,3); 
        Backgrounds(:,:,i) = single(double(curFrame));
    end

  
    T_lower=2;            % lower bound of T
    T_upper=Inf;          % upper bound of T
    R_incdec=0.01;        % steering control to maintain threshold
    
    R=R_lower.*ones(H,W); % threshold parameter
    T=T_lower*ones(H,W);  % learning parameter
    v=zeros(H,W);         % noise container parameter
    Xt=zeros(H,W);

    Dmin=0.*ones(H,W);       % dynamic controller parameter, dmin 
    DminNorm=0.*ones(H,W);   % normalized version of dmin 
    meanDist=0.*ones(H,W);   % mean of historical distances 

    BW=0.*ones(H,W);
    BWprev=0.*ones(H,W);
   
    Xt=(Xt);
    v=(v);
    R=(R);
    T=(T);
    Dmin=(Dmin);
    
    %post processing parameters for opening and closing 
    el1=strel('diamond',1);
    el2=strel('diamond',10);
    
    prevFrame=0.*ones(H,W);
    prevFrame=(prevFrame);
    
    %chck: Control parameter to ensure that whether scene changed or not
    %chck=0 scene not changed, otherwise changed
    
    chck=0; 
    idx=0; % index for updating background frames sequentially
    for i=firstFrame:length(allFiles)
        
        filename = strcat( [videoPath,'/input/'],allFiles(i).name )
        [pathstr, name, ext] = fileparts(filename);   
        frame = imread(filename);     
        frame = rgb2hsv(frame);
        frame=abs(frame.*255);         
        curFrame=frame(:,:,3); 

        Backgrounds2=reshape(Backgrounds, [H*W, N]);
        MB=mean(Backgrounds2,2);
        MB=reshape(MB, [H,W]);
        Gmag = getGradientDistance(gather(curFrame), gather(MB));
        Gmag = abs(Gmag);
        
        [BW, minDist]=getDist( Backgrounds, curFrame, Gmag, R, H, W, N);       
        BW=medfilt2(BW, [Med_P,Med_P]);   
        BW=bwareaopen(BW,10);          
        BW=imclose(imopen(BW,el1),el2); 
        BW1=uint8(BW)*255;

        filename2 = fullfile(binaryPath, ['b', name, '.png']);
        imwrite(BW1, filename2);     
     
        %update background frames as consecutive order, with sliding window
        %way
               
        idx=idx+1;        
        if idx==N+1
           idx=1;
        end
        
        p=1./(T);
        Backgrounds(:,:,idx) = (1-p).*Backgrounds(:,:,idx) + (p).*curFrame;
               
        %update dynamic controller parameters, dmin and normalized dmin in paper       
        if i==firstFrame
            meanDist=minDist;
        else
            meanDist=((5-1)*meanDist+minDist)./5;
        end
        Dmin=meanDist.*R_scale;
        DminNorm=Dmin./max(Dmin(:)+1); % normalized version of dmin
         
        % monitoring bilinking pixels
        v(Xt==1)=v(Xt==1)+1;
        v(Xt==0)=v(Xt==0)-0.1;
        v(v<0)=0;

        % update threshold parameter
        R(R< Dmin)=R(R< Dmin)+R_incdec*R(R<Dmin);
        R(R>=Dmin)=R(R>=Dmin)-R_incdec*R(R>=Dmin);
        R(R<=R_lower)=R_lower; 
        
        % update learning parameter
        T(BW==1)=T(BW==1)+1./(v(BW==1).*DminNorm(BW==1)+1);
        T(BW==0)=T(BW==0)-(v(BW==0)+0.1)./(DminNorm(BW==0)+1);
        T(T<=T_lower)=T_lower;  
                
        
        %initialization of binary segmented previous frame and old previos frame
        if i==firstFrame
            BWprev=BW;
            prevFrame=curFrame;
        else
            %catching blinking pixels to update v
            Xt=double(xor(BW, BWprev));
            Xt(Xt&BW)=0;
            BWprev = BW;
        end
        
        if  strcmp(category, 'PTZ') == 1 
            %check whether scene changed or not
            if i>2
                [ chck, ref] = isSceneChange( prevFrame, curFrame, H, W);
            end   

            %scene changed detected
            if chck==1
                 Backgrounds(:,:,idx) = ref;
                 prevFrame=ref;
                 chck=0;
            end
        end
        
       
    end
   
   
end
    
end
