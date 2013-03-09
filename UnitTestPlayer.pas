unit UnitTestPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitPlayer, UnitDirection, StdCtrls, ExtCtrls, UnitField, UnitContent,
  UnitPosition;

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
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  Player1,Player2,Player3,Player4: TPlayer;
  Field: Array [0..15, 0..15] of TField;  // PR: Array für die Felder

implementation

{$R *.dfm}

procedure CreateFields; // PR: erzeugt Spielfeld
var i,j,k: Integer;
    Pos: TPosition;
    Cont: TContent;
begin
for i:=0 to 15 do for j:=0 to 15 do
  begin
  Pos.X:=i;
  Pos.Y:=j;
  Randomize;
  k:=Random(10)+1;
    Case k of
      1..5: Cont:=meteorit;
      6..7: Cont:=earth;
      8..10: Cont:=empty;
    end;
  Field[i,j]:=TField.Create(Pos,Cont);
  end;
end;

procedure CreatePlayers(NumOfPlayers:Integer);  // PR: Erzeugt Spieler
var i: Integer;
    StartPos: TPosition;
begin
for i:=1 to NumOfPlayers do
  begin
    Case i of
      1:
      begin
      StartPos.X:=0;
      StartPos.Y:=0;
      Player1:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player;
      Field[StartPos.X+1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y+1].Content:=empty;
      end;
      2:
      begin
      StartPos.X:=15;
      StartPos.Y:=0;
      Player1:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player;
      Field[StartPos.X-1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y+1].Content:=empty;
      end;
      3:
      begin
      StartPos.X:=0;
      StartPos.Y:=15;
      Player1:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player;
      Field[StartPos.X+1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y-1].Content:=empty;
      end;
      4:
      begin
      StartPos.X:=15;
      StartPos.Y:=15;
      Player1:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player;
      Field[StartPos.X-1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y-1].Content:=empty;
      end;
    end;
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  CreateFields;
  CreatePlayers(1);
  KeyPreview:=true;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorläufige Steuerung
begin
  Case Key of
    'w': Player1.Move(U);
    'a': Player1.Move(L);
    's': Player1.Move(D);
    'd': Player1.Move(R);
  end;
  ShowMessage(player1.GetPositionString);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
//  with Form1.Image1 do
//  If player1.Position.Y<15 then Top:=Top-height;
  player1.Move(U);
  ShowMessage(player1.GetPositionString);
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  with Image1 do
  If player1.Position.X>0 then Left:=Left-width;
  player1.Move(L);
  ShowMessage(player1.GetPositionString);
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  with Image1 do
  If player1.Position.Y>0 then Top:=Top+height;
  player1.Move(D);
  ShowMessage(player1.GetPositionString);
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  with Image1 do
  If player1.Position.X<15 then Left:=Left+width;
  player1.Move(R);
  ShowMessage(player1.GetPositionString);
end;

end.
