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
  Image : TImage;//Image befindet sich auf Panel --> kann dann über alles bewegt werden
  Ground: TPanel;//Ground hält Standardposition --> ist dann ein weißes Feld
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
  PlayerGroupbox : Array[1..4] of TPlayerGroupbox; {Für die Spielereinstellungen}
  SettingSuddendeathImage : TCheckImage; {CheckImage wird als Objekt erstellt}
  NumberKeys : Byte;
  GroupNumber: Byte; {Nummer der Gruppe, in dem die Steuerung geändert wird}
  PanelNumber:Byte; {Nummer des Panels, in dem die Steuerung geändert wird}
  MousePos :TPoint; {Zum Drag&Drop für die Ufos}
  Drag:Boolean;     {true, wenn Image gedrückt gehalten wird}

implementation

uses UnitInterface, UnitCreateMenuObjects, Math;

{$R *.dfm}

procedure TFormMenu.FormCreate(Sender: TObject); //BB-Menü
 var i,j:Integer;
begin
 Canvas.Font.Size:=12;       //um Texthöhe später ermitteln zu können --> Objekthöhe richtet sich danach
 Canvas.Font.Name:='Arial';
 for i:=1 to 4 do
  begin
   CreatePlayerGroupbox(i);  {erstellen aller Objekte für die Spieler-Einstellungen}
  {Einstellungen für die jeweiligen Objekte}
   SetPanels(i);         //Grundfläche
   SetHeader(i);         //Überschrift
   SetNameLabel(i);
   SetNameEdit(i);
   SetControlButton(i);  //Button, mit dem die Steuerung verändert wird
   for j:=1 to 5 do
    begin
     SetControlPanel(i,j);  //Panels mit dazugehörigen Labels
     SetControlLabel(i,j);  //5 pro Spieler
    end;
   SetDragDropImageforGroupbox(i);
  end;
 {Settings - Panel}
 SettingsPanel.Color:=RGB(31,31,31);
 SettingsHeader.Font:=StandardFont(); //-->UnitCreateMenuObjects
 SettingsHeader.Font.Style:=[fsBold]; //Überschrift: Fett
 SettingsHeader.Font.Color:=RGB(31,31,31);
 CreateSettingObjects(); //CheckImage wird erstellt (für Suddendeath-Einstellung)
end;

procedure TFormMenu.ControlButtonKeyPress(Sender: TObject; var Key: Char); //
begin
 SetKey(Key);     //schreibt Buchstaben in Panel (PanelNumber gibt an, in welches); GroupNumber gibt an, welcher Spieler die Steuerung ändert --> Objekte können genau angesprochen werden
 PanelExpectKey();
end;

procedure TFormMenu.PanelExpectKey();//ändert Eigenschaften (Caption,Color & FontColor), wenn Panel Taste "erwartet"
begin
 if PanelNumber=6 then
  begin
   NumberOfPlayersEdit.SetFocus;//Sonst bleibt Fokus auf Button --> führt zu Bugs (Labels werden angesprochen ??!!)
   Exit;
  end;
 with PlayerGroupbox[GroupNumber].ControlPanel[PanelNumber] do
  begin
   Color:=clWhite;
   Font.Color:=RGB(31,31,31);
   Caption:='[TASTE]'
  end;
end;

procedure TFormMenu.PanelGotKey(); //wenn Taste eines Panels geändert wurde, wird Schriftfarbe & Farbe wieder zurückgesetzt
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
   Caption:=AnsiUpperCase(Key); //Damit Buchstabe groß dargestellt wird; Muss beim auswerten der Steuerung berücksichtigt werden!!!
   PanelGotKey();
  end;
 Inc(PanelNumber); //nächstes Panel
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
   TPanel(ParentPanel).Left:=MousePos.X-40; //Bilder sind 80 Hoch/Breit --> Cursor ist genau in der Mitte
   TPanel(ParentPanel).Top:=MousePos.Y-40;
  end;
end;

procedure TFormMenu.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
 var ParentPanel: TComponent;
begin
 ParentPanel:=TImage(Sender).GetParentComponent;
 drag:=true; //Maus muss gedrückt gehalten werden, damit Ufo bewegt werden kann
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
 for i:=1 to 4 do   //Positionen aller "GroundPanels" wird ermittelt
  begin
   PositionOfGroundPanel[i].X:=Playergroupbox[i].Panel.Left+Playergroupbox[i].DragDropImage.Ground.Left;
   PositionOfGroundPanel[i].Y:=Playergroupbox[i].Panel.Top+Playergroupbox[i].DragDropImage.Ground.Top;
  end;
 for i:=1 to 4 do  //Pythagoras...
  begin
   distances[i]:=sqrt((PositionOfGroundPanel[i].X-Pos.X)*(PositionOfGroundPanel[i].X-Pos.X)+(PositionOfGroundPanel[i].Y-Pos.Y)*(PositionOfGroundPanel[i].Y-Pos.Y));
  end;
 MinDistance:=MaxExtended;
 Noticei:=0; //sonst Warnung im Compiler; Zeile nicht nötig
 for I:=1 to 4 do //kleinster Wert wird ermittelt --> in "NoticeI" gespeichert
  if distances[i]<MinDistance then
   begin
    MinDistance:=distances[i];
    NoticeI:=I;
   end;
 GroundPanelNumber:=Noticei; //NoticeI gibt genau das GroundPanel an, welches dem losgelassenen Objekt am nächsten ist
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
 GetNextFreeGroundPanel(TPanel(ParentPanel).Left,TPanel(ParentPanel).Top,Sender,i); //nächtes GroundPanel wurde ermittelt --> I
 repeat
  inc(j);
 until TPanel(ParentPanel)=Playergroupbox[j].DragDropImage.Panel; //es wird ermittelt, zu welchem "GroundPanel" das Panel gehört --> J
 PlayerGroupbox[j].DragDropImage.Panel.Left:=Playergroupbox[j].Panel.Left+Playergroupbox[j].DragDropImage.Ground.Left; //zurück an seinen Ursprünglichen Ort --> GroundPanel J
 PlayerGroupbox[j].DragDropImage.Panel.Top:=Playergroupbox[j].Panel.Top+Playergroupbox[j].DragDropImage.Ground.Top;
 if i<>j then //Wenn das nächste "GroundPanel" nicht das eigene ist, dann:
  begin
   VImage:=TImage.Create(self); //Virtuelles Image erstelle (zum merken des Bildes)
   VImage.Picture:=Playergroupbox[j].DragDropImage.Image.Picture; //Bilder (von Panels I & J) werden getauscht
   Playergroupbox[j].DragDropImage.Image.Picture:=Playergroupbox[i].DragDropImage.Image.Picture;
   Playergroupbox[i].DragDropImage.Image.Picture:=VImage.Picture;
   VImage.Free; //
  end;
end;

procedure TFormMenu.ButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 GroupNumber:=0;
 Repeat
  inc(GroupNumber);
 until Sender = PlayerGroupbox[GroupNumber].ControlButton; //Gruppe wird ermittelt, in welchem die Steuerung geändert werden soll
 PanelNumber:=1; //1. Panel erwartet Taste
 PanelExpectKey(); //Eigenschaften ändern
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
     CheckImage.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\menu\checkbox-checked.bmp'); //Bild für Image Laden
     SettingSuddenDeathLabel2.Visible:=true;  //Objekte sichtbar machen
     SettingSuddenDeathLabel3.Visible:=true;
     SettingSuddendeathEdit.Visible:=true;
     SettingSuddendeathUpImage.Visible:=true;
     SettingSuddendeathDownImage.Visible:=true;
     Checked:=true; //Checkbox ist "gechecked"
    end;
  end
 else
  begin
   with SettingSuddendeathImage do
    begin
     CheckImage.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\menu\checkbox-unchecked.bmp');
     SettingSuddenDeathLabel2.Visible:=false; //Objekte unsichtbar machen
     SettingSuddenDeathLabel3.Visible:=false;
     SettingSuddendeathEdit.Visible:=false;
     SettingSuddendeathUpImage.Visible:=false;
     SettingSuddendeathDownImage.Visible:=false;
     Checked:=false; //Checkbox ist nicht "gechecked"
    end;
  end;
end;

procedure TFormMenu.SettingSuddendeathUpImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin                                   //Maximaler Wert
if StrToInt(SettingSuddendeathEdit.Text)<999 then SettingSuddendeathEdit.Text:=IntToStr(StrToInt(SettingSuddendeathEdit.Text)+1);
end;

procedure TFormMenu.SettingSuddendeathDownImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin                                   //Minimaler Wert
if StrToInt(SettingSuddendeathEdit.Text)>=1 then SettingSuddendeathEdit.Text:=IntToStr(StrToInt(SettingSuddendeathEdit.Text)-1);
end;

procedure TFormMenu.SettingSuddendeathEditKeyPress(Sender: TObject;
  var Key: Char);
begin
 if Key=#8 then (SettingSuddendeathEdit.Text:='');  //#8 = [DEL]
 if (StrToIntDef(Key,-1)>-1) and (length(SettingSuddendeathEdit.Text)<3) then SettingSuddendeathEdit.SelText:=Key; //SelText ist Stelle des Cursors --> dort wird "Key" eingefügt
end;//StrToIntDef: Überprüft auf güligen Integer Wert, ist das nicht der Fall, wird -1 ausgegeben --> es passiert nichts (jegliche anderen Zeichen werden abgefangen)

procedure TFormMenu.SettingSuddendeathEditExit(Sender: TObject);
begin
 if SettingSuddendeathEdit.Text='' then SettingSuddendeathEdit.Text:='180';//damit Editfeld nicht leer ist
end;

end.
