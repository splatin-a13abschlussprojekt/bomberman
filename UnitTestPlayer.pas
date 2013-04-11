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
    CountDownTimer: TTimer;
    CountdownPanel: TPanel;
    BomblessTimer: TTimer;
    ImageListRed: TImageList;
    ImageListYellow: TImageList;
    ImageListGreen: TImageList;
    ImageListBlue: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure LoadInterface(Sender: TObject);
    procedure Refresh(Sender: TObject; var Pos: TPosition);
    procedure Button1Click(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure Bomb1Pictures(Sender: TObject; var Pos: TPosition; Bomb: TBomb);
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
  BombPos: Array[1..4] of TPosition;
  Bombs: Array[1..4] of TBomb;
  ImageListPlayer: Array[1..4] of TImageList;
const size=26;
implementation

uses
  UnitMenu, StrUtils;

{$R *.dfm}

procedure TFormGame.FormCreate(Sender: TObject);
var i,j,k: Integer;
begin
{Farbe des CountdownPanels}
  CountdownPanel.Color:=RGB(31,31,31);
 {}
  CreateFields;
  CreatePlayers(Settings.NumOfPlayers);
  //SetLength(Bombs,0);
  for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
  RefreshTimer.Enabled:=true;
  KeyPreview:=true;

  for k:=1 to 4 do
  begin
    If Settings.PlayerSettings[k].UfoColor='red' then ImageListPlayer[k]:=ImageListRed;
    If Settings.PlayerSettings[k].UfoColor='yellow' then ImageListPlayer[k]:=ImageListYellow;
    If Settings.PlayerSettings[k].UfoColor='green' then ImageListPlayer[k]:=ImageListGreen;
    If Settings.PlayerSettings[k].UfoColor='blue' then ImageListPlayer[k]:=ImageListBlue;
  end;
end;

procedure TFormGame.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorl�ufige Steuerung
var PosMem: TPosition;
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
        empty,item,player01,player02,player03,player04,explosion:
          begin
          If Field[PosMem.X,PosMem.Y].Content<>bomb then Field[PosMem.X,PosMem.Y].Content:=empty;
          Case i of
            1: If Field[Player[i].Position.X,Player[i].Position.Y].Content=explosion then Player[i].Alive:=false else Field[Player[i].Position.X,Player[i].Position.Y].Content:=player01;
            2: If Field[Player[i].Position.X,Player[i].Position.Y].Content=explosion then Player[i].Alive:=false else Field[Player[i].Position.X,Player[i].Position.Y].Content:=player02;
            3: If Field[Player[i].Position.X,Player[i].Position.Y].Content=explosion then Player[i].Alive:=false else Field[Player[i].Position.X,Player[i].Position.Y].Content:=player03;
            4: If Field[Player[i].Position.X,Player[i].Position.Y].Content=explosion then Player[i].Alive:=false else Field[Player[i].Position.X,Player[i].Position.Y].Content:=player04;
          end;
          end;
        meteorit,earth,bomb: Player[i].Position:=PosMem;
      end;
    end;
    4:
    begin
    If Player[i].NumOfBombsPlanted<Player[i].NumOfBombs then
      begin
      //SetLength(Bombs,high(Bombs)+2);
      //Bombs[high(Bombs)]:=TBomb.Create(Player[i],2000);
      Bombs[i]:=TBomb.Create(Player[i],2000);
      Field[Player[i].Position.X,Player[i].Position.Y].Content:=bomb;
      Player[i].NumOfBombsPlanted:=Player[i].NumOfBombsPlanted+1;
      end;
    end;
  end;
  end;
end;

procedure TFormGame.Refresh(Sender: TObject; var Pos: TPosition); // PR: f�r den Refresh ist nur noch die Position n�tig
begin
  Case Field[Pos.X,Pos.Y].Content of
    explosion: If (Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y) then exit;
    empty: StringGrid1.Canvas.CopyRect(Rect(Pos.X*size,Pos.Y*size,Pos.X*size+size,Pos.Y*size+size),ImageBackground.Canvas,Rect(Pos.X*size,Pos.Y*size,Pos.X*size+size,Pos.Y*size+size)); // PR: mittels CopyRect Hintergrund aus  | //RV: Hintergrundbild (pict) | laden
    bomb: If (Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y) then exit Else ImageListBombs.Draw(StringGrid1.Canvas,Pos.X*size,Pos.Y
    *size,0);
    player01: ImageListPlayer[1].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);//ImageListUfos.Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,0);
    player02: ImageListPlayer[2].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);
    player03: ImageListPlayer[3].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);
    player04: ImageListPlayer[4].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);
  end;
end;

procedure TFormGame.LoadInterface(Sender: TObject); // PR: Testvisualisierung des Spielfeldes
var i,j,meteoritenauswahl: Integer;
begin
//RV: Hintergrund laden
StringGrid1.Canvas.CopyRect(Rect(0,0,948,948),ImageBackground.Canvas,Rect(0,0,948,948));
//RV: Delphi hat extrem lange geladen, als es versucht hat ein 425x425 Bild aus einer Image-List zu laden...

//RV: Content der Felder anzeigen
for i:=0 to 15 do for j:=0 to 15 do
  begin
    Randomize;
    Case Field[i,j].Content of
      empty: ImageListObjects.Draw(StringGrid1.Canvas, i*size, j*size, 5);
      meteorit: begin
                  meteoritenauswahl:=Random(4)+1;
                  ImageListObjects.Draw(StringGrid1.Canvas, i*size, j*size, meteoritenauswahl);
                end;
      earth: ImageListObjects.Draw(StringGrid1.Canvas, i*size, j*size,0);
      item: StringGrid1.Cells[i,j]:='I';
      player01: ImageListPlayer[1].Draw(StringGrid1.Canvas, i*size,j*size,8);
      player02: ImageListPlayer[2].Draw(StringGrid1.Canvas, i*size,j*size,8);
      player03: ImageListPlayer[3].Draw(StringGrid1.Canvas, i*size,j*size,8);
      player04: ImageListPlayer[4].Draw(StringGrid1.Canvas, i*size,j*size,8);
      bomb: StringGrid1.Cells[i,j]:='B';
    end;
  end;
end;

procedure TFormGame.Button1Click(Sender: TObject); // PR: Laden des Interface �ber Button - perspektivisch elegantere L�sung
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
var i,j,k: Integer;
    Pos: TPosition;
begin
for i:=0 to 15 do for j:=0 to 15 do
  begin
  k:=1;
  Pos:=Field[i,j].Position;
  If Field[i,j].Content <> FieldMem[i,j].Content then Refresh(FormGame,Pos);
  If Field[i,j].Content = bomb then
    begin
      BombPos[k].X:=i;
      BombPos[k].Y:=j;
      inc(k);
      Refresh(FormGame,Pos);
    end;
  end;
for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
end;


procedure TFormGame.Bomb1Pictures(Sender: TObject; var Pos: TPosition; Bomb: TBomb);
//RV: Bombenbilder malen
var ImageListExplosion: TImageList;
    i,j: Integer;
begin
  ImageListExplosion:=TImageList.Create(nil);
  for i:=1 to 4 do If Bomb.Owner=Player[i] then
  begin
  ImageListExplosion:=ImageListPlayer[i];
  j:=i;
  end;
  //else If Bomb.Owner=Player[2] then ImageListExplosion:=ImageListPlayer[2]
  //else If Bomb.Owner=Player[3] then ImageListExplosion:=ImageListPlayer[3]
  //else If Bomb.Owner=Player[4] then ImageListExplosion:=ImageListPlayer[4];

  with Pos do
  begin
    ImageListExplosion.Draw(StringGrid1.Canvas, X*size, Y*size, 2);

    If X>0 then If Field[X-1, Y].Content <> earth then
    begin
      ImageListExplosion.Draw(StringGrid1.Canvas, (X-1)*size, Y*size, 5);
      Field[X-1, Y].Content:=explosion;
    end;

    If X<16 then If Field[X+1, Y].Content <> earth then
    begin
    ImageListExplosion.Draw(StringGrid1.Canvas, (X+1)*size, Y*size, 6);
    Field[X+1, Y].Content:=explosion;
    end;

    If Y>0 then If Field[X, Y-1].Content <> earth then
    begin
    ImageListExplosion.Draw(StringGrid1.Canvas, X*size, (Y-1)*size, 7);
    Field[X, Y-1].Content:=explosion;
    end;

    If Y<16 then If Field[X, Y+1].Content <> earth then
    begin
    ImageListExplosion.Draw(StringGrid1.Canvas, X*size, (Y+1)*size, 4);
    Field[X, Y+1].Content:=explosion;
    end;
  end;

  BomblessTimer.Enabled:=true;
  BomblessTimer.OnTimer:=BomblessPictures;
end;

procedure TFormGame.BomblessPictures(Sender: TObject);
//RV: Bombenbilder l�schen
begin
  With BombPos[1] do
  begin
    If Field[X,Y].Content = explosion then
    begin
      StringGrid1.Canvas.CopyRect(Rect(X*size,Y*size,X*size+size,Y*size+size),ImageBackground.Canvas,Rect(X*size,Y*size,X*size+size,Y*size+size));
      Field[X,Y].Content:= empty;
    end;

    If X>0 then If Field[X-1,Y].Content = explosion then
    begin
      StringGrid1.Canvas.CopyRect(Rect((X-1)*size,Y*size,X*size,Y*size+size),ImageBackground.Canvas,Rect((X-1)*size,Y*size,X*size,Y*size+size));
      Field[X-1,Y].Content:=empty;
    end;

    If X<16 then If Field[X+1,Y].Content = explosion then
    begin
      StringGrid1.Canvas.CopyRect(Rect((X+1)*size,Y*size,(X+2)*size,Y*size+size),ImageBackground.Canvas,Rect((X+1)*size,Y*size,(X+2)*size,Y*size+size));
      Field[X+1,Y].Content:=empty;
    end;

    If Y>0 then If Field[X,Y-1].Content = explosion then
    begin
      StringGrid1.Canvas.CopyRect(Rect(X*size,(Y-1)*size,X*size+size,Y*size),ImageBackground.Canvas,Rect(X*size,(Y-1)*size,X*size+size,Y*size));
      Field[X,Y-1].Content:=empty;
    end;

    If Y<16 then If Field[X,Y+1].Content = explosion then
    begin
      StringGrid1.Canvas.CopyRect(Rect(X*size,(Y+1)*size,X*size+size,(Y+2)*size),ImageBackground.Canvas,Rect(X*size,(Y+1)*size,X*size+size,(Y+2)*size));
      Field[X,Y+1].Content:=empty;
    end;
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
 CountdownPanel.Caption := IntToStr(StrToInt(CountdownPanel.Caption)-1);
end;

end.
