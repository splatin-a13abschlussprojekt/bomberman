unit UnitField;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitDirection, StdCtrls, UnitPosition, UnitCoordinate, ExtCtrls, UnitContent;

type
  TField = class // PR: Felder mit Eigenschaften Position und Content
  private
    FPosition: TPosition;
    FContent: TContent;
    procedure SetPosition(Position: TPosition);
    procedure SetContent(Content: TContent);
  public
    constructor Create(Position:TPosition;Content:TContent);
    property Position: TPosition read FPosition write SetPosition;
    property Content: TContent read FContent write SetContent;
    procedure Explode;
  end;

procedure CreateFields;

var
  Field: Array [0..15, 0..15] of TField;  // PR: Array für die Felder
  FieldMem: Array [0..15, 0..15] of TField; // PR: zwischengespeichertes Feld zur Änderungsüberprüfung

implementation

constructor TField.Create(Position:TPosition;Content:TContent);
begin
  self.SetPosition(Position);
  self.SetContent(Content);
end;

procedure TField.Explode;
var i: Integer;
begin
If content=death then exit;
If content<>meteorit then
  begin
  self.SetContent(explosion);
  exit;
  end;
i:=Random(16)+1; // PR: zufälliges Erscheinen eines Items, wenn ein Meteorit zerstört wird
Case i of
  1..3: self.SetContent(energyup); // PR: P=3/16
  4: self.SetContent(bombup); // PR: P=1/16
  5..16: self.SetContent(explosion); // PR: P=3/4
end;
end;

procedure TField.SetPosition(Position: TPosition);
begin
  FPosition:=Position;
end;

procedure TField.SetContent(Content: TContent);
begin
  FContent:=Content;
end;

procedure CreateFields; // PR: erzeugt Spielfeld
var i,j,k: Integer;
    Pos: TPosition;
    Cont: TContent;
begin
Randomize;
for i:=0 to 15 do for j:=0 to 15 do
  begin
  Pos.X:=i;
  Pos.Y:=j;
  k:=Random(10)+1; // PR: zufälliges Füllen
    Case k of
      1..7: Cont:=meteorit;
      8: Cont:=earth;
      9..10: Cont:=empty;
    end;
  Field[i,j]:=TField.Create(Pos,Cont);
  FieldMem[i,j]:=TField.Create(Pos,Cont);
  end;
end;

end.
