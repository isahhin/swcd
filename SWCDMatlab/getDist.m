function [ BW, minDist] = getDist( Backgrounds1, IM, Gmag, R, H, W, N)
    sumBW=zeros(H,W);
    minDist=1000.*ones(H,W);
    for j=1:N
        dist=((abs(Backgrounds1(:,:,j)-IM))+ (Gmag));
        minDist(dist<minDist) = dist(dist<minDist);
        BW=dist>=R & (abs(Backgrounds1(:,:,j)-IM))>5;
        sumBW=sumBW+BW;
    end
    BW=sumBW>N-1;
    
end

