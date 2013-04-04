program ProjectBomberman;

uses
  Forms,
  UnitInterface in 'UnitInterface.pas' {Form1},
  UnitPlayer in 'UnitPlayer.pas',
  UnitTestPlayer in 'UnitTestPlayer.pas' {Form2},
  UnitPosition in 'UnitPosition.pas',
  UnitDirection in 'UnitDirection.pas',
  UnitCoordinate in 'UnitCoordinate.pas',
  UnitField in 'UnitField.pas',
  UnitContent in 'UnitContent.pas',
  UnitMenu in 'UnitMenu.pas' {FormMenu},
  UnitCreateMenuObjects in 'UnitCreateMenuObjects.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TFormMenu, FormMenu);
  Application.Run;
end.
