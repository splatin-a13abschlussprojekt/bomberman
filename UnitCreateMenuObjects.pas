unit UnitCreateMenuObjects;   //BB - Die Groupboxen f�r die Spieler Einstellungen werden erstellt, sowie
                                      // die Images zum ausw�hlen der UFOs (au�erhalb der Groupbox)
interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, StdCtrls, ExtCtrls;

 {Prozeduren zum Erstellen und setzten der Eigenschaften (Groupbox)}
    function StandardFont():TFont;
    procedure SetDragDropImageforGroupbox(i:Byte);
    procedure SetControlLabel(i,j:Byte);
    procedure SetControlPanel(i,j:Byte);
    procedure SetControlButton(i:Byte);
    procedure SetNameEdit(i:Byte);
    procedure SetNameLabel(i:Byte);
    procedure SetHeader(i:Byte);
    procedure SetPanels(i:Byte);
    procedure CreatePlayerGroupbox(i:Byte);
 {Settings}
    procedure CreateSettingObjects();
    procedure SetSettingObjects();

implementation

uses unitMenu;

function StandardFont():TFont;
begin
 StandardFont:=FormMenu.Font; //damit andere Font-Eigenschaften gef�llt sind ; sonst Fehler
 Result.Size:=12;
 Result.Name:='Arial';
 Result.Style:=[];
end;

procedure SetDragDropImageforGroupbox(I:Byte);
begin
 with PlayerGroupbox[i].DragDropImage.Ground do
  begin
   Name:='GroundPanel'+IntToStr(i);
   ParentBackground:=false;
   ParentColor:=false;
   Parent:=PlayerGroupbox[i].Panel;
   BevelInner:=bvNone;
   BevelOuter:=bvNone;
   Left:=Trunc(Playergroupbox[i].Panel.Width/2)-40;
   Top:=Playergroupbox[i].ControlLabel[5].Top+Playergroupbox[i].ControlLabel[5].Height+15;
   Color:=clWhite;
   Alignment:=taCenter;
   Caption:='';
   width:=80;
   Height:=80;
   Visible:=true;
  end;
 PlayerGroupbox[i].DragDropImage.Occupied:=false;
 with PlayerGroupbox[i].DragDropImage.Panel do
  begin
   Name:='ImagePanel'+IntToStr(i);
   ParentBackground:=false;
   ParentColor:=false;
   Parent:=FormMenu;
   BevelInner:=bvNone;
   BevelOuter:=bvNone;
   Left:=PlayerGroupbox[i].Panel.Left+Trunc(Playergroupbox[i].Panel.Width/2)-40;
   Top:=PlayerGroupbox[i].Panel.Top+Playergroupbox[i].ControlLabel[5].Top+Playergroupbox[i].ControlLabel[5].Height+15;
   Color:=clWhite;
   Alignment:=taCenter;
   Caption:=Name;
   width:=80;
   Height:=80;
   BringToFront;
   Visible:=true;
  end;
 //PlayerGroupbox[i].DragDropImage.Panel:=PlayerGroupbox[i].DragDropImage.Ground;
 with PlayerGroupbox[i].DragDropImage.Image do
  begin
   Parent:=TPanel(FormMenu.FindComponent('ImagePanel'+IntToStr(i)));  //PlayerGroupbox[i].DragDropImage.Panel funktioniert nicht..??!!
   Name := 'UfoImage'+IntToStr(i);
   AutoSize:=false;
   Proportional:=true;
   width:=80;
   Height:=80;
   Top:=0;
   Left:=0;
   case i of
    1: Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\ufos\blue-ufo.bmp');
    2: Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\ufos\green-ufo.bmp');
    3: Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\ufos\red-ufo.bmp');
    4: Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\ufos\yellow-ufo.bmp');
   end;
   OnMouseDown:=FormMenu.ImageMouseDown;
   OnMouseUp:=FormMenu.ImageMouseUp;
   OnMouseMove:=FormMenu.ImageMouseMove;
   visible:=true;
  end;
end;

procedure SetControlLabel(i,j:Byte);
begin
 with PlayerGroupbox[i].ControlLabel[j] do
  begin
   Parent:=Playergroupbox[i].Panel;
   case j of
    1: Name:='UpLabel'+IntToStr(i);
    2: Name:='DownLabel'+IntToStr(i);
    3: Name:='LeftLabel'+IntToStr(i);
    4: Name:='RightLabel'+IntToStr(i);
    5: Name:='BombLabel'+IntToStr(i);
   end;
   case j of
    1: Caption:='Hoch';
    2: Caption:='Runter';
    3: Caption:='Links';
    4: Caption:='Rechts';
    5: Caption:='Bombe';
   end;

   Font:=StandardFont();
   Font.Color:=clWhite;
   Height:=20;
   Left:=10;
   Top:=15+PlayerGroupbox[i].ControlButton.Height+PlayerGroupbox[i].ControlButton.Top+(j-1)*(15+Height);
   Visible:=true;
  end;
end;

procedure StandardControl(i,j:Byte);
begin
With PlayerGroupbox[i].ControlPanel[j] do
 Case i of
  1: Case j of         //ANSIUPPERCASE muss bei Auswertung wieder ANSILOWERCASE werden! sonst muss SHIFT gedr�ckt werden!
      1: Caption:=AnsiUpperCase('w');
      2: Caption:=AnsiUpperCase('s');
      3: Caption:=AnsiUpperCase('a');
      4: Caption:=AnsiUpperCase('d');
      5: Caption:=AnsiUpperCase('q');
     end;
  2: Case j of
      1: Caption:=AnsiUpperCase('z');
      2: Caption:=AnsiUpperCase('h');
      3: Caption:=AnsiUpperCase('g');
      4: Caption:=AnsiUpperCase('j');
      5: Caption:=AnsiUpperCase('t');
     end;
  3: Case j of
      1: Caption:=AnsiUpperCase('�');
      2: Caption:=AnsiUpperCase('�');
      3: Caption:=AnsiUpperCase('�');
      4: Caption:=AnsiUpperCase('#');
      5: Caption:=AnsiUpperCase('p');
     end;
  4: Case j of
      1: Caption:=AnsiUpperCase('5');
      2: Caption:=AnsiUpperCase('2');
      3: Caption:=AnsiUpperCase('1');
      4: Caption:=AnsiUpperCase('3');
      5: Caption:=AnsiUpperCase('4');
     end;
 end;
end;

procedure SetControlPanel(i,j:Byte);
begin
 with PlayerGroupbox[i].ControlPanel[j] do
  begin
   Parent:=Playergroupbox[i].Panel;
   case j of
    1: Name:='UpPanel'+IntToStr(i);
    2: Name:='DownPanel'+IntToStr(i);
    3: Name:='LeftPanel'+IntToStr(i);
    4: Name:='RightPanel'+IntToStr(i);
    5: Name:='BombPanel'+IntToStr(i);
   end;
   StandardControl(i,j);//Standard-Steuerung festlegen
   ParentBackground:=false;
   ParentColor:=false;
   BevelInner:=bvNone;
   BevelOuter:=bvNone;
   Font:=StandardFont();
   Font.Color:=RGB(255,255,255);
   Color:=RGB(50,50,50);
   Width:=Trunc(Playergroupbox[i].Panel.Width/2)-10;
   Height:=20;
   Left:=Trunc(Playergroupbox[i].Panel.Width/2);
   Top:=15+PlayerGroupbox[i].ControlButton.Height+PlayerGroupbox[i].ControlButton.Top+(j-1)*(15+Height);
   Visible:=true;
  end;
end;

procedure SetControlButton(i:Byte);
begin
 with PlayerGroupbox[i].ControlButton do
  begin
   Parent:=PlayerGroupbox[i].Panel;
   Name:='ControlButton'+IntToStr(i);
   Width:=TPanel(FormMenu.FindComponent('Panel'+IntToStr(i))).Width-20;
   Height:=30;
   Left:=10;
   Top:=PlayerGroupbox[i].NameEdit.Top+Playergroupbox[i].NameLabel.Height+25;
   Caption:='Steuerung �ndern';
   OnMouseUp:=FormMenu.ButtonMouseUp;
   OnKeyPress:=FormMenu.ControlButtonKeyPress;
   Visible:=true;
  end;
end;

procedure SetNameEdit(i:Byte);
begin
 with PlayerGroupbox[i].NameEdit do
  begin
   Parent:=PlayerGroupbox[i].Panel;
   Name:='NameEdit'+IntToStr(i);
   Font:=StandardFont;
   Left:=10+Playergroupbox[i].NameLabel.Width+5;
   Top:=PlayerGroupbox[i].Header.Top+PlayerGroupbox[i].Header.Height+15-4;
   Height:=12; //"Height" �ndern hat keine Auswirkung?!
   Width:=PlayerGroupbox[i].Panel.Width-Left-10;
   Text:='Spieler '+IntToStr(i);
   Visible:=true;
  end;
end;

procedure SetNameLabel(i:Byte);
begin
 with PlayerGroupbox[i].NameLabel do
  begin
   Parent:=PlayerGroupbox[i].Panel;
   Name:='NameLabel'+IntToStr(i);
   ParentFont:=false;
   Font:=StandardFont();
   Font.Color:=clWhite;
   Left:=10;
   Top:=PlayerGroupbox[i].Header.Top+PlayerGroupbox[i].Header.Height+15;
   Caption:='Name';
   Visible:=true;
  end;
end;

procedure SetHeader(i:Byte);
begin
 with PlayerGroupbox[i].Header do
    begin
     Name:='Header'+IntToStr(i);
     ParentBackground:=false;
     ParentColor:=false;
     Parent:=PlayerGroupbox[i].Panel;
     BevelInner:=bvNone;
     BevelOuter:=bvNone;
     Left:=10;
     Top:=10;
     Color:=clWhite;
    {Schrift}
     Font:=StandardFont();
     Font.Color:=RGB(31,31,31);
     Font.Style:=[fsBold];
    {}
     Alignment:=taCenter;
     Caption:='Spieler '+IntToStr(i);
     width:=TPanel(FormMenu.FindComponent('Panel'+IntToStr(i))).Width-20;
     Height:=FormMenu.Canvas.TextHeight('Spieler '+IntToStr(i))+10;
     Visible:=true;
    end;
end;

procedure SetPanels(i:Byte);
begin
 with PlayerGroupbox[i].Panel do
    begin
     Parent:=FormMenu;
     Name:='Panel'+IntToStr(i);
     ParentBackground:=false;
     BevelInner:=bvNone;
     BevelOuter:=bvNone;
     Caption:='';
     width:=200;
     Height:=400;
     Left:=20+(20+width)*(i-1);
     Top:=175;
     Color:=RGB(31,31,31);
     Visible:=true;
    end;
end;

procedure CreatePlayerGroupbox(i:Byte);
 var j : Byte;
begin
 PlayerGroupbox[i].Panel:=TPanel.Create(FormMenu);
 PlayerGroupbox[i].Header:=TPanel.Create(PlayerGroupbox[i].Panel);
 PlayerGroupbox[i].NameLabel:=TLabel.Create(PlayerGroupbox[i].Panel);
 PlayerGroupbox[i].NameEdit:=TEdit.Create(PlayerGroupbox[i].Panel);
 PlayerGroupbox[i].ControlButton:=TButton.Create(Playergroupbox[i].Panel);
 for j:=1 to 5 do
  begin
   Playergroupbox[i].ControlPanel[j]:=TPanel.Create(PlayergroupBox[i].Panel);
   Playergroupbox[i].ControlLabel[j]:=TLabel.Create(PlayergroupBox[i].Panel);
  end;
 PlayerGroupbox[i].DragDropImage.Ground:=TPanel.Create(PlayergroupBox[i].Panel);
 PlayerGroupbox[i].DragDropImage.Panel:=TPanel.Create(FormMenu);
 PlayerGroupbox[i].DragDropImage.Image:=TImage.Create(PlayergroupBox[i].DragDropImage.Panel);
end;

procedure CreateSettingObjects();
begin
 SettingSuddendeathImage.CheckImage:=TImage.Create(FormMenu.SettingsPanel);
 SettingSuddendeathImage.Checked:=false;
 SetsettingObjects();
end;

procedure SetSettingObjects();
begin
 with SettingSuddendeathImage.CheckImage do
  begin
   Parent:=FormMenu.SettingsPanel;
   Name := 'SettingSuddendeathImage';
   AutoSize:=false;
   Proportional:=true;
   width:=25;
   Height:=25;
   Top:=FormMenu.NumberOfPlayersLabel.Top+FormMenu.NumberOfPlayersLabel.Height+10;
   Left:=10;
   Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'Images\menu\checkbox-unchecked.bmp');
   OnMouseUp:=FormMenu.SettingSuddendeathMouseUp;
   Visible:=true;
  end;
end;

end.