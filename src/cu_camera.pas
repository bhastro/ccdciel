unit cu_camera;

{$mode objfpc}{$H+}

{
Copyright (C) 2015 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. 

}

// {$define camera_debug}


interface

uses  cu_fits, cu_mount, cu_wheel, u_global, u_utils,  indiapi,
  lazutf8sysutils, Classes, Forms, SysUtils;

type

TVideoRecordMode=(rmDuration,rmFrame,rmUnlimited);

T_camera = class(TComponent)
  protected
    FCameraInterface: TDevInterface;
    FStatus: TDeviceStatus;
    FWheelStatus: TDeviceStatus;
    FonMsg,FonDeviceMsg: TNotifyMsg;
    FonExposureProgress: TNotifyNum;
    FonFilterChange: TNotifyNum;
    FonFrameChange: TNotifyEvent;
    FonTemperatureChange: TNotifyNum;
    FonCoolerChange: TNotifyBool;
    FonStatusChange: TNotifyEvent;
    FonFilterNameChange: TNotifyEvent;
    FonWheelStatusChange: TNotifyEvent;
    FonNewImage: TNotifyEvent;
    FonVideoFrame: TNotifyEvent;
    FonAbortExposure,FonCameraDisconnected: TNotifyEvent;
    FonVideoPreviewChange,FonVideoSizeChange,FonVideoRateChange: TNotifyEvent;
    FonFPSChange,FonVideoExposureChange : TNotifyEvent;
    FImgStream: TMemoryStream;
    FVideoStream: TMemoryStream;
    FFilterNames: TStringList;
    FObjectName: string;
    FFits,FStackDark: TFits;
    FStackCount: integer;
    FMount: T_mount;
    Fwheel: T_wheel;
    FTimeOut: integer;
    FAutoLoadConfig: boolean;
    FhasVideo: boolean;
    FVerticalFlip: boolean;
    FAddFrames: boolean;
    FVideoSizes, FVideoRates:TStringList;
    FTemperatureRampActive, FCancelTemperatureRamp: boolean;
    FIndiTransfert: TIndiTransfert;
    FIndiTransfertDir,FIndiTransfertPrefix: string;
    procedure msg(txt: string);
    procedure NewImage;
    procedure WriteHeaders;
    procedure NewVideoFrame;
    procedure WriteVideoHeader(width,height,naxis,bitpix: integer);
    function GetDevicename: string; virtual; abstract;
    function GetBinX:integer; virtual; abstract;
    function GetBinY:integer; virtual; abstract;
    procedure SetFrametype(f:TFrameType); virtual; abstract;
    function  GetFrametype:TFrameType; virtual; abstract;
    function GetBinXrange:TNumRange; virtual; abstract;
    function GetBinYrange:TNumRange; virtual; abstract;
    function GetExposureRange:TNumRange; virtual; abstract;
    function GetTemperatureRange:TNumRange; virtual; abstract;
    function  GetTemperature: double; virtual; abstract;
    procedure SetTemperature(value:double); virtual; abstract;
    procedure SetTemperatureRamp(value:double);
    procedure SetTemperatureRampAsync(Data: PtrInt);
    function  GetCooler: boolean; virtual; abstract;
    procedure SetCooler(value:boolean); virtual; abstract;
    procedure SetFilter(num:integer); virtual; abstract;
    function  GetFilter:integer; virtual; abstract;
    procedure SetFilterNames(value:TStringList); virtual; abstract;
    function GetMaxX: double; virtual; abstract;
    function GetMaxY: double; virtual; abstract;
    function GetPixelSize: double; virtual; abstract;
    function GetPixelSizeX: double; virtual; abstract;
    function GetPixelSizeY: double; virtual; abstract;
    function GetBitperPixel: double; virtual; abstract;
    function GetColor: boolean;  virtual; abstract;
    procedure SetTimeout(num:integer); virtual; abstract;
    function GetVideoPreviewRunning: boolean;  virtual; abstract;
    function GetMissedFrameCount: cardinal; virtual; abstract;
    function GetVideoRecordDuration:integer; virtual; abstract;
    procedure SetVideoRecordDuration(value:integer); virtual; abstract;
    function GetVideoRecordFrames:integer; virtual; abstract;
    procedure SetVideoRecordFrames(value:integer); virtual; abstract;
    function GetVideoSize:string;virtual; abstract;
    procedure SetVideoSize(value:string); virtual; abstract;
    function GetVideoRate:string;virtual; abstract;
    procedure SetVideoRate(value:string); virtual; abstract;
    function GetFPS:double;virtual; abstract;
    function GetVideoRecordDir:string; virtual; abstract;
    procedure SetVideoRecordDir(value:string); virtual; abstract;
    function GetVideoRecordFile:string; virtual; abstract;
    procedure SetVideoRecordFile(value:string); virtual; abstract;
    function GetVideoExposure:integer; virtual; abstract;
    function GetVideoGain:integer; virtual; abstract;
    function GetVideoGamma:integer; virtual; abstract;
    function GetVideoBrightness:integer; virtual; abstract;
    procedure SetVideoExposure(value:integer); virtual; abstract;
    procedure SetVideoGain(value:integer); virtual; abstract;
    procedure SetVideoGamma(value:integer); virtual; abstract;
    procedure SetVideoBrightness(value:integer); virtual; abstract;
    function GetVideoExposureRange:TNumRange; virtual; abstract;
    function GetVideoGainRange:TNumRange; virtual; abstract;
    function GetVideoGammaRange:TNumRange; virtual; abstract;
    function GetVideoBrightnessRange:TNumRange; virtual; abstract;
    function GetVideoPreviewDivisor:integer; virtual; abstract;
    procedure SetVideoPreviewDivisor(value:integer); virtual; abstract;
  private
    lockvideoframe: boolean;
    TempFinal: Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    Procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string=''); virtual; abstract;
    Procedure Disconnect; virtual; abstract;
    Procedure SetBinning(binX,binY: integer); virtual; abstract;
    Procedure StartExposure(exptime: double); virtual; abstract;
    Procedure AbortExposure; virtual; abstract;
    procedure SetFrame(x,y,width,height: integer); virtual; abstract;
    procedure GetFrame(out x,y,width,height: integer); virtual; abstract;
    procedure GetFrameRange(out xr,yr,widthr,heightr: TNumRange); virtual; abstract;
    procedure ResetFrame; virtual; abstract;
    Procedure SetActiveDevices(focuser,filters,telescope: string); virtual; abstract;
    procedure StartVideoPreview; virtual; abstract;
    procedure StopVideoPreview; virtual; abstract;
    procedure StartVideoRecord(mode:TVideoRecordMode); virtual; abstract;
    procedure StopVideoRecord; virtual; abstract;
    property StackDark: TFits read FStackDark write FStackDark;
    property Fits: TFits read FFits write FFits;
    property Mount: T_mount read FMount write FMount;
    property wheel: T_wheel read Fwheel write Fwheel;
    property ObjectName: string read FObjectName write FObjectName;
    property CameraInterface: TDevInterface read FCameraInterface;
    property Status: TDeviceStatus read FStatus;
    property WheelStatus: TDeviceStatus read FWheelStatus;
    property ImgStream: TMemoryStream read FImgStream;
    property AddFrames: boolean read FAddFrames write FAddFrames;
    property VerticalFlip: boolean read FVerticalFlip;
    property hasVideo: boolean read FhasVideo;
    property VideoStream: TMemoryStream read FVideoStream;
    property VideoPreviewRunning: boolean read GetVideoPreviewRunning;
    property MissedFrameCount: Cardinal read GetMissedFrameCount;
    property VideoRecordDuration: integer read GetVideoRecordDuration write SetVideoRecordDuration;
    property VideoRecordFrames: integer read GetVideoRecordFrames write SetVideoRecordFrames;
    property VideoSizes:TStringList read FVideoSizes;
    property VideoRates:TStringList read FVideoRates;
    property VideoSize:string read GetVideoSize write SetVideoSize;
    property VideoRate:string read GetVideoRate write SetVideoRate;
    property VideoRecordDir:string read GetVideoRecordDir write SetVideoRecordDir;
    property VideoRecordFile:string read GetVideoRecordFile write SetVideoRecordFile;
    property VideoExposure: integer read GetVideoExposure write SetVideoExposure;
    property VideoExposureRange: TNumRange read GetVideoExposureRange;
    property VideoGain: integer read GetVideoGain write SetVideoGain;
    property VideoGainRange: TNumRange read GetVideoGainRange;
    property VideoGamma: integer read GetVideoGamma write SetVideoGamma;
    property VideoGammaRange: TNumRange read GetVideoGammaRange;
    property VideoBrightness: integer read GetVideoBrightness write SetVideoBrightness;
    property VideoBrightnessRange: TNumRange read GetVideoBrightnessRange;
    property VideoPreviewDivisor: integer read GetVideoPreviewDivisor write SetVideoPreviewDivisor;
    property Cooler: boolean read GetCooler write SetCooler;
    property Temperature: double read GetTemperature write SetTemperatureRamp;
    property TemperatureRampActive: Boolean read FTemperatureRampActive;
    property DeviceName: string read GetDevicename;
    property BinX: Integer read getBinX;
    property BinY: Integer read getBinY;
    property FrameType: TFrameType read GetFrametype write SetFrametype;
    property BinXrange: TNumRange read GetbinXrange;
    property BinYrange: TNumRange read GetbinYrange;
    property ExposureRange: TNumRange read GetExposureRange;
    property TemperatureRange: TNumRange read GetTemperatureRange;
    property MaxX: double read GetMaxX;
    property MaxY: double read GetMaxY;
    property PixelSize: double read GetPixelSize;
    property PixelSizeX: double read GetPixelSizeX;
    property PixelSizeY: double read GetPixelSizeY;
    property BitperPixel: double read GetBitperPixel;
    property Color: boolean read GetColor;
    property FPS: double read GetFPS;
    property StackCount: integer read FStackCount;
    property Filter: integer read GetFilter write SetFilter;
    property FilterNames: TStringList read FFilterNames write SetFilterNames;
    property Timeout: integer read FTimeout write SetTimeout;
    property AutoLoadConfig: boolean read FAutoLoadConfig write FAutoLoadConfig;
    property IndiTransfert: TIndiTransfert read FIndiTransfert write FIndiTransfert;
    property IndiTransfertDir: string read FIndiTransfertDir write FIndiTransfertDir;
    property onMsg: TNotifyMsg read FonMsg write FonMsg;
    property onDeviceMsg: TNotifyMsg read FonDeviceMsg write FonDeviceMsg;
    property onExposureProgress: TNotifyNum read FonExposureProgress write FonExposureProgress;
    property onTemperatureChange: TNotifyNum read FonTemperatureChange write FonTemperatureChange;
    property onCoolerChange: TNotifyBool read FonCoolerChange write FonCoolerChange;
    property onFilterChange: TNotifyNum read FonFilterChange write FonFilterChange;
    property onStatusChange: TNotifyEvent read FonStatusChange write FonStatusChange;
    property onFrameChange: TNotifyEvent read FonFrameChange write FonFrameChange;
    property onFilterNameChange: TNotifyEvent read FonFilterNameChange write FonFilterNameChange;
    property onWheelStatusChange: TNotifyEvent read FonWheelStatusChange write FonWheelStatusChange;
    property onNewImage: TNotifyEvent read FonNewImage write FonNewImage;
    property onVideoFrame: TNotifyEvent read FonVideoFrame write FonVideoFrame;
    property onCameraDisconnected: TNotifyEvent read FonCameraDisconnected write FonCameraDisconnected;
    property onAbortExposure: TNotifyEvent read FonAbortExposure write FonAbortExposure;
    property onVideoPreviewChange: TNotifyEvent read FonVideoPreviewChange write FonVideoPreviewChange;
    property onVideoSizeChange: TNotifyEvent read FonVideoSizeChange write FonVideoSizeChange;
    property onVideoRateChange: TNotifyEvent read FonVideoRateChange write FonVideoRateChange;
    property onFPSChange: TNotifyEvent read FonFPSChange write FonFPSChange;
    property onVideoExposureChange: TNotifyEvent read FonVideoExposureChange write FonVideoExposureChange;

end;

implementation

constructor T_camera.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimeOut:=100;
  FIndiTransfert:=itNetwork;
  FIndiTransfertDir:=defTransfertPath;
  FIndiTransfertPrefix:='ccdciel_tmp';
  FVerticalFlip:=false;
  FStatus := devDisconnected;
  FFilterNames:=TStringList.Create;
  FImgStream:=TMemoryStream.Create;
  FAddFrames:=false;
  FhasVideo:=false;
  FVideoStream:=TMemoryStream.Create;;
  lockvideoframe:=false;
  FVideoSizes:=TStringList.Create;
  FVideoRates:=TStringList.Create;
  FTemperatureRampActive:=false;
  FCancelTemperatureRamp:=false;
  FStackDark:=TFits.Create(nil);
  FStackCount:=0;
end;

destructor  T_camera.Destroy;
begin
  FImgStream.Free;
  FFilterNames.Free;
  FVideoStream.Free;
  FVideoSizes.Free;
  FVideoRates.Free;
  FStackDark.Free;
  inherited Destroy;
end;

procedure T_camera.msg(txt: string);
begin
 if Assigned(FonMsg) then FonMsg(DeviceName+': '+txt);
end;

procedure T_camera.SetTemperatureRamp(value:double);
begin
  if TemperatureSlope>0 then begin
    TempFinal:=value;
    Application.QueueAsyncCall(@SetTemperatureRampAsync,0);
  end else begin
    msg('Set temperature '+formatfloat(f1,value));
    SetTemperature(value);
  end;
end;

procedure T_camera.SetTemperatureRampAsync(Data: PtrInt);
var TempStart,TempNow,TempRamp: double;
    Nstep,TempStep: integer;
begin
  TempStep:=round(60.0/TemperatureSlope);
  if TempStep<1 then TempStep:=1;
  if FTemperatureRampActive then begin
     FCancelTemperatureRamp:=true;
     msg('Temperature ramp requested to stop');
     exit;
  end;
  msg('Set temperature ramp to '+formatfloat(f1,TempFinal)+' started');
  try
  FTemperatureRampActive:=true;
  TempStart:=GetTemperature;
  TempNow:=TempStart;
  if TempFinal>TempStart then
     TempRamp:=1.0
  else
     TempRamp:=-1.0;
  Nstep:=round(abs(TempStart-TempFinal));
  while Nstep>0 do begin
    TempNow:=TempNow+TempRamp;
    SetTemperature(TempNow);
    wait(TempStep);
    if FCancelTemperatureRamp then begin
       FCancelTemperatureRamp:=false;
       FTemperatureRampActive:=false;
       msg('Temperature ramp canceled');
       exit;
    end;
    dec(Nstep);
  end;
  SetTemperature(TempFinal);
  msg('Set temperature ramp finished');
  finally
    FTemperatureRampActive:=false;
    if Assigned(FonTemperatureChange) then FonTemperatureChange(GetTemperature);
  end;
end;

procedure T_camera.NewImage;
var f:TFits;
begin
if FAddFrames then begin  // stack preview frames
  // load temporary image
  f:=TFits.Create(nil);
  f.Stream:=ImgStream;
  f.LoadStream;
  // convert 8bit to 16bit to avoid quick overflow
  if f.HeaderInfo.bitpix=8 then
     f.Bitpix8to16;
  // substract dark if loaded and compatible
  if f.SameFormat(FStackDark) then
     f.Math(FStackDark,moSub);
  // check frame is compatible
  if FFits.SameFormat(f) then begin
     FFits.Math(f,moAdd);       // add frame
     inc(FStackCount);
  end
  else begin
     FFits.Math(f,moAdd,true);  // start a new stack
     FStackCount:=1;
  end;
  // update image
  FFits.Header.Assign(f.Header);
  WriteHeaders;
  if Assigned(FonNewImage) then FonNewImage(self);
  f.free;
end
else begin  // normal capture
  FStackCount:=0;
  {$ifdef camera_debug}msg('load stream');{$endif}
  Ffits.Stream:=ImgStream;
  Ffits.LoadStream;
  {$ifdef camera_debug}msg('write headers');{$endif}
  WriteHeaders;
  FFits.ApplyBPM;
  {$ifdef camera_debug}msg('display image');{$endif}
  if Assigned(FonNewImage) then FonNewImage(self);
end;
end;

procedure T_camera.WriteHeaders;
var dy,dm,dd: word;
    origin,observer,telname,objname: string;
    focal_length,pixscale1,pixscale2,ccdtemp,equinox,jd1: double;
    hbitpix,hnaxis,hnaxis1,hnaxis2,hnaxis3,hbin1,hbin2: integer;
    hfilter,hframe,hinstr,hdateobs : string;
    hbzero,hbscale,hdmin,hdmax,hra,hdec,hexp,hpix1,hpix2: double;
    gain,gamma,offset: double;
    Frx,Fry,Frwidth,Frheight: integer;
begin
  // get header values from camera (set by INDI driver)
  if not Ffits.Header.Valueof('BITPIX',hbitpix) then hbitpix:=Ffits.HeaderInfo.bitpix;
  if not Ffits.Header.Valueof('NAXIS',hnaxis)   then hnaxis:=Ffits.HeaderInfo.naxis;
  if not Ffits.Header.Valueof('NAXIS1',hnaxis1) then hnaxis1:=Ffits.HeaderInfo.naxis1;
  if not Ffits.Header.Valueof('NAXIS2',hnaxis2) then hnaxis2:=Ffits.HeaderInfo.naxis2;
  if not Ffits.Header.Valueof('NAXIS3',hnaxis3) then hnaxis3:=Ffits.HeaderInfo.naxis3;
  if not Ffits.Header.Valueof('BZERO',hbzero)   then hbzero:=Ffits.HeaderInfo.bzero;
  if not Ffits.Header.Valueof('BSCALE',hbscale) then hbscale:=Ffits.HeaderInfo.bscale;
  if not Ffits.Header.Valueof('EXPTIME',hexp)   then hexp:=-1;
  if not Ffits.Header.Valueof('PIXSIZE1',hpix1) then hpix1:=-1;
  if not Ffits.Header.Valueof('PIXSIZE2',hpix2) then hpix2:=-1;
  if hpix1<0 then if not Ffits.Header.Valueof('XPIXSZ',hpix1) then hpix1:=-1;
  if hpix2<0 then if not Ffits.Header.Valueof('YPIXSZ',hpix2) then hpix2:=-1;
  if not Ffits.Header.Valueof('XBINNING',hbin1) then hbin1:=-1;
  if not Ffits.Header.Valueof('YBINNING',hbin2) then hbin2:=-1;
  if not Ffits.Header.Valueof('FRAME',hframe)   then hframe:='Light   ';
  if not Ffits.Header.Valueof('FILTER',hfilter) then hfilter:='';
  if not Ffits.Header.Valueof('DATAMIN',hdmin)  then hdmin:=Ffits.HeaderInfo.dmin;
  if not Ffits.Header.Valueof('DATAMAX',hdmax)  then hdmax:=Ffits.HeaderInfo.dmax;
  if not Ffits.Header.Valueof('INSTRUME',hinstr) then hinstr:='';
  if not Ffits.Header.Valueof('DATE-OBS',hdateobs) then hdateobs:=FormatDateTime(dateisoshort,NowUTC);
  // get other values
  hra:=NullCoord; hdec:=NullCoord;
  if (Fmount.Status=devConnected) then begin
     hra:=15*Fmount.RA;
     hdec:=Fmount.Dec;
     equinox:=Fmount.Equinox;
     if equinox<>2000 then begin
       if equinox=0 then begin
         DecodeDate(now,dy,dm,dd);
         jd1:=jd(dy,dm,dd,0);
       end else begin
         jd1:=jd(trunc(equinox),1,1,0);
       end;
       hra:=deg2rad*hra;
       hdec:=deg2rad*hdec;
       PrecessionFK5(jd1,jd2000,hra,hdec);
       hra:=rad2deg*hra;
       hdec:=rad2deg*hdec;
     end;
  end;
  if (hfilter='')and(Fwheel.Status=devConnected) then begin
     hfilter:=Fwheel.FilterNames[Fwheel.Filter];
  end;
  ccdtemp:=Temperature;
  objname:=FObjectName;
  origin:=config.GetValue('/Info/ObservatoryName','');
  observer:=config.GetValue('/Info/ObserverName','');
  telname:=config.GetValue('/Info/TelescopeName','');
  if config.GetValue('/Astrometry/FocaleFromTelescope',true)
  then
     focal_length:=Fmount.FocaleLength
  else
     focal_length:=config.GetValue('/Astrometry/FocaleLength',0);
  if (focal_length<1) then msg('Error: Unknow telescope focal length, set in telescope driver or in PREFERENCE, ASTROMETRY.');
  try
   GetFrame(Frx,Fry,Frwidth,Frheight);
  except
   Frwidth:=0;
  end;
  try
   gain:=GetVideoGain;
   gamma:=GetVideoGamma;
   offset:=GetVideoBrightness;
  except
   gain:=0;
   gamma:=0;
   offset:=0;
  end;
  // write new header
  Ffits.Header.ClearHeader;
  Ffits.Header.Add('SIMPLE',true,'file does conform to FITS standard');
  Ffits.Header.Add('BITPIX',hbitpix,'number of bits per data pixel');
  Ffits.Header.Add('NAXIS',hnaxis,'number of data axes');
  Ffits.Header.Add('NAXIS1',hnaxis1 ,'length of data axis 1');
  Ffits.Header.Add('NAXIS2',hnaxis2 ,'length of data axis 2');
  if hnaxis=3 then Ffits.Header.Add('NAXIS3',hnaxis3 ,'length of data axis 3');;
  Ffits.Header.Add('EXTEND',true,'FITS dataset may contain extensions');
  Ffits.Header.Add('BZERO',hbzero,'offset data range to that of unsigned short');
  Ffits.Header.Add('BSCALE',hbscale,'default scaling factor');
  if hdmax>0 then begin
    Ffits.Header.Add('DATAMIN',hdmin,'Minimum value');
    Ffits.Header.Add('DATAMAX',hdmax,'Maximum value');
  end;
  Ffits.Header.Add('DATE',FormatDateTime(dateisoshort,NowUTC),'Date data written');
  if origin<>'' then Ffits.Header.Add('ORIGIN',origin,'Observatory name');
  if observer<>'' then Ffits.Header.Add('OBSERVER',observer,'Observer name');
  if telname<>'' then Ffits.Header.Add('TELESCOP',telname,'Telescope used for acquisition');
  if hinstr<>'' then Ffits.Header.Add('INSTRUME',hinstr,'Instrument used for acquisition');
  if hfilter<>'' then Ffits.Header.Add('FILTER',hfilter,'Filter');
  Ffits.Header.Add('SWCREATE','CCDciel '+ccdciel_version+'-'+RevisionStr,'');
  if objname<>'' then Ffits.Header.Add('OBJECT',objname,'Observed object name');
  Ffits.Header.Add('IMAGETYP',hframe,'Image Type');
  Ffits.Header.Add('DATE-OBS',hdateobs,'UTC start date of observation');
  if hexp>0 then Ffits.Header.Add('EXPTIME',hexp,'[s] Total Exposure Time');
  if FStackCount>1 then Ffits.Header.Add('STACKCNT',FStackCount,'Number of stacked frames');
  if gain>0 then Ffits.Header.Add('GAIN',gain,'Video gain');
  if gamma>0 then Ffits.Header.Add('GAMMA',gamma,'Video gamma');
  if offset>0 then Ffits.Header.Add('OFFSET',offset,'Video offset,brightness');
  if hpix1>0 then Ffits.Header.Add('XPIXSZ',hpix1 ,'[um] Pixel Size X');
  if hpix2>0 then Ffits.Header.Add('YPIXSZ',hpix2 ,'[um] Pixel Size Y');
  if hbin1>0 then Ffits.Header.Add('XBINNING',hbin1 ,'Binning factor X');
  if hbin2>0 then Ffits.Header.Add('YBINNING',hbin2 ,'Binning factor Y');
  Ffits.Header.Add('FOCALLEN',focal_length,'[mm] Telescope focal length');
  if ccdtemp<>NullCoord then Ffits.Header.Add('CCD-TEMP',ccdtemp ,'CCD temperature (Celsius)');
  if Frwidth<>0 then begin
    Ffits.Header.Add('FRAMEX',Frx,'Frame start x');
    Ffits.Header.Add('FRAMEY',Fry,'Frame start y');
    Ffits.Header.Add('FRAMEHGT',Frheight,'Frame height');
    Ffits.Header.Add('FRAMEWDH',Frwidth,'Frame width');
  end;
  if (hra<>NullCoord)and(hdec<>NullCoord) then begin
    Ffits.Header.Add('EQUINOX',2000.0,'');
    Ffits.Header.Add('RA',hra,'[deg] Telescope pointing RA');
    Ffits.Header.Add('DEC',hdec,'[deg] Telescope pointing DEC');
    if (hpix1>0)and(hpix2>0)and(focal_length>0)  then begin
       if hbin1>0 then hpix1:=hpix1*hbin1;
       if hbin2>0 then hpix2:=hpix2*hbin2;
       pixscale1:=rad2deg*arctan(hpix1/1000/focal_length);
       pixscale2:=rad2deg*arctan(hpix2/1000/focal_length);
       Ffits.Header.Add('CTYPE1','RA---TAN','Pixel coordinate system');
       Ffits.Header.Add('CTYPE2','DEC--TAN','Pixel coordinate system');
       Ffits.Header.Add('CRVAL1',hra,'value of ref pixel');
       Ffits.Header.Add('CRVAL2',hdec,'value of ref pixel');
       Ffits.Header.Add('CRPIX1',0.5+hnaxis1/2,'ref pixel');
       Ffits.Header.Add('CRPIX2',0.5+hnaxis2/2,'ref pixel');
       Ffits.Header.Add('CDELT1',pixscale1,'coordinate scale');
       Ffits.Header.Add('CDELT2',pixscale2,'coordinate scale');
    end;
  end;
  Ffits.Header.Add('END','','');
  Ffits.GetFitsInfo;
end;

procedure T_camera.NewVideoFrame;
var x,y,w,h: integer;
begin
  if lockvideoframe then exit;
  lockvideoframe:=true;
  try
  GetFrame(x,y,w,h);
  FVideoStream.Position:=0;
  if Color then begin
    WriteVideoHeader(w,h,3,8);
  end else begin
    WriteVideoHeader(w,h,2,8);
  end;
  FFits.VideoStream:=FVideoStream;
  if Assigned(FonVideoFrame) then FonVideoFrame(self);
  finally
    lockvideoframe:=false;
  end;
end;

procedure T_camera.WriteVideoHeader(width,height,naxis,bitpix: integer);
var
    hbitpix,hnaxis,hnaxis1,hnaxis2,hnaxis3: integer;
    hframe,hdateobs : string;
    hbzero,hbscale,hdmin,hdmax: double;
begin
  // simplified video header
  hbitpix:=bitpix;
  hnaxis:=naxis;
  if naxis=2 then begin
    hnaxis1:=width;
    hnaxis2:=height;
  end;
  if naxis=3 then begin
     hnaxis1:=4;       // 32bit video stream from INDI
     hnaxis2:=width;
     hnaxis3:=height;
  end;
  hframe:='Video   ';
  hbzero:=0;
  hbscale:=1;
  hdmin:=0;
  hdmax:=0;
  hdateobs:=FormatDateTime(dateisoshort,NowUTC);
  // write new header
  Ffits.Header.ClearHeader;
  Ffits.Header.Add('SIMPLE',true,'file does conform to FITS standard');
  Ffits.Header.Add('BITPIX',hbitpix,'number of bits per data pixel');
  Ffits.Header.Add('NAXIS',hnaxis,'number of data axes');
  Ffits.Header.Add('NAXIS1',hnaxis1 ,'length of data axis 1');
  Ffits.Header.Add('NAXIS2',hnaxis2 ,'length of data axis 2');
  if hnaxis=3 then Ffits.Header.Add('NAXIS3',hnaxis3 ,'length of data axis 3');;
  Ffits.Header.Add('EXTEND',true,'FITS dataset may contain extensions');
  Ffits.Header.Add('BZERO',hbzero,'offset data range to that of unsigned short');
  Ffits.Header.Add('BSCALE',hbscale,'default scaling factor');
  Ffits.Header.Add('DATAMIN',hdmin,'Minimum value');
  Ffits.Header.Add('DATAMAX',hdmax,'Maximum value');
  Ffits.Header.Add('DATE',FormatDateTime(dateisoshort,NowUTC),'Date data written');
  Ffits.Header.Add('SWCREATE','CCDciel '+ccdciel_version+'-'+RevisionStr,'');
  Ffits.Header.Add('IMAGETYP',hframe,'Image Type');
  Ffits.Header.Add('DATE-OBS',hdateobs,'UTC start date of observation');
  Ffits.Header.Add('END','','');
  Ffits.GetFitsInfo;
end;

end.

