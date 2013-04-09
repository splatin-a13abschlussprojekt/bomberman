unit UnitTestPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitPlayer, UnitDirection, StdCtrls, ExtCtrls, UnitField, UnitContent,
  UnitPosition, Grids, ImgList, UnitBomb, Math;

type
  TFormGame = class(TForm)
    Image1: TImage;
    StringGrid1: TStringGrid;
    ImageListUfos: TImageList;
    ImageListObjects: TImageList;
    ImageListBombs: TImageList;
    Button1: TButton;
    RefreshTimer: TTimer;
    ImageBackground: TImage;
    BombTimer: TTimer;
    BomblessTimer: TTimer;
    CountDownTimer: TTimer;
    CountdownPanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure LoadInterface(Sender: TObject);
    procedure Refresh(Sender: TObject; var Pos: TPosition);
    procedure Button1Click(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure BombPictures(Sender: TObject);
    procedure BomblessPictures(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CountDownTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormGame: TFormGame;
  BombPos: TPosition;

implementation

uses
  UnitMenu, StrUtils;

{$R *.dfm}

procedure TFormGame.FormCreate(Sender: TObject);
var i,j: Integer;
begin
{Farbe des CountdownPanels}
  CountdownPanel.Color:=RGB(31,31,31);
 {}

  CreateFields;
  CreatePlayers(1);
  for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
  RefreshTimer.Enabled:=true;
  KeyPreview:=true;
end;

procedure TFormGame.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorläufige Steuerung
var PosMem: TPosition;
    Bombs: Array of TBomb;
    i: Integer;
begin
i:=ceil((AnsiIndexText(Key,[Settings.PlayerSettings[1].KeyUp,Settings.PlayerSettings[1].KeyLeft,Settings.PlayerSettings[1].KeyDown,Settings.PlayerSettings[1].KeyRight,Settings.PlayerSettings[1].KeyBomb,Settings.PlayerSettings[2].KeyUp,Settings.PlayerSettings[2].KeyLeft,Settings.PlayerSettings[2].KeyDown,Settings.PlayerSettings[2].KeyRight,Settings.PlayerSettings[2].KeyBomb,Settings.PlayerSettings[3].KeyUp,Settings.PlayerSettings[3].KeyLeft,Settings.PlayerSettings[3].KeyDown,Settings.PlayerSettings[3].KeyRight,Settings.PlayerSettings[3].KeyBomb,Settings.PlayerSettings[4].KeyUp,Settings.PlayerSettings[4].KeyLeft,Settings.PlayerSettings[4].KeyDown,Settings.PlayerSettings[4].KeyRight,Settings.PlayerSettings[4].KeyBomb])+1)/5); // PR: Ermitteln des Spielers
If Player[i].Alive<>false then
  begin
  PosMem:=Player[i].Position;
  Case AnsiIndexText(Key,[Settings.PlayerSettings[i].KeyUp,Settings.PlayerSettings[i].KeyLeft,Settings.PlayerSettings[i].KeyDown,Settings.PlayerSettings[i].KeyRight]) of
    0: Player[i].Move(U);
    1: Player[i].Move(L);
    2: Player[i].Move(D);
    3: Player[i].Move(R);
  end;
  case AnsiIndexText(Key,[Settings.PlayerSettings[i].KeyUp,Settings.PlayerSettings[i].KeyLeft,Settings.PlayerSettings[i].KeyDown,Settings.PlayerSettings[i].KeyRight,Settings.PlayerSettings[i].KeyBomb]) of
    0,1,2,3:
    begin
      Case Field[Player[i].Position.X,Player[i].Position.Y].Content of
        empty,item,player01,player02,player03,player04:
          begin
          If Field[PosMem.X,PosMem.Y].Content<>bomb then Field[PosMem.X,PosMem.Y].Content:=empty;
          Case i of
            1: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player01;
            2: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player02;
            3: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player03;
            4: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player04;
          end;
          end;
        meteorit,earth,bomb: Player[i].Position:=PosMem;
      end;
      BomblessPictures(FormGame);
    end;
    4:
    begin
    If Player[i].NumOfBombsPlanted<Player[i].NumOfBombs then
      begin
      SetLength(Bombs,high(Bombs)+1);
      Bombs[high(Bombs)]:=TBomb.Create(Player[i],2000);
      Field[Player[i].Position.X,Player[i].Position.Y].Content:=bomb;
      Player[i].NumOfBombsPlanted:=Player[i].NumOfBombsPlanted+1;
      end;
    end;
  end;
  end;
end;

procedure TFormGame.Refresh(Sender: TObject; var Pos: TPosition); // PR: für den Refresh ist nur noch die Position nötig
begin
  BomblessTimer.Enabled:=false;

  Case Field[Pos.X,Pos.Y].Content of
    empty: StringGrid1.Canvas.CopyRect(Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26),ImageBackground.Canvas,Rect(Pos.X*26,Pos.Y*26,Pos.X*26+26,Pos.Y*26+26)); // PR: mittels CopyRect Hintergrund aus  | //RV: Hintergrundbild (pict) | laden
    bomb: If (Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y) then exit Else ImageListBombs.Draw(StringGrid1.Canvas,Pos.X*26,Pos.Y
    *26,0);
    player01: ImageListUfos.Draw(StringGrid1.Canvas, Pos.X*26,Pos.Y*26,0);
  end;
end;

procedure TFormGame.LoadInterface(Sender: TObject); // PR: Testvisualisierung des Spielfeldes
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

procedure TFormGame.Button1Click(Sender: TObject); // PR: Laden des Interface über Button - perspektivisch elegantere Lösung
begin
 LoadInterface(FormGame);
 {Countdown (BB)}
 if Settings.SuddenDeathSettings.activated=true then
  begin
   CountDownPanel.Caption:=IntToStr(Settings.SuddenDeathSettings.time);
   CountDownTimer.Enabled:=true;
  end;
end;

procedure TFormGame.RefreshTimerTimer(Sender: TObject);
var i,j: Integer;
    Pos: TPosition;
begin
for i:=0 to 15 do for j:=0 to 15 do
  begin
  Pos:=Field[i,j].Position;
  If Field[i,j].Content <> FieldMem[i,j].Content then Refresh(FormGame,Pos);
  If Field[i,j].Content = bomb then
    begin
      BombPos.X:=i;
      BombPos.Y:=j;
      BombTimer.Enabled:=true;
      BombTimer.OnTimer:=BombPictures;
      Refresh(FormGame,Pos);
    end;
  end;
for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
end;


procedure TFormGame.BombPictures(Sender: TObject);
//RV: Bombenbilder malen
begin
  ImageListBombs.Draw(StringGrid1.Canvas, BombPos.X*26, BombPos.Y*26, 2);
  If BombPos.X>0 then If Field[BombPos.X-1, BombPos.Y].Content <> earth then ImageListBombs.Draw(StringGrid1.Canvas, (BombPos.X-1)*26, BombPos.Y*26, 5);
  If BombPos.X<16 then If Field[BombPos.X+1, BombPos.Y].Content <> earth then ImageListBombs.Draw(StringGrid1.Canvas, (BombPos.X+1)*26, BombPos.Y*26, 6);
  If BombPos.Y>0 then If Field[BombPos.X, BombPos.Y-1].Content <> earth then ImageListBombs.Draw(StringGrid1.Canvas, BombPos.X*26, (BombPos.Y-1)*26, 7);
  If BombPos.Y<16 then If Field[BombPos.X, BombPos.Y+1].Content <> earth then ImageListBombs.Draw(StringGrid1.Canvas, BombPos.X*26, (BombPos.Y+1)*26, 4);

  BombTimer.Enabled:=false;

  BomblessTimer.Enabled:=true;
  BomblessTimer.OnTimer:=BomblessPictures;
end;

procedure TFormGame.BomblessPictures(Sender: TObject);
//RV: Bombenbilder löschen
begin
  With BombPos do
  begin
    If Field[X,Y].Content = empty then StringGrid1.Canvas.CopyRect(Rect(X*26,Y*26,X*26+26,Y*26+26),ImageBackground.Canvas,Rect(X*26,Y*26,X*26+26,Y*26+26));
    If X>0 then If Field[X-1,Y].Content = empty then StringGrid1.Canvas.CopyRect(Rect((X-1)*26,Y*26,X*26,Y*26+26),ImageBackground.Canvas,Rect((X-1)*26,Y*26,X*26,Y*26+26));
    If X<16 then If Field[X+1,Y].Content = empty then StringGrid1.Canvas.CopyRect(Rect((X+1)*26,Y*26,(X+2)*26,Y*26+26),ImageBackground.Canvas,Rect((X+1)*26,Y*26,(X+2)*26,Y*26+26));
    If Y>0 then If Field[X,Y-1].Content = empty then StringGrid1.Canvas.CopyRect(Rect(X*26,(Y-1)*26,X*26+26,Y*26),ImageBackground.Canvas,Rect(X*26,(Y-1)*26,X*26+26,Y*26));
    If Y<16 then If Field[X,Y+1].Content = empty then StringGrid1.Canvas.CopyRect(Rect(X*26,(Y+1)*26,X*26+26,(Y+2)*26),ImageBackground.Canvas,Rect(X*26,(Y+1)*26,X*26+26,(Y+2)*26));
  end;
end;

procedure TFormGame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 FormMenu.WindowState:=WsNormal;
end;

procedure TFormGame.CountDownTimerTimer(Sender: TObject);
begin
 if StrToInt(CountdownPanel.Caption) = 0 then
  begin
   CountDownTimer.Enabled:=false;
   exit;
  end;
 CountdownPanel.Caption := IntTOStr(StrToInt(CountdownPanel.Caption)-1);
end;

end.
