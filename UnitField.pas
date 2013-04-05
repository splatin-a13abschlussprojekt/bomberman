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

implementation

constructor TField.Create(Position:TPosition;Content:TContent);
begin
  self.SetPosition(Position);
  self.SetContent(Content);
end;

procedure TField.Explode;
begin
  case FContent of
    meteorit: self.SetContent(empty);
    item: self.SetContent(empty);
    player: self.SetContent(empty); //Dinge, die passieren, wenn ein Spieler explodiert, quasi sterben und so
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

end.
