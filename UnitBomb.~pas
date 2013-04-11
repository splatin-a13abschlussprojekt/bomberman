unit UnitBomb;

interface

uses SysUtils, UnitPosition, UnitDirection, UnitCoordinate, UnitPlayer, ExtCtrls, UnitField, UnitContent;

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

constructor TBomb.Create;  //default-constructor
var pos:TPosition;
begin
  pos.x:=0;
  pos.y:=0;
  self.SetPosition(pos);
  self.SetRange(1);
  self.StartTimer(1000);
end;

                                 //normaler Konstruktor
constructor TBomb.Create(Owner:TPlayer;Time:Integer);
begin
  self.SetOwner(Owner);
  self.SetPosition(Owner.Position);
  self.SetRange(Owner.BombRange);
  self.StartTimer(Time);
end;

destructor TBomb.Destroy;       //Desktruktor
begin
  FTimer.Free;
  inherited;
end;

procedure TBomb.StartTimer(Time:Integer);
begin                          //Timer starten
  FTimer := TTimer.Create(nil);
  FTimer.Interval:=Time;
  FTimer.OnTimer:=Detonate;
  FTimer.Enabled:=true;
end;

procedure TBomb.Detonate(Sender:TObject);
var i:Integer;
    pos: TPosition;
begin
pos.X:=FPosition.X;
pos.Y:=FPosition.Y;
FormGame.Bomb1Pictures(FormGame, pos, Self);

i:=1;
while (i<=FRange) and (FPosition.X+i <= 15) do
  begin
  Case Field[FPosition.X+i,FPosition.Y].Content of
    player01: Player1.Alive:=false;
    player02: Player2.Alive:=false;
    player03: Player3.Alive:=false;
    player04: Player4.Alive:=false;
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
    player01: Player1.Alive:=false;
    player02: Player2.Alive:=false;
    player03: Player3.Alive:=false;
    player04: Player4.Alive:=false;
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
    player01: Player1.Alive:=false;
    player02: Player2.Alive:=false;
    player03: Player3.Alive:=false;
    player04: Player4.Alive:=false;
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
    player01: Player1.Alive:=false;
    player02: Player2.Alive:=false;
    player03: Player3.Alive:=false;
    player04: Player4.Alive:=false;
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
If (FPosition.X=Owner.Position.X) and (FPosition.Y=Owner.Position.Y) then Owner.Alive:=false;
Field[FPosition.X,FPosition.Y].Explode;
Owner.NumOfBombsPlanted:=Owner.NumOfBombsPlanted-1;
self.Destroy;
end;

procedure TBomb.SetPosition(Position:TPosition);
begin
  FPosition:=Position;
end;

procedure TBomb.SetRange(Range:Integer);
begin
  FRange:=Range;
end;

procedure TBomb.SetOwner(Owner:TPlayer);
begin
  FOwner:=Owner;
end;

end. 
