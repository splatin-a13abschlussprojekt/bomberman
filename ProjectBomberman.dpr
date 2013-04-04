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
  UnitCreateMenuObjects in 'UnitCreateMenuObjects.pas',
  UnitHiddenForm in 'UnitHiddenForm.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TFormMenu, FormMenu);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
