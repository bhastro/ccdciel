unit fu_internalguider;

{$mode objfpc}{$H+}

{
Copyright (C) 2022 Patrick Chevalley & Han Kleijn

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

uses   UScaleDPI, Dialogs, u_hints, u_translation, u_global,
  Classes, SysUtils, FileUtil, Forms, Graphics, Controls, StdCtrls, ExtCtrls, Spin,
  math,LCLintf, ComCtrls, Buttons, Menus;


type
  trend_info=record ra,dec,racorr,deccorr : double; dither:boolean; end;//for internal guider
  xy_guiderlist =array of trend_info;


type
  { Tf_internalguider }

  Tf_internalguider = class(TFrame)
    BtnZoom05: TSpeedButton;
    BtnZoom1: TSpeedButton;
    BtnZoom2: TSpeedButton;
    BtnZoomAdjust: TSpeedButton;
    ButtonSetTemp: TButton;
    ButtonDark: TButton;
    ButtonCalibrate: TButton;
    ButtonLoop: TButton;
    ButtonGuide: TButton;
    ButtonStop: TButton;
    ButtonStop1: TButton;
    CheckBoxInverseSolarTracking1: TCheckBox;
    CheckBoxReverseDec1: TCheckBox;
    CheckBoxTrackSolar1: TCheckBox;
    Cooler: TCheckBox;
    disable_guiding1: TCheckBox;
    Exposure: TFloatSpinEdit;
    Label11: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    LabelInfo: TLabel;
    LabelInfo2: TLabel;
    LabelTemperature: TLabel;
    Label9: TLabel;
    LabelStatusDec: TLabel;
    LabelStatusRA: TLabel;
    framesize1: TComboBox;
    MenuItemDarkInfo: TMenuItem;
    MenuItemLoadDark: TMenuItem;
    minHFD1: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    LabelDark: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    label_estimate1: TLabel;
    measure_method2: TCheckBox;
    MenuItemClearDark: TMenuItem;
    MenuItemCaptureDark: TMenuItem;
    MenuItem2: TMenuItem;
    pa1: TEdit;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    PanelTemperature: TPanel;
    PanelOffset: TPanel;
    PanelGain: TPanel;
    pier_side1: TEdit;
    pixelsize1: TEdit;
    PopupMenuDark: TPopupMenu;
    pulsegainEast1: TEdit;
    pulsegainNorth1: TEdit;
    pulsegainSouth1: TEdit;
    pulsegainWest1: TEdit;
    ra_hysteresis1: TSpinEdit;
    dec_hysteresis1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    ra_gain1: TSpinEdit;
    scale1: TUpDown;
    Binning: TSpinEdit;
    Gain: TSpinEdit;
    Offset: TSpinEdit;
    ShortestPulse1: TSpinEdit;
    minSNR1: TSpinEdit;
    LongestPulse1: TSpinEdit;
    Temperature: TSpinEdit;
    TabSheetOptions: TTabSheet;
    TabSheetCamera: TTabSheet;
    Gamma: TTrackBar;
    Luminosity: TTrackBar;
    unitarcseconds1: TCheckBox;
    vpa_solar1: TFloatSpinEdit;
    v_solar1: TFloatSpinEdit;
    xy_trend1: TImage;
    xy_Panel1: TImage;
    Label3: TLabel;
    led: TShape;
    Panel2: TPanel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel3: TPanel;
    dec_gain1: TSpinEdit;
    TabSheetAdvanced: TTabSheet;
    TabSheetGuider: TTabSheet;
    Title: TLabel;
    procedure BtnZoom05Click(Sender: TObject);
    procedure BtnZoom1Click(Sender: TObject);
    procedure BtnZoom2Click(Sender: TObject);
    procedure BtnZoomAdjustClick(Sender: TObject);
    procedure ButtonCalibrateClick(Sender: TObject);
    procedure ButtonDarkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonLoopClick(Sender: TObject);
    procedure ButtonGuideClick(Sender: TObject);
    procedure ButtonSetTempClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure CheckBoxTrackSolar1Change(Sender: TObject);
    procedure CoolerClick(Sender: TObject);
    procedure dec_gain1Change(Sender: TObject);
    procedure dec_hysteresis1Change(Sender: TObject);
    procedure disable_guiding1Change(Sender: TObject);
    procedure ExposureChange(Sender: TObject);
    procedure LongestPulse1Change(Sender: TObject);
    procedure MenuItemCaptureDarkClick(Sender: TObject);
    procedure MenuItemClearDarkClick(Sender: TObject);
    procedure MenuItemDarkInfoClick(Sender: TObject);
    procedure MenuItemLoadDarkClick(Sender: TObject);
    procedure minHFD1Change(Sender: TObject);
    procedure minSNR1Change(Sender: TObject);
    procedure pa1Change(Sender: TObject);
    procedure pier_side1Change(Sender: TObject);
    procedure pixelsize1Change(Sender: TObject);
    procedure pulsegainEast1Change(Sender: TObject);
    procedure pulsegainNorth1Change(Sender: TObject);
    procedure pulsegainSouth1Change(Sender: TObject);
    procedure pulsegainWest1Change(Sender: TObject);
    procedure ra_gain1Change(Sender: TObject);
    procedure ra_hysteresis1Change(Sender: TObject);
    procedure scale1Click(Sender: TObject; Button: TUDBtnType);
    procedure ShortestPulse1Change(Sender: TObject);
    procedure vpa_solar1Change(Sender: TObject);
    procedure v_solar1Change(Sender: TObject);
  private
    { private declarations }
    thescale : double;
    FonStart, FonStop, FonCalibrate, FonLoop, FonRedraw: TNotifyEvent;
    FonSetTemperature,FonSetCooler, FonCaptureDark, FonLoadDark, FonClearDark,FonDarkInfo: TNotifyEvent;
    FonParameterChange: TNotifyStr;
    cur_minHFD,cur_minSNR,cur_Exposure,cur_vsolar,cur_vpasolar : double;
    cur_RAgain,cur_RA_hysteresis,cur_DECgain,cur_DEC_hysteresis,cur_LongestPulse,cur_shortestPulse: integer;
    cur_pa1,cur_pier_side1,cur_pixelsize1,cur_pulsegainEast1,cur_pulsegainNorth1,cur_pulsegainSouth1,
    cur_pulsegainWest1: string;
    cur_disable_guiding, cur_tracksolar: boolean;
    procedure ShowMinMove;
    procedure SetLed (cl : tcolor);
    procedure SetRA_hysteresis(value:integer);
    function GetRA_hysteresis:integer;
    procedure SetDEC_hysteresis(value:integer);
    function GetDEC_hysteresis:integer;
    function GetRAgain:integer;
    procedure SetRAgain(value:integer);
    function GetDECgain:integer;
    procedure SetDECgain(value:integer);
    function GetpulsegainEastsetting:double;
    procedure SetpulsegainEastsetting(value:double);
    function GetpulsegainWestsetting:double;
    procedure SetpulsegainWestsetting(value:double);
    function GetpulsegainNorthsetting:double;
    procedure SetpulsegainNorthsetting(value:double);
    function GetpulsegainSouthsetting:double;
    procedure SetpulsegainSouthsetting(value:double);
    function Getpier_sidesetting:string;
    procedure Setpier_sidesetting(value:string);
    function GetPAsetting:double;
    procedure SetPixelSize(value:double);
    function GetPixelSize:double;
    procedure SetMinHFD(value:double);
    function GetMinHFD:double;
    procedure SetShortestPulse(value:integer);
    function GetShortestPulse:integer;
    procedure SetLongestPulse(value:integer);
    function GetLongestPulse:integer;
    procedure SetMinSNR(value:integer);
    function GetMinSNR:integer;
    procedure SetPAsetting(value:double);
    function Getdisableguiding: boolean;
    function GetUseArcSeconds: boolean;
    procedure SetUseArcSeconds(value:boolean);
    function GetScale:integer;
    procedure SetScale(value:integer);
    function GetFrameSize: integer;
    function GetInverseSolarTracking: Boolean;
    procedure SetInverseSolarTracking(value: Boolean);
    function GetSolartracking: Boolean;
    procedure SetSolarTracking(value: Boolean);
    procedure SetV_solar(value:double);
    function GetV_solar:double;
    procedure SetVPA_solar(value:double);
    function GetVPa_solar:double;
    function GetReverseDec: Boolean;
    procedure SetReverseDec(value: Boolean);




  public
    { public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor  Destroy; override;
    procedure SetLang;
    procedure draw_xy(xy_trend :xy_guiderlist);//draw XY points
    procedure draw_trend(xy_trend :xy_guiderlist);//draw trend
    procedure trend_message(message1,message2,message3 :string);//clear trend and place message
    property onLoop: TNotifyEvent read FonLoop write FonLoop;
    property onStart: TNotifyEvent read FonStart write FonStart;
    property onStop: TNotifyEvent read FonStop write FonStop;
    property onCalibrate: TNotifyEvent read FonCalibrate write FonCalibrate;
    property onRedraw: TNotifyEvent read FonRedraw write FonRedraw;
    property onCaptureDark: TNotifyEvent read FonCaptureDark write FonCaptureDark;
    property onLoadDark: TNotifyEvent read FonLoadDark write FonLoadDark;
    property onClearDark: TNotifyEvent read FonClearDark write FonClearDark;
    property onDarkInfo: TNotifyEvent read FonDarkInfo write FonDarkInfo;
    property onParameterChange: TNotifyStr read FonParameterChange write FonParameterChange;
    property onSetTemperature: TNotifyEvent read FonSetTemperature write FonSetTemperature;
    property onSetCooler: TNotifyEvent read FonSetCooler write FonSetCooler;
    property RA_hysteresis: integer read GetRA_hysteresis write SetRA_hysteresis;
    property DEC_hysteresis: integer read GetDEC_hysteresis write SetDEC_hysteresis;
    property RAgain: integer read GetRAgain write SetRAgain;
    property DECgain: integer read GetDECgain write SetDECgain;
    property disable_guiding: boolean read Getdisableguiding;
    property use_arcsec: boolean read GetUseArcseconds write SetUseArcSeconds;
    property pulsegainEast: double read GetpulsegainEastsetting write SetpulsegainEastsetting; // movement in arcsec/second. Found by the calibration
    property pulsegainWest: double read GetpulsegainWestsetting write SetpulsegainWestsetting; // movement in arcsec/second. Found by the calibration
    property pulsegainNorth: double read GetpulsegainNorthsetting write SetpulsegainNorthsetting; // movement in arcsec/second. Found by the calibration
    property pulsegainSouth: double read GetpulsegainSouthsetting write SetpulsegainSouthsetting; // movement in arcsec/second. Found by the calibration
    property pixel_size: double read GetPixelSize write SetPixelSize; // scale in arcsec/pixel.
    property minHFD: double read GetMinHFD write SetMinHFD;
    property ShortestPulse: integer read GetShortestPulse write SetShortestPulse; // minimum pulse duration. If below skip.
    property LongestPulse: integer read GetLongestPulse write SetLongestPulse;    // maximum pulse duration. Truncated if above.
    property MinSNR: integer read GetMinSNR write SetMinSNR;
    property pier_side: string read Getpier_sidesetting write Setpier_sidesetting; // movement in arcsec/second. Found by the calibration
    property PA : double read GetPAsetting write SetPAsetting;// Guider image orientation in radians. Found by the calibration
    property trend_scale: integer read Getscale write Setscale;
    property FrameSize: integer read GetFrameSize;
    property InverseSolarTracking: Boolean read GetInverseSolarTracking write SetInverseSolarTracking;
    property SolarTracking: Boolean read GetSolarTracking write SetSolarTracking;
    property v_solar: double read GetV_solar write SetV_solar;
    property vpa_solar: double read GetVPa_solar write SetVPA_solar;
    property ReverseDec: Boolean read GetReverseDec write SetReverseDec;
  end;

implementation

uses cu_mount;

{$R *.lfm}

{ Tf_internalguider }

constructor Tf_internalguider.Create(aOwner: TComponent);
begin
 inherited Create(aOwner);
 {$ifdef lclcocoa}
 Title.Color:=clWindowFrame;
 {$endif}
 {$ifndef mswindows}
 Panel2.Color:=clDefault;
 Panel3.Color:=clDefault;
 Panel4.Color:=clDefault;
 Panel5.Color:=clDefault;
 {$endif}
 PageControl1.ActivePageIndex:=0;
 ScaleDPI(Self);
 SetLang;
 LabelStatusRA.Caption:='';
 LabelStatusDec.Caption:='';
 LabelInfo.Caption:='';
 LabelInfo2.Caption:='';
 pier_side1.Text:='N/A';
 cur_minHFD:=minHFD;
 cur_minSNR:=minSNR;
 cur_pa1:=pa1.Text;
 cur_pier_side1:=pier_side1.Text;
 cur_pixelsize1:=pixelsize1.Text;
 cur_pulsegainEast1:=pulsegainEast1.Text;
 cur_pulsegainNorth1:=pulsegainNorth1.Text;
 cur_pulsegainSouth1:=pulsegainSouth1.Text;
 cur_pulsegainWest1:=pulsegainWest1.Text;
 cur_DECgain:=DECgain;
 cur_DEC_hysteresis:=DEC_hysteresis;
 cur_disable_guiding:=disable_guiding;
 cur_LongestPulse:=LongestPulse;
 cur_shortestPulse:=shortestPulse;
 cur_Exposure:=Exposure.value;
 cur_RAgain:=RAgain;
 cur_RA_hysteresis:=RA_hysteresis;
 cur_tracksolar:=SolarTracking;
 cur_vsolar:=v_solar1.Value;
 cur_vpasolar:=vpa_solar1.Value;
end;

destructor  Tf_internalguider.Destroy;
begin
 inherited Destroy;
end;


procedure Tf_internalguider.SetLang;
begin
  Title.Caption:=rsInternalGuid;
  TabSheetGuider.Caption:=rsGuider;
  ButtonGuide.Caption:=rsGuide;
  ButtonStop.Caption:=rsStop;
  ButtonCalibrate.Caption:=rsCalibrate;
  Label2.Caption:='α '+rsGain+':';
  Label3.Caption:='δ '+rsGain+':';
  Label1.Caption:=rsHysteresis+':';
  Label4.Caption:=rsHysteresis+':';
  TabSheetCamera.Caption:=rsCamera;
  ButtonLoop.Caption:=rsLoop;
  ButtonStop1.Caption:=rsStopLoop;
  ButtonDark.Caption:=rsDark;
  MenuItemCaptureDark.Caption:=rsCreateFromCa;
  MenuItemLoadDark.Caption:=rsLoadDarkFile;
  MenuItemClearDark.Caption:=rsClearDarkFra;
  MenuItemDarkInfo.Caption:=rsViewHeader;
  Label10.Caption:=rsExposure;
  Label14.Caption:=rsBinning;
  Label15.Caption:=rsGain;
  Label16.Caption:=rsOffset2;
  Label21.Caption:=rsTemperature;
  ButtonSetTemp.Caption:=rsSet;
  Cooler.Caption:=rsCooler;
  Label17.Caption:=rsGamma;
  Label18.Caption:=rsLuminosity;
  Label19.Caption:=rsZoom;
  TabSheetOptions.Caption:=rsOptions2;
  TabSheetAdvanced.Caption:=rsAdvanced;
  GroupBox2.Caption:=rsCalibrationR;
  Label5.Caption:=rsCameraAngle+' [°]';
  Label6.Caption:=rsPulseGain+blank+rsEast+' [px*cos(δ)/sec]';
  Label7.Caption:=rsPulseGain+blank+rsWest+' [px*cos(δ)/sec]';
  Label8.Caption:=rsPulseGain+blank+rsNorth+' [px/sec]';
  Label13.Caption:=rsPulseGain+blank+rsSouth+' [px/sec]';
  Label12.Caption:=rsMeasuredAtEW;
  label_estimate1.Caption:=rsPixelScale+' ["/px]';
  GroupBox1.Caption:=rsOptions2+':';
  Label22.Caption:=rsShortestGuid+' [ms]';
  label11.Caption:=rsLongestGuide+' [ms]';
  Label20.Caption:=rsMinimumMove;
  Label23.Caption:=rsMinimum2+' HFD';
  Label24.Caption:=rsMinimum2+' SNR';
  measure_method2.Caption:=rsMeasurePixel;
  disable_guiding1.Caption:=rsDisableGuidi;
  Label9.Caption:=rsFrameSize;
  framesize1.Items[0]:=rsMax2;
  CheckBoxTrackSolar1.Caption:=rsActivateSola;
//  CheckBoxReverseDec1.Caption:=rsReverseDecAf;
  Label25.Caption:=rsApparentMoti+' ["/min]';
  Label26.Caption:=rsApparentMoti2+' [°]';
end;

function Tf_internalguider.Getdisableguiding:boolean;
begin
  result:=disable_guiding1.checked;
end;

function Tf_internalguider.GetUseArcSeconds:boolean;
begin
  result:=unitarcseconds1.checked;
end;


procedure Tf_internalguider.SetUseArcSeconds(value:boolean);
begin
  unitarcseconds1.checked:=value;
end;

function Tf_internalguider.GetRA_hysteresis:integer;
begin
  result:=ra_hysteresis1.Value;
end;

procedure Tf_internalguider.SetRA_hysteresis(value:integer);
begin
  ra_hysteresis1.Value:=value;
end;

function Tf_internalguider.GetDec_hysteresis:integer;
begin
  result:=dec_hysteresis1.Value;
end;

procedure Tf_internalguider.SetDec_hysteresis(value:integer);
begin
  dec_hysteresis1.Value:=value;
end;

function Tf_internalguider.GetpulsegainEASTsetting:double;
begin
  result:=strtofloat(pulsegainEAST1.text);
end;

procedure Tf_internalguider.SetpulsegainEastsetting(value:double);
begin
  pulsegainEAST1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.GetpulsegainWestsetting:double;
begin
  result:=strtofloat(pulsegainWest1.text);
end;

procedure Tf_internalguider.SetpulsegainWestsetting(value:double);
begin
  pulsegainWest1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.GetpulsegainNorthsetting:double;
begin
  result:=strtofloat(pulsegainNorth1.text);
end;

procedure Tf_internalguider.SetpulsegainNorthsetting(value:double);
begin
  pulsegainNorth1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.GetpulsegainSouthsetting:double;
begin
  result:=strtofloat(pulsegainSouth1.text);
end;

procedure Tf_internalguider.SetpulsegainSouthsetting(value:double);
begin
  pulsegainSouth1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.Getpier_sidesetting:string;
begin
  result:=pier_side1.text;
end;

procedure Tf_internalguider.SetPixelSize(value:double);
begin
  pixelsize1.text:=floattostrF(value,FFgeneral,4,4);
end;

function Tf_internalguider.GetPixelSize:double;
begin
  result:=strtofloat(pixelsize1.text);
end;


procedure Tf_internalguider.SetMinHFD(value:double);
begin
  MinHFD1.value:=value;
end;

function Tf_internalguider.GetMinHFD:double;
begin
  result:=MinHFD1.value;
end;


procedure Tf_internalguider.SetShortestPulse(value:integer);
begin
  ShortestPulse1.value:=value;
end;

function Tf_internalguider.GetShortestPulse:integer;
begin
  result:=ShortestPulse1.value;
end;

procedure Tf_internalguider.SetLongestPulse(value:integer);
begin
  LongestPulse1.value:=value;
end;

function Tf_internalguider.GetLongestPulse:integer;
begin
  result:=LongestPulse1.value;
end;

procedure Tf_internalguider.SetMinSNR(value:integer);
begin
  MinSNR1.value:=value;
end;

function Tf_internalguider.GetMinSNR:integer;
begin
  result:=MinSNR1.value;
end;

procedure Tf_internalguider.Setpier_sidesetting(value:string);
begin
  pier_side1.text:=value;
end;

function Tf_internalguider.GetPAsetting:double;
begin
  result:=strtofloat(PA1.text);
end;

procedure Tf_internalguider.SetPAsetting(value:double);
begin
  PA1.text:=floattostrF(value,FFgeneral,3,1);
end;

function Tf_internalguider.GetRAgain:integer;
begin
  result:=ra_gain1.Value;
end;

procedure Tf_internalguider.SetRAgain(value:integer);
begin
  ra_gain1.Value:=value;
end;

function Tf_internalguider.GetDECgain:integer;
begin
  result:=dec_gain1.Value;
end;

procedure Tf_internalguider.SetDECgain(value:integer);
begin
  dec_gain1.Value:=value;
end;

function Tf_internalguider.GetScale:integer;
begin
  result:=scale1.position;
end;

procedure Tf_internalguider.SetV_solar(value:double);
begin
  v_solar1.Value:=value;
end;

function Tf_internalguider.GetV_solar:double;
begin
  result:=v_solar1.Value;
end;

procedure Tf_internalguider.SetVPA_solar(value:double);
begin
  vpa_solar1.Value:=value;
end;

function Tf_internalguider.GetVPa_solar:double;
begin
  result:=vpa_solar1.Value;
end;


procedure Tf_internalguider.SetScale(value:integer);
begin
  scale1.position:=value;
  case value of 6: thescale:=0.25;
                5: thescale:=0.5;
                4: thescale:=1.0;
                3: thescale:=2.0;
                2: thescale:=4.0;
                1: thescale:=8.0;
                0: thescale:=16.0;
  end;

 draw_xy(nil);//plot xy values
 draw_trend(nil);// plot trends

end;

procedure Tf_internalguider.SetLed(cl: tcolor);
begin
  led.Brush.Color:=cl;
end;

procedure Tf_internalguider.ButtonGuideClick(Sender: TObject);
begin
  setled(clgreen);
  if Assigned(FonStart) then FonStart(self);
end;

procedure Tf_internalguider.ButtonStopClick(Sender: TObject);
begin
  if Assigned(FonStop) then FonStop(self);
  setled(clGray);
end;



procedure Tf_internalguider.CheckBoxTrackSolar1Change(Sender: TObject);
begin
  v_solar1.Enabled:=CheckBoxTrackSolar1.checked;
  vpa_solar1.enabled:=CheckBoxTrackSolar1.checked;
  if (cur_tracksolar<>SolarTracking) and Assigned(FonParameterChange) then FonParameterChange('SolarTracking = '+BoolToStr(SolarTracking,'true','false'));
  cur_tracksolar:=SolarTracking;
end;

procedure Tf_internalguider.ButtonSetTempClick(Sender: TObject);
begin
  if Assigned(FonSetTemperature) then FonSetTemperature(self);
end;

procedure Tf_internalguider.CoolerClick(Sender: TObject);
begin
  if Assigned(FonSetCooler) then FonSetCooler(self);
end;

procedure Tf_internalguider.ButtonDarkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var p: TPoint;
begin
  p.x:=0;
  p.y:=ButtonDark.Height;
  p:=ButtonDark.ClientToScreen(p);
  PopupMenuDark.PopUp(p.x,p.y);
end;

procedure Tf_internalguider.MenuItemCaptureDarkClick(Sender: TObject);
begin
  if Assigned(FonCaptureDark) then FonCaptureDark(self);
end;

procedure Tf_internalguider.MenuItemLoadDarkClick(Sender: TObject);
begin
  if Assigned(FonLoadDark) then FonLoadDark(self);
end;

procedure Tf_internalguider.minHFD1Change(Sender: TObject);
begin
  if (cur_minHFD<>minHFD) and Assigned(FonParameterChange) then FonParameterChange('Minimum HFD setting = '+FormatFloat(f2,minHFD));
  cur_minHFD:=minHFD;
end;

procedure Tf_internalguider.minSNR1Change(Sender: TObject);
begin
  if (cur_minSNR<>minSNR) and Assigned(FonParameterChange) then FonParameterChange('Minimum SNR setting = '+FormatFloat(f2,minSNR));
  cur_minSNR:=minSNR;
end;

procedure Tf_internalguider.pa1Change(Sender: TObject);
begin
  if (cur_pa1<>pa1.Text) and Assigned(FonParameterChange) then FonParameterChange('Camera angle = '+pa1.Text);
  cur_pa1:=pa1.Text;
end;

procedure Tf_internalguider.pier_side1Change(Sender: TObject);
begin
  if (cur_pier_side1<>pier_side1.Text) and Assigned(FonParameterChange) then FonParameterChange('Measured at = '+pier_side1.Text);
  cur_pier_side1:=pier_side1.Text;
end;

procedure Tf_internalguider.pixelsize1Change(Sender: TObject);
begin
  if (cur_pixelsize1<>pixelsize1.Text) and Assigned(FonParameterChange) then FonParameterChange('Pixel scale = '+pixelsize1.Text);
  ShowMinMove;
  cur_pixelsize1:=pixelsize1.Text;
end;

procedure Tf_internalguider.pulsegainEast1Change(Sender: TObject);
begin
  if (cur_pulsegainEast1<>pulsegainEast1.Text) and Assigned(FonParameterChange) then FonParameterChange('Pulse gain East = '+pulsegainEast1.Text);
  ShowMinMove;
  cur_pulsegainEast1:=pulsegainEast1.Text;
end;

procedure Tf_internalguider.pulsegainNorth1Change(Sender: TObject);
begin
  if (cur_pulsegainNorth1<>pulsegainNorth1.Text) and Assigned(FonParameterChange) then FonParameterChange('Pulse gain North = '+pulsegainNorth1.Text);
  cur_pulsegainNorth1:=pulsegainNorth1.Text;
end;

procedure Tf_internalguider.pulsegainSouth1Change(Sender: TObject);
begin
  if (cur_pulsegainSouth1<>pulsegainSouth1.Text) and Assigned(FonParameterChange) then FonParameterChange('Pulse gain South = '+pulsegainSouth1.Text);
  cur_pulsegainSouth1:=pulsegainSouth1.Text;
end;

procedure Tf_internalguider.pulsegainWest1Change(Sender: TObject);
begin
  if (cur_pulsegainWest1<>pulsegainWest1.Text) and Assigned(FonParameterChange) then FonParameterChange('Pulse gain West = '+pulsegainWest1.Text);
  cur_pulsegainWest1:=pulsegainWest1.Text;
end;

procedure Tf_internalguider.dec_gain1Change(Sender: TObject);
begin
  if (cur_DECgain<>DECgain) and Assigned(FonParameterChange) then FonParameterChange('DEC Gain = '+IntToStr(DECgain));
  cur_DECgain:=DECgain;
end;

procedure Tf_internalguider.dec_hysteresis1Change(Sender: TObject);
begin
  if (cur_DEC_hysteresis<>DEC_hysteresis) and Assigned(FonParameterChange) then FonParameterChange('DEC Hyst = '+IntToStr(DEC_hysteresis));
  cur_DEC_hysteresis:=DEC_hysteresis;
end;

procedure Tf_internalguider.disable_guiding1Change(Sender: TObject);
begin
  if (cur_disable_guiding<>disable_guiding) and Assigned(FonParameterChange) then FonParameterChange('MountGuidingEnabled = '+BoolToStr(not disable_guiding,'true','false'));
  cur_disable_guiding:=disable_guiding;
end;

procedure Tf_internalguider.LongestPulse1Change(Sender: TObject);
begin
  if (cur_LongestPulse<>LongestPulse) and Assigned(FonParameterChange) then FonParameterChange('Max RA duration = '+IntToStr(LongestPulse)+', Max DEC duration = '+IntToStr(LongestPulse));
  cur_LongestPulse:=LongestPulse;
end;

procedure Tf_internalguider.ShortestPulse1Change(Sender: TObject);
begin
 ShowMinMove;
 if (cur_shortestPulse<>shortestPulse) and Assigned(FonParameterChange) then FonParameterChange('Shortest guide pulse setting = '+IntToStr(shortestPulse));
 cur_shortestPulse:=shortestPulse;
end;

procedure Tf_internalguider.vpa_solar1Change(Sender: TObject);
begin
 if (cur_vpasolar<>vpa_solar1.Value) and Assigned(FonParameterChange) then FonParameterChange('Solar tracking PA = '+vpa_solar1.Text);
 cur_vpasolar:=vpa_solar1.Value;
end;

procedure Tf_internalguider.v_solar1Change(Sender: TObject);
begin
 if (cur_vsolar<>v_solar1.Value) and Assigned(FonParameterChange) then FonParameterChange('Solar tracking rate = '+v_solar1.Text);
 cur_vsolar:=v_solar1.Value;
end;

procedure Tf_internalguider.ExposureChange(Sender: TObject);
begin
  if (cur_Exposure<>Exposure.value) and Assigned(FonParameterChange) then FonParameterChange('Exposure = '+FormatFloat(f0,Exposure.value*1000)+' ms');
  cur_Exposure:=Exposure.value;
end;

procedure Tf_internalguider.ra_gain1Change(Sender: TObject);
begin
  if (cur_RAgain<>RAgain) and Assigned(FonParameterChange) then FonParameterChange('RA Gain = '+IntToStr(RAgain));
  cur_RAgain:=RAgain;
end;

procedure Tf_internalguider.ra_hysteresis1Change(Sender: TObject);
begin
  if (cur_RA_hysteresis<>RA_hysteresis) and Assigned(FonParameterChange) then FonParameterChange('RA Hyst = '+IntToStr(RA_hysteresis));
  cur_RA_hysteresis:=RA_hysteresis;
end;

procedure Tf_internalguider.MenuItemClearDarkClick(Sender: TObject);
begin
  if Assigned(FonClearDark) then FonClearDark(self);
end;

procedure Tf_internalguider.MenuItemDarkInfoClick(Sender: TObject);
begin
  if Assigned(FonDarkInfo) then FonDarkInfo(self);
end;

procedure Tf_internalguider.scale1Click(Sender: TObject; Button: TUDBtnType);
begin
  trend_scale:=scale1.position;//trigger a redraw trend
end;

procedure Tf_internalguider.ShowMinMove;
var px,asec: double;
begin
  px:=ShortestPulse*pulsegainEast/1000;
  asec:=px*pixel_size;
  label20.Caption:=rsMinimumMove+': '+FormatFloat(f2, px)+' '+rsPixel+', '+FormatFloat(f2, asec)+' "';
end;

procedure Tf_internalguider.ButtonCalibrateClick(Sender: TObject);
var txt: string;
    n: integer;
begin
 txt:= rsSelectACalib+#10+#10+rsOption1Calib+#10+#10+rsOption2Calib+#10+#10+rsOption3Cance;
 {$ifdef lclgtk2}
 // inverted button with GTK2
//if mount.isGEM then
  if true then
    n:=QuestionDlg (rsGuiderCalibr, txt, mtCustom,
          [22,rsCancel,'IsCancel', 21, rscalibration2, 20,rsCalibration],
          '')
  else
    n:=QuestionDlg (rsGuiderCalibr, txt, mtCustom,
          [22,rsCancel,'IsCancel', 20,rsCalibration],
          '');
 {$else}
// if mount.isGem then
   if true then
   n:=QuestionDlg (rsGuiderCalibr, txt, mtCustom,
         [20,rsCalibration, 21,rscalibration2, 22,rsCancel,'IsCancel'],
         '')
 else
   n:=QuestionDlg (rsGuiderCalibr, txt, mtCustom,
         [20,rsCalibration, 22,rsCancel,'IsCancel'],
         '');
 {$endif}
 case n of
      20:begin
          ReverseDec:=false;
          setled(clYellow);
          if Assigned(FonCalibrate) then FonCalibrate(self);
         end;
      21:begin
          ReverseDec:=true;
          setled(clYellow);
          if Assigned(FonCalibrate) then FonCalibrate(self);
         end;

      22:exit;
   end;
end;

procedure Tf_internalguider.ButtonLoopClick(Sender: TObject);
begin
  if Assigned(FonLoop) then FonLoop(self);
end;

procedure Tf_internalguider.draw_xy(xy_trend :xy_guiderlist);
var
 i,w2,h2,diameter, lenb,x,y,counter :integer;
 rms_ra,rms_dec,mean_ra,mean_dec,scale,scale2 :double;
 scaleunit : string;
const
    len=2;
begin
 with xy_panel1 do
 begin
   w2:= width div 2;
   h2:= height div 2;

   {clear}
   Canvas.Pen.width :=1;{thickness lines}
   Canvas.pen.color:=clScrollbar;
   canvas.font.color:=clBtntext;
   canvas.brush.color:=clmenu;
   canvas.rectangle(0,0, width,height);
   canvas.Brush.Style:=bsClear;{transparent style}
   canvas.moveto(0,h2);{cross}
   canvas.lineto(width,h2);{cross}

   canvas.moveto(w2,0);{cross}
   canvas.lineto(w2,height);

   diameter:=round(20);
   canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);
   diameter:=round(40);
   canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);
   diameter:=round(60);
   canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);


   if ((use_arcsec=false) or (pixel_size=0)) then
   begin
      scale:=1/thescale;
      scale2:=1;
      scaleunit:=' px';
   end
   else
   begin
      scale:=pixel_size/thescale;
      scale2:=pixel_size;
      scaleunit:=' "';
   end;
   canvas.textout(w2,h2+20-10,floattostrF(2*scale,FFgeneral,0,1));
   canvas.textout(w2,h2+40-10,floattostrF(4*scale,FFgeneral,0,1));
   canvas.textout(w2,h2+60-10,floattostrF(6*scale,FFgeneral,0,1)+scaleunit);

   //draw xy graph
   lenb:=length(xy_trend)-1;
   counter:=0;
   rms_ra:=0;
   mean_ra:=0;
   mean_dec:=0;
   for i:=0 to lenb do
   begin
     if xy_trend[i].ra<1E99 then //valid data
     begin
     x:=w2+round(xy_trend[i].ra*10*thescale) ;
     y:=h2-round(xy_trend[i].dec*10*thescale);

     x:=min(max(0,x),width);
     y:=min(max(0,y),height);
     if i<6 then Canvas.pen.color:=clBtnText else  Canvas.pen.color:=clGrayText;

     if i<>0 then canvas.lineto(x,y) else canvas.moveto(x,y);
     canvas.Ellipse(x-len,y-len,x+1+len,y+1+len);{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
     mean_ra:=mean_ra+xy_trend[i].ra;
     mean_dec:=mean_dec+xy_trend[i].dec;
     inc(counter)
    end;
   end;

   if counter>0 then // calculate the RMS error of the variation around the mean value;
   begin // report the RMS values
     mean_ra:=mean_ra/counter;//mean or average value
     mean_dec:=mean_dec/counter;
     rms_ra:=0;
     rms_dec:=0;
     for i:=0 to counter-1 do
     begin
       rms_ra:=rms_ra+sqr(xy_trend[i].ra-mean_ra);
       rms_dec:=rms_dec+sqr(xy_trend[i].dec-mean_dec);
     end;
     rms_ra:=sqrt(rms_ra/counter);
     rms_dec:=sqrt(rms_dec/counter);

     canvas.textout(1,h2,'α  '+floattostrF(scale2*rms_ra,FFgeneral,2,1));
     canvas.textout(w2+2,2,'δ  '+floattostrF(scale2*rms_dec,FFgeneral,2,1));
   end;
 end;
end;

procedure Tf_internalguider.trend_message(message1,message2,message3 :string);//clear trend and place message
begin
 with xy_trend1 do
 begin
   canvas.brush.color:=clmenu;
   canvas.rectangle(0,0, width,height);
   canvas.font.color:=clblue;
   canvas.textout(5,10,message1);
   canvas.textout(5,35,message2);
   canvas.textout(5,60,message3);
 end;
end;


procedure Tf_internalguider.draw_trend(xy_trend :xy_guiderlist);//draw trend.
var
 i, h2, lenb, x, y, counter :integer;
 scale: double;
 scaleunit : string;
begin
 with xy_trend1 do
 begin
   h2:= height div 2;

   {clear}
   Canvas.pen.color:=clScrollbar;
   canvas.font.color:=clBtntext;
   canvas.brush.color:=clmenu;
   canvas.rectangle(0,0, width,height);
   canvas.Brush.Style:=bsClear;{transparent style}
   Canvas.Pen.width :=1;{thickness lines}

   for i:=-2 to 2 do
   begin
     canvas.moveto(0,h2+I*20);{lines}
     canvas.lineto(width,h2+i*20);{lines}
   end;

   if ((use_arcsec=false) or (pixel_size=0)) then
   begin
      scale:=1/thescale;
      scaleunit:=' px';
   end
   else
   begin
      scale:=pixel_size/thescale;
      scaleunit:=' "';
   end;
   canvas.textout(0,h2+20-10,floattostrF(-2*scale,FFgeneral,0,1));
   canvas.textout(0,h2+40-10,floattostrF(-4*scale,FFgeneral,0,1));
   canvas.textout(0,h2-20-10,'+'+floattostrF(+2*scale,FFgeneral,0,1));
   canvas.textout(0,h2-40-10,'+'+floattostrF(+4*scale,FFgeneral,0,1)+scaleunit);



   Canvas.Pen.width :=2;{thickness lines}
   lenb:=length(xy_trend)-1;
   Canvas.pen.color:=clBlue;
   canvas.font.color:=clBlue;
   canvas.textout(5,0,'α');

   //draw DEC trend
   Canvas.pen.color:=clRed;
   canvas.font.color:=clRed;
   canvas.textout(15,0,'δ');
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i].ra<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i].dec*10*thescale);
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       if counter<>lenb then canvas.lineto(x,y) else canvas.moveto(x,y);
       dec(counter);
     end;
   end;

   //drawDEC  corrective action
   Canvas.pen.color:=clRED;
   canvas.font.color:=clBtntext;
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i].ra<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i].deccorr*10*thescale) ;
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       canvas.moveto(x-1,h2);{one pixel behind to allow both RA and DEC action to be drawn}
       canvas.lineto(x-1,y);
       dec(counter);

       if xy_trend[i].dither then canvas.textout(x,height-20,'∿');//dither indication
     end;
   end;

   //draw RA trend
   Canvas.pen.color:=clBlue;
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i].ra<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i].ra*10*thescale) ;
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       if counter<>lenb then canvas.lineto(x,y) else canvas.moveto(x,y);
       dec(counter);
     end;
   end;

   //draw RA corrective action
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i].ra<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i].racorr*10*thescale) ;
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       canvas.moveto(x+1,h2);{one pixel before to allow both RA and DEC action to be drawn}
       canvas.lineto(x+1,y);
       dec(counter);
     end;
   end;
 end;
end;

procedure Tf_internalguider.BtnZoomAdjustClick(Sender: TObject);
begin
  GuideImgZoom:=0;
  if Assigned(FonRedraw) then FonRedraw(self);
end;

procedure Tf_internalguider.BtnZoom05Click(Sender: TObject);
begin
  GuideImgZoom:=0.5;
  if Assigned(FonRedraw) then FonRedraw(self);
end;

procedure Tf_internalguider.BtnZoom1Click(Sender: TObject);
begin
  GuideImgZoom:=1;
  if Assigned(FonRedraw) then FonRedraw(self);
end;

procedure Tf_internalguider.BtnZoom2Click(Sender: TObject);
begin
  GuideImgZoom:=2;
  if Assigned(FonRedraw) then FonRedraw(self);
end;

function Tf_internalguider.GetFrameSize: integer;
var
  err, v : integer;
begin
  val(framesize1.text,v,err);
  if err<>0 then result:=999999 else result:=v;
end;

function Tf_internalguider.GetInverseSolarTracking: boolean;
begin
  result:=CheckBoxInverseSolarTracking1.Checked;
end;

procedure Tf_internalguider.SetInverseSolarTracking(value: Boolean);
begin
  CheckBoxInverseSolarTracking1.Checked:=value;
end;


function Tf_internalguider.GetSolarTracking: boolean;
begin
  result:=CheckBoxTrackSolar1.Checked;
end;

procedure Tf_internalguider.SetSolarTracking(value: Boolean);
begin
  CheckBoxTrackSolar1.Checked:=value;
end;

function Tf_internalguider.GetReverseDec: boolean;
begin
  result:=CheckBoxReverseDec1.Enabled and CheckBoxReverseDec1.Checked;
end;

procedure Tf_internalguider.SetReverseDec(value: Boolean);
begin
  CheckBoxReverseDec1.Checked:=value;
end;



end.

