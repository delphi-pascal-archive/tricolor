unit UTriangleTricolor;

interface

uses math,Types,windows,Graphics,SysUtils;

type
 TIntegerArray=array[word] of integer;
 PIntegerArray=^TIntegerArray;
 tMyPoint=record x,y,c:integer; end;
 TListeMyPoint=array[0..1] of tMyPoint;
 TByte=array[0..3] of byte;


type
 TTriangleTricolor=class(Tobject)
  private
    { Déclarations privées }
    FSommet:array[0..4]of TMYPoint;
    bord:array of TListeMyPoint;
    fcanvas:tcanvas;
    fbitmap:tbitmap;
    FMin,FMax:integer;
    function GetSommet(n: Integer): TMyPoint;
    procedure SetSommet(n: Integer; Value: TMyPoint);
    procedure drawHlineC(p1,p2:tmypoint);
    procedure drawHlineB(p1,p2:tmypoint);
    procedure PrepareBords;
    procedure CreateBord(a,b:tmypoint;drawfirst:boolean);
  public
    { Déclarations publiques }
    property Sommet[n:integer]:TMyPoint read GetSommet write SetSommet;    property canvas:tcanvas read fcanvas write fcanvas;
    procedure DrawInCanvas(canvas:tcanvas);
    procedure DrawInBitMap(bitmap:Tbitmap);
  end;

function MyPoint(x,y,c:integer):tmypoint;

implementation


// converti une couleur RVG en BVR
function convertcolor(c:integer):integer;
begin
 result:=rgb(tbyte(c)[2],tbyte(c)[1],tbyte(c)[0]);
end;

// calcul la couleur intermédiaire entre c1 et c2
function calculcouleur(pos,mx,c1,c2:integer):integer;
var
 a,b:TByte;
 i:integer;
begin
 if mx=0 then mx:=1;
 a:=tbyte(c1);
 b:=tbyte(c2);
 for i:=0 to 3 do a[i]:=a[i]+pos*(b[i]-a[i]) div mx;
 result:=integer(a);
end;


// converti x, y ,c en mypoint
function MyPoint(x,y,c:integer):tmypoint;
begin
 result.x:=x;
 result.y:=y;
 result.c:=c;
end;

// échange a et b
procedure SwapAB(var a,b:tmypoint);
var t:tmypoint;
begin
 t:=a; a:=b; b:=t;
end;

//lecture pour la propriété Sommet
function TTriangleTricolor.GetSommet(n: Integer): TMyPoint;
begin
 result:=Mypoint(0,0,0);
 if (n<1) or (n>3) then exit;
 result:=Fsommet[n];
end;

//écriture pour la propriété Sommet
procedure TTriangleTricolor.SetSommet(n: Integer; Value: TMyPoint);
begin
 if (n<1) or (n>3) then exit;
 Fsommet[n]:=value;
end;

// rempli le tableau des bords gauche et droit avec la ligne de a à b
procedure TTriangleTricolor.CreateBord(a,b:tmypoint;drawfirst:boolean);
var
 dx,dy,i:integer;
 drawlast:boolean;
 x,y,c:integer;
begin
 // si a et b au même endroit, c'est pas une droite mais un point, on sort
 if (a.x=b.x) and (a.y=b.y) then exit;
 // si c'est une ligne horizontal, on sort, elle sert à rien
 if (a.y=b.y) then exit;
 //on doit dessiner le dernier point
 drawlast:=true;
 // si b et avant a, on inverse les deux pour l'algorithme
 if b.y<a.y then
  begin
   swapab(a,b);
   drawlast:=drawfirst;  //doit t'on donc dessiner le dernier point ?
   drawfirst:=true;      // dans tout les cas, on devra dessiner le permier
  end;

 // trace la droite de a à b
 dx:=b.x-a.x;
 dy:=b.y-a.y;

 for i:=byte(not drawfirst) to dy-byte(not drawlast) do
  begin
   x:=(a.x*dy+i*dx) div dy;     // calcul X en fonction de Y
                                // sorte de moyenne pondérée entre a.x et b.x
   y:=a.y+i;                    // calcul Y
   c:=calculcouleur(i,dy,a.c,b.c); //calcul la couleur de ce point
                                // aussi une sorte de moyenne pondérée entre a.c et b.c
   if (y-fmin>=0) and (y<=fmax) then
    begin                       // comme on est dans un triangle, il n'y a qu'un bord
                                //gauche et un droit, donc deux points par ligne
     bord[y-fmin][1]:=bord[y-fmin][0]; // on décale le premier dans le deuxième au cas où
                                // il avait déjà été calculé
     bord[y-fmin][0]:=mypoint(x,y,c); //on sauve notre point
    end;
  end;
end;

// est-ce que a et c sont du même côté de la droite horizontale passant par b ???
// si a ou b sont sur la droite passant par C, on retourne vrai aussi
function MemeCote(a,b,c:tmypoint):boolean;
begin
 result:=(sign(b.y-a.y)*sign(c.y-b.y))<=0;
end;

// dessin le triangle tricolor dans Fcanvas
procedure TTriangleTricolor.drawHlineC(p1,p2:tmypoint);
var
 i,dx:integer;
begin
 // on range dans l'ordre croissant des abscisses
 if p1.x>p2.x then swapab(p1,p2);
 dx:=p2.x-p1.x;
 // on trace un segment horizontal entre P1 et P2 avec le dégradé de
 // couleur de p1.c à p2.c
 for i:=0 to dx do canvas.pixels[p1.x+i,p1.y]:=calculcouleur(i,dx,p1.c,p2.c);
end;

// dessin le triangle tricolor dans FBitmap
// optimisation avec scanline
procedure TTriangleTricolor.drawHlineB(p1,p2:tmypoint);
var
 i,dx:integer;
 p:pintegerarray;
begin
 // si c'est en dehors du bitmap, on sort
 if (p1.y<0) or (p1.y>=fbitmap.Height) then exit;

 fbitmap.PixelFormat:=pf32bit;
 // on range dans l'ordre croissant des abscisses
 if p1.x>p2.x then swapab(p1,p2);
 dx:=p2.x-p1.x;

 p:=fbitmap.ScanLine[p1.y];
 // on trace un segment horizontal entre P1 et P2 avec le dégradé de
 // couleur de p1.c à p2.c
 for i:=0 to dx do
  if (p1.x+i>=0) and (p1.x+i<fbitmap.Width) then
   p[p1.x+i]:=convertcolor(calculcouleur(i,dx,p1.c,p2.c));
end;


// crée le tableau des bords
procedure TTriangleTricolor.PrepareBords;
var
 i:integer;
begin
 // on cherche le maximum
 FMax:=max(max(Fsommet[1].y,Fsommet[2].y),Fsommet[3].y);
 if FMax<0 then exit;
 //on cherche le minimum
 FMin:=min(min(Fsommet[1].y,Fsommet[2].y),Fsommet[3].y);
 if FMin<0 then FMin:=0;
 //on alloue le tableau
 setlength(bord,fmax-fmin+1);
 // on crée deux sommets en plus pour que i-1 et i+1 existe toujours
 Fsommet[0]:=fsommet[3];
 Fsommet[4]:=fsommet[1];

 // on trace les trois côtés du triangle dans bords
 for i:=1 to 3 do
   CreateBord(Fsommet[i],Fsommet[i+1],MemeCote(Fsommet[i-1],Fsommet[i],Fsommet[i+1]));
end;


// dessine dans fcanvas
procedure TTriangleTricolor.DrawInCanvas(canvas:tcanvas);
var
 i:integer;
begin
 PrepareBords;
 fcanvas:=canvas;
 for i:=0 to high(bord) do drawHlineC(bord[i][0],bord[i][1]);
end;

// dessine dans fbitmap
procedure TTriangleTricolor.DrawInBitMap(bitmap:Tbitmap);
var
 i:integer;
begin
 PrepareBords;
 fbitmap:=bitmap;
 for i:=0 to high(bord) do drawHlineB(bord[i][0],bord[i][1]);
end;

end.
