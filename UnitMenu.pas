unit UnitMenu;         //BB - Menü

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, shellAPI;

type
 TPlayerSettings = record
  Name    : String[15];
  KeyUp   : Char;
  KeyDown :Char;
  KeyLeft :Char;
  KeyRight:Char;
  KeyBomb :Char;
  UfoColor:String[6];
 end;

 TSuddenDeathSettings = record
  activated : Boolean;
  time : Word;
 end;

 TSettings = record
  SuddenDeathSettings : TSuddenDeathSettings;
  SFX : Boolean;
  NumOfWins : Word; //Sieglimit
  NumOfPlayers : Word;
  PlayerSettings : Array[1..4] of TPlayerSettings;
 end;

 TCheckImage = record
  CheckImage : TImage;
  Checked: Boolean;
 end;

 TDragDropImage = record
  Panel : TPanel;
  Color : String[6];
  Image : TImage;//Image befindet sich auf Panel --> kann dann über alles bewegt werden
  Ground: TPanel;//Ground hält Standardposition --> ist dann ein weißes Feld
 end;

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
    StartButton: TButton;
    CloseButton: TButton;
    Label1: TLabel;
    RoundsEdit: TEdit;     //Rounds gibt maximale anzahl der Siege an
    RoundsUpImage: TImage;
    RoundsDownImage: TImage;
    TitlePanel: TPanel;
    Button1: TButton;
    SFXLabel: TLabel;
    CheckboxCheckedImage: TImage;
    CheckboxUncheckedImage: TImage;
    UfoblueImage: TImage;
    UfogreenImage: TImage;
    UforedImage: TImage;
    UfoyellowImage: TImage;
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
    procedure UpdateSettings();
    procedure StartButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure RoundsUpImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RoundsDownImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NumberOfPlayersEditChange(Sender: TObject);
    procedure RoundsEditKeyPress(Sender: TObject; var Key: Char);
    procedure DeleteAllMenuObjects();
    procedure SaveSettings();
    procedure SetSettings();
    procedure LoadSettings();
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure SFXMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FormMenu: TFormMenu;
  PlayerGroupbox : Array[1..4] of TPlayerGroupbox; {Für die Spielereinstellungen}
  SuddenDeathImage : TCheckImage; {CheckImage wird als Objekt erstellt}
  SFXImage : TCheckImage; {Um SFX an/aus zu schalten}
  Settings : TSettings; {hier Umsind alle Einstellungen gespeichert --> zum späteren auslesen}
  GroupNumber: Byte; {Nummer der Gruppe, in dem die Steuerung geändert wird}
  PanelNumber:Byte; {Nummer des Panels, in dem die Steuerung geändert wird}
  MousePos :TPoint; {Zum Drag&Drop für die Ufos}
  Drag:Boolean;     {true, wenn Image gedrückt gehalten wird}

implementation

uses UnitCreateMenuObjects, UnitTestPlayer, Math;

{$R *.dfm}

procedure TFormMenu.FormCreate(Sender: TObject); //BB-Menü
 var i,j:Integer;
begin
 TitlePanel.Color:=RGB(0,0,25);
 TitlePanel.Font.Color:=RGB(200,200,200);
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

 LoadSettings();
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
     mColor : String[6];
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
   mColor:=Playergroupbox[j].DragDropImage.Color;
   VImage.Picture:=Playergroupbox[j].DragDropImage.Image.Picture; //Bilder (von Panels I & J) werden getauscht
   Playergroupbox[j].DragDropImage.Color:=Playergroupbox[i].DragDropImage.Color;
   Playergroupbox[j].DragDropImage.Image.Picture:=Playergroupbox[i].DragDropImage.Image.Picture;
   Playergroupbox[i].DragDropImage.Color:=mColor;
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
 if SuddenDeathImage.Checked=false then
  begin
   with SuddenDeathImage do
    begin
     CheckImage.Picture:=CheckboxCheckedImage.Picture; //Bild für Image Laden
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
   with SuddenDeathImage do
    begin
     CheckImage.Picture:=CheckboxUnCheckedImage.Picture;
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

procedure TFormMenu.UpdateSettings(); //Auslesen der Einstellungen und in Settings speichern
 var i,j : Byte;
begin                                         //damit '[taste]' nicht gespeichert wird --> Panel wird dann mit Standardsteuerung belegt
 for i:=1 to 4 do for j:=1 to 5 do if length(PlayerGroupbox[i].COntrolPanel[j].Caption)>1 then UnitCreateMenuObjects.StandardControl(i,j);
 With Settings do
  begin
   NumOfWins:=StrToInt(RoundsEdit.text);
   NumOfPlayers:=StrToInt(NumberOfPlayersEdit.Text);
   if SuddenDeathImage.Checked=true then
    begin
     SuddenDeathSettings.activated:=true;
     SuddenDeathSettings.time:=StrToInt(SettingSuddendeathEdit.Text);
    end
   else
    begin
     SuddenDeathSettings.activated:=false;
     SuddenDeathSettings.time:=180;//Standardlänge bis zum Sudden death
    end;
   SFX:=SFXImage.Checked;
   for i:=1 to 4 do
    begin
     With PlayerSettings[i] do
      begin
       Name:=    Playergroupbox[i].NameEdit.Text;              //Spielereinstellungen nacheinander abgehen
       KeyUp:=   Playergroupbox[i].ControlPanel[1].Caption[1];
       KeyDown:= Playergroupbox[i].ControlPanel[2].Caption[1];
       KeyLeft:= Playergroupbox[i].ControlPanel[3].Caption[1];
       KeyRight:=Playergroupbox[i].ControlPanel[4].Caption[1];
       KeyBomb:= Playergroupbox[i].ControlPanel[5].Caption[1];
       UfoColor:=Playergroupbox[i].DragDropImage.Color;
      end;
    end;
  end;
end;

procedure TFormMenu.StartButtonClick(Sender: TObject);
 var i:Byte;
begin
 UpdateSettings();
 FormGame.FormCreate(FormMenu);
 {Panels/Labels für die Punkte}
 for i:=1 to 4 do
  begin
   If i<=Settings.NumOfPlayers then
    begin
     TPanel(FormGame.FindComponent('PointsPanel'+IntToStr(i))).Visible:=true;
     TPanel(FormGame.FindComponent('PointsPanel'+IntToStr(i))).Caption:='0';
     TLabel(FormGame.FindComponent('PointsLabel'+IntToStr(i))).Visible:=true;
     TLabel(FormGame.FindComponent('PointsLabel'+IntToStr(i))).Caption:=Settings.Playersettings[i].Name;
    end
   else
    begin
     TPanel(FormGame.FindComponent('PointsPanel'+IntToStr(i))).Visible:=false;
     TLabel(FormGame.FindComponent('PointsLabel'+IntToStr(i))).Visible:=false;
    end;
  end;
 {}
 if Settings.SuddenDeathSettings.activated=true then FormGame.CountDownPanel.Caption:=IntToStr(Settings.SuddenDeathSettings.time) else FormGame.CountdownPanel.Caption:='0';
 FormGame.CreateBeginGamePanel();
 FormGame.KeyPreview:=false;
 FormGame.BeginGameTimer.Enabled:=true;
 if FormMenu.WindowState<>wsMinimized then FormMenu.WindowState:=wsMinimized; //minimieren
 if FormGame.Visible=false then FormGame.Showmodal; //auf FormMenu kann nicht mehr zugegriffen werden (vom User)
end;

procedure TFormMenu.CloseButtonClick(Sender: TObject);
begin
 close;
end;

procedure TFormMenu.RoundsUpImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if StrToInt(RoundsEdit.Text)<99 then RoundsEdit.Text:=IntToStr(StrToInt(RoundsEdit.Text)+1);
end;

procedure TFormMenu.RoundsDownImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if StrToInt(RoundsEdit.Text)>1 then RoundsEdit.Text:=IntToStr(StrToInt(RoundsEdit.Text)-1);
end;

procedure TFormMenu.NumberOfPlayersEditChange(Sender: TObject);
 var i:Byte;
begin
 for i:=1 to StrToInt(NumberOfPlayersEdit.Text) do
  begin
   Playergroupbox[i].Header.Color:=clWhite;
   PlayerGroupbox[i].Header.Font.Color:=RGB(31,31,31);
  end;
 if StrToInt(NumberOfPlayersEdit.Text)=4 then exit else
  begin
   for i:=StrToInt(NumberOfPlayersEdit.Text)+1 to 4 do
    begin
     Playergroupbox[i].Header.Color:=RGB(31,31,31);
     PlayerGroupbox[i].Header.Font.Color:=clWhite;
    end;
  end;
end;

procedure TFormMenu.RoundsEditKeyPress(Sender: TObject; var Key: Char);
begin
if Key=#8 then (RoundsEdit.Text:='');  //#8 = [DEL]
 if (StrToIntDef(Key,-1)>-1) and (length(RoundsEdit.Text)<2) then RoundsEdit.SelText:=Key;
end;

procedure TFormMenu.DeleteAllMenuObjects();
 var i : Byte;
begin
 for i:=1 to 4 do
  begin
   with PlayerGroupbox[i] do Panel.Free;//Objekte, die auf dem Panel liegen, werden ebenfalls gelöscht
  end;
 SuddenDeathImage.CheckImage.Free;
 SFXImage.CheckImage.Free;
end;

procedure TFormMenu.SaveSettings();
 var Path : String; //Pfad zum Speichern
     FPlayerSettings : File of TSettings; //typisierte Datei funktioniert nicht
begin
 Path:=ExtractFilePath(ParamStr(0))+'Files\'; //Ordner wird erstellt
 if not DirectoryExists(Path) then ForceDirectories(Path);
   AssignFile(FPlayerSettings,Path+'Settings.dat');
   Rewrite(FPlayerSettings);
   Write(FPlayerSettings,Settings);
   CloseFile(FPlayerSettings);
end;

procedure TFOrmMenu.SetSettings();
 var i: Byte;
begin
 if Settings.SuddenDeathSettings.activated = true then SettingSuddendeathMouseUp(FormMenu,mbLeft,[]{ShiftState = Leer (Ctrl/Shift/alt) nicht nötigt},10,10{Position});
 if Settings.SFX = false then SFXMouseUp(FormMenu,mbLeft,[],10,10);
 SettingSuddendeathEdit.Text:=IntToStr(Settings.SuddenDeathSettings.time);
 NumberOfPlayersEdit.Text:=IntToStr(Settings.NumOfPlayers);
 RoundsEdit.Text:=IntToStr(Settings.NumOfPlayers);
 for i:=1 to 4 do
  begin
   PlayerGroupbox[i].NameEdit.Text:=Settings.PlayerSettings[i].Name;
   PlayerGroupbox[i].ControlPanel[1].Caption:=Settings.PlayerSettings[i].KeyUp;
   PlayerGroupbox[i].ControlPanel[2].Caption:=Settings.PlayerSettings[i].KeyDown;
   PlayerGroupbox[i].ControlPanel[3].Caption:=Settings.PlayerSettings[i].KeyLeft;
   PlayerGroupbox[i].ControlPanel[4].Caption:=Settings.PlayerSettings[i].KeyRight;
   PlayerGroupbox[i].ControlPanel[5].Caption:=Settings.PlayerSettings[i].KeyBomb;
   PlayerGroupbox[i].DragDropImage.Image.Picture:=TImage(FormMenu.FindComponent('Ufo'+Settings.PlayerSettings[i].UfoColor+'Image')).Picture;
   PlayerGroupbox[i].DragDropImage.Color:=Settings.PlayerSettings[i].UfoColor;
  end;
end;

procedure TFOrmMenu.LoadSettings();
 var Path : String; //Pfad zum Laden
     FPlayerSettings : File of TSettings; //typisierte Datei funktioniert nicht
begin
   Path:=ExtractFilePath(ParamStr(0))+'Files\';
   if not FileExists(Path+'Settings.dat') then exit; //sonst Fehler
   AssignFile(FPlayerSettings,Path+'Settings.dat');
   Reset(FPlayerSettings);
   Read(FPlayerSettings,Settings);
   CloseFile(FPlayerSettings);
   SetSettings();
end;

procedure TFormMenu.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 UpdateSettings();
 SaveSettings();
 DeleteAllMenuObjects();
end;

procedure TFormMenu.Button1Click(Sender: TObject);
begin
ShellExecute(Handle,NIL,PCHAR(ExtractFilePath(ParamStr(0))+'Files\Nutzerhandbuch.pdf'),PCHAR(''),NIL, SW_Show);
end;

procedure TFormMenu.SFXMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if SFXImage.Checked = false then
  begin
   with SFXImage do
    begin
     CheckImage.Picture:=CheckboxCheckedImage.Picture; //Bild für Image Laden
     Checked:=true; //Checkbox ist "gechecked"
    end;
  end
 else
  begin
   with SFXImage do
    begin
     CheckImage.Picture:=CheckboxUnCheckedImage.Picture;
     Checked:=false; //Checkbox ist nicht "gechecked"
    end;
  end;
end;

end.
