function [ R_lower, medP, R_scale ] = getsParameters_best_new(video)

R_lower=35;    
medP=5; 
R_scale=0.1;
  %cameraJitter ++
  if strcmp(video, 'badminton') == 1
     medP=7;   R_lower=20;   R_scale=2; 
  end
  if strcmp(video, 'boulevard') == 1
     medP=5;    R_lower=40;   R_scale=2; 
  end
  if strcmp(video, 'sidewalk') == 1
     medP=7;    R_lower=15;   R_scale=2; 
  end
  if strcmp(video, 'traffic') == 1
     medP=7;   R_lower=30;   R_scale=2; 
  end
    
  %badWeather ++
  if strcmp(video, 'blizzard') == 1
     medP=3;    R_lower=10;   R_scale=2;
  end
  if strcmp(video, 'skating') == 1
     medP=3;    R_lower=10;   R_scale=1;
  end
  if strcmp(video, 'snowFall') == 1 
     medP=7;   R_lower=15;   R_scale=2;
  end
  if strcmp(video, 'wetSnow') == 1
     medP=7;   R_lower=20;   R_scale=2;
  end
  
  %baseline oo
  if strcmp(video, 'highway') == 1
     medP=5;    R_lower=25;   R_scale=0.1;
  end
  if strcmp(video, 'office') == 1
     medP=3;    R_lower=30;   R_scale=0.1;
  end
  if strcmp(video, 'pedestrians') == 1
     medP=7;    R_lower=25;   R_scale=1;
  end
  if strcmp(video, 'PETS2006') == 1
     medP=3;    R_lower=30;   R_scale=0.1;
  end
  
  %dynamicBackground ++
  if strcmp(video, 'boats') == 1
     medP=7;   R_lower=15;   R_scale=1; 
  end
  if strcmp(video, 'canoe') == 1
     medP=5;  R_lower=35;   R_scale=0.1; 
  end
  if strcmp(video, 'fall') == 1
     medP=11;  R_lower=10;   R_scale=2;
  end
  if strcmp(video, 'fountain01') == 1
     medP=11;  R_lower=15;   R_scale=2; 
   end
  if strcmp(video, 'fountain02') == 1
     medP=7;   R_lower=25;   R_scale=1; 
  end
  if strcmp(video, 'overpass') == 1
     medP=7;   R_lower=15;   R_scale=1; 
  end
  
  
    %intermittentObjectMotion ++
  if strcmp(video, 'abandonedBox') == 1
     medP=1;  R_lower=55;   R_scale=0.1;
  end
  if strcmp(video, 'parking') == 1
     medP=3;  R_lower=10;   R_scale=2;
  end  
  if strcmp(video, 'sofa') == 1
     medP=3;  R_lower=15;   R_scale=0.1;
  end
  if strcmp(video, 'streetLight') == 1
     medP=1;  R_lower=50;   R_scale=0.1;
  end
  if strcmp(video, 'tramstop') == 1
     medP=3;  R_lower=15;   R_scale=2;
  end
  if strcmp(video, 'winterDriveway') == 1 
     medP=3;  R_lower=40;   R_scale=2;
  end
  
   %lowFramerate ++
  if strcmp(video, 'port_0_17fps') == 1
     medP=9;  R_lower=40;   R_scale=2;
  end
  if strcmp(video, 'tramCrossroad_1fps') == 1
     medP=3;  R_lower=40;   R_scale=0.1;
  end
  if strcmp(video, 'tunnelExit_0_35fps') == 1
     medP=9;  R_lower=15;   R_scale=0.1;
  end
  if strcmp(video, 'turnpike_0_5fps') == 1
     medP=9;  R_lower=15;   R_scale=0.1;
  end
    
 
   %nightVideos ++
  if strcmp(video, 'bridgeEntry') == 1
     medP=1;  R_lower=25;   R_scale=2;
  end
  if strcmp(video, 'busyBoulvard') == 1
     medP=3;  R_lower=15;   R_scale=2;
  end
  if strcmp(video, 'fluidHighway') == 1
     medP=3;  R_lower=50;   R_scale=2; 
  end
   if strcmp(video, 'streetCornerAtNight') == 1
     medP=3;  R_lower=45;   R_scale=2; 
  end
  if strcmp(video, 'tramStation') == 1
     medP=3;  R_lower=20;   R_scale=2;
  end
  if strcmp(video, 'winterStreet') == 1
     medP=3;  R_lower=35;   R_scale=2;
  end
  
   %PTZ ++
  if strcmp(video, 'continuousPan') == 1
     medP=15;    R_lower=40;   R_scale=2;  
  end
  if strcmp(video, 'intermittentPan') == 1
     medP=11;    R_lower=20;   R_scale=2;  
  end
  if strcmp(video, 'twoPositionPTZCam') == 1
     medP=9;    R_lower=25;   R_scale=2;  
  end
  if strcmp(video, 'zoomInZoomOut') == 1
     medP=9;    R_lower=50;   R_scale=2;  
  end
  
  %shadow ++
  if strcmp(video, 'backdoor') == 1
     medP=7;  R_lower=20;   R_scale=2;
  end
  if strcmp(video, 'bungalows') == 1
     medP=3;  R_lower=20;   R_scale=0.1;  
  end
  if strcmp(video, 'busStation') == 1
     medP=3;  R_lower=40;   R_scale=0.1; 
  end 
  if strcmp(video, 'copyMachine') == 1
     medP=5; R_lower=35;   R_scale=0.1;   
  end
  if strcmp(video, 'cubicle') == 1
     medP=3;  R_lower=25;   R_scale=2;
  end
  if strcmp(video, 'peopleInShade') == 1
     medP=3;  R_lower=25;   R_scale=1;
  end
  
  
  %thermal ++
  if strcmp(video, 'corridor') == 1
     medP=9;    R_lower=25;  R_scale=0.1;
  end
  if strcmp(video, 'diningRoom') == 1
     medP=3;    R_lower=10;  R_scale=1;
  end
  if strcmp(video, 'lakeSide') == 1      
     medP=3;    R_lower=10;  R_scale=1;
  end
  if strcmp(video, 'library') == 1
     medP=7;    R_lower=25;  R_scale=0.1;
  end
  if strcmp(video, 'park') == 1
     medP=1;    R_lower=25;  R_scale=0.1;
  end
  
  %turbulence ++
  if strcmp(video, 'turbulence0') == 1
     medP=11;   R_lower=30;  R_scale=2; 
  end
  if strcmp(video, 'turbulence1') == 1
     medP=11;   R_lower=35;  R_scale=2;
  end
  if strcmp(video, 'turbulence2') == 1
     medP=7;    R_lower=30;  R_scale=2;
  end
  if strcmp(video, 'turbulence3') == 1
     medP=7;    R_lower=25;  R_scale=2;
  end


end