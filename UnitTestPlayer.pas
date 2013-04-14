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
    ImageListRed: TImageList;
    ImageListYellow: TImageList;
    ImageListGreen: TImageList;
    ImageListBlue: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure LoadInterface(Sender: TObject);
    procedure Refresh(Sender: TObject; var Pos: TPosition);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure Bomb1Pictures(Sender: TObject; var Pos: TPosition; Bomb: TBomb);
    procedure BomblessPictures1(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CountDownTimerTimer(Sender: TObject);
    procedure Button1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); //aufrufen mit Button1MouseUp(Sender,mbLeft//linke Maustaste,[]{Shift nicht aktiviert},PosX,PosY{Position, wo geklickt wurde})
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormGame: TFormGame;
  BombPos: Array[1..4] of TPosition;  //RV: z.Z. noch auf 4 beschränkt, da es noch keine Items gibt
  BombPos1: Array of TPosition;
  BombPos2: Array of TPosition;
  BombPos3: Array of TPosition;
  BombPos4: Array of TPosition;
  Bombs: Array[1..4] of TBomb;       //RV: s.o.
  ImageListPlayer: Array[1..4] of TImageList;  //RV: damit wird dann später dem jeweiligen Player die ImageList der im Menü ausgesuchte Farbe zugeordnet
  BombNum: String;
  BombPlayer: Integer;
  BomblessTimer1: Array of TTimer;
  BomblessTimer2: Array of TTimer;
  BomblessTimer3: Array of TTimer;
  BomblessTimer4: Array of TTimer;

const size=40;    //HS: gibt die Größe der Felder an, daher nenne ich sie auch Feldfaktor
implementation

uses
  UnitMenu, StrUtils;

{$R *.dfm}

procedure TFormGame.FormCreate(Sender: TObject);
var i,j,k: Integer;
begin
  CountdownPanel.Color:=RGB(31,31,31); {Farbe des CountdownPanels in Standard-Stil}
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
  SetLength(BombPos2,StrToInt(BombNum[1]));
  SetLength(BombPos3,StrToInt(BombNum[1]));
  SetLength(BombPos4,StrToInt(BombNum[1]));

  for k:=1 to 4 do
  begin
    If Settings.PlayerSettings[k].UfoColor='red' then ImageListPlayer[k]:=ImageListRed;
    If Settings.PlayerSettings[k].UfoColor='yellow' then ImageListPlayer[k]:=ImageListYellow;
    If Settings.PlayerSettings[k].UfoColor='green' then ImageListPlayer[k]:=ImageListGreen;
    If Settings.PlayerSettings[k].UfoColor='blue' then ImageListPlayer[k]:=ImageListBlue;
  end;
end;

procedure TFormGame.FormKeyPress(Sender: TObject; var Key: Char);  // PR: vorläufige Steuerung
var PosMem: TPosition;
    i: Integer;
begin
i:=ceil((AnsiIndexText(Key,[Settings.PlayerSettings[1].KeyUp,Settings.PlayerSettings[1].KeyLeft,Settings.PlayerSettings[1].KeyDown,Settings.PlayerSettings[1].KeyRight,Settings.PlayerSettings[1].KeyBomb,Settings.PlayerSettings[2].KeyUp,Settings.PlayerSettings[2].KeyLeft,Settings.PlayerSettings[2].KeyDown,Settings.PlayerSettings[2].KeyRight,Settings.PlayerSettings[2].KeyBomb,Settings.PlayerSettings[3].KeyUp,Settings.PlayerSettings[3].KeyLeft,Settings.PlayerSettings[3].KeyDown,Settings.PlayerSettings[3].KeyRight,Settings.PlayerSettings[3].KeyBomb,Settings.PlayerSettings[4].KeyUp,Settings.PlayerSettings[4].KeyLeft,Settings.PlayerSettings[4].KeyDown,Settings.PlayerSettings[4].KeyRight,Settings.PlayerSettings[4].KeyBomb])+1)/5); // PR: Ermitteln des Spielers
If i=0 then exit; // PR: Abbruch, falls ungültige Eingabe
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
        empty,item,player01,player02,player03,player04:
          begin
          If Field[PosMem.X,PosMem.Y].Content<>bomb then Field[PosMem.X,PosMem.Y].Content:=empty;
          If (PosMem.X=Player1.Position.X) and (PosMem.Y=Player1.Position.Y) and (Player1.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player01;
          If (PosMem.X=Player2.Position.X) and (PosMem.Y=Player2.Position.Y) and (Player2.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player02;
          If (PosMem.X=Player3.Position.X) and (PosMem.Y=Player3.Position.Y) and (Player3.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player03;
          If (PosMem.X=Player4.Position.X) and (PosMem.Y=Player4.Position.Y) and (Player4.Alive=true) then Field[PosMem.X,PosMem.Y].Content:=player04;
          Case i of
            1: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player01;
            2: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player02;
            3: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player03;
            4: Field[Player[i].Position.X,Player[i].Position.Y].Content:=player04;
          end;
          end;
        meteorit,earth,bomb: Player[i].Position:=PosMem;
        explosion:
          begin
          Player[i].Alive:=false;
          If Field[PosMem.X,PosMem.Y].Content<>bomb then Field[PosMem.X,PosMem.Y].Content:=empty;
          end;
      end;
    end;
    4:
    begin
    If Player[i].NumOfBombsPlanted<Player[i].NumOfBombs then // PR: Anzahl der gelegten Bomben darf Maximalanzahl nicht überschreiten
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

procedure TFormGame.Refresh(Sender: TObject; var Pos: TPosition); // PR: für den Refresh ist nur noch die Position nötig
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
      item: StringGrid1.Cells[i,j]:='I';
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
  1: BombPos1[Player[1].NumOfBombsPlanted]:=Pos;
  2: BombPos2[Player[2].NumOfBombsPlanted]:=Pos;
  3: BombPos3[Player[3].NumOfBombsPlanted]:=Pos;
  4: BombPos4[Player[4].NumOfBombsPlanted]:=Pos;
  end;

  with Pos do
  begin
    ImageListExplosion.Draw(StringGrid1.Canvas, X*size, Y*size, 2);

    for k:=1 to Bomb.Range do
    begin
      If X>k-1 then If Field[X-k, Y].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, (X-k)*size, Y*size, 5);

      If X<17-k then If Field[X+k, Y].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, (X+k)*size, Y*size, 6);

      If Y-k>=0 then If Field[X, Y-k].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, X*size, (Y-k)*size, 7);

      If Y+k<=15 then If Field[X, Y+k].Content = explosion then
      ImageListExplosion.Draw(StringGrid1.Canvas, X*size, (Y+k)*size, 4);
    end;
  end;

  case BombPlayer of
    1: begin
    BomblessTimer1[Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer1[Bomb.Owner.NumOfBombsPlanted].Interval:=100;
    BomblessTimer1[Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer1[Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
    2:  begin
    BomblessTimer2[Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer2[Bomb.Owner.NumOfBombsPlanted].Interval:=100;
    BomblessTimer2[Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer2[Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
    3:  begin
    BomblessTimer3[Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer3[Bomb.Owner.NumOfBombsPlanted].Interval:=100;
    BomblessTimer3[Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer3[Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
    4:  begin
    BomblessTimer4[Bomb.Owner.NumOfBombsPlanted]:=TTimer.Create(nil);
    BomblessTimer4[Bomb.Owner.NumOfBombsPlanted].Interval:=100;
    BomblessTimer4[Bomb.Owner.NumOfBombsPlanted].Enabled:=true;
    BomblessTimer4[Bomb.Owner.NumOfBombsPlanted].OnTimer:=BomblessPictures1;
    end;
  end;
end;


procedure TFormGame.BomblessPictures1(Sender: TObject);
//RV: Bombenbilder der Bombe von Player1 löschen
var k: Integer;
begin
  If BombPlayer=1 then
  begin
    With BombPos1[Player[1].NumOfBombsPlanted] do
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
  BomblessTimer1[Player[1].NumOfBombsPlanted].Destroy;
  end

  else if BombPlayer=2 then
  begin
    With BombPos2[Player[2].NumOfBombsPlanted] do
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
  BomblessTimer2[Player[2].NumOfBombsPlanted].Destroy;
  end

  else if BombPlayer=3 then
  begin
    With BombPos3[Player[3].NumOfBombsPlanted] do
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
  BomblessTimer3[Player[3].NumOfBombsPlanted].Destroy;
  end

  else if BombPlayer=4 then
  begin
    With BombPos4[Player[4].NumOfBombsPlanted] do
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
  BomblessTimer4[Player[4].NumOfBombsPlanted].Destroy;
  end;
end;


procedure TFormGame.FormClose(Sender: TObject; var Action: TCloseAction);
var i: Integer;
begin
  FormMenu.WindowState:=WsNormal;//BB: beim Schließen der Formgame-Form, erhät FormMenu wieder Normale größe
end;

procedure TFormGame.CountDownTimerTimer(Sender: TObject);
begin
 if StrToInt(CountdownPanel.Caption) = 0 then
  begin
   CountDownTimer.Enabled:=false;
   //BB: HIER VERLINKUNG ZUR PROZEDUR; DIE SUDDEN DEATH AUSFÜHRT
   exit;
  end;
 CountdownPanel.Caption := IntToStr(StrToInt(CountdownPanel.Caption)-1);
end;

procedure TFormGame.Button1MouseUp(Sender: TObject; Button: TMouseButton; // PR: Laden des Interface über Button - perspektivisch elegantere Lösung
  Shift: TShiftState; X, Y: Integer);
begin
 LoadInterface(FormGame);
 {Countdown (BB)}
 if Settings.SuddenDeathSettings.activated=true then
  begin
   CountDownPanel.Caption:=IntToStr(Settings.SuddenDeathSettings.time); //BB: Zeit bis zum Sudden Death auslesen (wenn aktiviert)
   CountDownTimer.Enabled:=true; //BB: jede Sekunde die übrige Zeit um 1 verringern
  end;
end;

end.
