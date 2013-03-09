unit UnitPlayer;

interface

uses SysUtils, UnitPosition, UnitDirection, UnitCoordinate;


type
  TPlayer = class
  private
    FNumber: Integer;
    FName: String;
    FPosition: TPosition;
    procedure SetNumber(Number: Integer);
    procedure SetName(Name: String);
    procedure SetPosition(Position: TPosition);
  public
    constructor Create; overload;
    constructor Create(Number:Integer;Name:String;Position:TPosition); overload;
    property Name: string read FName write SetName;
    property Position: TPosition read FPosition write SetPosition;
    procedure Move(Direction: TDirection);
    function GetPositionString:String;
  end;


implementation

constructor TPlayer.Create;
var pos:TPosition;
begin
  self.SetNumber(0);
  self.SetName('testplayer');
  pos.x:=0;
  pos.y:=0;
  self.SetPosition(pos);
end;

constructor TPlayer.Create(Number:Integer;Name:String;Position:TPosition);
begin
  self.SetNumber(Number);
  self.SetName(Name);
  self.SetPosition(Position);
end;

procedure TPlayer.SetNumber(Number:Integer);
begin
  FNumber:=Number;
end;

procedure TPlayer.SetName(Name: String);
begin
  FName:=Name;
end;

procedure TPlayer.SetPosition(Position: TPosition);
begin
  FPosition:=Position;
end;

procedure TPlayer.Move(direction: TDirection);
begin
  case direction of
    U : if FPosition.Y > 0  then dec(FPosition.Y);
    L : if FPosition.X > 0 then dec(FPosition.X);
    D : if FPosition.Y < 15 then inc(FPosition.Y);
    R : if FPosition.X < 15 then inc(FPosition.X);
  end;
end;

function TPlayer.GetPositionString : String;
begin
  result:='X: '+IntToStr(Position.X)+'; Y:'+IntToStr(Position.Y);
end;


end.
