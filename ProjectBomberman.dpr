program ProjectBomberman;

uses
  Forms,
  UnitPlayer in 'UnitPlayer.pas',
  UnitTestPlayer in 'UnitTestPlayer.pas' {FormGame},
  UnitPosition in 'UnitPosition.pas',
  UnitDirection in 'UnitDirection.pas',
  UnitCoordinate in 'UnitCoordinate.pas',
  UnitField in 'UnitField.pas',
  UnitContent in 'UnitContent.pas',
  UnitMenu in 'UnitMenu.pas' {FormMenu},
  UnitCreateMenuObjects in 'UnitCreateMenuObjects.pas',
  UnitBomb in 'UnitBomb.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMenu, FormMenu);
  Application.CreateForm(TFormGame, FormGame);
  Application.Run;
end.
