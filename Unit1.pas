unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,UTriangleTricolor, ExtCtrls;

type
  TForm1 = class(TForm)
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;



var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 tri:ttriangletricolor;
 bit:tbitmap;
begin
 bit:=tbitmap.Create;
 bit.Width:=width;
 bit.Height:=height;
 tri:= ttriangletricolor.create;
 tri.Sommet[1]:=MyPoint(clientwidth div 2,0,clred);
 tri.Sommet[2]:=MyPoint(0,clientheight div 2,clyellow);
 tri.Sommet[3]:=MyPoint(x,y,clwhite);
 tri.DrawInBitMap(bit);
 tri.Sommet[1]:=MyPoint(0,clientheight div 2,clyellow);
 tri.Sommet[2]:=MyPoint(clientwidth div 2,clientheight,clgreen);
 tri.Sommet[3]:=MyPoint(x,y,clwhite);
 tri.DrawInBitMap(bit);
 tri.Sommet[1]:=MyPoint(clientwidth div 2,clientheight,clgreen);
 tri.Sommet[2]:=MyPoint(clientwidth,clientheight div 2,clblue);
 tri.Sommet[3]:=MyPoint(x,y,clwhite);
 tri.DrawInBitMap(bit);
 tri.Sommet[1]:=MyPoint(clientwidth,clientheight div 2,clblue);
 tri.Sommet[2]:=MyPoint(clientwidth div 2,0,clred);
 tri.Sommet[3]:=MyPoint(x,y,clwhite);
 tri.DrawInBitMap(bit);
 tri.Free;
 canvaS.Draw(0,0,bit);
end;

end.
