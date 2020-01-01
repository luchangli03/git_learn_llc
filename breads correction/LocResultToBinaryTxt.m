function LocResultToBinaryTxt(WriteDat,FileName)

% WriteDat=LocArry;
% FileName=sprintf('LocArry_driftCorrByBeads.txt');

% FileName='LocArry_whole.txt';

WriteDat=WriteDat';
WriteDat=single(WriteDat);

fid=fopen(FileName,'w');
fwrite(fid,WriteDat(:),'single');

fclose(fid);



