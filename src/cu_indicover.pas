unit cu_indicover;

{$mode objfpc}{$H+}

{
Copyright (C) 2021 Patrick Chevalley

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

interface

uses cu_cover, indibaseclient, indibasedevice, indiapi, indicom, u_translation,
     u_global, ExtCtrls, Forms, Classes, SysUtils;

type

T_indicover = class(T_cover)
 private
   indiclient: TIndiBaseClient;
   InitTimer: TTimer;
   ConnectTimer: TTimer;
   ReadyTimer: TTimer;
   connectprop: ISwitchVectorProperty;
   connecton,connectoff: ISwitch;
   CoverDevice: Basedevice;
   CoverStatus,LightStatus: ISwitchVectorProperty;
   CoverPark,CoverUnpark,LightOn,LightOff: ISwitch;
   LightIntensity: INumberVectorProperty;
   configprop: ISwitchVectorProperty;
   configload,configsave: ISwitch;
   Fready,Fconnected,FConnectDevice: boolean;
   Findiserver, Findiserverport, Findidevice: string;
   procedure CreateIndiClient;
   procedure InitTimerTimer(Sender: TObject);
   procedure ConnectTimerTimer(Sender: TObject);
   procedure ReadyTimerTimer(Sender: TObject);
   procedure ClearStatus;
   procedure CheckStatus;
   procedure NewDevice(dp: Basedevice);
   procedure NewMessage(mp: IMessage);
   procedure NewProperty(indiProp: IndiProperty);
   procedure NewNumber(nvp: INumberVectorProperty);
   procedure NewText(tvp: ITextVectorProperty);
   procedure NewSwitch(svp: ISwitchVectorProperty);
   procedure NewLight(lvp: ILightVectorProperty);
   procedure DeleteDevice(dp: Basedevice);
   procedure DeleteProperty(indiProp: IndiProperty);
   procedure ServerConnected(Sender: TObject);
   procedure ServerDisconnected(Sender: TObject);
   procedure LoadConfig;
 protected
   function GetCoverState: TCoverStatus; override;
   function GetCalibratorState: TCalibratorStatus; override;
   procedure SetTimeout(num:integer); override;
 public
   constructor Create(AOwner: TComponent);override;
   destructor  Destroy; override;
   Procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string=''; cp6:string='');  override;
   Procedure Disconnect; override;
   Procedure OpenCover; override;
   Procedure CloseCover; override;
   function GetBrightness: integer; override;
   Procedure CalibratorOn(value: integer); override;
   Procedure CalibratorOff; override;
end;

implementation

procedure T_indicover.CreateIndiClient;
begin
if csDestroying in ComponentState then exit;
  indiclient:=TIndiBaseClient.Create;
  indiclient.Timeout:=FTimeOut;
  indiclient.onNewDevice:=@NewDevice;
  indiclient.onNewMessage:=@NewMessage;
  indiclient.onNewProperty:=@NewProperty;
  indiclient.onNewNumber:=@NewNumber;
  indiclient.onNewText:=@NewText;
  indiclient.onNewSwitch:=@NewSwitch;
  indiclient.onNewLight:=@NewLight;
  indiclient.onDeleteDevice:=@DeleteDevice;
  indiclient.onDeleteProperty:=@DeleteProperty;
  indiclient.onServerConnected:=@ServerConnected;
  indiclient.onServerDisconnected:=@ServerDisconnected;
  ClearStatus;
end;

constructor T_indicover.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FCoverInterface:=INDI;
 ClearStatus;
 Findiserver:='localhost';
 Findiserverport:='7624';
 Findidevice:='';
 InitTimer:=TTimer.Create(nil);
 InitTimer.Enabled:=false;
 InitTimer.Interval:=60000;
 InitTimer.OnTimer:=@InitTimerTimer;
 ConnectTimer:=TTimer.Create(nil);
 ConnectTimer.Enabled:=false;
 ConnectTimer.Interval:=1000;
 ConnectTimer.OnTimer:=@ConnectTimerTimer;
 ReadyTimer:=TTimer.Create(nil);
 ReadyTimer.Enabled:=false;
 ReadyTimer.Interval:=2000;
 ReadyTimer.OnTimer:=@ReadyTimerTimer;
end;

destructor  T_indicover.Destroy;
begin
 InitTimer.Enabled:=false;
 ConnectTimer.Enabled:=false;
 ReadyTimer.Enabled:=false;
 if indiclient<>nil then indiclient.onServerDisconnected:=nil;
 FreeAndNil(InitTimer);
 FreeAndNil(ConnectTimer);
 FreeAndNil(ReadyTimer);
 inherited Destroy;
end;

procedure T_indicover.ClearStatus;
begin
    CoverDevice:=nil;
    CoverStatus:=nil;
    LightStatus:=nil;
    LightIntensity:=nil;
    connectprop:=nil;
    configprop:=nil;
    Fready:=false;
    Fconnected := false;
    FConnectDevice:=false;
    FStatus := devDisconnected;
    FHasCalibrator:=false;
    FHasCover:=false;
    if Assigned(FonStatusChange) then FonStatusChange(self);
end;

procedure T_indicover.CheckStatus;
begin
    if Fconnected and
       (CoverStatus<>nil)
    then begin
      ReadyTimer.Enabled := false;
      ReadyTimer.Enabled := true;
    end;
end;

procedure T_indicover.ReadyTimerTimer(Sender: TObject);
begin
  ReadyTimer.Enabled := false;
  FStatus := devConnected;
  if (not Fready) then begin
    Fready:=true;
    if FAutoloadConfig and FConnectDevice then LoadConfig;
    FHasCalibrator:=(LightStatus<>nil);
    FHasCover:=(CoverStatus<>nil);
    if Assigned(FonStatusChange) then FonStatusChange(self);
  end;
end;

Procedure T_indicover.Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string=''; cp6:string='');
begin
CreateIndiClient;
if not indiclient.Connected then begin
  Findiserver:=cp1;
  Findiserverport:=cp2;
  Findidevice:=cp3;
  Fdevice:=cp3;
  FStatus := devDisconnected;
  if Assigned(FonStatusChange) then FonStatusChange(self);
  msg('Connecting to INDI server "'+Findiserver+':'+Findiserverport+'" for device "'+Findidevice+'"',9);
  indiclient.SetServer(Findiserver,Findiserverport);
  indiclient.watchDevice(Findidevice);
  indiclient.ConnectServer;
  FStatus := devConnecting;
  if Assigned(FonStatusChange) then FonStatusChange(self);
  InitTimer.Enabled:=true;
end
else msg(' Cover already connected',0);
end;

procedure T_indicover.InitTimerTimer(Sender: TObject);
begin
  InitTimer.Enabled:=false;
  if (CoverDevice=nil)or(not Fready) then begin
    msg(rsError2,0);
    if not Fconnected then begin
      msg(rsNoResponseFr,0);
      msg('Is "'+Findidevice+'" a running cover driver?',0);
    end
    else if (configprop=nil) then
       msg('Cover '+Findidevice+' Missing property CONFIG_PROCESS',0)
    else if (CoverStatus=nil)and(LightStatus=nil) then
       msg('Cover '+Findidevice+' One of the property CAP_PARK or FLAT_LIGHT_CONTROL is required',0);
    Disconnect;
  end;
end;

Procedure T_indicover.Disconnect;
begin
InitTimer.Enabled:=False;
ConnectTimer.Enabled:=False;
try
if (indiclient<>nil)and(not indiclient.Terminated) then
  indiclient.Terminate;
except
end;
ClearStatus;
end;

procedure T_indicover.ServerConnected(Sender: TObject);
begin
   ConnectTimer.Enabled:=True;
end;

procedure T_indicover.ConnectTimerTimer(Sender: TObject);
begin
  ConnectTimer.Enabled:=False;
  if (connectprop<>nil) then begin
    if (connectoff.s=ISS_ON) then begin
      FConnectDevice:=true;
      indiclient.connectDevice(Findidevice);
      exit;
    end;
  end
  else begin
    ConnectTimer.Enabled:=true;
    exit;
  end;
end;

procedure T_indicover.ServerDisconnected(Sender: TObject);
begin
  FStatus := devDisconnected;
  if Assigned(FonStatusChange) then FonStatusChange(self);
  msg(rsServer+' '+rsDisconnected3,1);
end;

procedure T_indicover.NewDevice(dp: Basedevice);
begin
  if dp.getDeviceName=Findidevice then begin
     msg('INDI server send new device: "'+dp.getDeviceName+'"',9);
     Fconnected:=true;
     CoverDevice:=dp;
  end;
end;

procedure T_indicover.DeleteDevice(dp: Basedevice);
begin
  if dp.getDeviceName=Findidevice then begin
     Disconnect;
  end;
end;

procedure T_indicover.DeleteProperty(indiProp: IndiProperty);
begin
  { TODO :  check if a vital property is removed ? }
end;

procedure T_indicover.NewMessage(mp: IMessage);
begin
  if Assigned(FonDeviceMsg) then FonDeviceMsg(Findidevice+': '+mp.msg);
  mp.free;
end;

procedure T_indicover.NewProperty(indiProp: IndiProperty);
var propname: string;
    proptype: INDI_TYPE;
    TxtProp: ITextVectorProperty;
    Txt: IText;
    buf: string;
begin
  propname:=indiProp.getName;
  proptype:=indiProp.getType;

  if (proptype=INDI_TEXT)and(propname='DRIVER_INFO') then begin
     buf:='';
     TxtProp:=indiProp.getText;
     if TxtProp<>nil then begin
       Txt:=IUFindText(TxtProp,'DRIVER_EXEC');
       if Txt<>nil then buf:=buf+Txt.lbl+': '+Txt.Text+', ';
       Txt:=IUFindText(TxtProp,'DRIVER_VERSION');
       if Txt<>nil then buf:=buf+Txt.lbl+': '+Txt.Text+', ';
       Txt:=IUFindText(TxtProp,'DRIVER_INTERFACE');
       if Txt<>nil then buf:=buf+Txt.lbl+': '+Txt.Text;
       msg(buf,9);
     end;
  end
  else if (proptype=INDI_SWITCH)and(connectprop=nil)and(propname='CONNECTION') then begin
     connectprop:=indiProp.getSwitch;
     connecton:=IUFindSwitch(connectprop,'CONNECT');
     connectoff:=IUFindSwitch(connectprop,'DISCONNECT');
     if (connecton=nil)or(connectoff=nil) then connectprop:=nil;
  end
  else if (proptype=INDI_SWITCH)and(configprop=nil)and(propname='CONFIG_PROCESS') then begin
     configprop:=indiProp.getSwitch;
     configload:=IUFindSwitch(configprop,'CONFIG_LOAD');
     configsave:=IUFindSwitch(configprop,'CONFIG_SAVE');
     if (configload=nil)or(configsave=nil) then configprop:=nil;
  end
  else if (proptype=INDI_SWITCH)and(CoverStatus=nil)and(propname='CAP_PARK') then begin
     CoverStatus:=indiProp.getSwitch;
     CoverPark:=IUFindSwitch(CoverStatus,'PARK');
     CoverUnpark:=IUFindSwitch(CoverStatus,'UNPARK');
     if (CoverPark=nil)or(CoverUnpark=nil) then CoverStatus:=nil;
  end
  else if (proptype=INDI_SWITCH)and(LightStatus=nil)and(propname='FLAT_LIGHT_CONTROL') then begin
     LightStatus:=indiProp.getSwitch;
     LightOn:=IUFindSwitch(LightStatus,'FLAT_LIGHT_ON');
     LightOff:=IUFindSwitch(LightStatus,'FLAT_LIGHT_OFF');
     if (LightOn=nil)or(LightOff=nil) then LightStatus:=nil;
  end
  else if (proptype=INDI_NUMBER)and(LightIntensity=nil)and(propname='FLAT_LIGHT_INTENSITY') then begin
     LightIntensity:=indiProp.getNumber;
     FMaxBrightness:=round(LightIntensity.np[0].max);
  end;
  CheckStatus;
end;

procedure T_indicover.NewNumber(nvp: INumberVectorProperty);
begin
end;

procedure T_indicover.NewText(tvp: ITextVectorProperty);
begin
//  writeln('NewText: '+tvp.name+' '+tvp.tp[0].text);
end;

procedure T_indicover.NewSwitch(svp: ISwitchVectorProperty);
var sw: ISwitch;
begin
  if (svp.name='CONNECTION') then begin
    sw:=IUFindOnSwitch(svp);
    if (sw<>nil)and(sw.name='DISCONNECT') then begin
      Disconnect;
    end;
  end
  else if svp=CoverStatus then begin
    if Assigned(FonCoverChange) then FonCoverChange(self);
  end
  else if svp=LightStatus then begin
    if Assigned(FonCoverChange) then FonCoverChange(self);
  end;
end;

procedure T_indicover.NewLight(lvp: ILightVectorProperty);
begin
end;

function T_indicover.GetCoverState: TCoverStatus;
begin
 result:=covUnknown;
 if CoverStatus<>nil then begin
   if CoverStatus.s=IPS_BUSY then
      result:=covMoving
   else if CoverStatus.s=IPS_ALERT then
      result:=covError
   else begin
     if CoverPark.s=ISS_ON then
       result:=covClosed
     else
       result:=covOpen;
   end;
 end;
end;

function  T_indicover.GetCalibratorState: TCalibratorStatus;
begin
  result:=calUnknown;
  if LightStatus<>nil then begin
    if LightOn.s=ISS_ON then
      result:=calReady
    else
      result:=calOff;
  end;
end;

procedure T_indicover.SetTimeout(num:integer);
begin
 FTimeOut:=num;
  if indiclient<>nil then indiclient.Timeout:=FTimeOut;
end;

procedure T_indicover.LoadConfig;
begin
  if configprop<>nil then begin
    IUResetSwitch(configprop);
    configload.s:=ISS_ON;
    indiclient.sendNewSwitch(configprop);
  end;
end;


Procedure T_indicover.OpenCover;
begin
 if CoverStatus<>nil then begin
   IUResetSwitch(CoverStatus);
   CoverUnpark.s:=ISS_ON;
   indiclient.sendNewSwitch(CoverStatus);
 end;
end;

Procedure T_indicover.CloseCover;
begin
 if CoverStatus<>nil then begin
   IUResetSwitch(CoverStatus);
   CoverPark.s:=ISS_ON;
   indiclient.sendNewSwitch(CoverStatus);
 end;
end;

function T_indicover.GetBrightness: integer;
begin
 result:=0;
 if LightIntensity<>nil then begin
   result:=round(LightIntensity.np[0].Value);
 end;
end;

Procedure T_indicover.CalibratorOn(value: integer);
begin
 if LightIntensity<>nil then begin
   LightIntensity.np[0].Value:=value;
   indiclient.sendNewNumber(LightIntensity);
 end;
 if LightStatus<>nil then begin
   IUResetSwitch(LightStatus);
   LightOn.s:=ISS_ON;
   indiclient.sendNewSwitch(LightStatus);
 end;
end;

Procedure T_indicover.CalibratorOff;
begin
 if LightStatus<>nil then begin
   IUResetSwitch(LightStatus);
   LightOff.s:=ISS_ON;
   indiclient.sendNewSwitch(LightStatus);
 end;
end;

end.

