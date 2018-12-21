unit fu_safety;

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

uses  UScaleDPI, u_global, Graphics, Dialogs, u_translation,
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls;

type

  { Tf_safety }

  Tf_safety = class(TFrame)
    Panel2: TPanel;
    Label1: TLabel;
    led: TShape;
    Panel1: TPanel;
    Title: TLabel;
  private
    { private declarations }
    procedure SetLang;
  public
    { public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor  Destroy; override;
  end;

implementation

{$R *.lfm}

{ Tf_safety }

constructor Tf_safety.Create(aOwner: TComponent);
begin
 inherited Create(aOwner);
 {$ifdef lclcocoa}
 Title.Color:=clWindowFrame;
 {$endif}
 ScaleDPI(Self);
 SetLang;
end;

destructor  Tf_safety.Destroy;
begin
 inherited Destroy;
end;

procedure Tf_safety.SetLang;
begin
  Title.Caption:=rsSafetyMonito;
  label1.Caption:=rsSafeForOpera;
end;

end.
