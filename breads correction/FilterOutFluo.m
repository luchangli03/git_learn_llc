function [oXYPos]=FilterOutFluo(iXYPos, Th, Iteration)
% Th=3.5;

% another method is filter by nearest neighbor distance 
% or neighbor number for a distance th

oXYPos=iXYPos;

for i=1:Iteration
        
        MeanCenterPos=mean(oXYPos,1);
        % filter some bad points
        fnum=size(oXYPos,1);
        diff=oXYPos-repmat(MeanCenterPos,fnum,1);
        
        distance=sqrt(sum(diff.^2,2));
        DistanceTh = std(distance)*Th;
        pos=distance<DistanceTh;
 
        oXYPos=oXYPos(pos,:);

        

end
