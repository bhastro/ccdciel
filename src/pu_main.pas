unit pu_main;

{$mode objfpc}{$H+}

{
Copyright (C) 2015 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}

interface

uses fu_devicesconnection, fu_preview, fu_capture, fu_msg, fu_visu, fu_frame,
  fu_starprofile, fu_filterwheel, fu_focuser, fu_mount, fu_ccdtemp,
  pu_devicesetup, pu_options, pu_filtername, pu_indigui, cu_fits, cu_camera,
  cu_wheel, cu_mount, cu_focuser, XMLConf, u_utils, u_global,
  lazutf8sysutils, Classes, SysUtils, FileUtil, Forms, Controls,
  Math, Graphics, Dialogs, ExtCtrls, Menus, ComCtrls;

type

  { Tf_main }

  Tf_main = class(TForm)
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuFilterName: TMenuItem;
    MenuIndiSettings: TMenuItem;
    MenuAscomSettings: TMenuItem;
    MenuOpen: TMenuItem;
    MenuSave: TMenuItem;
    N6: TMenuItem;
    MenuViewFrame: TMenuItem;
    N5: TMenuItem;
    MenuOptions: TMenuItem;
    MenuViewCCDtemp: TMenuItem;
    N4: TMenuItem;
    MenuResetTools: TMenuItem;
    N3: TMenuItem;
    MenuViewFilters: TMenuItem;
    MenuViewStarProfile: TMenuItem;
    MenuViewFocuser: TMenuItem;
    MenuViewMount: TMenuItem;
    MenuViewMessages: TMenuItem;
    MenuViewPreview: TMenuItem;
    MenuViewCapture: TMenuItem;
    MenuViewHistogram: TMenuItem;
    MenuViewConnection: TMenuItem;
    MenuViewhdr: TMenuItem;
    MenuQuit: TMenuItem;
    MenuSetup: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    OpenDialog1: TOpenDialog;
    PanelCenter: TPanel;
    PanelRight: TPanel;
    PanelLeft: TPanel;
    PanelTop: TPanel;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    ConnectTimer: TTimer;
    StatusbarTimer: TTimer;
    procedure ConnectTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1Paint(Sender: TObject);
    procedure Image1Resize(Sender: TObject);
    procedure MenuFilterNameClick(Sender: TObject);
    procedure MenuIndiSettingsClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MenuOptionsClick(Sender: TObject);
    procedure MenuResetToolsClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure MenuViewCCDtempClick(Sender: TObject);
    procedure MenuViewConnectionClick(Sender: TObject);
    procedure MenuViewFiltersClick(Sender: TObject);
    procedure MenuViewFocuserClick(Sender: TObject);
    procedure MenuViewFrameClick(Sender: TObject);
    procedure MenuViewhdrClick(Sender: TObject);
    procedure MenuQuitClick(Sender: TObject);
    procedure MenuSetupClick(Sender: TObject);
    procedure MenuViewHistogramClick(Sender: TObject);
    procedure MenuViewMessagesClick(Sender: TObject);
    procedure MenuViewMountClick(Sender: TObject);
    procedure MenuViewPreviewClick(Sender: TObject);
    procedure MenuViewCaptureClick(Sender: TObject);
    procedure MenuViewStarProfileClick(Sender: TObject);
    procedure PanelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PanelDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure StatusbarTimerTimer(Sender: TObject);
  private
    { private declarations }
    camera: T_camera;
    wheel: T_wheel;
    focuser: T_focuser;
    mount: T_mount;
    CameraName,WheelName,FocuserName,MountName: string;
    WantCamera,WantWheel,WantFocuser,WantMount: boolean;
    f_devicesconnection: Tf_devicesconnection;
    f_filterwheel: Tf_filterwheel;
    f_ccdtemp: Tf_ccdtemp;
    f_frame: Tf_frame;
    f_preview: Tf_preview;
    f_capture: Tf_capture;
    f_starprofile: Tf_starprofile;
    f_focuser: Tf_focuser;
    f_mount: Tf_mount;
    f_visu: Tf_visu;
    f_msg: Tf_msg;
    fits: TFits;
    ImaBmp: TBitmap;
    ImgScale0: double;
    ImgCx, ImgCy, OrigX, OrigY, Mx, My,Starwindow,Focuswindow: integer;
    StartX, StartY, EndX, EndY: integer;
    FrameX,FrameY,FrameW,FrameH: integer;
    ImgFrameX,ImgFrameY,ImgFrameW,ImgFrameH: integer;
    MouseMoving, MouseFrame, LockMouse: boolean;
    Capture,Preview,PreviewLoop: boolean;
    LogToFile,LogFileOpen: Boolean;
    NeedRestart, GUIready: boolean;
    LogFile: string;
    MsgLog: Textfile;
    Procedure InitLog;
    Procedure CloseLog;
    Procedure WriteLog( buf : string);
    procedure SetTool(tool:TFrame; configname: string; defaultParent: TPanel; defaultpos: integer; amenu: TMenuItem);
    procedure SetConfig;
    procedure SetOptions;
    procedure Restart;
    procedure GUIdestroy(Sender: TObject);
    Procedure Connect(Sender: TObject);
    Procedure Disconnect(Sender: TObject);
    Procedure CheckConnectionStatus;
    Procedure ConnectCamera(Sender: TObject);
    Procedure DisconnectCamera(Sender: TObject);
    procedure SetCameraActiveDevices;
    procedure ShowBinningRange;
    procedure ShowFrameRange;
    procedure ShowFrame;
    procedure SetFrame(Sender: TObject);
    procedure ResetFrame(Sender: TObject);
    Procedure FrameChange(Sender: TObject);
    procedure ShowExposureRange;
    procedure ShowTemperatureRange;
    procedure SetTemperature(Sender: TObject);
    procedure SetFocusMode;
    Procedure ConnectWheel(Sender: TObject);
    Procedure DisconnectWheel(Sender: TObject);
    Procedure ConnectFocuser(Sender: TObject);
    Procedure DisconnectFocuser(Sender: TObject);
    Procedure ConnectMount(Sender: TObject);
    Procedure DisconnectMount(Sender: TObject);
    Procedure SetFilter(Sender: TObject);
    Procedure NewMessage(msg: string);
    Procedure CameraStatus(Sender: TObject);
    procedure CameraProgress(n:double);
    procedure CameraTemperatureChange(t:double);
    Procedure WheelStatus(Sender: TObject);
    procedure FilterChange(n:double);
    procedure FilterNameChange(Sender: TObject);
    Procedure FocusStart(Sender: TObject);
    Procedure FocusStop(Sender: TObject);
    Procedure FocuserStatus(Sender: TObject);
    procedure FocuserPositionChange(n:double);
    procedure FocuserSpeedChange(n:double);
    procedure FocuserTimerChange(n:double);
    procedure FocusIN(Sender: TObject);
    procedure FocusOUT(Sender: TObject);
    Procedure MountStatus(Sender: TObject);
    Procedure MountCoordChange(Sender: TObject);
    procedure CameraNewImage(Sender: TObject);
    Procedure AbortExposure(Sender: TObject);
    Procedure StartPreviewExposure(Sender: TObject);
    Procedure StartCaptureExposure(Sender: TObject);
    Procedure RedrawHistogram(Sender: TObject);
    Procedure Redraw(Sender: TObject);
    Procedure ZoomImage(Sender: TObject);
    Procedure ClearImage;
    Procedure DrawImage;
    Procedure PlotImage;
    Procedure DrawHistogram;
    procedure Screen2Fits(x,y: integer; out xx,yy:integer);
    procedure Screen2CCD(x,y: integer; out xx,yy:integer);
    procedure Fits2Screen(x,y: integer; out xx,yy: integer);
  public
    { public declarations }
  end;

var
  f_main: Tf_main;

implementation

{$R *.lfm}

{ Tf_main }

Procedure Tf_main.InitLog;
begin
  try
     LogFile:=slash(GetAppConfigDirUTF8(false,true))+'Log_'+FormatDateTime('yyyymmdd_hhnnss',now)+'.log';
     Filemode:=2;
     AssignFile(MsgLog,LogFile);
     Rewrite(MsgLog);
     WriteLn(MsgLog,FormatDateTime(dateiso,Now)+'  Start new log');
     LogFileOpen:=true;
  except
  {$I-}
     LogFileOpen:=false;
     LogToFile:=false;
     CloseFile(MsgLog);
     IOResult;
  {$I+}
  end;
end;

Procedure Tf_main.CloseLog;
begin
  try
    if LogFileOpen then begin
      LogFileOpen:=false;
      CloseFile(MsgLog);
    end;
  except
    {$I-}
    IOResult;
    {$I+}
  end;
end;

Procedure Tf_main.WriteLog( buf : string);
begin
  try
    if LogToFile then begin
     if not LogFileOpen then begin
        InitLog;
        if not LogFileOpen then exit;
     end;
     WriteLn(MsgLog,FormatDateTime(dateiso,Now)+'  '+UTF8ToSys(buf));
     Flush(MsgLog);
    end;
  except
    {$I-}
    LogFileOpen:=false;
    LogToFile:=false;
    CloseFile(MsgLog);
    {$I+}
  end;
end;

procedure Tf_main.Restart;
begin
  ShowMessage('The program will restart now...');
  NeedRestart:=true;
  Close;
end;

procedure Tf_main.SetTool(tool:TFrame; configname: string; defaultParent: TPanel; defaultpos: integer; amenu: TMenuItem);
var pn: string;
    i: integer;
    par: Tpanel;
begin
pn:=config.GetValue('/Tools/'+configname+'/Parent',defaultParent.Name);
par:=defaultParent;
for i:=0 to ComponentCount-1 do begin
   if Components[i].Name=pn then begin
      par:=TPanel(Components[i]);
      break;
   end;
end;
if par.Width>par.Height then begin
   tool.Align:=alLeft;
end else begin
   tool.Align:=alTop;
end;
tool.Top:=config.GetValue('/Tools/'+widestring(configname)+'/Top',defaultpos);
tool.Left:=config.GetValue('/Tools/'+widestring(configname)+'/Left',defaultpos);
tool.Parent:=par;
tool.Visible:=config.GetValue('/Tools/'+widestring(configname)+'/Visible',true);
amenu.Checked:=tool.Visible;
end;

procedure Tf_main.FormCreate(Sender: TObject);
var DefaultInterface: TDevInterface;
begin
  {$ifdef mswindows}
  DefaultInterface:=ASCOM;
  {$else}
  DefaultInterface:=INDI;
  {$endif}
  NeedRestart:=false;
  GUIready:=false;
  ConfigExtension:= '.conf';
  config:=TCCDConfig.Create(self);
  config.Filename:=GetAppConfigFileUTF8(false,true,true);
  LogFile:=slash(GetAppConfigDirUTF8(false,true))+'Log_'+FormatDateTime('yyyymmdd_hhnnss',now)+'.log';
  LogFileOpen:=false;

  Top:=config.GetValue('/Window/Top',0);
  Left:=config.GetValue('/Window/Left',0);
  Width:=config.GetValue('/Window/Width',1024);
  Height:=config.GetValue('/Window/Height',768);

  camera:=T_camera.Create(TDevInterface(config.GetValue('/CameraInterface',ord(DefaultInterface))));
  camera.onMsg:=@NewMessage;
  camera.onExposureProgress:=@CameraProgress;
  camera.onFrameChange:=@FrameChange;
  camera.onTemperatureChange:=@CameraTemperatureChange;
  camera.onNewImage:=@CameraNewImage;
  camera.onStatusChange:=@CameraStatus;

  wheel:=T_wheel.Create(TDevInterface(config.GetValue('/FilterWheelInterface',ord(DefaultInterface))));
  wheel.camera:=camera;
  wheel.onMsg:=@NewMessage;
  wheel.onFilterChange:=@FilterChange;
  wheel.onFilterNameChange:=@FilterNameChange;
  wheel.onStatusChange:=@WheelStatus;

  focuser:=T_focuser.Create(TDevInterface(config.GetValue('/FocuserInterface',ord(DefaultInterface))));
  focuser.onMsg:=@NewMessage;
  focuser.onPositionChange:=@FocuserPositionChange;
  focuser.onSpeedChange:=@FocuserSpeedChange;
  focuser.onTimerChange:=@FocuserTimerChange;
  focuser.onStatusChange:=@FocuserStatus;

  mount:=T_mount.Create(TDevInterface(config.GetValue('/MountInterface',ord(DefaultInterface))));
  mount.onMsg:=@NewMessage;
  mount.onCoordChange:=@MountCoordChange;
  mount.onStatusChange:=@MountStatus;

  f_devicesconnection:=Tf_devicesconnection.Create(self);
  f_devicesconnection.onConnect:=@Connect;

  f_visu:=Tf_visu.Create(self);
  f_visu.onRedraw:=@Redraw;
  f_visu.onZoom:=@ZoomImage;
  f_visu.onRedrawHistogram:=@RedrawHistogram;

  f_msg:=Tf_msg.Create(self);

  f_frame:=Tf_frame.Create(self);
  f_frame.onSet:=@SetFrame;
  f_frame.onReset:=@ResetFrame;

  f_preview:=Tf_preview.Create(self);
  f_preview.onStartExposure:=@StartPreviewExposure;
  f_preview.onAbortExposure:=@AbortExposure;
  f_preview.onMsg:=@NewMessage;

  f_capture:=Tf_capture.Create(self);
  f_capture.onStartExposure:=@StartCaptureExposure;
  f_capture.onAbortExposure:=@AbortExposure;
  f_capture.onMsg:=@NewMessage;

  f_filterwheel:=Tf_filterwheel.Create(self);
  f_filterwheel.onSetFilter:=@SetFilter;

  f_focuser:=Tf_focuser.Create(self);
  f_focuser.onFocusIN:=@FocusIN;
  f_focuser.onFocusOUT:=@FocusOUT;

  f_starprofile:=Tf_starprofile.Create(self);
  f_starprofile.onFocusStart:=@FocusStart;
  f_starprofile.onFocusStop:=@FocusStop;

  f_ccdtemp:=Tf_ccdtemp.Create(self);
  f_ccdtemp.onSetTemperature:=@SetTemperature;

  f_mount:=Tf_mount.Create(self);

  fits:=TFits.Create(self);

  SetConfig;
  SetOptions;

  f_ccdtemp.Setpoint.Text:=config.GetValue('/Temperature/Setpoint','0');
  f_preview.ExpTime.Text:=config.GetValue('/Preview/Exposure','1');
  f_capture.ExpTime.Text:=config.GetValue('/Capture/Exposure','1');
  f_capture.Fname.Text:=config.GetValue('/Capture/FileName','');
  f_capture.SeqNum.Text:=config.GetValue('/Capture/Count','1');

  ImaBmp:=TBitmap.Create;
  LockMouse:=false;
  ImgCx:=0;
  ImgCy:=0;
  StartX:=0;
  StartY:=0;
  EndX:=0;
  EndY:=0;
  Capture:=false;
  Preview:=false;
  PreviewLoop:=false;
  MenuIndiSettings.Enabled:=(camera.CameraInterface=INDI);
  MenuAscomSettings.Enabled:=(camera.CameraInterface=ASCOM);

  NewMessage('Initialized');
end;

procedure Tf_main.FormShow(Sender: TObject);
begin
  SetTool(f_devicesconnection,'Connection',PanelTop,0,MenuViewConnection);
  SetTool(f_visu,'Histogram',PanelTop,f_devicesconnection.left+1,MenuViewHistogram);
  SetTool(f_msg,'Messages',PanelTop,f_visu.left+1,MenuViewMessages);

  SetTool(f_preview,'Preview',PanelRight,0,MenuViewPreview);
  SetTool(f_capture,'Capture',PanelRight,f_preview.top+1,MenuViewCapture);
  SetTool(f_filterwheel,'Filters',PanelRight,f_capture.top+1,MenuViewFilters);
  SetTool(f_frame,'Frame',PanelRight,f_filterwheel.top+1,MenuViewFrame);

  SetTool(f_focuser,'Focuser',PanelLeft,0,MenuViewFocuser);
  SetTool(f_starprofile,'Starprofile',PanelLeft,f_focuser.top+1,MenuViewStarProfile);
  SetTool(f_ccdtemp,'CCDTemp',PanelLeft,f_starprofile.top+1,MenuViewCCDtemp);
  SetTool(f_mount,'Mount',PanelLeft,f_ccdtemp.top+1,MenuViewMount);

  StatusBar1.Visible:=false; // bug with statusbar visibility
  StatusbarTimer.Enabled:=true;
end;

procedure Tf_main.StatusbarTimerTimer(Sender: TObject);
begin
 StatusbarTimer.Enabled:=false;
 StatusBar1.Visible:=true;  // bug with statusbar visibility
end;

procedure Tf_main.MenuResetToolsClick(Sender: TObject);
begin
  SetTool(f_devicesconnection,'',PanelTop,0,MenuViewConnection);
  SetTool(f_visu,'',PanelTop,f_devicesconnection.left+1,MenuViewHistogram);
  SetTool(f_msg,'',PanelTop,f_visu.left+1,MenuViewMessages);

  SetTool(f_preview,'',PanelRight,0,MenuViewPreview);
  SetTool(f_capture,'',PanelRight,f_preview.top+1,MenuViewCapture);
  SetTool(f_filterwheel,'',PanelRight,f_capture.top+1,MenuViewFilters);
  SetTool(f_frame,'',PanelRight,f_filterwheel.top+1,MenuViewFrame);

  SetTool(f_focuser,'',PanelLeft,0,MenuViewFocuser);
  SetTool(f_starprofile,'',PanelLeft,f_focuser.top+1,MenuViewStarProfile);
  SetTool(f_ccdtemp,'',PanelLeft,f_starprofile.top+1,MenuViewCCDtemp);
  SetTool(f_mount,'',PanelLeft,f_ccdtemp.top+1,MenuViewMount);
end;

procedure Tf_main.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  config.SetValue('/Tools/Connection/Parent',f_devicesconnection.Parent.Name);
  config.SetValue('/Tools/Connection/Visible',f_devicesconnection.Visible);
  config.SetValue('/Tools/Connection/Top',f_devicesconnection.Top);
  config.SetValue('/Tools/Connection/Left',f_devicesconnection.Left);

  config.SetValue('/Tools/Histogram/Parent',f_visu.Parent.Name);
  config.SetValue('/Tools/Histogram/Visible',f_visu.Visible);
  config.SetValue('/Tools/Histogram/Top',f_visu.Top);
  config.SetValue('/Tools/Histogram/Left',f_visu.Left);

  config.SetValue('/Tools/Messages/Parent',f_msg.Parent.Name);
  config.SetValue('/Tools/Messages/Visible',f_msg.Visible);
  config.SetValue('/Tools/Messages/Top',f_msg.Top);
  config.SetValue('/Tools/Messages/Left',f_msg.Left);

  config.SetValue('/Tools/Focuser/Parent',f_focuser.Parent.Name);
  config.SetValue('/Tools/Focuser/Visible',f_focuser.Visible);
  config.SetValue('/Tools/Focuser/Top',f_focuser.Top);
  config.SetValue('/Tools/Focuser/Left',f_focuser.Left);

  config.SetValue('/Tools/Starprofile/Parent',f_starprofile.Parent.Name);
  config.SetValue('/Tools/Starprofile/Visible',f_starprofile.Visible);
  config.SetValue('/Tools/Starprofile/Top',f_starprofile.Top);
  config.SetValue('/Tools/Starprofile/Left',f_starprofile.Left);

  config.SetValue('/Tools/Frame/Parent',f_frame.Parent.Name);
  config.SetValue('/Tools/Frame/Visible',f_frame.Visible);
  config.SetValue('/Tools/Frame/Top',f_frame.Top);
  config.SetValue('/Tools/Frame/Left',f_frame.Left);

  config.SetValue('/Tools/Preview/Parent',f_preview.Parent.Name);
  config.SetValue('/Tools/Preview/Visible',f_preview.Visible);
  config.SetValue('/Tools/Preview/Top',f_preview.Top);
  config.SetValue('/Tools/Preview/Left',f_preview.Left);

  config.SetValue('/Tools/Capture/Parent',f_capture.Parent.Name);
  config.SetValue('/Tools/Capture/Visible',f_capture.Visible);
  config.SetValue('/Tools/Capture/Top',f_capture.Top);
  config.SetValue('/Tools/Capture/Left',f_capture.Left);

  config.SetValue('/Tools/Filters/Parent',f_filterwheel.Parent.Name);
  config.SetValue('/Tools/Filters/Visible',f_filterwheel.Visible);
  config.SetValue('/Tools/Filters/Top',f_filterwheel.Top);
  config.SetValue('/Tools/Filters/Left',f_filterwheel.Left);

  config.SetValue('/Tools/CCDTemp/Parent',f_ccdtemp.Parent.Name);
  config.SetValue('/Tools/CCDTemp/Visible',f_ccdtemp.Visible);
  config.SetValue('/Tools/CCDTemp/Top',f_ccdtemp.Top);
  config.SetValue('/Tools/CCDTemp/Left',f_ccdtemp.Left);

  config.SetValue('/Tools/Mount/Parent',f_mount.Parent.Name);
  config.SetValue('/Tools/Mount/Visible',f_mount.Visible);
  config.SetValue('/Tools/Mount/Top',f_mount.Top);
  config.SetValue('/Tools/Mount/Left',f_mount.Left);

  config.SetValue('/Window/Top',Top);
  config.SetValue('/Window/Left',Left);
  config.SetValue('/Window/Width',Width);
  config.SetValue('/Window/Height',Height);

  config.SetValue('/Temperature/Setpoint',f_ccdtemp.Setpoint.Text);
  config.SetValue('/Preview/Exposure',f_preview.ExpTime.Text);
  config.SetValue('/Capture/Exposure',f_capture.ExpTime.Text);
  config.SetValue('/Capture/FileName',f_capture.Fname.Text);
  config.SetValue('/Capture/Count',f_capture.SeqNum.Text);

  config.Flush;
  NewMessage('Program exit');
  CloseLog;
  CloseAction:=caFree;
end;

procedure Tf_main.FormDestroy(Sender: TObject);
begin
  camera.Free;
  wheel.Free;
  focuser.Free;
  mount.Free;
  ImaBmp.Free;
  config.Free;
  if NeedRestart then ExecNoWait(paramstr(0));
end;

procedure Tf_main.Image1DblClick(Sender: TObject);
var x,y: integer;
begin
 Screen2fits(Mx,My,x,y);
 x:=x-(Starwindow div 2);
 y:=y-(Starwindow div 2);
 f_starprofile.showprofile(fits.image,fits.imageC,fits.imageMin,x,y,Starwindow,fits.HeaderInfo.naxis1,fits.HeaderInfo.naxis2);
 Image1.Invalidate;
end;

procedure Tf_main.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Shift=[ssLeft] then begin
   if f_visu.Zoom>0 then begin
     Mx:=X;
     My:=y;
     MouseMoving:=true;
     screen.Cursor:=crHandPoint;
   end;
 end else if ssShift in Shift then begin
   if EndX>0 then begin
      Image1.Canvas.Frame(StartX,StartY,EndX,EndY);
   end;
   MouseFrame:=true;
   Startx:=X;
   Starty:=y;
   EndX:=-1;
   EndY:=-1
 end;

end;

procedure Tf_main.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var xx,yy: integer;
    val:integer;
begin
if LockMouse then exit;
 if MouseMoving then begin
    LockMouse:=true;
    ImgCx:=ImgCx+round((X-Mx) / f_visu.Zoom);
    ImgCy:=ImgCy+round((Y-My) / f_visu.Zoom);
    PlotImage;
    LockMouse:=false;
 end
 else if MouseFrame then begin
    Image1.Canvas.Pen.Color:=clWhite;
    Image1.Canvas.Pen.Mode:=pmXor;
    if EndX>0 then begin
       Image1.Canvas.Frame(StartX,StartY,EndX,EndY);
    end;
    EndX:=X;
    EndY:=Y;
    Image1.Canvas.Frame(StartX,StartY,EndX,EndY);
 end
 else if (fits.HeaderInfo.naxis1>0) then begin
    Screen2fits(x,y,xx,yy);
    if (xx>0)and(xx<fits.HeaderInfo.naxis1)and(yy>0)and(yy<fits.HeaderInfo.naxis2) then
       val:=trunc(fits.imageMin+fits.image[0,yy,xx]/fits.imageC)
    else val:=0;
    StatusBar1.Panels[0].Text:=inttostr(xx)+'/'+inttostr(yy)+': '+inttostr(val);
end;
Mx:=X;
My:=Y;
end;

procedure Tf_main.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var xx,x1,y1,x2,y2,w,h: integer;
begin
if MouseMoving then begin
  ImgCx:=ImgCx+X-Mx;
  ImgCy:=ImgCy+Y-My;
  PlotImage;
  Mx:=X;
  My:=Y;
end;
if MouseFrame then begin
  EndX:=X;
  EndY:=Y;
  Screen2CCD(StartX,StartY,x1,y1);
  Screen2CCD(EndX,EndY,x2,y2);
  if x1>x2 then begin
    xx:=x1; x1:=x2; x2:=xx;
  end;
  if y1>y2 then begin
    xx:=y1; y1:=y2; y2:=xx;
  end;
  w:=x2-x1;
  h:=y2-y1;
  f_frame.FX.Text:=inttostr(x1);
  f_frame.FY.Text:=inttostr(y1);
  f_frame.FWidth.Text:=inttostr(w);
  f_frame.FHeight.Text:=inttostr(h);
end;
MouseMoving:=false;
MouseFrame:=false;
screen.Cursor:=crDefault;
end;

procedure Tf_main.ConnectTimerTimer(Sender: TObject);
begin
  ConnectTimer.Enabled:=false;
  // Thing to do after all devices are connected
  SetCameraActiveDevices;
  ShowTemperatureRange;
  ShowExposureRange;
  ShowBinningRange;
  ShowFrameRange;
  SetFocusMode;
end;

procedure Tf_main.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
if camera.Status<>devDisconnected then begin
   CanClose:=(MessageDlg('The camera is connected. Do you want to exit the program now?',mtConfirmation,mbYesNo,0)=mrYes);
end else begin
   CanClose:=true;
end;
if CanClose then begin
 AbortExposure(nil);
end;
end;

procedure Tf_main.Image1Resize(Sender: TObject);
begin
  image1.Picture.Bitmap.SetSize(image1.Width,image1.Height);
  ClearImage;
  DrawImage;
end;

procedure Tf_main.SetConfig;
begin
case camera.CameraInterface of
   INDI : CameraName:=config.GetValue('/INDIcamera/Device','');
   ASCOM: CameraName:=config.GetValue('/ASCOMcamera/Device','');
end;
case wheel.WheelInterface of
   INCAMERA: WheelName:=CameraName;
   INDI : WheelName:=config.GetValue('/INDIwheel/Device','');
   ASCOM: WheelName:=config.GetValue('/ASCOMwheel/Device','');
end;
case focuser.FocuserInterface of
   INDI : FocuserName:=config.GetValue('/INDIfocuser/Device','');
   ASCOM: FocuserName:=config.GetValue('/ASCOMfocuser/Device','');
end;
case mount.MountInterface of
   INDI : MountName:=config.GetValue('/INDImount/Device','');
   ASCOM: MountName:=config.GetValue('/ASCOMmount/Device','');
end;
end;

procedure Tf_main.SetOptions;
begin
  Starwindow:=config.GetValue('/StarAnalysis/Window',20);
  Focuswindow:=config.GetValue('/StarAnalysis/Focus',200);
  LogToFile:=config.GetValue('/Log/Messages',true);
  if LogToFile<>LogFileOpen then CloseLog;
end;

Procedure Tf_main.Connect(Sender: TObject);
begin
if f_devicesconnection.BtnConnect.Caption='Disconnect' then begin
  Disconnect(Sender);
end else begin
  WantCamera:=true;
  WantWheel:=config.GetValue('/Devices/FilterWheel',false);
  WantFocuser:=config.GetValue('/Devices/Focuser',false);;
  WantMount:=config.GetValue('/Devices/Mount',false);;

  if WantCamera and (CameraName='') then begin
    ShowMessage('Please configure your camera!');
    MenuSetup.Click;
    exit;
  end;
  if WantWheel and (WheelName='') then begin
    ShowMessage('Please configure your filter wheel!');
    MenuSetup.Click;
    exit;
  end;
  if WantFocuser and (FocuserName='') then begin
    ShowMessage('Please configure your focuser!');
    MenuSetup.Click;
    exit;
  end;
  if WantMount and (MountName='') then begin
    ShowMessage('Please configure your mount!');
    MenuSetup.Click;
    exit;
  end;

  f_devicesconnection.LabelCamera.Visible:=WantCamera;
  f_devicesconnection.LabelWheel.Visible:=WantWheel;
  f_devicesconnection.LabelFocuser.Visible:=WantFocuser;
  f_devicesconnection.LabelMount.Visible:=WantMount;
  f_devicesconnection.PanelDev.Visible:=true;

  if WantCamera  then ConnectCamera(Sender);
  if WantWheel   then ConnectWheel(Sender);
  if WantFocuser then ConnectFocuser(Sender);
  if WantMount   then ConnectMount(Sender);
end;
end;

Procedure Tf_main.Disconnect(Sender: TObject);
begin
if camera.Status<>devDisconnected then begin
   if (sender=nil) or (MessageDlg('Are you sure you want to disconnect all the devices now?',mtConfirmation,mbYesNo,0)=mrYes) then begin
     camera.AbortExposure;
     f_preview.stop;
     f_capture.stop;
     Capture:=false;
     StatusBar1.Panels[1].Text:='';
     DisconnectCamera(Sender);
     DisconnectWheel(Sender);
     DisconnectFocuser(Sender);
     DisconnectMount(Sender);
   end;
end;
end;

Procedure Tf_main.CheckConnectionStatus;
var allcount, upcount, downcount, concount: integer;
procedure SetDisconnected;
begin
f_devicesconnection.led.Brush.Color:=clRed;
f_devicesconnection.BtnConnect.Caption:='Connect';
end;
procedure SetConnected;
begin
f_devicesconnection.led.Brush.Color:=clLime;
f_devicesconnection.BtnConnect.Caption:='Disconnect';
end;
procedure SetConnecting;
begin
f_devicesconnection.led.Brush.Color:=clYellow;
f_devicesconnection.BtnConnect.Caption:='Disconnect';
end;

begin
allcount:=0; upcount:=0; downcount:=0; concount:=0;
 if WantCamera then begin
  inc(allcount);
  case camera.Status of
    devConnected: inc(upcount);
    devDisconnected: inc(downcount);
    devConnecting: inc(concount);
  end;
 end;
 if WantWheel then begin
  inc(allcount);
  case wheel.Status of
    devConnected: inc(upcount);
    devDisconnected: inc(downcount);
    devConnecting: inc(concount);
  end;
 end;

 if allcount=0 then SetDisconnected
 else if (upcount=allcount) then begin
   SetConnected;
   ConnectTimer.Enabled:=true;
 end
 else if concount>0 then SetConnecting
 else SetDisconnected;
end;

Procedure Tf_main.ConnectCamera(Sender: TObject);
begin
   case camera.CameraInterface of
    INDI : camera.Connect(config.GetValue('/INDI/Server',''),
                          config.GetValue('/INDI/ServerPort',''),
                          config.GetValue('/INDIcamera/Device',''),
                          config.GetValue('/INDIcamera/Sensor',''),
                          config.GetValue('/INDIcamera/DevicePort',''));
    ASCOM: camera.Connect(config.GetValue('/ASCOMcamera/Device',''));
  end;
end;

Procedure Tf_main.DisconnectCamera(Sender: TObject);
begin
 camera.Disconnect;
end;

procedure Tf_main.SetCameraActiveDevices;
var fn,wn,mn: string;
begin
 if WantFocuser then fn:=FocuserName else fn:='';
 if WantWheel then wn:=WheelName else wn:='';
 if WantMount then mn:=MountName else mn:='';
 camera.SetActiveDevices(fn,wn,mn);
end;

procedure Tf_main.ShowTemperatureRange;
var buf: string;
begin
  f_ccdtemp.Current.Text:=FormatFloat(f1,camera.Temperature);
  buf:=FormatFloat(f0,camera.TemperatureRange.min)+'...'+FormatFloat(f0,camera.TemperatureRange.max);
  f_ccdtemp.Setpoint.Hint:='Desired temperature'+crlf+buf;
end;

procedure Tf_main.SetTemperature(Sender: TObject);
var t: double;
begin
  t:=StrToFloatDef(f_ccdtemp.Setpoint.Text,-1000);
  if t<>-1000 then begin
     camera.Temperature:=t;
  end;
end;

procedure Tf_main.ShowExposureRange;
var buf: string;
begin
 buf:=FormatFloat(f0,camera.ExposureRange.min)+'...'+FormatFloat(f0,camera.ExposureRange.max);
 buf:='Exposure time in secondes'+crlf+buf;
 f_capture.ExpTime.Hint:=buf;
 f_preview.ExpTime.Hint:=buf;
end;

procedure Tf_main.ShowFrame;
var x,y,w,h: integer;
begin
 camera.GetFrame(x,y,w,h);
 if (x<>FrameX)or(y<>FrameY)or(w<>FrameW)or(h<>FrameH) then begin
   FrameX:=x;
   FrameY:=y;
   FrameW:=w;
   FrameH:=h;
   f_frame.FX.Text:=inttostr(FrameX);
   f_frame.FY.Text:=inttostr(FrameY);
   f_frame.FWidth.Text:=inttostr(FrameW);
   f_frame.FHeight.Text:=inttostr(FrameH);
   NewMessage('Camera frame x='+f_frame.FX.Text+' y='+f_frame.FY.Text+' width='+f_frame.FWidth.Text+' height='+f_frame.FHeight.Text);
 end;
end;

procedure Tf_main.ShowFrameRange;
var rx,ry,rw,rh:TNumRange;
begin
 camera.GetFrameRange(rx,ry,rw,rh);
 f_frame.FX.Hint:=FormatFloat(f0,rx.min)+'...'+FormatFloat(f0,rx.max);
 f_frame.FY.Hint:=FormatFloat(f0,ry.min)+'...'+FormatFloat(f0,ry.max);
 f_frame.FWidth.Hint:=FormatFloat(f0,rw.min)+'...'+FormatFloat(f0,rw.max);
 f_frame.FHeight.Hint:=FormatFloat(f0,rh.min)+'...'+FormatFloat(f0,rh.max);
 ShowFrame;
end;

Procedure Tf_main.FrameChange(Sender: TObject);
begin
 ShowFrame;
end;

procedure Tf_main.SetFrame(Sender: TObject);
var x,y,w,h: integer;
begin
  x:=StrToIntDef(f_frame.FX.Text,-1);
  y:=StrToIntDef(f_frame.FY.Text,-1);
  w:=StrToIntDef(f_frame.FWidth.Text,-1);
  h:=StrToIntDef(f_frame.FHeight.Text,-1);
  if (x<0)or(y<0)or(w<0)or(h<0) then
     NewMessage('Invalid frame values')
  else
     camera.SetFrame(x,y,w,h);
end;

procedure Tf_main.ResetFrame(Sender: TObject);
begin
  camera.ResetFrame;
end;

procedure Tf_main.ShowBinningRange;
var rxmin,rxmax,rxstep,rymin,rymax,rystep: integer;
    i,j:integer;
begin
 rxmin:=round(camera.BinXrange.min);
 rxmax:=round(camera.BinXrange.max);
 rxstep:=round(camera.BinXrange.step);
 rymin:=round(camera.BinYrange.min);
 rymax:=round(camera.BinYrange.max);
 rystep:=round(camera.BinYrange.step);
 if rxmin<1 then rxmin:=1;
 if rxmax<rxmin then rxmax:=rxmin;
 if rxmax>8 then rxmax:=8;
 if rxstep<1 then rxstep:=1;
 if rymin<1 then rymin:=1;
 if rymax<rxmin then rymax:=rymin;
 if rymax>8 then rymax:=8;
 if rystep<1 then rystep:=1;
 f_preview.Binning.Clear;
 f_capture.Binning.Clear;
 i:=rxmin;
 while i<=rxmax do begin
   j:=rymin;
   while j<=rymax do begin
     if i=j then begin  // only "square" binning in combobox list
       f_preview.Binning.Items.Add(inttostr(i)+'x'+inttostr(j));
       f_capture.Binning.Items.Add(inttostr(i)+'x'+inttostr(j));
     end;
     inc(j,rystep);
   end;
   inc(i,rxstep);
 end;
 f_preview.Binning.ItemIndex:=0;
 f_capture.Binning.ItemIndex:=0;
end;

Procedure Tf_main.ConnectWheel(Sender: TObject);
begin
  case wheel.WheelInterface of
    INCAMERA : wheel.Connect;
    INDI : wheel.Connect(config.GetValue('/INDI/Server',''),
                          config.GetValue('/INDI/ServerPort',''),
                          config.GetValue('/INDIwheel/Device',''),
                          config.GetValue('/INDIwheel/DevicePort',''));
    ASCOM: wheel.Connect(config.GetValue('/ASCOMwheel/Device',''));
  end;
end;

Procedure Tf_main.DisconnectWheel(Sender: TObject);
begin
wheel.Disconnect;
end;

Procedure Tf_main.ConnectFocuser(Sender: TObject);
begin
  case focuser.FocuserInterface of
    INDI : focuser.Connect(config.GetValue('/INDI/Server',''),
                          config.GetValue('/INDI/ServerPort',''),
                          config.GetValue('/INDIfocuser/Device',''),
                          config.GetValue('/INDIfocuser/DevicePort',''));
    ASCOM: focuser.Connect(config.GetValue('/ASCOMfocuser/Device',''));
  end;
end;

Procedure Tf_main.DisconnectFocuser(Sender: TObject);
begin
focuser.Disconnect;
end;

procedure Tf_main.SetFocusMode;
begin
  if focuser.hasAbsolutePosition then begin
     f_focuser.PanelAbsPos.Visible:=true;
     f_focuser.PanelTimerMove.Visible:=false;
  end else begin
     f_focuser.PanelAbsPos.Visible:=false;
     f_focuser.PanelTimerMove.Visible:=true;
  end;
end;

Procedure Tf_main.ConnectMount(Sender: TObject);
begin
  case mount.MountInterface of
    INDI : mount.Connect(config.GetValue('/INDI/Server',''),
                          config.GetValue('/INDI/ServerPort',''),
                          config.GetValue('/INDImount/Device',''),
                          config.GetValue('/INDImount/DevicePort',''));
    ASCOM: mount.Connect(config.GetValue('/ASCOMmount/Device',''));
  end;
end;

Procedure Tf_main.DisconnectMount(Sender: TObject);
begin
mount.Disconnect;
end;

procedure Tf_main.NewMessage(msg: string);
begin
  if f_msg.msg.Lines.Count>100 then f_msg.msg.Lines.Delete(0);
  f_msg.msg.Lines.Add(FormatDateTime('hh:nn:ss',now)+':'+msg);
  f_msg.msg.SelStart:=f_msg.msg.GetTextLen-1;
  f_msg.msg.SelLength:=0;
  f_msg.msg.ScrollBy(0,f_msg.msg.Lines.Count);
  if LogToFile then begin
    WriteLog(msg);
  end;
end;

Procedure Tf_main.CameraStatus(Sender: TObject);
var bx,by: integer;
    buf: string;
begin
 case camera.Status of
   devDisconnected:begin
                   f_preview.stop;
                   f_capture.stop;
                   Capture:=false;
                   StatusBar1.Panels[1].Text:='';
                   f_devicesconnection.LabelCamera.Font.Color:=clRed;
                   end;
   devConnecting:  begin
                   NewMessage('Connecting camera...');
                   f_devicesconnection.LabelCamera.Font.Color:=clOrange;
                   end;
   devConnected:   begin
                   NewMessage('Camera connected');
                   bx:=camera.BinX;
                   by:=camera.BinY;
                   buf:=inttostr(bx)+'x'+inttostr(by);
                   f_preview.Binning.Text:=buf;
                   f_devicesconnection.LabelCamera.Font.Color:=clGreen;
                   end;
 end;
 CheckConnectionStatus;
end;

procedure  Tf_main.CameraTemperatureChange(t:double);
begin
 f_ccdtemp.Current.Text:=FormatFloat(f1,t);
end;

Procedure Tf_main.WheelStatus(Sender: TObject);
begin
case wheel.Status of
  devDisconnected:begin
                      f_devicesconnection.LabelWheel.Font.Color:=clRed;
                  end;
  devConnecting:  begin
                      NewMessage('Connecting filter wheel...');
                      f_devicesconnection.LabelWheel.Font.Color:=clOrange;
                   end;
  devConnected:   begin
                      NewMessage('Filter wheel connected');
                      f_devicesconnection.LabelWheel.Font.Color:=clGreen;
                      f_filterwheel.Filters.Items.Assign(wheel.FilterNames);
                      if (wheel.Filter>0)and(wheel.Filter<=f_filterwheel.Filters.Items.Count) then
                         f_filterwheel.Filters.ItemIndex:=round(wheel.Filter)-1;
                   end;
end;
CheckConnectionStatus;
end;

Procedure Tf_main.SetFilter(Sender: TObject);
begin
  wheel.Filter:=f_filterwheel.Filters.ItemIndex+1;
end;

procedure Tf_main.FilterChange(n:double);
begin
if (n>0)and(n<=f_filterwheel.Filters.Items.Count) then
   f_filterwheel.Filters.ItemIndex:=round(n)-1;
end;

procedure Tf_main.FilterNameChange(Sender: TObject);
begin
f_filterwheel.Filters.Items.Assign(wheel.FilterNames);
if (wheel.Filter>0)and(wheel.Filter<=f_filterwheel.Filters.Items.Count) then
   f_filterwheel.Filters.ItemIndex:=round(wheel.Filter)-1;
end;

procedure Tf_main.MenuFilterNameClick(Sender: TObject);
var i:integer;
    k: string;
    fn:TStringList;
begin
  if wheel.Status=devConnected then begin
     f_filtername.FilterList.Clear;
     f_filtername.FilterList.RowCount:=wheel.FilterNames.Count+1;
     for i:=1 to wheel.FilterNames.Count do begin
        k:=inttostr(i);
        f_filtername.FilterList.Keys[i]:=k;
        f_filtername.FilterList.Values[k]:=wheel.FilterNames[i-1];
     end;
     f_filtername.ShowModal;
     if f_filtername.ModalResult=mrOK then begin
       fn:=TStringList.Create;
       fn.Clear;
       for i:=1 to wheel.FilterNames.Count do begin
          k:=inttostr(i);
          fn.Add(f_filtername.FilterList.Values[k]);
       end;
       wheel.FilterNames:=fn;
       fn.Free;
     end;
  end
  else NewMessage('Please connect the filter wheel first');
end;

Procedure Tf_main.FocuserStatus(Sender: TObject);
begin
case focuser.Status of
  devDisconnected:begin
                      f_devicesconnection.LabelFocuser.Font.Color:=clRed;
                  end;
  devConnecting:  begin
                      NewMessage('Connecting focuser...');
                      f_devicesconnection.LabelFocuser.Font.Color:=clOrange;
                   end;
  devConnected:   begin
                      NewMessage('Focuser connected');
                      f_devicesconnection.LabelFocuser.Font.Color:=clGreen;
                      f_focuser.Position.Text:=inttostr(focuser.Position);
                      f_focuser.speed.Text:=inttostr(focuser.Speed);
                      f_focuser.timer.Text:=inttostr(focuser.Timer);
                   end;
end;
CheckConnectionStatus;
end;

procedure Tf_main.FocuserPositionChange(n:double);
begin
  f_focuser.Position.Text:=inttostr(round(n));
end;

procedure Tf_main.FocuserSpeedChange(n:double);
begin
  f_focuser.speed.Text:=inttostr(round(n));
end;

procedure Tf_main.FocuserTimerChange(n:double);
begin
  f_focuser.timer.Text:=inttostr(round(n));
end;

procedure Tf_main.FocusIN(Sender: TObject);
var n:integer;
begin
 if focuser.hasAbsolutePosition then begin
    focuser.Position:=focuser.Position-StrToIntDef(f_focuser.PosIncr.Text,1000);
 end else begin
    n:=StrToIntDef(f_focuser.speed.Text,-1);
    if n>0 then focuser.Speed:=n;
    focuser.FocusIn;
    n:=StrToIntDef(f_focuser.timer.Text,-1);
    if n>0 then focuser.Timer:=n;
 end;
end;

procedure Tf_main.FocusOUT(Sender: TObject);
var n:integer;
begin
 if focuser.hasAbsolutePosition then begin
   focuser.Position:=focuser.Position+StrToIntDef(f_focuser.PosIncr.Text,1000);
 end else begin
   n:=StrToIntDef(f_focuser.speed.Text,-1);
   if n>0 then focuser.Speed:=n;
   focuser.FocusOut;
   n:=StrToIntDef(f_focuser.timer.Text,-1);
   if n>0 then focuser.Timer:=n;
 end;
end;

Procedure Tf_main.MountStatus(Sender: TObject);
begin
case mount.Status of
  devDisconnected:begin
                      f_devicesconnection.LabelMount.Font.Color:=clRed;
                  end;
  devConnecting:  begin
                      NewMessage('Connecting mount...');
                      f_devicesconnection.LabelMount.Font.Color:=clOrange;
                   end;
  devConnected:   begin
                      NewMessage('Mount connected');
                      f_devicesconnection.LabelMount.Font.Color:=clGreen;
                      MountCoordChange(Sender);
                   end;
end;
CheckConnectionStatus;
end;

Procedure Tf_main.MountCoordChange(Sender: TObject);
begin
 f_mount.RA.Text:=RAToStr(mount.RA);
 f_mount.DE.Text:=DEToStr(mount.Dec);
end;

procedure Tf_main.MenuViewhdrClick(Sender: TObject);
begin
  fits.ViewHeaders;
end;

procedure Tf_main.MenuQuitClick(Sender: TObject);
begin
  Close;
end;

procedure Tf_main.MenuSetupClick(Sender: TObject);
begin
  if camera.Status<>devDisconnected then begin
    ShowMessage('Disconnect the camera before to change the configuration.');
    exit;
  end;

  f_setup.ConnectionInterface:=TDevInterface(config.GetValue('/Interface',ord(camera.CameraInterface)));
  f_setup.IndiServer.Text:=config.GetValue('/INDI/Server','localhost');
  f_setup.IndiPort.Text:=config.GetValue('/INDI/ServerPort','7624');

  f_setup.DeviceList.Checked[0]:=true;
  f_setup.DeviceList.Checked[1]:=config.GetValue('/Devices/FilterWheel',false);
  f_setup.DeviceList.Checked[2]:=config.GetValue('/Devices/Focuser',false);;
  f_setup.DeviceList.Checked[3]:=config.GetValue('/Devices/Mount',false);;

  f_setup.CameraConnection:=TDevInterface(config.GetValue('/CameraInterface',ord(camera.CameraInterface)));
  if f_setup.CameraIndiDevice.Items.Count=0 then begin
    f_setup.CameraIndiDevice.Items.Add(config.GetValue('/INDIcamera/Device',''));
    f_setup.CameraIndiDevice.ItemIndex:=0;
  end;
  f_setup.CameraIndiDevice.Text:=config.GetValue('/INDIcamera/Device','');
  f_setup.CameraSensor:=config.GetValue('/INDIcamera/Sensor','');
  f_setup.CameraIndiDevPort.Text:=config.GetValue('/INDIcamera/DevicePort','');
  f_setup.AscomCamera.Text:=config.GetValue('/ASCOMcamera/Device','');

  f_setup.WheelConnection:=TDevInterface(config.GetValue('/FilterWheelInterface',ord(wheel.WheelInterface)));
  if f_setup.WheelIndiDevice.Items.Count=0 then begin
    f_setup.WheelIndiDevice.Items.Add(config.GetValue('/INDIwheel/Device',''));
    f_setup.WheelIndiDevice.ItemIndex:=0;
  end;
  f_setup.WheelIndiDevice.Text:=config.GetValue('/INDIwheel/Device','');
  f_setup.WheelIndiDevPort.Text:=config.GetValue('/INDIwheel/DevicePort','');
  f_setup.AscomWheel.Text:=config.GetValue('/ASCOMwheel/Device','');

  f_setup.FocuserConnection:=TDevInterface(config.GetValue('/FocuserInterface',ord(focuser.FocuserInterface)));
  if f_setup.FocuserIndiDevice.Items.Count=0 then begin
    f_setup.FocuserIndiDevice.Items.Add(config.GetValue('/INDIfocuser/Device',''));
    f_setup.FocuserIndiDevice.ItemIndex:=0;
  end;
  f_setup.FocuserIndiDevice.Text:=config.GetValue('/INDIfocuser/Device','');
  f_setup.FocuserIndiDevPort.Text:=config.GetValue('/INDIfocuser/DevicePort','');
  f_setup.AscomFocuser.Text:=config.GetValue('/ASCOMfocuser/Device','');

  f_setup.MountConnection:=TDevInterface(config.GetValue('/MountInterface',ord(mount.MountInterface)));
  if f_setup.MountIndiDevice.Items.Count=0 then begin
    f_setup.MountIndiDevice.Items.Add(config.GetValue('/INDImount/Device',''));
    f_setup.MountIndiDevice.ItemIndex:=0;
  end;
  f_setup.MountIndiDevice.Text:=config.GetValue('/INDImount/Device','');
  f_setup.MountIndiDevPort.Text:=config.GetValue('/INDImount/DevicePort','');
  f_setup.AscomMount.Text:=config.GetValue('/ASCOMmount/Device','');

  f_setup.ShowModal;
  if f_setup.ModalResult=mrOK then begin
    config.SetValue('/Interface',ord(f_setup.ConnectionInterface));
    config.SetValue('/INDI/Server',f_setup.IndiServer.Text);
    config.SetValue('/INDI/ServerPort',f_setup.IndiPort.Text);

    config.SetValue('/Devices/Camera',f_setup.DeviceList.Checked[0]);
    config.SetValue('/Devices/FilterWheel',f_setup.DeviceList.Checked[1]);
    config.SetValue('/Devices/Focuser',f_setup.DeviceList.Checked[2]);;
    config.SetValue('/Devices/Mount',f_setup.DeviceList.Checked[3]);;

    config.SetValue('/CameraInterface',ord(f_setup.CameraConnection));
    if f_setup.CameraIndiDevice.Text<>'' then config.SetValue('/INDIcamera/Device',f_setup.CameraIndiDevice.Text);
    config.SetValue('/INDIcamera/Sensor',f_setup.CameraSensor);
    config.SetValue('/INDIcamera/DevicePort',f_setup.CameraIndiDevPort.Text);
    config.SetValue('/ASCOMcamera/Device',f_setup.AscomCamera.Text);

    config.SetValue('/FilterWheelInterface',ord(f_setup.WheelConnection));
    if f_setup.WheelIndiDevice.Text<>'' then config.SetValue('/INDIwheel/Device',f_setup.WheelIndiDevice.Text);
    config.SetValue('/INDIwheel/DevicePort',f_setup.WheelIndiDevPort.Text);
    config.SetValue('/ASCOMwheel/Device',f_setup.AscomWheel.Text);

    config.SetValue('/FocuserInterface',ord(f_setup.FocuserConnection));
    if f_setup.FocuserIndiDevice.Text<>'' then config.SetValue('/INDIfocuser/Device',f_setup.FocuserIndiDevice.Text);
    config.SetValue('/INDIfocuser/DevicePort',f_setup.FocuserIndiDevPort.Text);
    config.SetValue('/ASCOMfocuser/Device',f_setup.AscomFocuser.Text);

    config.SetValue('/MountInterface',ord(f_setup.MountConnection));
    if f_setup.MountIndiDevice.Text<>'' then config.SetValue('/INDImount/Device',f_setup.MountIndiDevice.Text);
    config.SetValue('/INDImount/DevicePort',f_setup.MountIndiDevPort.Text);
    config.SetValue('/ASCOMmount/Device',f_setup.AscomMount.Text);

    config.Flush;

    if f_setup.RestartRequired then
       Restart
    else
       SetConfig;
  end;
end;

procedure Tf_main.MenuOptionsClick(Sender: TObject);
begin
   f_option.CaptureDir.Text:=config.GetValue('/Files/CapturePath',defCapturePath);
   f_option.Logtofile.Checked:=config.GetValue('/Log/Messages',true);
   f_option.Logtofile.Hint:='Log files are saved in '+ExtractFilePath(LogFile);
   f_option.StarWindow.Text:=inttostr(config.GetValue('/StarAnalysis/Window',Starwindow));
   f_option.FocusWindow.Text:=inttostr(config.GetValue('/StarAnalysis/Focus',Focuswindow));

   f_option.ShowModal;

   if f_option.ModalResult=mrOK then begin
     config.SetValue('/Files/CapturePath',f_option.CaptureDir.Text);
     config.SetValue('/StarAnalysis/Window',StrToIntDef(f_option.StarWindow.Text,Starwindow));
     config.SetValue('/StarAnalysis/Focus',StrToIntDef(f_option.FocusWindow.Text,Focuswindow));
     config.SetValue('/Log/Messages',f_option.Logtofile.Checked);

     config.Flush;

     SetOptions;
   end;
end;

procedure Tf_main.MenuViewConnectionClick(Sender: TObject);
begin
  f_devicesconnection.Visible:=MenuViewConnection.Checked;
end;

procedure Tf_main.MenuViewFiltersClick(Sender: TObject);
begin
  f_filterwheel.Visible:=MenuViewFilters.Checked;
end;

procedure Tf_main.MenuViewCCDtempClick(Sender: TObject);
begin
  f_ccdtemp.Visible:=MenuViewCCDtemp.Checked;
end;

procedure Tf_main.MenuViewFocuserClick(Sender: TObject);
begin
  f_focuser.Visible:=MenuViewFocuser.Checked;
end;

procedure Tf_main.MenuViewFrameClick(Sender: TObject);
begin
  f_frame.Visible:=MenuViewFrame.Checked;
end;

procedure Tf_main.MenuViewHistogramClick(Sender: TObject);
begin
  f_visu.Visible:=MenuViewHistogram.Checked;
end;

procedure Tf_main.MenuViewMessagesClick(Sender: TObject);
begin
  f_msg.Visible:=MenuViewMessages.Checked;
end;

procedure Tf_main.MenuViewMountClick(Sender: TObject);
begin
  f_mount.Visible:=MenuViewMount.Checked;
end;

procedure Tf_main.MenuViewPreviewClick(Sender: TObject);
begin
  f_preview.Visible:=MenuViewPreview.Checked;
end;

procedure Tf_main.MenuViewCaptureClick(Sender: TObject);
begin
  f_capture.Visible:=MenuViewCapture.Checked;
end;

procedure Tf_main.MenuViewStarProfileClick(Sender: TObject);
begin
  f_starprofile.Visible:=MenuViewStarProfile.Checked;
end;

procedure Tf_main.PanelDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
if sender is TPanel then begin
  TFrame(TDragObject(Source).Control).Parent:=TPanel(Sender);
  TFrame(TDragObject(Source).Control).Top:=Y;
  TFrame(TDragObject(Source).Control).Left:=X;
  if TPanel(Sender).Width>TPanel(Sender).Height then begin
     TFrame(TDragObject(Source).Control).Align:=alLeft;
  end else begin
     TFrame(TDragObject(Source).Control).Align:=alTop;
  end;
end;
end;

procedure Tf_main.PanelDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
 if Source is TDragObject then begin
   Accept:=TDragObject(Source).Control is TFrame;
 end;
end;

Procedure Tf_main.AbortExposure(Sender: TObject);
begin
  camera.AbortExposure;
  Preview:=false;
  Capture:=false;
  NewMessage('Abort exposure');
  StatusBar1.Panels[1].Text:='Stop';
end;

Procedure Tf_main.StartPreviewExposure(Sender: TObject);
var e: double;
    buf: string;
    p,binx,biny: integer;
begin
if (camera.Status=devConnected) and (not Capture) then begin
  Preview:=true;
  PreviewLoop:=f_preview.Loop;
  e:=StrToFloatDef(f_preview.ExpTime.Text,-1);
  if (e<camera.ExposureRange.min)or(e>camera.ExposureRange.max) then begin
    NewMessage('Invalid exposure time '+f_preview.ExpTime.Text);
    f_preview.stop;
    Preview:=false;
    exit;
  end;
  p:=pos('x',f_preview.Binning.Text);
  if p>0 then begin
     buf:=trim(copy(f_preview.Binning.Text,1,p-1));
     binx:=StrToIntDef(buf,-1);
     buf:=trim(copy(f_preview.Binning.Text,p+1,9));
     biny:=StrToIntDef(buf,-1);
     if (binx<camera.BinXrange.min)or(biny<camera.BinYrange.min) or
        (binx>camera.BinXrange.max)or(biny>camera.BinYrange.max)
         then begin
           NewMessage('Invalid binning '+f_preview.Binning.Text);
           f_preview.stop;
           Preview:=false;
           exit;
         end;
     if (camera.BinX<>binx)or(camera.BinY<>biny) then
        camera.SetBinning(binx,biny);
  end;
  if camera.FrameType<>LIGHT then camera.FrameType:=LIGHT;
  camera.StartExposure(e);
end
else begin
   f_preview.stop;
   Preview:=false;
   StatusBar1.Panels[1].Text:='';
end;
end;

Procedure Tf_main.StartCaptureExposure(Sender: TObject);
var e: double;
    buf: string;
    p,binx,biny: integer;
    ftype:TFrameType;
begin
if (camera.Status=devConnected) then begin
  if Preview then begin
    camera.AbortExposure;
    f_preview.stop;
    NewMessage('Stop preview');
    StatusBar1.Panels[1].Text:='';
  end;
  Preview:=false;
  Capture:=true;
  e:=StrToFloatDef(f_capture.ExpTime.Text,-1);
  if e<0 then begin
    NewMessage('Invalid exposure time '+f_capture.ExpTime.Text);
    f_capture.Stop;
    Capture:=false;
    exit;
  end;
  p:=pos('x',f_capture.Binning.Text);
  if p>0 then begin
     buf:=trim(copy(f_capture.Binning.Text,1,p-1));
     binx:=StrToIntDef(buf,-1);
     buf:=trim(copy(f_capture.Binning.Text,p+1,9));
     biny:=StrToIntDef(buf,-1);
     if (binx<camera.BinXrange.min)or(biny<camera.BinYrange.min) or
        (binx>camera.BinXrange.max)or(biny>camera.BinYrange.max)
        then begin
          NewMessage('Invalid binning '+f_capture.Binning.Text);
          f_capture.Stop;
          Capture:=false;
          exit;
        end;
     if (camera.BinX<>binx)or(camera.BinY<>biny) then
        camera.SetBinning(binx,biny);
  end;
  if (f_capture.FrameType.ItemIndex>=0)and(f_capture.FrameType.ItemIndex<=ord(High(TFrameType))) then begin
    ftype:=TFrameType(f_capture.FrameType.ItemIndex);
    if camera.FrameType<>ftype then camera.FrameType:=ftype;
  end;
  NewMessage('Starting '+f_capture.FrameType.Text+' exposure '+inttostr(f_capture.SeqCount)+' for '+f_capture.ExpTime.Text+' seconds');
  camera.StartExposure(e);
end
else begin
   f_capture.Stop;
   Capture:=false;
   StatusBar1.Panels[1].Text := '';
end;
end;

procedure Tf_main.CameraProgress(n:double);
var txt: string;
begin
  if n>=10 then txt:=FormatFloat(f0, n)
           else txt:=FormatFloat(f1, n);
  if Capture then begin
    if f_capture.Running then
      StatusBar1.Panels[1].Text := 'Seq: '+inttostr(f_capture.SeqCount)
                                   +'  Exp: '+txt+' sec.';
  end
  else if Preview then begin
     StatusBar1.Panels[1].Text := 'Exp: '+txt+' sec.';
  end;
end;

procedure Tf_main.CameraNewImage(Sender: TObject);
var dt: Tdatetime;
    fn,imgsize: string;
    i:integer;
begin
  dt:=NowUTC;
  ImgFrameX:=FrameX;
  ImgFrameY:=FrameY;
  ImgFrameW:=FrameW;
  ImgFrameH:=FrameH;
  fits.Stream:=camera.ImgStream;
  i:=fits.Header.Indexof('END');
  fits.Header.Insert(i,'TESTS','''Toto''','Test');
  inc(i);
  fits.Header.Insert(i,'TESTI',45,'Test');
  inc(i);
  fits.Header.Insert(i,'TESTF',45.56,'Test');
  inc(i);
  fits.Header.Insert(i,'COMMENT','Commentaire','');
  inc(i);
  fits.Header.Insert(i,'','Commentaire 2','');
  imgsize:=inttostr(fits.HeaderInfo.naxis1)+'x'+inttostr(fits.HeaderInfo.naxis2);
  DrawImage;
  DrawHistogram;
  if Capture then begin
     fn:=slash(config.GetValue('/Files/CapturePath',defCapturePath))
         +f_capture.Fname.Text+'_';
     if wheel.Status=devConnected then
         fn:=fn+wheel.FilterNames[wheel.Filter-1]+'_';
     fn:=fn+FormatDateTime('yyyymmdd_hhnnss',dt)
         +'.fits';
     camera.ImgStream.Position:=0;
     camera.ImgStream.SaveToFile(fn);
     NewMessage('Saved file '+fn);
     StatusBar1.Panels[2].Text:='Saved '+fn+' '+imgsize;
     f_capture.SeqCount:=f_capture.SeqCount+1;
     if f_capture.SeqCount<=StrToInt(f_capture.SeqNum.Text) then begin
        if f_capture.Running then StartCaptureExposure(nil);
     end else begin
        Capture:=false;
        f_capture.Stop;
        NewMessage('Stop capture');
        StatusBar1.Panels[1].Text := 'Seq: '+inttostr(f_capture.SeqCount-1)+' Finished';
     end;
  end
  else if Preview then begin
    StatusBar1.Panels[2].Text:='Preview '+FormatDateTime('hh:nn:ss',now)+'  '+imgsize;
    if f_preview.Loop and f_preview.Running then StartPreviewExposure(nil)
       else begin
         f_preview.stop;
         NewMessage('End preview');
         StatusBar1.Panels[1].Text:='';
    end;
  end;
end;

Procedure Tf_main.RedrawHistogram(Sender: TObject);
begin
  DrawHistogram;
end;

Procedure Tf_main.Redraw(Sender: TObject);
begin
  DrawImage;
  DrawHistogram;
end;

Procedure Tf_main.ZoomImage(Sender: TObject);
begin
  PlotImage;
end;


procedure Tf_main.Screen2Fits(x,y: integer; out xx,yy:integer);
begin
  if f_visu.Zoom=0.5 then begin
     xx:=(x * 2)-OrigX;
     yy:=(y * 2)-OrigY;
  end else if f_visu.Zoom=1 then begin
      xx:=x-OrigX;
      yy:=y-OrigY;
  end else if f_visu.Zoom=2 then begin
     xx:=(x div 2)-OrigX;
     yy:=(y div 2)-OrigY;
  end else  begin
     xx:=trunc(x/ImgScale0);
     yy:=trunc(y/ImgScale0);
  end;
end;

procedure Tf_main.Fits2Screen(x,y: integer; out xx,yy: integer);
begin
  if f_visu.Zoom=0 then begin
    xx:=round(x * ImgScale0);
    yy:=round(y * ImgScale0);
  end
  else if f_visu.Zoom=0.5 then begin
    xx:=(x+OrigX) div 2;
    yy:=(y+OrigY) div 2;
  end
  else if f_visu.Zoom=1 then begin
    xx:=x+OrigX;
    yy:=y+OrigY;
  end
  else if f_visu.Zoom=2 then begin
    xx:=2*(x+OrigX);
    yy:=2*(y+OrigY);
  end;
end;

procedure Tf_main.Screen2CCD(x,y: integer; out xx,yy:integer);
begin
   if f_visu.Zoom=0.5 then begin
     xx:=(x * 2)-OrigX;
     yy:=imabmp.Height-(y*2)+OrigY;
   end else if f_visu.Zoom=1 then begin
     xx:=x-OrigX;
     yy:=imabmp.Height-y+OrigY;
   end else if f_visu.Zoom=2 then begin
     xx:=(x div 2)-OrigX;
     yy:=imabmp.Height-(y div 2)+OrigY;
   end else  begin
     xx:=trunc(x/ImgScale0);
     yy:=trunc((image1.Height-y)/ImgScale0);
   end;
   xx:=xx+ImgFrameX;
   yy:=yy+ImgFrameY;
end;

Procedure Tf_main.DrawImage;
begin
if fits.HeaderInfo.naxis>0 then begin
  if f_visu.BtnLinear.Checked then fits.itt:=ittlinear
  else if f_visu.BtnLog.Checked then fits.itt:=ittlog
  else if f_visu.BtnSqrt.Checked then fits.itt:=ittsqrt;
  fits.ImgDmax:=f_visu.ImgMax*256;
  fits.ImgDmin:=f_visu.ImgMin*256;
  fits.GetIntfImg;
  fits.GetBitmap(ImaBmp);
  if f_starprofile.FindStar then
    f_starprofile.showprofile(fits.image,fits.imageC,fits.imageMin,round(f_starprofile.StarX),round(f_starprofile.StarY),Starwindow,fits.HeaderInfo.naxis1,fits.HeaderInfo.naxis2);
  PlotImage;
end;
end;

Procedure Tf_main.ClearImage;
begin
image1.Picture.Bitmap.Canvas.Brush.Color:=clDarkBlue;
image1.Picture.Bitmap.Canvas.Pen.Color:=clBlack;
image1.Picture.Bitmap.Canvas.FillRect(0,0,image1.Width,image1.Height);
end;

Procedure Tf_main.PlotImage;
var r1,r2: double;
    w,h,px,py: integer;
    bmp2:Tbitmap;
begin
ClearImage;
if f_visu.Zoom=0 then begin
  // adjust
  r1:=ImaBmp.Width/ImaBmp.Height;
  w:=image1.width;
  h:=image1.height;
  r2:=w/h;
  if r1>r2 then begin
    h:=trunc(w/r1);
    ImgScale0:=h/ImaBmp.Height;
  end else begin
    w:=trunc(h*r1);
    ImgScale0:=w/ImaBmp.Width;
  end;
  image1.Picture.Bitmap.Canvas.StretchDraw(rect(0,0,w,h),ImaBmp);
end
else if f_visu.Zoom=0.5 then begin
   // zoom 0.5
   bmp2:=Tbitmap.Create;
   bmp2.SetSize(Image1.Width * 2,Image1.Height * 2);
   bmp2.Canvas.Brush.Color:=clDarkBlue;
   bmp2.Canvas.Pen.Color:=clBlack;
   bmp2.Canvas.FillRect(0,0,bmp2.Width,bmp2.Height);
   px:=ImgCx-((ImaBmp.Width-bmp2.Width) div 2);
   py:=ImgCy-((ImaBmp.Height-bmp2.Height) div 2);
   OrigX:=px;
   OrigY:=py;
   bmp2.Canvas.Draw(px,py,ImaBmp);
   image1.Picture.Bitmap.Canvas.StretchDraw(rect(0,0,image1.width,image1.Height),bmp2);
   bmp2.Free;
end
else if f_visu.Zoom=1 then begin
   // zoom 1
   px:=ImgCx-((ImaBmp.Width-Image1.Width) div 2);
   py:=ImgCy-((ImaBmp.Height-Image1.Height) div 2);
   OrigX:=px;
   OrigY:=py;
   image1.Picture.Bitmap.Canvas.Draw(px,py,ImaBmp);
end
else if f_visu.Zoom=2 then begin
   // zoom 2
   bmp2:=Tbitmap.Create;
   bmp2.SetSize(Image1.Width div 2,Image1.Height div 2);
   bmp2.Canvas.Brush.Color:=clDarkBlue;
   bmp2.Canvas.Pen.Color:=clBlack;
   bmp2.Canvas.FillRect(0,0,bmp2.Width,bmp2.Height);
   px:=ImgCx-((ImaBmp.Width-bmp2.Width) div 2);
   py:=ImgCy-((ImaBmp.Height-bmp2.Height) div 2);
   OrigX:=px;
   OrigY:=py;
   bmp2.Canvas.Draw(px,py,ImaBmp);
   image1.Picture.Bitmap.Canvas.StretchDraw(rect(0,0,image1.width,image1.Height),bmp2);
   bmp2.Free;
end;
Application.ProcessMessages;
end;

procedure Tf_main.Image1Paint(Sender: TObject);
var x,y,s: integer;
begin
  Inherited paint;
  if f_starprofile.FindStar then begin
     Fits2Screen(round(f_starprofile.StarX),round(f_starprofile.StarY),x,y);
     if f_visu.Zoom=0      then s:=round(Starwindow * ImgScale0)
     else if f_visu.Zoom=0.5 then s:=Starwindow div 2
     else if f_visu.Zoom=1 then s:=Starwindow
     else if f_visu.Zoom=2 then s:=2*Starwindow;
     with Image1.Canvas do begin
        Pen.Color:=clLime;
        Frame(x-s,y-s,x+s,y+s);
     end;
  end;
end;

Procedure Tf_main.DrawHistogram;
begin
  if fits.HeaderInfo.naxis>0 then begin
     f_visu.DrawHistogram(fits.Histogram);
  end;
end;

procedure Tf_main.MenuIndiSettingsClick(Sender: TObject);
begin
  if not GUIready then begin
     f_indigui:=Tf_indigui.Create(self);
     f_indigui.onDestroy:=@GUIdestroy;
     f_indigui.IndiServer:=config.GetValue('/INDI/Server','');
     f_indigui.IndiPort:=config.GetValue('/INDI/ServerPort','');
     GUIready:=true;
  end;
  f_indigui.Show;
end;

procedure Tf_main.MenuOpenClick(Sender: TObject);
var mem: TMemoryStream;
    fn,imgsize: string;
begin
  if OpenDialog1.Execute then begin
     fn:=OpenDialog1.FileName;
     mem:=TMemoryStream.Create;
     mem.LoadFromFile(fn);
     fits.Stream:=mem;
     mem.free;
     DrawImage;
     DrawHistogram;
     imgsize:=inttostr(fits.HeaderInfo.naxis1)+'x'+inttostr(fits.HeaderInfo.naxis2);
     NewMessage('Open file '+fn);
     StatusBar1.Panels[2].Text:='Open file '+fn+' '+imgsize;
  end;
end;

procedure Tf_main.MenuSaveClick(Sender: TObject);
var fn: string;
begin
if fits.HeaderInfo.naxis>0 then begin
   if SaveDialog1.Execute then begin
      fn:=SaveDialog1.FileName;
      fits.Stream.SaveToFile(fn);
   end;
end;
end;

Procedure Tf_main.FocusStart(Sender: TObject);
var x,y,xc,yc,s,s2: integer;
begin
  if f_starprofile.FindStar then begin
     s:=Focuswindow;
     s2:=s div 2;
     Fits2Screen(round(f_starprofile.StarX),round(f_starprofile.StarY),x,y);
     Screen2CCD(x,y,xc,yc);
     camera.SetFrame(xc-s2,yc-s2,s,s);
     f_preview.Loop:=true;
     f_preview.Running:=true;
     f_starprofile.StarX:=s2;
     f_starprofile.StarY:=s2;
     NewMessage('Focus aid started');
     StartPreviewExposure(nil);
  end
  else begin
    f_starprofile.focus.Checked:=false;
    NewMessage('Select a star first!');
  end;
end;

Procedure Tf_main.FocusStop(Sender: TObject);
begin
   camera.ResetFrame;
   f_preview.Running:=false;
   f_preview.Loop:=false;
   StartPreviewExposure(nil);
   NewMessage('Focus aid stoped');
end;

procedure Tf_main.GUIdestroy(Sender: TObject);
begin
  GUIready:=false;
end;

end.


