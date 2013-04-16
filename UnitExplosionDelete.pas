unit UnitExplosionDelete;

interface

uses SysUtils, UnitPosition, ExtCtrls, MMSystem;

type TBombMist = class
  private
    FPosition: TPosition;
    FBool: Boolean;
    FNumber: Integer;
    FTimer: TTimer;
    procedure SetPosition(Position: TPosition);
    procedure StartTimer;
    procedure SetTimer(Timer: TTimer);
    procedure SetBool(Bool: Boolean);
    procedure SetNumber(Number: Integer);
  public
    constructor Create(Pos: TPosition; Num: Integer);
    destructor Destroy;
    property Timer: TTimer read FTimer write SetTimer;
    property Position: TPosition read FPosition write SetPosition;
    property Bool: Boolean read FBool write SetBool;
    property Number: Integer read FNumber write SetNumber;
  end;

implementation

uses UnitTestPlayer;

constructor TBombMist.Create(Pos:TPosition; Num: Integer);
begin
  self.SetPosition(Pos);
  self.SetBool(true);
  self.SetNumber(Num);
  self.StartTimer;
end;

procedure TBombMist.StartTimer;
begin                          //Timer starten
  FTimer := TTimer.Create(nil);
  FTimer.Interval:=200;
  FTimer.Enabled:=true;
  FTimer.OnTimer:=FormGame.BomblessPictures1;
end;

procedure TBombMist.SetTimer(Timer: TTimer);
begin
  FTimer:=Timer;
end;

procedure TBombMist.SetPosition(Position: TPosition);
begin
  FPosition:=Position;
end;

procedure TBombMist.SetBool(Bool: Boolean);
begin
  FBool:=Bool;
end;

procedure TBombMist.SetNumber(Number: Integer);
begin
  FNumber:=Number;
end;

destructor TBombMist.Destroy;       //Desktruktor
begin
  FTimer.Free;
  inherited;
end;

end.
