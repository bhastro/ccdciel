unit UScaleDPI;

{$mode objfpc}{$H+}

{
Copyright (C) 2019 Patrick Chevalley

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

uses
  Math, Types, StdCtrls, Buttons,
  Forms, Graphics, Controls, ComCtrls, Grids, LCLType;

procedure SetScale(cnv: TCanvas);
procedure ScaleDPI(Control: TControl);
procedure ScaleImageList(ImgList: TImageList);
function DoScaleX(Size: integer): integer;
function DoScaleY(Size: integer): integer;
function scale: double;

var
  UseScaling: boolean = True;
  DesignDPI: integer = 96;
  RunDPI: integer = 96;

implementation

uses BGRABitmap, BGRABitmapTypes;

procedure SetScale(cnv: TCanvas);
var
  rs: TSize;
  sc: double;
const
  teststr = 'The Lazy Fox Jumps';
  designlen = 125;
  designhig = 18;
begin
  RunDPI:=DesignDPI;
  try
  RunDPI := Screen.PixelsPerInch;
  RunDPI:=max(RunDPI,72);
  RunDPI:=min(RunDPI,480);
  {$ifdef SCALE_BY_DPI_ONLY}
  exit;
  {$else}
  // take account for font size
  rs := cnv.TextExtent(teststr);
  sc := rs.cx / designlen;
  sc := max(sc, rs.cy / designhig);
  if abs(1 - sc) < 0.02 then
    sc := 1;
  if (sc>0.75)and(sc<5) then
    RunDPI := round(DesignDPI * sc);
  {$endif}
  except
  end;
end;

function scale: double;
begin
  Result := UScaleDPI.RunDPI / UScaleDPI.DesignDPI;
  if Result < 1 then
    Result := 1;
end;

function DoScaleX(Size: integer): integer;
begin
  if (not UseScaling) or (RunDPI <= DesignDPI) then
    Result := Size
  else
    Result := MulDiv(Size, RunDPI, DesignDPI);
end;

function DoScaleY(Size: integer): integer;
begin
  if (not UseScaling) or (RunDPI <= DesignDPI) then
    Result := Size
  else
    Result := MulDiv(Size, RunDPI, DesignDPI);
end;

procedure ScaleImageList(ImgList: TImageList);
var
  TempBmp: TBitmap;
  TempBGRA: array of TBGRABitmap;
  NewWidth, NewHeight: integer;
  i: integer;

begin
  if (not UseScaling) or (RunDPI <= DesignDPI * 1.2) then
    exit;

  NewWidth := DoScaleX(ImgList.Width);
  NewHeight := DoScaleY(ImgList.Height);

  setlength(TempBGRA, ImgList.Count);
  TempBmp := TBitmap.Create;
  for i := 0 to ImgList.Count - 1 do
  begin
    ImgList.GetBitmap(i, TempBmp);
    TempBGRA[i] := TBGRABitmap.Create(TempBmp);
    TempBGRA[i].ResampleFilter := rfBestQuality;
    if (TempBGRA[i].Width = 0) or (TempBGRA[i].Height = 0) then
      continue;
    while (TempBGRA[i].Width < NewWidth) or (TempBGRA[i].Height < NewHeight) do
      BGRAReplace(TempBGRA[i], TempBGRA[i].FilterSmartZoom3(moLowSmooth));
    BGRAReplace(TempBGRA[i], TempBGRA[i].Resample(NewWidth, NewHeight));
  end;
  TempBmp.Free;

  ImgList.Clear;
  ImgList.Width := NewWidth;
  ImgList.Height := NewHeight;

  for i := 0 to high(TempBGRA) do
  begin
    ImgList.Add(TempBGRA[i].Bitmap, nil);
    TempBGRA[i].Free;
  end;
end;

procedure ScaleDPI(Control: TControl);
var
  n: integer;
  WinControl: TWinControl;
begin
  if (not UseScaling) or (RunDPI <= DesignDPI) then
    exit;

  if Control is TUpDown then
  begin
      if TUpDown(Control).Associate <> nil then
      begin
        WinControl := TUpDown(Control).Associate;
        TUpDown(Control).Associate := nil;
        TUpDown(Control).Associate := WinControl;
        exit;
      end;
  end;

  with Control do
  begin
    Left := DoScaleX(Left);
    Top := DoScaleY(Top);
    Width := DoScaleX(Width);
    Height := DoScaleY(Height);
    Constraints.MaxHeight := DoScaleX(Constraints.MaxHeight);
    Constraints.MaxWidth := DoScaleX(Constraints.MaxWidth);
    Constraints.MinHeight := DoScaleX(Constraints.MinHeight);
    Constraints.MinWidth := DoScaleX(Constraints.MinWidth);
  end;

  if Control is TToolBar then
  begin
    with TToolBar(Control) do
    begin
      ButtonWidth := DoScaleX(ButtonWidth);
      ButtonHeight := DoScaleY(ButtonHeight);
    end;
    exit;
  end;

  if Control is TStringGrid then
  begin
    with TStringGrid(Control) do
    begin
      DefaultRowHeight:=DoScaleY(DefaultRowHeight);
      for n := 0 to ColCount - 1 do
      begin
        ColWidths[n] := DoScaleX(ColWidths[n]);
      end;
    end;
    exit;
  end;

  if Control is TSpeedButton then
  begin
    with TSpeedButton(Control) do
    begin
      if Font.Height<0 then
        Font.Height:=-DoScaleX(abs(Font.Height));
    end;
  end;

  if Control is TWinControl then
  begin
    WinControl := TWinControl(Control);
    if WinControl.ControlCount > 0 then
    begin
      for n := 0 to WinControl.ControlCount - 1 do
      begin
        if WinControl.Controls[n] is TControl then
        begin
          ScaleDPI(WinControl.Controls[n]);
        end;
      end;
    end;
  end;
end;

end.
