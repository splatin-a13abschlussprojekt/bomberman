unit UnitTestPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitPlayer, UnitDirection, StdCtrls, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  player1: TPlayer;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  player1:=TPlayer.Create;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  player1.Move(U);
  with Image1 do
  Top:=Top-height;
  ShowMessage(player1.GetPositionString);
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  player1.Move(L);
  ShowMessage(player1.GetPositionString);
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  player1.Move(D);
  with Image1 do
  Top:=Top+height;
  ShowMessage(player1.GetPositionString);
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  player1.Move(R);
  ShowMessage(player1.GetPositionString);
end;

end.
