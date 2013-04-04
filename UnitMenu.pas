unit UnitMenu;         //BB

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
 TCheckImage = record
  CheckImage : TImage;
  Checked: Boolean;
 end;

type  
 TDragDropImage = record
  Panel : TPanel;
  Image : TImage;//Image befindet sich auf Panel
  Ground: TPanel;//Ground hält Standardposition --> ist dann ein weißes Feld
  Occupied:Boolean;
 end;
 
type
 TPlayerGroupbox = record     //wird in UnitCreatePlayerGroupbox erstellt
  Panel       : TPanel;
  Header      : TPanel;
  NameLabel   : TLabel;
  NameEdit    : TEdit;
  ControlButton : TButton;
  ControlPanel: Array[1..5] of TPanel;
  ControlLabel: Array[1..5] of TLabel;
  DragDropImage :  TDragDropImage;
 end;

type
  TFormMenu = class(TForm)
    NumberOfPlayersEdit: TEdit;
    NumberOfPlayersLabel: TLabel;
    SettingsPanel: TPanel;
    SettingsHeader: TPanel;
    NumberOfPlayersUpImage: TImage;
    NumberOfPlayersDownImage: TImage;
    SettingSuddenDeathLabel1: TLabel;
    SettingSuddenDeathLabel2: TLabel;
    SettingSuddendeathEdit: TEdit;
    SettingSuddendeathUpImage: TImage;
    SettingSuddendeathDownImage: TImage;
    SettingSuddenDeathLabel3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ControlButtonKeyPress(Sender: TObject; var Key: Char);
    procedure PanelExpectKey();
    procedure PanelGotKey();
    procedure SetKey(Key:Char);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NumberOfPlayersUpImageMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure NumberOfPlayersDownImageMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SettingSuddendeathMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SettingSuddendeathUpImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SettingSuddendeathDownImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SettingSuddendeathEditKeyPress(Sender: TObject;
      var Key: Char);
    procedure SettingSuddendeathEditExit(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FormMenu: TFormMenu;
  PlayerGroupbox : Array[1..4] of TPlayerGroupbox;
  SettingSuddendeathImage : TCheckImage;
  NumberKeys : Byte;
  GroupNumber: Byte;
  PanelNumber:Byte;
  MousePos :TPoint;
  Drag:Boolean;

implementation

uses UnitInterface, UnitCreateMenuObjects, Math;

{$R *.dfm}

procedure TFormMenu.FormCreate(Sender: TObject); //BB-Menü
 var i,j:Integer;
begin
 Canvas.Font.Size:=12;       //um Texthöhe später ermitteln zu können
 Canvas.Font.Name:='Arial';
 for i:=1 to 4 do
  begin
   CreatePlayerGroupbox(i);
   SetPanels(i);
   SetHeader(i);
   SetNameLabel(i);
   SetNameEdit(i);
   SetControlButton(i);
   for j:=1 to 5 do
    begin
     SetControlPanel(i,j);
     SetControlLabel(i,j);
    end;
   SetDragDropImageforGroupbox(i);
  end;

 {Settings - Panel}
 SettingsPanel.Color:=RGB(31,31,31);
 SettingsHeader.Font:=StandardFont();
 SettingsHeader.Font.Style:=[fsBold];
 SettingsHeader.Font.Color:=RGB(31,31,31);
 CreateSettingObjects();
end;

procedure TFormMenu.ControlButtonKeyPress(Sender: TObject; var Key: Char);
begin
 SetKey(Key);
 PanelExpectKey();
 if PanelNumber=6 then
  begin
   NumberOfPlayersEdit.SetFocus;
   Exit;
  end;
end;

procedure TFormMenu.PanelExpectKey();
begin
 if PanelNumber=6 then
  begin
   NumberOfPlayersEdit.SetFocus;  //sonst wird mit Labels fortegesetzt?!
   Exit;
  end;
 with PlayerGroupbox[GroupNumber].ControlPanel[PanelNumber] do
  begin
   Color:=clWhite;
   Font.Color:=RGB(31,31,31);
   Caption:='[TASTE]'
  end;
end;

procedure TFormMenu.PanelGotKey();
begin

 with PlayerGroupbox[GroupNumber].ControlPanel[PanelNumber] do
  begin
   Color:=RGB(50,50,50);
   Font.Color:=clWhite;
  end;
end;

procedure TFormMenu.SetKey(Key:Char);
begin

 with PlayerGroupbox[GroupNumber].ControlPanel[PanelNumber] do
  begin
   Caption:=AnsiUpperCase(Key);
   PanelGotKey();
  end;
 Inc(PanelNumber);
end;

procedure TFormMenu.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  var ParentPanel: TComponent;
begin
if (Drag=true) and (TImage(Sender).Canvas.Pixels[0,0]<>clWhite) then
  begin
   GetCursorPos(MousePos);
   MousePos:=ScreenToClient(MousePos);
   ParentPanel:=TImage(Sender).GetParentComponent;  //Panel, auf welches das Image(Sender) liegt, wird ermittelt;
   TPanel(ParentPanel).Left:=MousePos.X-40;
   TPanel(ParentPanel).Top:=MousePos.Y-40;
  end;
end;

procedure TFormMenu.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
 var ParentPanel: TComponent;
begin
 ParentPanel:=TImage(Sender).GetParentComponent;
 drag:=true;
 TPanel(ParentPanel).BringToFront; //damit es über allen Objekten ist
end;

procedure GetNextFreeGroundPanel(X,Y:Integer; Sender : TObject; var GroundPanelNumber : Byte);
 var i : Byte;
     MinDistance : Real;
     distances : Array[1..4] of Real;
     PositionOfGroundPanel:Array[1..4] of TPoint;
     NoticeI : Byte;
     Pos : TPoint;
begin
 Pos.X:=X;
 Pos.Y:=Y;
 for i:=1 to 4 do
  begin
   PositionOfGroundPanel[i].X:=Playergroupbox[i].Panel.Left+Playergroupbox[i].DragDropImage.Ground.Left;
   PositionOfGroundPanel[i].Y:=Playergroupbox[i].Panel.Top+Playergroupbox[i].DragDropImage.Ground.Top;
  end;
 for i:=1 to 4 do
  begin
   distances[i]:=sqrt((PositionOfGroundPanel[i].X-Pos.X)*(PositionOfGroundPanel[i].X-Pos.X)+(PositionOfGroundPanel[i].Y-Pos.Y)*(PositionOfGroundPanel[i].Y-Pos.Y));
  end;
 MinDistance:=MaxExtended;
 Noticei:=0;;
 for I:=1 to 4 do
  if distances[i]<MinDistance then
   begin
    MinDistance:=distances[i];
    NoticeI:=I;
   end;
 //ShowMessage(FloatToStr(distances[1])+'|'+Floattostr(distances[2])+'|'+Floattostr(distances[3])+'|'+Floattostr(distances[4])+'|');
 GroundPanelNumber:=Noticei;
end;

procedure TFormMenu.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
 var ParentPanel: TComponent;
     i,j : Byte;
     VImage:TIMage;
begin
 j:=0;
 drag:=false;
 ParentPanel:=TImage(Sender).GetParentComponent;
 GetNextFreeGroundPanel(TPanel(ParentPanel).Left,TPanel(ParentPanel).Top,Sender,i);
 repeat
  inc(j);
 until TPanel(ParentPanel)=Playergroupbox[j].DragDropImage.Panel;
 PlayerGroupbox[j].DragDropImage.Panel.Left:=Playergroupbox[j].Panel.Left+Playergroupbox[j].DragDropImage.Ground.Left;
 PlayerGroupbox[j].DragDropImage.Panel.Top:=Playergroupbox[j].Panel.Top+Playergroupbox[j].DragDropImage.Ground.Top;
 if i<>j then
  begin
   PlayerGroupbox[j].DragDropImage.Panel.Left:=Playergroupbox[j].Panel.Left+Playergroupbox[j].DragDropImage.Ground.Left;
   PlayerGroupbox[j].DragDropImage.Panel.Top:=Playergroupbox[j].Panel.Top+Playergroupbox[j].DragDropImage.Ground.Top;
   VImage:=TImage.Create(self);
   VImage.Picture:=Playergroupbox[j].DragDropImage.Image.Picture;
   Playergroupbox[j].DragDropImage.Image.Picture:=Playergroupbox[i].DragDropImage.Image.Picture;
   Playergroupbox[i].DragDropImage.Image.Picture:=VImage.Picture;
   VImage.Free;
  end;
end;

procedure TFormMenu.ButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  GroupNumber:=0;
 Repeat
  inc(GroupNumber);
 until Sender = PlayerGroupbox[GroupNumber].ControlButton;
 PanelNumber:=1;
 PanelExpectKey();
end;

procedure TFormMenu.NumberOfPlayersUpImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if StrToInt(NumberOfPlayersEdit.Text)<4 then NumberOfPlayersEdit.Text:=IntToStr(StrToInt(NumberOfPlayersEdit.Text)+1);
end;

procedure TFormMenu.NumberOfPlayersDownImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if StrToInt(NumberOfPlayersEdit.Text)>2 then NumberOfPlayersEdit.Text:=IntToStr(StrToInt(NumberOfPlayersEdit.Text)-1);
end;

procedure TFormMenu.SettingSuddendeathMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if SettingSuddendeathImage.Checked=false then
  begin
   with SettingSuddendeathImage do
    begin
     CheckImage.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\menu\checkbox-checked.bmp');
     SettingSuddenDeathLabel2.Visible:=true;
     SettingSuddenDeathLabel3.Visible:=true;
     SettingSuddendeathEdit.Visible:=true;
     SettingSuddendeathUpImage.Visible:=true;
     SettingSuddendeathDownImage.Visible:=true;
     Checked:=true;
    end;
  end
 else
  begin
   with SettingSuddendeathImage do
    begin
     CheckImage.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\menu\checkbox-unchecked.bmp');
     SettingSuddenDeathLabel2.Visible:=false;
     SettingSuddenDeathLabel3.Visible:=false;
     SettingSuddendeathEdit.Visible:=false;
     SettingSuddendeathUpImage.Visible:=false;
     SettingSuddendeathDownImage.Visible:=false;
     Checked:=false;
    end;
  end;
end;

procedure TFormMenu.SettingSuddendeathUpImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if StrToInt(SettingSuddendeathEdit.Text)<999 then SettingSuddendeathEdit.Text:=IntToStr(StrToInt(SettingSuddendeathEdit.Text)+1);
end;

procedure TFormMenu.SettingSuddendeathDownImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if StrToInt(SettingSuddendeathEdit.Text)>=1 then SettingSuddendeathEdit.Text:=IntToStr(StrToInt(SettingSuddendeathEdit.Text)-1);
end;

procedure TFormMenu.SettingSuddendeathEditKeyPress(Sender: TObject;
  var Key: Char);
begin
 if Key=#8 then (SettingSuddendeathEdit.Text:='');
 if (StrToIntDef(Key,-1)>-1) and (length(SettingSuddendeathEdit.Text)<3) then
  begin
   SettingSuddendeathEdit.SelText:=Key;
  end;
end;

procedure TFormMenu.SettingSuddendeathEditExit(Sender: TObject);
begin
 if SettingSuddendeathEdit.Text='' then SettingSuddendeathEdit.Text:='180';
end;

end.
