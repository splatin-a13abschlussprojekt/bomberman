unit UnitPlayer;

interface

uses SysUtils, UnitPosition, UnitDirection, UnitCoordinate, UnitContent, UnitField;


type
  TPlayer = class
  private
    FNumber: Integer;
    FName: String;
    FPosition: TPosition;
    FAlive: Boolean;
    FBombRange: Integer;
    procedure SetNumber(Number: Integer);
    procedure SetName(Name: String);
    procedure SetPosition(Position: TPosition);
    procedure SetAlive(Alive: Boolean);
    procedure SetBombRange(BombRange: Integer);
  public
    constructor Create; overload;
    constructor Create(Number:Integer;Name:String;Position:TPosition); overload;
    property Name: string read FName write SetName;
    property Position: TPosition read FPosition write SetPosition;
    procedure Move(Direction: TDirection);
    function GetPositionString:String;
    property Alive: Boolean read FAlive write SetAlive;
    property BombRange: Integer read FBombRange write SetBombRange;
  end;

procedure CreatePlayers(NumOfPlayers:Integer);

var
  Player1,Player2,Player3,Player4: TPlayer;

implementation

constructor TPlayer.Create;
var pos:TPosition;
begin
  self.SetNumber(0);
  self.SetName('testplayer');
  pos.x:=0;
  pos.y:=0;
  self.SetPosition(pos);
  self.SetAlive(true);
end;

constructor TPlayer.Create(Number:Integer;Name:String;Position:TPosition);
begin
  self.SetNumber(Number);
  self.SetName(Name);
  self.SetPosition(Position);
  self.SetBombRange(1);
  self.SetAlive(true);
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

procedure TPlayer.SetAlive(Alive: Boolean);
begin
  FAlive:=Alive;
end;

procedure TPlayer.SetBombRange(BombRange: Integer);
begin
  FBombRange:=BombRange;
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

procedure CreatePlayers(NumOfPlayers:Integer);  // PR: erzeugt Spieler
var i: Integer;
    StartPos: TPosition;
begin
for i:=1 to NumOfPlayers do
  begin
    Case i of
      1:
      begin
      StartPos.X:=0;
      StartPos.Y:=0;
      Player1:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player01;
      Field[StartPos.X+1,StartPos.Y].Content:=empty; // PR: hier wird sichergestellt, dass der Spieler Platz hat
      Field[StartPos.X,StartPos.Y+1].Content:=empty;
      end;
      2:
      begin
      StartPos.X:=15;
      StartPos.Y:=0;
      Player2:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player01;
      Field[StartPos.X-1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y+1].Content:=empty;
      end;
      3:
      begin
      StartPos.X:=0;
      StartPos.Y:=15;
      Player3:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player01;
      Field[StartPos.X+1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y-1].Content:=empty;
      end;
      4:
      begin
      StartPos.X:=15;
      StartPos.Y:=15;
      Player4:=TPlayer.Create(i,'Player'+IntToStr(i),StartPos);
      Field[StartPos.X,StartPos.Y].Content:=player01;
      Field[StartPos.X-1,StartPos.Y].Content:=empty;
      Field[StartPos.X,StartPos.Y-1].Content:=empty;
      end;
    end;
  end;
end;

end.
