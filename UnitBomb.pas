unit UnitBomb;

interface

uses SysUtils, UnitPosition, UnitDirection, UnitCoordinate, UnitPlayer, ExtCtrls;

type TBomb = class
  private
    FPosition: TPosition;
    FRange: Integer;
    FTimer: TTimer;
    procedure SetPosition(Position: TPosition);
    procedure SetRange(Range: Integer);
    procedure StartTimer(Time:Integer);
    procedure Detonate(Sender: TObject);
  public
    constructor Create; overload;
    constructor Create(Position:TPosition;Range:Integer;Time:Integer); overload;
    destructor Destroy; override;
    property Position: TPosition read FPosition write SetPosition;
    property Range: Integer read FRange write SetRange;
  end;

implementation

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
constructor TBomb.Create(Position:TPosition;Range:Integer;Time:Integer);
begin
  self.SetPosition(Position);
  self.SetRange(Range);
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
begin
  for i := 1 to FRange do
  begin
    {
    Field[FPosition.X+i,FPosition.Y].Explode
    Field[FPosition.X-i,FPosition.Y].Explode
    Field[FPosition.X,FPosition.Y+i].Explode
    Field[FPosition.X,FPosition.Y-i].Explode
    }
  end;
  {Field.[FPosition.X,FPosition.Y].Content:=empty;}
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



end.
 
