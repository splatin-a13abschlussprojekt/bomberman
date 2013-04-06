unit UnitTestPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitPlayer, UnitDirection, StdCtrls, ExtCtrls, UnitField, UnitContent,
  UnitPosition, Grids, ImgList, UnitBomb;

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

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
var i,j: Integer;
begin
  CreateFields;
  CreatePlayers(1);
  for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
  RefreshTimer.Enabled:=true;
  KeyPreview:=true;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorl�ufige Steuerung
var PosMem: TPosition;
    TestBomb: TBomb;
begin
If Player1.Alive=false then exit;
  PosMem:=Player1.Position;
  Case Key of
    'w': Player1.Move(U);
    'a': Player1.Move(L);
    's': Player1.Move(D);
    'd': Player1.Move(R);
  end;
  case Key of
    'w','a','s','d':
    begin
      Case Field[Player1.Position.X,Player1.Position.Y].Content of
        empty,item,player01:
          begin
          If Field[PosMem.X,PosMem.Y].Content<>bomb then Field[PosMem.X,PosMem.Y].Content:=empty;
          Field[Player1.Position.X,Player1.Position.Y].Content:=player01;
          end;
        meteorit,earth,bomb: Player1.Position:=PosMem;
      end;
    end;
    'q':
    begin
      TestBomb:=TBomb.Create(Player1.Position,1,1000);
      Field[Player1.Position.X,Player1.Position.Y].Content:=bomb;
    end;
  end;

end;

procedure TForm2.Refresh(Sender: TObject; var Pos: TPosition); // PR: f�r den Refresh ist nur noch die Position n�tig
var pict: TBitmap;
begin
  pict:= TBitmap.Create;
  ImageListBackground.Getbitmap(0, pict);    //RV: pict wird Hintergrundbild
  Case Field[Pos.X,Pos.Y].Content of
    empty: StringGrid1.Canvas.CopyRect(Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26),pict.Canvas,Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26)); // PR: mittels CopyRect Hintergrund aus  | //RV: Hintergrundbild (pict) | laden
    bomb: If (Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y) then exit Else StringGrid1.Cells[pos.X,pos.Y]:='B';
    player01: ImageListUfos.Draw(StringGrid1.Canvas, Pos.X*26,Pos.Y*26,0);
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
      player01: ImageListUfos.Draw(StringGrid1.Canvas, i*26,j*26,0);
      bomb: StringGrid1.Cells[i,j]:='B';
    end;
  end;
end;

procedure TForm2.Button1Click(Sender: TObject); // PR: Laden des Interface �ber Button - perspektivisch elegantere L�sung
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
  If Field[i,j].Content = bomb then Refresh(Form2,Pos);
  end;
for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
end;

end.
