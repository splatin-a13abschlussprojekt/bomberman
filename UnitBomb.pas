unit UnitBomb;

interface

uses SysUtils, UnitPosition, UnitDirection, UnitCoordinate, UnitPlayer, ExtCtrls, UnitField, UnitContent, MMSystem;

type TBomb = class
  private
    FPosition: TPosition;
    FRange: Integer;
    FTimer: TTimer;
    FOwner: TPlayer;
    procedure SetPosition(Position: TPosition);
    procedure SetRange(Range: Integer);
    procedure StartTimer(Time:Integer);
    procedure Detonate(Sender: TObject);
    procedure SetOwner(Owner: TPlayer);
  public
    constructor Create; overload;
    constructor Create(Owner:TPlayer;Time:Integer); overload;
    destructor Destroy; override;
    property Position: TPosition read FPosition write SetPosition;
    property Range: Integer read FRange write SetRange;
    property Owner: TPlayer read FOwner write SetOwner;
  end;

implementation

uses UnitTestPlayer;

constructor TBomb.Create;  //me default-constructor
var pos:TPosition;
begin
  pos.x:=0;
  pos.y:=0;
  self.SetPosition(pos);
  self.SetRange(1);
  self.StartTimer(1000);
end;

                                 //me normaler Konstruktor
constructor TBomb.Create(Owner:TPlayer;Time:Integer);
begin
  self.SetOwner(Owner);
  self.SetPosition(Owner.Position);
  self.SetRange(Owner.BombRange);
  self.StartTimer(Time);
end;

destructor TBomb.Destroy;       //me Desktruktor
begin
  FTimer.Free;
  inherited;
end;

procedure TBomb.StartTimer(Time:Integer);
begin                          //me Timer starten
  FTimer := TTimer.Create(nil);
  FTimer.Interval:=Time;
  FTimer.OnTimer:=Detonate;
  FTimer.Enabled:=true;
end;

procedure TBomb.Detonate(Sender:TObject); //me bombe detonieren lassen
var i:Integer;
    pos: TPosition;    //RV: Position der Bombe, wird sp�ter mit �bergeben
begin
pos.X:=FPosition.X;   //RV: Festsetzen der Position
pos.Y:=FPosition.Y;
// PR: Bei Explosion wird Umfeld der Bombe in jede Richtung untersucht und je nach Inhalt der Felder entsprechend verfahren
sndPlaySound('Files\Sounds\laser.wav', SND_ASYNC); //HS: Abspielen des Sounds "laser"
i:=1;
while (i<=FRange) and (FPosition.X+i <= 15) do
  begin
  Case Field[FPosition.X+i,FPosition.Y].Content of
    player01: Player1.Die;
    player02: Player2.Die;
    player03: Player3.Die;
    player04: Player4.Die;
    meteorit:
      begin
      Field[FPosition.X+i,FPosition.Y].Explode;
      break;
      end;
    earth, bomb: break;
  end;
  Field[FPosition.X+i,FPosition.Y].Explode;
  Inc(i)
  end;
i:=1;
while (i<=FRange) and (FPosition.X-i >=0) do
  begin
  Case Field[FPosition.X-i,FPosition.Y].Content of
    player01: Player1.Die;
    player02: Player2.Die;
    player03: Player3.Die;
    player04: Player4.Die;
    meteorit:
      begin
      Field[FPosition.X-i,FPosition.Y].Explode;
      break;
      end;
    earth, bomb: break;
  end;
  Field[FPosition.X-i,FPosition.Y].Explode;
  Inc(i)
  end;
i:=1;
while (i<=FRange) and (FPosition.Y+i <= 15) do
  begin
  Case Field[FPosition.X,FPosition.Y+i].Content of
    player01: Player1.Die;
    player02: Player2.Die;
    player03: Player3.Die;
    player04: Player4.Die;
    meteorit:
      begin
      Field[FPosition.X,FPosition.Y+i].Explode;
      break;
      end;
    earth, bomb: break;
  end;
  Field[FPosition.X,FPosition.Y+i].Explode;
  Inc(i)
  end;
i:=1;
while (i<=FRange) and (FPosition.Y-i >=0) do
  begin
  Case Field[FPosition.X,FPosition.Y-i].Content of
    player01: Player1.Die;
    player02: Player2.Die;
    player03: Player3.Die;
    player04: Player4.Die;
    meteorit:
      begin
      Field[FPosition.X,FPosition.Y-i].Explode;
      break;
      end;
    earth, bomb: break;
  end;
  Field[FPosition.X,FPosition.Y-i].Explode;
  Inc(i)
  end;
If (FPosition.X=Owner.Position.X) and (FPosition.Y=Owner.Position.Y) then Owner.Die; // PR: �berpr�fung der Bombenposition, falls sich dort Spieler aufh�lt
Field[FPosition.X,FPosition.Y].Explode;
FormGame.Bomb1Pictures(FormGame, pos, Self);
//Owner.NumOfBombsPlanted:=Owner.NumOfBombsPlanted-1;
self.Destroy;
end;

procedure TBomb.SetPosition(Position:TPosition);   //me setter f�r die position
begin
  FPosition:=Position;
end;

procedure TBomb.SetRange(Range:Integer);           //me setter f�r die reichweite
begin
  FRange:=Range;
end;

procedure TBomb.SetOwner(Owner:TPlayer);           //me setter f�r den besitzer
begin
  FOwner:=Owner;
end;

end. 
