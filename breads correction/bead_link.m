%% parameters

SNRth = 30;

PixelSize = 97; % nm
DistanceTh = 100 / PixelSize; % 100nm threshold

XYPosSel = 2:3; % 2,3:x,y

%% decrease search scope to improve efficiency

pos = LocArry(:,9) > SNRth;
LocArry_s = LocArry(pos,:);


%% link fiducial markers
TotalFrameNum = LocArry_s(end,end);
EndFramePos = strfind(LocArry_s(:,end)',TotalFrameNum);

DatLen = size(LocArry_s,1);

BackwardId = zeros(1,DatLen);
ForwardID = zeros(1,DatLen);
LastFrame = 0;

for i = 1:(EndFramePos(1)-1)
    curFrame=LocArry_s(i,end);
    CurXYPos=LocArry_s(i,XYPosSel);
    
    if(curFrame~=LastFrame)
        NextFramePos=strfind(LocArry_s(:,end)',curFrame+1);
        XYPos_NextFrame=LocArry_s(NextFramePos,XYPosSel);
        FluoNum_NextFrame=size(XYPos_NextFrame,1);
        LastFrame=curFrame;
    end
    PosDiff=XYPos_NextFrame-repmat(CurXYPos,FluoNum_NextFrame,1);
    
    Distance=sqrt(sum(PosDiff.^2,2));
    [mdat,mpos]=min(Distance);
    
    if(mdat <= DistanceTh)
        ConsecId=mpos-1+NextFramePos(1);
        BackwardId(i)=ConsecId;
        ForwardID(ConsecId)=i;

    end 
end

%
F1FluoNum=sum(LocArry_s(:,end)==1);
ConsectiveNum=ones(1,F1FluoNum);

for i=1:F1FluoNum
    CurID=i;
    NextID=BackwardId(CurID);
        
    while(NextID > CurID)
        
        CurID=NextID;
        NextID=BackwardId(CurID);
        
        ConsectiveNum(i) = ConsectiveNum(i)+1;
    end
end

FiducialFluoId = strfind(ConsectiveNum, TotalFrameNum);
FiducialFluoNum = length(FiducialFluoId);

% row: x and y of each FiducialFluo
FiducialFluo_XYPosArry = zeros(TotalFrameNum, 2*FiducialFluoNum);

for i=1:FiducialFluoNum
    
    CurID=FiducialFluoId(i);
    NextID=BackwardId(CurID);
    
    ppos=1;
    PosSel=(i-1)*2+1:i*2;
    
    FiducialFluo_XYPosArry(ppos,PosSel)=LocArry_s(CurID,XYPosSel);
    ppos=ppos+1;
    
    while(NextID > CurID)
        
        CurID=NextID;
        NextID=BackwardId(CurID);
        
        FiducialFluo_XYPosArry(ppos,PosSel)=LocArry_s(CurID,XYPosSel);
        ppos=ppos+1;
    end
end

figure
plot(FiducialFluo_XYPosArry(:,1))
figure
plot(FiducialFluo_XYPosArry(:,2))

% save FiducialFluo_LinkData BackwardId BackwardId ConsectiveNum FiducialFluoId FiducialFluoNum FiducialFluo_XYPosArry

