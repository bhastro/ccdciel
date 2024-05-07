unit cu_indiweather;

{$mode objfpc}{$H+}

{
Copyright (C) 2018 Patrick Chevalley

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

uses cu_weather, indibaseclient, indibasedevice, indiapi, indicom, u_translation,
     u_global, ExtCtrls, Forms, Classes, SysUtils;

type

T_indiweather = class(T_weather)
 private
   indiclient: TIndiBaseClient;
   InitTimer: TTimer;
   ConnectTimer: TTimer;
   ReadyTimer: TTimer;
   WeatherDevice: Basedevice;
   connectprop: ISwitchVectorProperty;
   connecton,connectoff: ISwitch;
   WeatherStatusProp: ILightVectorProperty;
   configprop: ISwitchVectorProperty;
   configload,configsave: ISwitch;
   WeatherParamProp: INumberVectorProperty;
   wforecast,wtemp,wpressure,whumidity,wwindspeed,wwindgust,wrainhour,wcloud: INumber;
   Fready,Fconnected,FConnectDevice: boolean;
   Findiserver, Findiserverport, Findidevice: string;
   stClear: boolean;
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
   function  GetClear:boolean; override;
   procedure GetCapabilities; override;
   function GetCloudCover: double; override;
   function GetDewPoint: double; override;
   function GetHumidity: double; override;
   function GetPressure: double; override;
   function GetRainRate: double; override;
   function GetSkyBrightness: double; override;
   function GetSkyQuality: double; override;
   function GetSkyTemperature: double; override;
   function GetStarFWHM: double; override;
   function GetTemperature: double; override;
   function GetWindDirection: double; override;
   function GetWindGust: double; override;
   function GetWindSpeed: double; override;
   function GetWeatherStatus: boolean; override;
   function GetWeatherDetail: string; override;
   procedure SetTimeout(num:integer); override;
 public
   constructor Create(AOwner: TComponent);override;
   destructor  Destroy; override;
   Procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string=''; cp6:string='');  override;
   Procedure Disconnect; override;

end;

implementation

procedure T_indiweather.CreateIndiClient;
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

constructor T_indiweather.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FWeatherInterface:=INDI;
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

destructor  T_indiweather.Destroy;
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

procedure T_indiweather.ClearStatus;
begin
    WeatherDevice:=nil;
    WeatherStatusProp:=nil;
    connectprop:=nil;
    configprop:=nil;
    Fready:=false;
    Fconnected := false;
    FConnectDevice:=false;
    FStatus := devDisconnected;
    stClear:=false;
    if Assigned(FonStatusChange) then FonStatusChange(self);
end;

procedure T_indiweather.CheckStatus;
begin
    if Fconnected and
       (WeatherStatusProp<>nil)
    then begin
      ReadyTimer.Enabled := false;
      ReadyTimer.Enabled := true;
    end;
end;

procedure T_indiweather.ReadyTimerTimer(Sender: TObject);
begin
  ReadyTimer.Enabled := false;
  FStatus := devConnected;
  if (not Fready) then begin
    Fready:=true;
    if FAutoloadConfig and FConnectDevice then LoadConfig;
    GetCapabilities;
    if Assigned(FonStatusChange) then FonStatusChange(self);
  end;
end;

Procedure T_indiweather.Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string=''; cp6:string='');
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
else msg(' Weather already connected',0);
end;

procedure T_indiweather.InitTimerTimer(Sender: TObject);
begin
  InitTimer.Enabled:=false;
  if (WeatherDevice=nil)or(not Fready) then begin
    msg(rsError2,0);
    if not Fconnected then begin
      msg(rsNoResponseFr,0);
      msg('Is "'+Findidevice+'" a running weather driver?',0);
    end
    else if (configprop=nil) then
       msg('Weather '+Findidevice+' Missing property CONFIG_PROCESS',0)
    else if (WeatherStatusProp=nil) then
       msg('Weather '+Findidevice+' Missing property WEATHER_STATUS',0);
    Disconnect;
  end;
end;

Procedure T_indiweather.Disconnect;
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

procedure T_indiweather.ServerConnected(Sender: TObject);
begin
   ConnectTimer.Enabled:=True;
end;

procedure T_indiweather.ConnectTimerTimer(Sender: TObject);
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

procedure T_indiweather.ServerDisconnected(Sender: TObject);
begin
  FStatus := devDisconnected;
  if Assigned(FonStatusChange) then FonStatusChange(self);
  msg(rsServer+' '+rsDisconnected3,1);
end;

procedure T_indiweather.NewDevice(dp: Basedevice);
begin
  if dp.getDeviceName=Findidevice then begin
     msg('INDI server send new device: "'+dp.getDeviceName+'"',9);
     Fconnected:=true;
     WeatherDevice:=dp;
  end;
end;

procedure T_indiweather.DeleteDevice(dp: Basedevice);
begin
  if dp.getDeviceName=Findidevice then begin
     Disconnect;
  end;
end;

procedure T_indiweather.DeleteProperty(indiProp: IndiProperty);
begin
  { TODO :  check if a vital property is removed ? }
end;

procedure T_indiweather.NewMessage(mp: IMessage);
begin
  if Assigned(FonDeviceMsg) then FonDeviceMsg(Findidevice+': '+mp.msg);
  mp.free;
end;

procedure T_indiweather.NewProperty(indiProp: IndiProperty);
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
  else if (proptype=INDI_LIGHT)and(WeatherStatusProp=nil)and(propname='WEATHER_STATUS') then begin
     WeatherStatusProp:=indiProp.getLight;
  end
  else if (proptype=INDI_NUMBER)and(WeatherParamProp=nil)and(propname='WEATHER_PARAMETERS') then begin
     WeatherParamProp:=indiProp.getNumber;
     wforecast:=IUFindNumber(WeatherParamProp,'WEATHER_FORECAST');
     wtemp:=IUFindNumber(WeatherParamProp,'WEATHER_TEMPERATURE');
     wpressure:=IUFindNumber(WeatherParamProp,'WEATHER_PRESSURE');
     whumidity:=IUFindNumber(WeatherParamProp,'WEATHER_HUMIDITY');
     wwindspeed:=IUFindNumber(WeatherParamProp,'WEATHER_WIND_SPEED');
     wwindgust:=IUFindNumber(WeatherParamProp,'WEATHER_WIND_GUST');
     wrainhour:=IUFindNumber(WeatherParamProp,'WEATHER_RAIN_HOUR');
     wcloud:=IUFindNumber(WeatherParamProp,'WEATHER_CLOUDS');
     if wcloud=nil then wcloud:=IUFindNumber(WeatherParamProp,'WEATHER_CLOUD_COVER');
     if ObsWeather and (WeatherParamProp.s=IPS_OK) then begin
       if (wpressure<>nil)and(wpressure.Value<>0) then ObsPressure:=wpressure.Value;
       if (wtemp<>nil)and(wtemp.Value<>0) then ObsTemperature:=wtemp.Value;
       if (whumidity<>nil)and(whumidity.Value<>0) then ObsHumidity:=whumidity.Value;
     end;
  end;
  CheckStatus;
end;

procedure T_indiweather.NewNumber(nvp: INumberVectorProperty);
begin
  if ObsWeather and (nvp=WeatherParamProp) and (nvp.s=IPS_OK) then begin
    if (wpressure<>nil)and(wpressure.Value<>0) then ObsPressure:=wpressure.Value;
    if (wtemp<>nil)and(wtemp.Value<>0) then ObsTemperature:=wtemp.Value;
    if (whumidity<>nil)and(whumidity.Value<>0) then ObsHumidity:=whumidity.Value;
  end;
end;

procedure T_indiweather.NewText(tvp: ITextVectorProperty);
begin
//  writeln('NewText: '+tvp.name+' '+tvp.tp[0].text);
end;

procedure T_indiweather.NewSwitch(svp: ISwitchVectorProperty);
var sw: ISwitch;
begin
  if (svp.name='CONNECTION') then begin
    sw:=IUFindOnSwitch(svp);
    if (sw<>nil)and(sw.name='DISCONNECT') then begin
      Disconnect;
    end;
  end;
end;

procedure T_indiweather.NewLight(lvp: ILightVectorProperty);
var ok: boolean;
begin
  if lvp=WeatherStatusProp then begin
     ok:=GetWeatherStatus;
     if ok<>stClear then begin
       stClear:=ok;
       if Assigned(FonClearChange) then FonClearChange(self);
     end;
  end;
end;

function  T_indiweather.GetClear:Boolean;
begin
  // Use only WEATHER_STATUS, limit are set in INDI driver
  result:=WeatherStatus;
end;

procedure T_indiweather.GetCapabilities;
begin
 FhasCloudCover:=(wcloud<>nil);
 FhasDewPoint:=false;
 FhasHumidity:=(whumidity<>nil);
 FhasPressure:=(wpressure<>nil);
 FhasRainRate:=(wrainhour<>nil);
 FhasSkyBrightness:=false;
 FhasSkyQuality:=false;
 FhasSkyTemperature:=false;
 FhasStarFWHM:=false;
 FhasTemperature:=(wtemp<>nil);
 FhasWindDirection:=false;
 FhasWindGust:=(wwindgust<>nil);
 FhasWindSpeed:=(wwindspeed<>nil);
 FhasStatus:=(WeatherStatusProp<>nil);
end;

function T_indiweather.GetWeatherStatus: boolean;
var i: integer;
begin
 result:=false;
 if WeatherStatusProp<>nil then begin
    result:=WeatherStatusProp.s=IPS_OK;
    FWeatherMessage:='';
    if not result then
       for i:=0 to WeatherStatusProp.nlp-1 do begin
         if WeatherStatusProp.lp[i].s<>IPS_OK then
            FWeatherMessage:=FWeatherMessage+' '+WeatherStatusProp.lp[i].lbl;
       end;
 end;
end;

function T_indiweather.GetWeatherDetail: string;
var x: double;
begin
 result:='';
 if WeatherStatusProp<>nil then begin
    if FhasCloudCover then begin
       x:=CloudCover;
       result:=result+crlf+'CloudCover='+FormatFloat(f2,x);
    end;
    if FhasDewPoint then begin
       x:=DewPoint;
       result:=result+crlf+'DewPoint='+FormatFloat(f2,x);
    end;
    if FhasHumidity then begin
       x:=Humidity;
       result:=result+crlf+'Humidity='+FormatFloat(f2,x);
    end;
    if FhasPressure then begin
       x:=Pressure;
       result:=result+crlf+'Pressure='+FormatFloat(f2,x);
    end;
    if FhasRainRate then begin
       x:=RainRate;
       result:=result+crlf+'RainRate='+FormatFloat(f2,x);
    end;
    if FhasSkyBrightness then begin
       x:=SkyBrightness;
       result:=result+crlf+'SkyBrightness='+FormatFloat(f4,x);
    end;
    if FhasSkyQuality then begin
       x:=SkyQuality;
       result:=result+crlf+'SkyQuality='+FormatFloat(f2,x);
    end;
    if FhasSkyTemperature then begin
       x:=SkyTemperature;
       result:=result+crlf+'SkyTemperature='+FormatFloat(f2,x);
    end;
    if FhasStarFWHM then begin
       x:=StarFWHM;
       result:=result+crlf+'StarFWHM='+FormatFloat(f2,x);
    end;
    if FhasTemperature then begin
       x:=Temperature;
       result:=result+crlf+'Temperature='+FormatFloat(f2,x);
    end;
    if FhasWindDirection then begin
       x:=WindDirection;
       result:=result+crlf+'WindDirection='+FormatFloat(f2,x);
    end;
    if FhasWindGust then begin
       x:=WindGust;
       result:=result+crlf+'WindGust='+FormatFloat(f2,x);
    end;
    if FhasWindSpeed then begin
       x:=WindSpeed;
       result:=result+crlf+'WindSpeed='+FormatFloat(f2,x);
    end;
    result:=result+crlf;
 end;
 end;

function T_indiweather.GetCloudCover: double;
begin
 if (WeatherParamProp<>nil) and (wcloud<>nil) then
   result:=wcloud.Value
 else
   result:=NullCoord;
end;

function T_indiweather.GetDewPoint: double;
begin
 result:=NullCoord;
end;

function T_indiweather.GetHumidity: double;
begin
 if (WeatherParamProp<>nil) and (whumidity<>nil) then
   result:=whumidity.Value
 else
   result:=NullCoord;
end;

function T_indiweather.GetPressure: double;
begin
 if (WeatherParamProp<>nil) and (wpressure<>nil) then
   result:=wpressure.Value
 else
   result:=NullCoord;
end;

function T_indiweather.GetRainRate: double;
begin
 if (WeatherParamProp<>nil) and (wrainhour<>nil) then
   result:=wrainhour.Value
 else
   result:=NullCoord;
end;

function T_indiweather.GetSkyBrightness: double;
begin
 result:=NullCoord;
end;

function T_indiweather.GetSkyQuality: double;
begin
 result:=NullCoord;
end;

function T_indiweather.GetSkyTemperature: double;
begin
 result:=NullCoord;
end;

function T_indiweather.GetStarFWHM: double;
begin
 result:=NullCoord;
end;

function T_indiweather.GetTemperature: double;
begin
 if (WeatherParamProp<>nil) and (wtemp<>nil) then
   result:=wtemp.Value
 else
   result:=NullCoord;
end;

function T_indiweather.GetWindDirection: double;
begin
 result:=NullCoord;
end;

function T_indiweather.GetWindGust: double;
begin
 if (WeatherParamProp<>nil) and (wwindgust<>nil) then
   result:=wwindgust.Value
 else
   result:=NullCoord;
end;

function T_indiweather.GetWindSpeed: double;
begin
 if (WeatherParamProp<>nil) and (wwindspeed<>nil) then
   result:=wwindspeed.Value
 else
   result:=NullCoord;
end;

procedure T_indiweather.SetTimeout(num:integer);
begin
 FTimeOut:=num;
 if indiclient<>nil then indiclient.Timeout:=FTimeOut;
end;

procedure T_indiweather.LoadConfig;
begin
  if configprop<>nil then begin
    IUResetSwitch(configprop);
    configload.s:=ISS_ON;
    indiclient.sendNewSwitch(configprop);
  end;
end;



end.

