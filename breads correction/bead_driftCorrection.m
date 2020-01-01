
GroupFrameNum = 200;
XYPosSel = 2:3; % 2,3:x,y

%% drift calculation for each group
TotalFrameNum = LocArry(end,end);

GroupFrameNum_half = floor(GroupFrameNum/2);

GroupNum = floor(TotalFrameNum/GroupFrameNum);
FiducialFluo_XYMeanDat = zeros(GroupNum,FiducialFluoNum*2);

for n=1:FiducialFluoNum
    fsel=(2*n-1):2*n;
    
    for fcnt=1:GroupNum
        PosSel = (fcnt-1)*GroupFrameNum+1:fcnt*GroupFrameNum;
        FiducialFluo_CurGroup = FiducialFluo_XYPosArry(PosSel,fsel);

         % filter some bad points
        [FiducialFluo_CurGroup1]=FilterOutFluo(FiducialFluo_CurGroup, 3.5, 2);
        MeanCenterPos=mean(FiducialFluo_CurGroup1,1);
       
        FiducialFluo_XYMeanDat(fcnt,fsel) = MeanCenterPos;
    end
end

FiducialFluo_XYMeanDat1 = FiducialFluo_XYMeanDat-repmat(FiducialFluo_XYMeanDat(1,:),size(FiducialFluo_XYMeanDat,1),1);

% among many fiducial markers
XDrift_Group=FiducialFluo_XYMeanDat1(:,1:2:end);
YDrift_Group=FiducialFluo_XYMeanDat1(:,2:2:end);

XDrift_Group_Mean=mean(XDrift_Group,2);
YDrift_Group_Mean=mean(YDrift_Group,2);

GroupFrame=(1:GroupNum)*GroupFrameNum-GroupFrameNum_half;
figure(1)
hold on
% plot(XDrift_Group(:,1))
% plot(XDrift_Group(:,2))
plot(GroupFrame,XDrift_Group_Mean)

figure(2)
hold on
% plot(YDrift_Group(:,1))
% plot(YDrift_Group(:,2))
plot(GroupFrame,YDrift_Group_Mean)

%% drift for each frame by linear interpolation
XDrift_EachFrame=zeros(TotalFrameNum,1);
YDrift_EachFrame=zeros(TotalFrameNum,1);


for f=1:TotalFrameNum
    % forward and backward
    FGroup=floor((f+GroupFrameNum_half)/GroupFrameNum);
    BGroup=FGroup+1;
    
    FGroup=max(FGroup,1);
    BGroup=min(BGroup,GroupNum);
    
    FGroup_CenterFrame=FGroup*GroupFrameNum-GroupFrameNum_half;
    BGroup_CenterFrame=BGroup*GroupFrameNum-GroupFrameNum_half;
    
    CurXDrift = XDrift_Group_Mean(FGroup)*abs(f-BGroup_CenterFrame)/GroupFrameNum + XDrift_Group_Mean(BGroup)*abs(f-FGroup_CenterFrame)/GroupFrameNum;
    CurYDrift = YDrift_Group_Mean(FGroup)*abs(f-BGroup_CenterFrame)/GroupFrameNum + YDrift_Group_Mean(BGroup)*abs(f-FGroup_CenterFrame)/GroupFrameNum;
    
    XDrift_EachFrame(f) = CurXDrift;
    YDrift_EachFrame(f) = CurYDrift;

end

figure(1)
plot(XDrift_EachFrame)

figure(2)
plot(YDrift_EachFrame)


%% apply drift
LocArry_DriftCorr=LocArry;

for fcnt=1:TotalFrameNum
    fcnt
    pos = LocArry(:,end)==fcnt;
    
   	LocArry_DriftCorr(pos,XYPosSel(1)) = LocArry(pos,XYPosSel(1))-XDrift_EachFrame(fcnt);
   	LocArry_DriftCorr(pos,XYPosSel(2)) = LocArry(pos,XYPosSel(2))-YDrift_EachFrame(fcnt);
    
end

save LocArry_driftCorrByBeads_b100 LocArry_DriftCorr LocArry XDrift_Group YDrift_Group XDrift_Group_Mean YDrift_Group_Mean GroupFrameNum

LocResultToBinaryTxt(LocArry_DriftCorr,'LocArry_DriftCorrByBeads.txt')

% diff=LocArry(:,2:3)-LocArry_DriftCorr(:,2:3);
% plot(diff(:,1))
% hold on
% plot(diff(:,2))

