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
    ImageListBombs: TImageList;
    Button1: TButton;
    RefreshTimer: TTimer;
    ImageBackground: TImage;
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

procedure TForm2.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorläufige Steuerung
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
      TestBomb:=TBomb.Create(Player1,1000);
      Field[Player1.Position.X,Player1.Position.Y].Content:=bomb;
    end;
  end;

end;

procedure TForm2.Refresh(Sender: TObject; var Pos: TPosition); // PR: für den Refresh ist nur noch die Position nötig
var pict: TBitmap;
begin
  Case Field[Pos.X,Pos.Y].Content of
    empty: StringGrid1.Canvas.CopyRect(Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26),ImageBackground.Canvas,Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26)); // PR: mittels CopyRect Hintergrund aus  | //RV: Hintergrundbild (pict) | laden
    bomb: If (Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y) then exit Else ImageListBombs.Draw(StringGrid1.Canvas,Pos.X*26,Pos.Y
    *26,0);
    player01: ImageListUfos.Draw(StringGrid1.Canvas, Pos.X*26,Pos.Y*26,0);
  end;
end;

procedure TForm2.LoadInterface(Sender: TObject); // PR: Testvisualisierung des Spielfeldes
var i,j,meteoritenauswahl: Integer;
begin
//RV: Hintergrund laden
StringGrid1.Canvas.CopyRect(Rect(0,0,425,425),ImageBackground.Canvas,Rect(0,0,425,425));
//RV: Delphi hat extrem lange geladen, als es versucht hat ein 425x425 Bild aus einer Image-List zu laden... 

//RV: Content der Felder anzeigen
for i:=0 to 15 do for j:=0 to 15 do
  begin
    Randomize;
    Case Field[i,j].Content of
      empty: ImageListObjects.Draw(StringGrid1.Canvas, i*26, j*26, 5);
      meteorit: begin
                  meteoritenauswahl:=Random(4)+1;
                  ImageListObjects.Draw(StringGrid1.Canvas, i*26, j*26, meteoritenauswahl);
                end;
      earth: ImageListObjects.Draw(StringGrid1.Canvas, i*26, j*26,0);
      item: StringGrid1.Cells[i,j]:='I';
      player01: ImageListUfos.Draw(StringGrid1.Canvas, i*26,j*26,0);
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
  If Field[i,j].Content = bomb then Refresh(Form2,Pos);
  end;
for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
end;



end.
