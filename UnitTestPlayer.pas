unit UnitTestPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitPlayer, UnitDirection, StdCtrls, ExtCtrls, UnitField, UnitContent,
  UnitPosition, Grids, ImgList;

type
  TForm2 = class(TForm)
    Image1: TImage;
    StringGrid1: TStringGrid;
    ImageListUfos: TImageList;
    ImageListObjects: TImageList;
    ImageListBackground: TImageList;
    Button1: TButton;
    RefreshTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure LoadInterface(Sender: TObject);
    procedure Refresh(Sender: TObject; var Pos: TPosition);
    procedure Button1Click(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  Player1,Player2,Player3,Player4: TPlayer;
  Field: Array [0..15, 0..15] of TField;  // PR: Array für die Felder
  FieldMem: Array [0..15, 0..15] of TField; // PR: zwischengespeichertes Feld zur Änderungsüberprüfung

implementation

{$R *.dfm}

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

procedure CreatePlayers(NumOfPlayers:Integer);  // PR: erzeugt Spieler
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
      Field[StartPos.X+1,StartPos.Y].Content:=empty; // PR: hier wird sichergestellt, dass der Spieler Platz hat
      Field[StartPos.X,StartPos.Y+1].Content:=empty;
      end;
      2:
      begin
      StartPos.X:=15;
      StartPos.Y:=0;
      Player2:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player;
      Field[StartPos.X-1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y+1].Content:=empty;
      end;
      3:
      begin
      StartPos.X:=0;
      StartPos.Y:=15;
      Player3:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player;
      Field[StartPos.X+1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y-1].Content:=empty;
      end;
      4:
      begin
      StartPos.X:=15;
      StartPos.Y:=15;
      Player4:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player;
      Field[StartPos.X-1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y-1].Content:=empty;
      end;
    end;
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
var i,j: Integer;
begin
  CreateFields;
  CreatePlayers(1);
  for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
  RefreshTimer.Enabled:=true;
  KeyPreview:=true;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorläufige Steuerung
var PosMem: TPosition;
begin
  PosMem:=Player1.Position;
  Case Key of
    'w': Player1.Move(U);
    'a': Player1.Move(L);
    's': Player1.Move(D);
    'd': Player1.Move(R);
  end;
  Case Key of
    'w','a','s','d':
    begin
      Case Field[Player1.Position.X,Player1.Position.Y].Content of
        empty,item,player:
          begin
          Field[PosMem.X,PosMem.Y].Content:=empty;
          Field[Player1.Position.X,Player1.Position.Y].Content:=player;
          end;
        meteorit,earth,bomb: Player1.Position:=PosMem;
      end;
    end;
  end;
end;

procedure TForm2.Refresh(Sender: TObject; var Pos: TPosition); // PR: für den Refresh ist nur noch die Position nötig
var pict: TBitmap;
begin
  pict:= TBitmap.Create;
  ImageListBackground.Getbitmap(0, pict);    //RV: pict wird Hintergrundbild
  Case Field[Pos.X,Pos.Y].Content of
    empty: StringGrid1.Canvas.CopyRect(Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26),pict.Canvas,Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26)); // PR: mittels CopyRect Hintergrund aus  | //RV: Hintergrundbild (pict) | laden
    bomb: StringGrid1.Cells[pos.X,pos.Y]:='B'; 
    player: ImageListUfos.Draw(StringGrid1.Canvas, Pos.X*26,Pos.Y*26,0);
  end;
end;

procedure TForm2.LoadInterface(Sender: TObject); // PR: Testvisualisierung des Spielfeldes
var i,j,meteoritenauswahl, bgload: Integer;   //RV: bgload=backgroundload
begin
for bgload := 0 to 8 do             //RV: Hintergrund laden
  with ImageListBackground do
  begin
  case bgload of
    0: Draw(StringGrid1.Canvas, 0, 0, bgload);
    1: Draw(StringGrid1.Canvas, 149, 0, bgload);
    2: Draw(StringGrid1.Canvas, 298, 0, bgload);
    3: Draw(StringGrid1.Canvas, 0, 149, bgload);
    4: Draw(StringGrid1.Canvas, 149, 149, bgload);
    5: Draw(StringGrid1.Canvas, 298, 149, bgload);
    6: Draw(StringGrid1.Canvas, 0, 298, bgload);
    7: Draw(StringGrid1.Canvas, 149, 298, bgload);
    8: Draw(StringGrid1.Canvas, 298, 298, bgload);
    end;
  end;


//RV: Content der Felder anzeigen
for i:=0 to 15 do for j:=0 to 15 do
  begin
    Randomize;
    Case Field[i,j].Content of
      empty: ImageListObjects.Draw(StringGrid1.Canvas, i*26, j*26, 5);
      meteorit: //ImageListObjects.Draw(StringGrid1.Canvas, i*26, j*26, 1);
                begin
                  meteoritenauswahl:=Random(4)+1;
                  ImageListObjects.Draw(StringGrid1.Canvas, i*26, j*26, meteoritenauswahl);
                end;
      earth: ImageListObjects.Draw(StringGrid1.Canvas, i*26, j*26,0); {StringGrid1.Cells[i,j]:='E';}
      item: StringGrid1.Cells[i,j]:='I';
      player: ImageListUfos.Draw(StringGrid1.Canvas, i*26,j*26,0);
      bomb: StringGrid1.Cells[i,j]:='B';
    end;
  end;
end;

procedure TForm2.Button1Click(Sender: TObject); // PR: Laden des Interface über Button - perspektivisch elegantere Lösung
begin
LoadInterface(Form2);
end;

procedure TForm2.RefreshTimerTimer(Sender: TObject);
var i,j: Integer;
    Pos: TPosition;
begin
for i:=0 to 15 do for j:=0 to 15 do
  begin
  Pos:=Field[i,j].Position;
  If Field[i,j].Content <> FieldMem[i,j].Content then Refresh(Form2,Pos);
  end;
for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
end;

end.
