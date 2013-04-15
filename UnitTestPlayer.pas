unit UnitTestPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitPlayer, UnitDirection, StdCtrls, ExtCtrls, UnitField, UnitContent,
  UnitPosition, Grids, ImgList, UnitBomb, Math, MMSystem;

type
  TFormGame = class(TForm)
    StringGrid1: TStringGrid;
    ImageListUfos: TImageList;
    ImageListObjects: TImageList;
    ImageListBombs: TImageList;
    RefreshTimer: TTimer;
    ImageBackground: TImage;
    BombTimer: TTimer;
    CountDownTimer: TTimer;
    CountdownPanel: TPanel;
    ImageListRed: TImageList;
    ImageListYellow: TImageList;
    ImageListGreen: TImageList;
    ImageListBlue: TImageList;
    ImageListItems: TImageList;
    PointsLabel1: TLabel;
    PointsLabel3: TLabel;
    PointsLabel2: TLabel;
    PointsLabel4: TLabel;
    PointsPanel1: TPanel;
    PointsPanel2: TPanel;
    PointsPanel3: TPanel;
    PointsPanel4: TPanel;
    BeginGameTimer: TTimer;
    NewGameButton: TButton;
    PauseButton: TButton;
    SuddenDeathTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure LoadInterface(Sender: TObject);
    procedure Refresh(Sender: TObject; var Pos: TPosition);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure Bomb1Pictures(Sender: TObject; var Pos: TPosition; Bomb: TBomb);
    procedure BomblessPictures1(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CountDownTimerTimer(Sender: TObject);
    procedure CreateBeginGamePanel();
    procedure OnLoadINterfaceTimer(Sender : TObject);
    procedure TimerLoadInterface();
    procedure BeginGameTimerTimer(Sender: TObject);
    procedure PauseButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NewGameButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); //aufrufen mit Button1MouseUp(Sender,mbLeft//linke Maustaste,[]{Shift nicht aktiviert},PosX,PosY{Position, wo geklickt wurde})
    procedure CreateEndGamePanel(Winner : Byte);
    procedure GameEndsOnTimer(Sender : TObject);
    procedure GameEndsTimer();
    procedure WinnerExists(Winner : Byte);
    procedure SuddenDeathTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormGame: TFormGame;
  BombPos: Array[1..4] of TPosition;  //RV: z.Z. noch auf 4 beschr�nkt, da es noch keine Items gibt
  BombPos1: Array of TPosition;
  BombPos2: Array of TPosition;
  BombPos3: Array of TPosition;
  BombPos4: Array of TPosition;
  Bombs: Array[1..4] of TBomb;       //RV: s.o.
  ImageListPlayer: Array[1..4] of TImageList;  //RV: damit wird dann sp�ter dem jeweiligen Player die ImageList der im Men� ausgesuchte Farbe zugeordnet
  BombNum: String;
  BombPlayer: Integer;
  BomblessTimer1: Array of TTimer;
  BomblessTimer2: Array of TTimer;
  BomblessTimer3: Array of TTimer;
  BomblessTimer4: Array of TTimer;
  BeginGamePanel: TPanel;
  EndGamePanel  : TPanel;
  SuddenDeathPos: TPosition;
  xdirection, ydirection: Integer; // PR: F�r die Richtungsumkehr bei SuddenDeath n�tig --> damit Spirale entsteht

const size=40;    //HS: gibt die Gr��e der Felder an, daher nenne ich sie auch Feldfaktor
implementation

uses
  UnitMenu, StrUtils, UnitCreateMenuObjects;

{$R *.dfm}

procedure TFormGame.FormCreate(Sender: TObject);
var i,j,k: Integer;
begin
  CountdownPanel.Color:=RGB(31,31,31); {Farbe des CountdownPanels in Standard-Stil}
  for i:=1 to 4 do TPanel(FormGame.FindComponent('PointsPanel'+IntToStr(i))).Color:=RGB(31,31,31);
  CreateFields;
  CreatePlayers(Settings.NumOfPlayers);
  //SetLength(Bombs,0);
  for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
  RefreshTimer.Enabled:=true;
  KeyPreview:=true;
  BombNum:='1111';
  //BombPlayer:=StrToInt(BombNum[1]+BombNum[2]+BombNum[3]+BombNum[4]);
  //SetLength(BomblessTimer,BombPlayer);
  SetLength(BomblessTimer1,StrToInt(BombNum[1]));
  SetLength(BomblessTimer2,StrToInt(BombNum[2]));
  SetLength(BomblessTimer3,StrToInt(BombNum[3]));
  SetLength(BomblessTimer4,StrToInt(BombNum[4]));
  SetLength(BombPos1,StrToInt(BombNum[1]));
  SetLength(BombPos2,StrToInt(BombNum[2]));
  SetLength(BombPos3,StrToInt(BombNum[3]));
  SetLength(BombPos4,StrToInt(BombNum[4]));

  for k:=1 to 4 do
  begin
   ImageListPlayer[k]:=TImageList(FormGame.FindComponent('ImageList'+Settings.PlayerSettings[k].UfoColor));
  end;
end;

procedure TFormGame.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorl�ufige Steuerung
var PosMem: TPosition;
    i,j: Integer;
begin
if (Sender <> FormGame) and KeyPreview=false then exit;//sonst st�rzt das Programm ab
i:=ceil((AnsiIndexText(Key,[Settings.PlayerSettings[1].KeyUp,Settings.PlayerSettings[1].KeyLeft,Settings.PlayerSettings[1].KeyDown,Settings.PlayerSettings[1].KeyRight,Settings.PlayerSettings[1].KeyBomb,Settings.PlayerSettings[2].KeyUp,Settings.PlayerSettings[2].KeyLeft,Settings.PlayerSettings[2].KeyDown,Settings.PlayerSettings[2].KeyRight,Settings.PlayerSettings[2].KeyBomb,Settings.PlayerSettings[3].KeyUp,Settings.PlayerSettings[3].KeyLeft,Settings.PlayerSettings[3].KeyDown,Settings.PlayerSettings[3].KeyRight,Settings.PlayerSettings[3].KeyBomb,Settings.PlayerSettings[4].KeyUp,Settings.PlayerSettings[4].KeyLeft,Settings.PlayerSettings[4].KeyDown,Settings.PlayerSettings[4].KeyRight,Settings.PlayerSettings[4].KeyBomb])+1)/5); // PR: Ermitteln des Spielers
If i=0 then exit; // PR: Abbruch, falls ung�ltige Eingabe
If Player[i].Alive<>false then
  begin
  PosMem:=Player[i].Position; // PR: Speicherung der alten Position
  Case AnsiIndexText(Key,[Settings.PlayerSettings[i].KeyUp,Settings.PlayerSettings[i].KeyLeft,Settings.PlayerSettings[i].KeyDown,Settings.PlayerSettings[i].KeyRight]) of // PR: Auslesen der Steuerungseinstellungen und Vergleich mit Eingabe bestimmt Bewegungsrichtung
    0: Player[i].Move(U);
    1: Player[i].Move(L);
    2: Player[i].Move(D);
    3: Player[i].Move(R);
  end;
  case AnsiIndexText(Key,[Settings.PlayerSettings[i].KeyUp,Settings.PlayerSettings[i].KeyLeft,Settings.PlayerSettings[i].KeyDown,Settings.PlayerSettings[i].KeyRight,Settings.PlayerSettings[i].KeyBomb]) of
    0,1,2,3:
    begin
      Case Field[Player[i].Position.X,Player[i].Position.Y].Content of // PR: unterschiedliches Verhalten je nach Inhalt des Zielfeldes
        empty,bombup,energyup,explosion,player01,player02,player03,player04:
          begin
          If Field[PosMem.X,PosMem.Y].Content<>bomb then Field[PosMem.X,PosMem.Y].Content:=empty;
          If (PosMem.X=Player1.Position.X) and (PosMem.Y=Player1.Position.Y) and (Player1.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player01;
          If (PosMem.X=Player2.Position.X) and (PosMem.Y=Player2.Position.Y) and (Player2.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player02;
          If (PosMem.X=Player3.Position.X) and (PosMem.Y=Player3.Position.Y) and (Player3.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player03;
          If (PosMem.X=Player4.Position.X) and (PosMem.Y=Player4.Position.Y) and (Player4.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player04;
          If Field[Player[i].Position.X,Player[i].Position.Y].Content=explosion then
            begin
            Player[i].Die;
            exit;
            end;
          If Field[Player[i].Position.X,Player[i].Position.Y].Content=bombup then
          begin
            sndPlaySound('Files\Sounds\itemcollect.wav', SND_ASYNC); //HS: Abspielen des Sounds "itemcollect"
            Player[i].NumOfBombs:=Player[i].NumOfBombs+1;
            j:=StrToInt(BombNum[i]);
            inc(j);
            Delete(BombNum,i,1);
            Insert(IntToStr(j),BombNum,i);
            //showmessage(BombNum);
            Case i of
              1: begin
              SetLength(BombPos1, Player[1].NumOfBombs);
              end;
              2: begin
              SetLength(BombPos2, StrToInt(BombNum[2]));
              end;
              3: begin
              SetLength(BombPos3, Player[i].NumOfBombs);
              end;
              4: begin
              SetLength(BombPos4, Player[i].NumOfBombs);
              end;
            end;
          end;
          If Field[Player[i].Position.X,Player[i].Position.Y].Content=energyup then
          begin
             sndPlaySound('Files\Sounds\itemcollect.wav', SND_ASYNC); //HS: Abspielen des Sounds "itemcollect"
             Player[i].BombRange:=Player[i].BombRange+1;
          end;
          Case i of
            1: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player01;
            2: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player02;
            3: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player03;
            4: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player04;
          end;
          end;
        meteorit,earth,bomb: Player[i].Position:=PosMem;
      end;
    end;
    4:
    begin
    If Player[i].NumOfBombsPlanted<Player[i].NumOfBombs then // PR: Anzahl der gelegten Bomben darf Maximalanzahl nicht �berschreiten
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
    bomb: If ((Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y)) or ((Pos.X=Player2.Position.X) and (Pos.Y=Player2.Position.Y)) or ((Pos.X=Player3.Position.X) and (Pos.Y=Player3.Position.Y)) or ((Pos.X=Player4.Position.X) and (Pos.Y=Player4.Position.Y)) then exit Else
          begin
            If ((Pos.X=Player1.Position.X-1) and (Pos.Y=Player1.Position.Y)) or ((Pos.X=Player1.Position.X+1) and (Pos.Y=Player1.Position.Y)) or ((Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y-1)) or ((Pos.X=Player1.Position.X) and (Pos.Y=Player1.Position.Y+1)) then ImageListPlayer[1].Draw(StringGrid1.Canvas,Pos.X*size,Pos.Y*size,0);
            If ((Pos.X=Player2.Position.X-1) and (Pos.Y=Player2.Position.Y)) or ((Pos.X=Player2.Position.X+1) and (Pos.Y=Player2.Position.Y)) or ((Pos.X=Player2.Position.X) and (Pos.Y=Player2.Position.Y-1)) or ((Pos.X=Player2.Position.X) and (Pos.Y=Player2.Position.Y+1)) then ImageListPlayer[2].Draw(StringGrid1.Canvas,Pos.X*size,Pos.Y*size,0);
            If ((Pos.X=Player3.Position.X-1) and (Pos.Y=Player3.Position.Y)) or ((Pos.X=Player3.Position.X+1) and (Pos.Y=Player3.Position.Y)) or ((Pos.X=Player3.Position.X) and (Pos.Y=Player3.Position.Y-1)) or ((Pos.X=Player3.Position.X) and (Pos.Y=Player3.Position.Y+1)) then ImageListPlayer[3].Draw(StringGrid1.Canvas,Pos.X*size,Pos.Y*size,0);
            If ((Pos.X=Player4.Position.X-1) and (Pos.Y=Player4.Position.Y)) or ((Pos.X=Player4.Position.X+1) and (Pos.Y=Player4.Position.Y)) or ((Pos.X=Player4.Position.X) and (Pos.Y=Player4.Position.Y-1)) or ((Pos.X=Player4.Position.X) and (Pos.Y=Player4.Position.Y+1)) then ImageListPlayer[4].Draw(StringGrid1.Canvas,Pos.X*size,Pos.Y*size,0);
          end;
    player01: ImageListPlayer[1].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);//ImageListUfos.Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,0);
    player02: ImageListPlayer[2].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);
    player03: ImageListPlayer[3].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);
    player04: ImageListPlayer[4].Draw(StringGrid1.Canvas, Pos.X*size,Pos.Y*size,8);
  end;
  BombNum:=IntToStr(Player[1].NumOfBombs)+IntToStr(Player[2].NumOfBombs)+IntToStr(Player[3].NumOfBombs)+IntToStr(Player[4].NumOfBombs);
  //BombPlayer:=StrToInt(BombNum[1]+BombNum[2]+BombNum[3]+BombNum[4]);
end;

procedure TFormGame.LoadInterface(Sender: TObject); // PR: Testvisualisierung des Spielfeldes
var i,j,meteoritenauswahl: Integer;
begin
//RV: Hintergrund laden
StringGrid1.Canvas.CopyRect(Rect(0,0,750,750),ImageBackground.Canvas,Rect(0,0,750,750));
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
      bombup,energyup: StringGrid1.Cells[i,j]:='I';
      player01: ImageListPlayer[1].Draw(StringGrid1.Canvas, i*size,j*size,8);
      player02: ImageListPlayer[2].Draw(StringGrid1.Canvas, i*size,j*size,8);
      player03: ImageListPlayer[3].Draw(StringGrid1.Canvas, i*size,j*size,8);
      player04: ImageListPlayer[4].Draw(StringGrid1.Canvas, i*size,j*size,8);
      bomb: StringGrid1.Cells[i,j]:='B';
    end;
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
      //BombPos[k].X:=i;
      //BombPos[k].Y:=j;
      //inc(k);
      Refresh(FormGame,Pos);
    end;
  end;
for i:=0 to 15 do for j:=0 to 15 do FieldMem[i,j].Content:=Field[i,j].Content;
end;


procedure TFormGame.Bomb1Pictures(Sender: TObject; var Pos: TPosition; Bomb: TBomb);
//RV: Bombenbilder malen
var ImageListExplosion: TImageList;
    i,j,k: Integer;
begin
  ImageListExplosion:=TImageList.Create(nil);
  for i:=1 to 4 do If Bomb.Owner=Player[i] then
  begin
  ImageListExplosion:=ImageListPlayer[i];
  BombPlayer:=i;
  end;

  case BombPlayer of
  1: BombPos1[StrToInt(BombNum[1])-Player[1].NumOfBombsPlanted]:=Pos;
  2: BombPos2[StrToInt(BombNum[2])-Player[2].NumOfBombsPlanted]:=Pos;
  3: BombPos3[StrToInt(BombNum[3])-Player[3].NumOfBombsPlanted]:=Pos;
  4: BombPos4[StrToInt(BombNum[4])-Player[4].NumOfBombsPlanted]:=Pos;
  end;

  with Pos do
  begin
    ImageListExplosion.Draw(StringGrid1.Canvas, X*size, Y*size, 2);

    for k:=1 to Bomb.Range do
    begin
      If X>k-1 then If Field[X-k, Y].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, (X-k)*size, Y*size, 5)
      else if Field[X-k, Y].Content = energyup then ImageListItems.Draw(StringGrid1.Canvas, (X-k)*size, Y*size, 1)
      else if Field[X-k, Y].Content = bombup then ImageListItems.Draw(StringGrid1.Canvas, (X-k)*size, Y*size, 0);

      If X<17-k then If Field[X+k, Y].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, (X+k)*size, Y*size, 6)
      else if Field[X+k, Y].Content = energyup then ImageListItems.Draw(StringGrid1.Canvas, (X+k)*size, Y*size, 1)
      else if Field[X+k, Y].Content = bombup then ImageListItems.Draw(StringGrid1.Canvas, (X+k)*size, Y*size, 0);

      If Y-k>=0 then If Field[X, Y-k].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, X*size, (Y-k)*size, 7)
      else if Field[X, Y-k].Content = energyup then ImageListItems.Draw(StringGrid1.Canvas, X*size, (Y-k)*size, 1)
      else if Field[X, Y-k].Content = bombup then ImageListItems.Draw(StringGrid1.Canvas, X*size, (Y-k)*size, 0);

      If Y+k<=15 then If Field[X, Y+k].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, X*size, (Y+k)*size, 4)
      else if Field[X, Y+k].Content = energyup then ImageListItems.Draw(StringGrid1.Canvas, X*size, (Y+k)*size, 1)
      else if Field[X, Y+k].Content = bombup then ImageListItems.Draw(StringGrid1.Canvas, X*size, (Y+k)*size, 0);
    end;
  end;

  case BombPlayer of
    1: begin
    BomblessTimer1[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer1[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Interval:=600;
    BomblessTimer1[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer1[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
    2:  begin
    BomblessTimer2[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer2[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Interval:=600;
    BomblessTimer2[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer2[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
    3:  begin
    BomblessTimer3[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer3[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Interval:=600;
    BomblessTimer3[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer3[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
    4:  begin
    BomblessTimer4[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer4[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Interval:=600;
    BomblessTimer4[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer4[Bomb.Owner.NumOfBombs-Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
  end;
end;


procedure TFormGame.BomblessPictures1(Sender: TObject);
//RV: Bombenbilder der Bombe von Player1 l�schen
var k: Integer;
begin
  If BombPlayer=1 then
  begin
    With BombPos1[StrToInt(BombNum[1])-Player[1].NumOfBombsPlanted] do
    begin
      If Field[X,Y].Content = explosion then
      begin
        StringGrid1.Canvas.CopyRect(Rect(X*size,Y*size,X*size+size,Y*size+size),ImageBackground.Canvas,Rect(X*size,Y*size,X*size+size,Y*size+size));
        Field[X,Y].Content:= empty;
      end;

      for k:=1 to Bombs[1].Range do
      begin
        If X>k-1 then If Field[X-k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size));
          Field[X-k,Y].Content:=empty;
        end;

        If X<17-k then If Field[X+k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size));
          Field[X+k,Y].Content:=empty;
        end;

        If Y>k-1 then If Field[X,Y-k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size));
          Field[X,Y-k].Content:=empty;
        end;

        If Y<17-k then If Field[X,Y+k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size));
          Field[X,Y+k].Content:=empty;
        end;
      end;
    end;
  BomblessTimer1[StrToInt(BombNum[1])-Player[1].NumOfBombsPlanted].Destroy;
  Player[1].NumOfBombsPlanted:=Player[1].NumOfBombsPlanted-1;
  end

  else if BombPlayer=2 then
  begin
    With BombPos2[StrToInt(BombNum[2])-Player[2].NumOfBombsPlanted] do
    begin
      If Field[X,Y].Content = explosion then
      begin
        StringGrid1.Canvas.CopyRect(Rect(X*size,Y*size,X*size+size,Y*size+size),ImageBackground.Canvas,Rect(X*size,Y*size,X*size+size,Y*size+size));
        Field[X,Y].Content:= empty;
      end;

      for k:=1 to Bombs[2].Range do
      begin
        If X>k-1 then If Field[X-k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size));
          Field[X-k,Y].Content:=empty;
        end;

        If X<17-k then If Field[X+k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size));
          Field[X+k,Y].Content:=empty;
        end;

        If Y>k-1 then If Field[X,Y-k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size));
          Field[X,Y-k].Content:=empty;
        end;

        If Y<17-k then If Field[X,Y+k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size));
          Field[X,Y+k].Content:=empty;
        end;
      end;
    end;
  //showmessage(IntToStr(Player[2].NumOfBombsPlanted));
  BomblessTimer2[StrToInt(BombNum[2])-Player[2].NumOfBombsPlanted].Destroy;
  Player[2].NumOfBombsPlanted:=Player[2].NumOfBombsPlanted-1;
  end

  else if BombPlayer=3 then
  begin
    With BombPos3[StrToInt(BombNum[3])-Player[3].NumOfBombsPlanted] do
    begin
      If Field[X,Y].Content = explosion then
      begin
        StringGrid1.Canvas.CopyRect(Rect(X*size,Y*size,X*size+size,Y*size+size),ImageBackground.Canvas,Rect(X*size,Y*size,X*size+size,Y*size+size));
        Field[X,Y].Content:= empty;
      end;

      for k:=1 to Bombs[3].Range do
      begin
        If X>k-1 then If Field[X-k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size));
          Field[X-k,Y].Content:=empty;
        end;

        If X<17-k then If Field[X+k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size));
          Field[X+k,Y].Content:=empty;
        end;

        If Y>k-1 then If Field[X,Y-k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size));
          Field[X,Y-k].Content:=empty;
        end;

        If Y<17-k then If Field[X,Y+k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size));
          Field[X,Y+k].Content:=empty;
        end;
      end;
    end;
  BomblessTimer3[StrToInt(BombNum[3])-Player[3].NumOfBombsPlanted].Destroy;
  Player[3].NumOfBombsPlanted:=Player[3].NumOfBombsPlanted-1;
  end

  else if BombPlayer=4 then
  begin
    With BombPos4[StrToInt(BombNum[4])-Player[4].NumOfBombsPlanted] do
    begin
      If Field[X,Y].Content = explosion then
      begin
        StringGrid1.Canvas.CopyRect(Rect(X*size,Y*size,X*size+size,Y*size+size),ImageBackground.Canvas,Rect(X*size,Y*size,X*size+size,Y*size+size));
        Field[X,Y].Content:= empty;
      end;

      for k:=1 to Bombs[4].Range do
      begin
        If X>k-1 then If Field[X-k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X-k)*size,Y*size,(X-k+1)*size,Y*size+size));
          Field[X-k,Y].Content:=empty;
        end;

        If X<17-k then If Field[X+k,Y].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size),ImageBackground.Canvas,Rect((X+k)*size,Y*size,(X+k+1)*size,Y*size+size));
          Field[X+k,Y].Content:=empty;
        end;

        If Y>k-1 then If Field[X,Y-k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y-k)*size,X*size+size,(Y-k+1)*size));
          Field[X,Y-k].Content:=empty;
        end;


        If Y<17-k then If Field[X,Y+k].Content = explosion then
        begin
          StringGrid1.Canvas.CopyRect(Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size),ImageBackground.Canvas,Rect(X*size,(Y+k)*size,X*size+size,(Y+k+1)*size));
          Field[X,Y+k].Content:=empty;
        end;
      end;
    end;
  BomblessTimer4[StrToInt(BombNum[4])-Player[4].NumOfBombsPlanted].Destroy;
  Player[4].NumOfBombsPlanted:=Player[4].NumOfBombsPlanted-1;
  end;
end;


procedure TFormGame.FormClose(Sender: TObject; var Action: TCloseAction);
var i: Integer;
begin
  FormMenu.WindowState:=WsNormal;//BB: beim Schlie�en der Formgame-Form, erh�t FormMenu wieder Normale gr��e
  if BeginGameTimer.Enabled then BeginGameTimer.Enabled:=false;
  If not Assigned(BeginGamePanel) then BeginGamePanel.Free;

 { 
  If Assigned(BeginGamePanel) then BeginGamePanel.Free;
  if Assigned(TTimer(FormGame.FindComponent('GameEndsTimer'))) then TTimer(FormGame.FindComponent('GameEndsTimer')).Free;
  if CountDownTimer.Enabled then CountDownTimer.Enabled:=false; }
end;

procedure TFormGame.CountDownTimerTimer(Sender: TObject);
begin
 if StrToInt(CountdownPanel.Caption) = 0 then
  begin
   CountDownTimer.Enabled:=false;
   SuddenDeathPos.X:=0;
   SuddenDeathPos.Y:=0;
   xdirection:=1;
   ydirection:=0;
   SuddenDeathTimer.Tag:=0;
   SuddenDeathTimer.Enabled:=true;
   exit;
  end;
 CountdownPanel.Caption := IntToStr(StrToInt(CountdownPanel.Caption)-1);
end;

procedure TFOrmGame.CreateBeginGamePanel();
begin
 FormGame.NewGameButton.Enabled:=false;
 BeginGamePanel:=TPanel.Create(FormGame);
 with BeginGamePanel do
  begin
   Parent:=FormGame;
   ParentBackground:=false;
   ParentColor:=false;
   BevelInner:=bvNone;
   BevelOuter:=bvNone;
   Height:=StringGrid1.Height;
   Width:=StringGrid1.Width;
   Left:=StringGrid1.Left;
   Top:=StringGrid1.Top;
   Color:=RGB(31,31,31);
   Font.Name:='Arial';
   Font.Size:=100;
   Font.Color:=clWhite;
   Font.Style:=[];
   Caption:='3';
   Visible:=true;
  end;
end;

procedure TFormGame.OnLoadINterfaceTimer(Sender : TObject);
begin
 FormGame.LoadInterface(FormGame);
 Sender.Free;
end;

procedure TFormGame.TimerLoadInterface();
 var Timer : TTimer;
begin
 Timer:=TTimer.Create(FormGame);
 Timer.Name:='LoadInterfaceTimer';
 Timer.Interval:=1;
 Timer.Enabled:=true;
 Timer.OnTimer:=OnLoadINterfaceTimer;
end;

procedure TFormGame.BeginGameTimerTimer(Sender: TObject);//BB
begin
 if BeginGamePanel.Caption = '1' then
  begin
   TimerLoadInterface();//einzige Methode, die Funktionierte, um das Interface automatisch zu laden
   FormGame.KeyPreview:=true;
   if Settings.SuddenDeathSettings.activated=true then
    begin
     CountDownPanel.Caption:=IntToStr(Settings.SuddenDeathSettings.time);
     CountDownTimer.Enabled:=true; //Inhalt: jede Sekunde die �brige Zeit um 1 verringern
    end;
   PauseButton.Enabled:=true;
   BeginGamePanel.Free;
   PauseButton.SetFocus;//sonstfunktioniert Stuerung nicht
   BeginGameTimer.Enabled:=false;
  end
 else BeginGamePanel.Caption:=IntToStr(StrToInt(BeginGamePanel.Caption)-1);
end;

procedure TFormGame.PauseButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if KeyPreview=true then
  begin
   KeyPreview:=false;
   If Settings.SuddenDeathSettings.activated=true then CountDownTimer.Enabled:=false;
   PauseButton.Caption:='Spiel fortsetzen';
  end
 else
  begin
   KeyPreview:=true;
   If Settings.SuddenDeathSettings.activated=true then CountDownTimer.Enabled:=true;
   PauseButton.Caption:='Spiel pausieren';
  end;
end;

procedure TFormGame.NewGameButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Assigned(EndGamePanel) then EndGamePanel.Free;
 FormMenu.StartButtonClick(FormGame);
end;

procedure TFOrmGame.CreateEndGamePanel(Winner : Byte);
begin
 EndGamePanel:=TPanel.Create(FormGame);
 with EndGamePanel do
  begin
   Parent:=FormGame;
   ParentBackground:=false;
   ParentColor:=false;
   BevelInner:=bvNone;
   BevelOuter:=bvNone;
   Height:=StringGrid1.Height;
   Width:=StringGrid1.Width;
   Left:=StringGrid1.Left;
   Top:=StringGrid1.Top;
   Color:=RGB(31,31,31);
   Font.Name:='Arial';
   Font.Size:=25;
   Font.Color:=clWhite;
   Font.Style:=[];
   if Winner = 0 then Caption:='kein Spieler hat gewonnen' else
   if (Winner>=1) and (Winner<=4) then Caption:=Settings.Playersettings[Winner].Name+' hat die Runde gewonnen' else
   if (Winner>=5) and (Winner<=8) then Caption:=Settings.Playersettings[Winner-4].Name+' hat gewonnen';
   Visible:=false;
  end;
end;

function PlayerWinsWholeGame(Player : Byte):Boolean;
begin
 if StrToInt(Tpanel(FormGame.FindComponent('PointsPanel'+IntToStr(Player))).Caption)=Settings.NumOfWins then Result:=true else Result:= false;
end;

procedure TFormGame.GameEndsOnTimer(Sender : TObject);
begin
 if EndGamePanel.Visible then
  begin
   if Pos('Runde',EndGamePanel.Caption)>0 then //ich wei�, nicht die eleganteste l�sung
    begin
     CreateBeginGamePanel();
     BeginGameTimer.Enabled:=true;
     EndGamePanel.Free;
     NewGameButton.Enabled:=false;
     TTimer(Sender).Free;
    end;
  end;
 EndGamePanel.Visible:=true;
 NewGameButton.Enabled:=true;
 
end;

procedure TFormGame.GameEndsTimer();
  var Timer : TTimer;
begin
 //if Assigned(Timer) then exit;
 Timer:=TTimer.Create(FormGame);
 Timer.Name:='GameEndsTimer';
 Timer.Interval:=3000;
 Timer.Enabled:=true;
 Timer.OnTimer:=GameEndsOnTimer;
end;

procedure TFormGame.WinnerExists(Winner : Byte);
begin
 Tpanel(FormGame.FindComponent('PointsPanel'+IntToStr(Winner))).Caption:=IntToStr(StrToInt(Tpanel(FormGame.FindComponent('PointsPanel'+IntToStr(Winner))).Caption)+1);
 if PlayerWinsWholeGame(Winner) = true then Winner:=Winner+4;
 TimerLoadInterface;
 PauseButton.Enabled:=false;
 CreateEndGamePanel(Winner);
 GameEndsTimer();

end;

procedure TFormGame.SuddenDeathTimerTimer(Sender: TObject); // PR: Ziel der ganzen Sache ist es das Spielfeld spiralenf�rmig zu begrenzen.
begin
Case Field[SuddenDeathPos.X,SuddenDeathPos.Y].Content of
  player01: Player1.Die;
  player02: Player2.Die;
  player03: Player3.Die;
  player04: Player4.Die;
end;
Field[SuddenDeathPos.X,SuddenDeathPos.Y].Content:=death;
SuddenDeathPos.X:=SuddenDeathPos.X+xdirection;
SuddenDeathPos.Y:=SuddenDeathPos.Y+ydirection;
If (SuddenDeathPos.X>15) or (SuddenDeathPos.Y>15) or (SuddenDeathPos.X<0) or (SuddenDeathPos.Y<0) or (Field[SuddenDeathPos.X,SuddenDeathPos.Y].Content=death) then SuddenDeathTimer.Tag:=1;
while SuddenDeathTimer.Tag=1 do
  begin
  SuddenDeathPos.X:=SuddenDeathPos.X-xdirection;
  SuddenDeathPos.Y:=SuddenDeathPos.Y-ydirection;
  SuddenDeathTimer.Tag:=0;
  If ydirection=-1 then
    begin
    ydirection:=0;
    xdirection:=1;
    break
    end;
  If xdirection=-1 then
    begin
    ydirection:=-1;
    xdirection:=0;
    end;
  If ydirection=1 then
    begin
    ydirection:=0;
    xdirection:=-1;
    end;
  If xdirection=1 then
    begin
    xdirection:=0;
    ydirection:=1;
    end;
  end;
end;

end.
