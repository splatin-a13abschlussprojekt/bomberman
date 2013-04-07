program ProjectBomberman;

uses
  Forms,
  UnitInterface in 'UnitInterface.pas' {Form1},
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
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormGame, FormGame);
  Application.Run;
end.
