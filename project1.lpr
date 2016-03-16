program project1;
uses allegro,crt,sysutils,DateUtils,math,windows;
CONST pi=3.14159265359;
type
  L=record                      //paletka
    x_max,x_min,y_max,y_min:integer;
    w_x:integer;
    w_y:integer;

end;
  P=record         //pilka
    r:integer;  //promien
    x,y:double;  //wspolrzedne srodka
    vx,vy:double; //Wektory predkosci
    vxn,vyn:double; //Znormalizowane wektory predkosci
    timenow,timepast:TDateTime; //Potrzebne do obliczenia delta time
    deltatime:double;           //Czas pomiedzy frame'ami
    predkosc:double;
    calkowityczas:double;
     licznikfps:integer;
     px,py:double;
    kolix,koliy:double;
  end;
  O=record
   x1,x2,y1,y2,sz,wys:double;
   end;

var
  CnTicks:integer;
  krzak,  paletka1,pilkaB : AL_BITMAPptr;
  bufor :AL_BITMAPptr;
procedure IntTicks;CDECL;
begin
    INC(CnTicks);
end;
//*************************************************************
procedure normalizuj(var Pilka:P);
var
dl:double;
begin
dl:=sqrt(power(Pilka.vx,2)+power(Pilka.vy,2));
Pilka.vxn:=(Pilka.vx/dl);
Pilka.vyn:=(Pilka.vy/dl);

end;
procedure inicjalizuj(width,height:longint);
begin
    if not al_init then
       begin
         writeln('Blad inicjalizacji biblioteki Allegro!');
         readln;
         halt(1);
       end;
    al_install_timer;
    if not al_install_int_ex (@IntTicks, AL_BPS_TO_TIMER(120)) then
       begin
         al_message('Blad inicjalizacji timera!');
         readln;
         halt(1);
       end;
    if not al_install_keyboard then
       begin
         al_message('Blad inicjalizacji klawiatury!');
         readln;
         halt(1);
       end;
    al_set_color_depth(32);
    if not al_set_gfx_mode(AL_GFX_AUTODETECT_WINDOWED,width,height,0,0) then
       begin
         al_message('Blad ustawienia trybu graficznego!');
         readln;
         halt;
       end;
end;
function fabs(x1,x2:double):double;
begin
  if x1>x2 then fabs:=x1-x2
  else if x2>x1 then fabs:=x2-x1
  else fabs:=0;
end;

//*************************************************************
//FUNKCJE OD RUCHU
procedure aktualizuj_polozenie_pilki(var Pilka:P) ;
var
    dl:real;
    time:double;
  begin
         Pilka.x:=Pilka.x+Pilka.px;
         Pilka.y:=Pilka.y+Pilka.py;  ;

end;
procedure reaguj_na_kolizje(var Pilka:P;side:char);
var
  x:integer;
  Mnoznik:integer;
  begin
  mnoznik:=-1;
     if (side='p') or (side='l') then begin
        Pilka.vxn:=Pilka.vxn*-1 ;

      // al_message('P OR L');
     end
               else if (side='d') or (side='g') then begin Pilka.vyn:=Pilka.vyn*-1;
                     //al_message('D OR G');
                  end     ;
end;
function coll(Pilka:P; Obiekt:O):byte;
var
  CD:double;
 dystans_x,dystans_y:double;
begin
    coll:=0;
if ((Pilka.x + Pilka.px + Pilka.r >= Obiekt.x1)
and (Pilka.x + Pilka.px - Pilka.r <= Obiekt.x2))
and ((Pilka.y + Pilka.py + Pilka.r >= Obiekt.y1)
and (Pilka.y + Pilka.py - Pilka.r <= Obiekt.y2)) then


begin
   coll:=3;
Pilka.kolix:=Pilka.x;
Pilka.koliy:=Pilka.y;
   if ((Pilka.x+Pilka.r<Obiekt.x1) and (Pilka.x+Pilka.px+Pilka.r>=Obiekt.x1)) or
   ((Pilka.x-Pilka.r>Obiekt.x2) and (Pilka.x-Pilka.r+Pilka.px<=Obiekt.x2)) then coll:=1;
   if ((Pilka.y+Pilka.r<Obiekt.y1) and (Pilka.y+Pilka.r+Pilka.py>=Obiekt.y1)) or
   ((Pilka.y-Pilka.r>Obiekt.y2) and (Pilka.y-Pilka.r+Pilka.py<=Obiekt.y2))then coll:=2 ;
end;

end;

procedure obiekty(var Pilka:P);

var
  obiekty:array [1..5] of O;
  x1,x2:integer;
  i:integer;
  s1,s2,s3,s4:string;
  b:byte;
begin
   obiekty[1].x1:=-5;
   obiekty[1].x2:=0;
   obiekty[1].y1:=-5;
   obiekty[1].y2:=600;
   Obiekty[1].sz:=5;
   Obiekty[1].wys:=605;
   {lewa sciana}
   obiekty[2].x1:=-5;
   obiekty[2].x2:=800;
   obiekty[2].y1:=-5;
   obiekty[2].y2:=0;
      Obiekty[2].sz:=805;
   Obiekty[2].wys:=5;
   {gorna sciana}
   obiekty[3].x1:=0;
   obiekty[3].x2:=800;
   obiekty[3].y1:=600;
   obiekty[3].y2:=605;
      Obiekty[3].sz:=800;
   Obiekty[3].wys:=5;
   {dolna sciana}
   obiekty[4].x1:=800;
   obiekty[4].x2:=805;
   obiekty[4].y1:=-5;
   obiekty[4].y2:=605;
      Obiekty[4].sz:=5;
   Obiekty[4].wys:=610;
   {prawa sciana}
   obiekty[5].x1:=400;
   obiekty[5].x2:=500;
   obiekty[5].y1:=300;
   obiekty[5].y2:=400;
      Obiekty[5].sz:=100;
   Obiekty[5].wys:=100;
   {obiekt na srodku}
        for i:=1 to high(obiekty) do
        begin
          b:=  coll(Pilka,Obiekty[i]) ;
             if b=1 then begin
             Pilka.kolix:=Pilka.x;
             Pilka.koliy:=Pilka.y;
                if (Pilka.px<0) then
                   begin
                     Pilka.x:=Obiekty[i].x2+Pilka.r+1;
                     Pilka.vxn:=Pilka.vxn*(-1);
                   end
                else if (Pilka.px>0) then
                   begin
                     Pilka.x:=Obiekty[i].x1-Pilka.r-1;
                     Pilka.vxn:=Pilka.vxn*(-1);
                   end;
             end ;
              if b=2 then begin
               Pilka.kolix:=Pilka.x;
               Pilka.koliy:=Pilka.y;
                 if (Pilka.py<0) then
                    begin
                       Pilka.y:=Obiekty[i].y2+Pilka.r+1;
                       Pilka.vyn:=Pilka.vyn*(-1);
                    end
                 else if (Pilka.py>0) then
                     begin
                      Pilka.y:=Obiekty[i].y1-Pilka.r-1;
                      Pilka.vyn:=Pilka.vyn*(-1);
                     end;
             end;
              {if b=3 then begin
               str(Pilka.x+Pilka.r:2:2,s1);
               str(obiekty[i].x1:2:2,s2);
               str(Pilka.x+Pilka.px+Pilka.r:2:2,s3);
               stR(Obiekty[i].x1:2:2,s4);
               al_message(s1+'<'+s2+' and '+s3+'>='+s4);

               str(Pilka.x-Pilka.r:2:2,s1);
               str(obiekty[i].x2:2:2,s2);
               str(Pilka.x-Pilka.r+Pilka.px:2:2,s3);
               stR(Obiekty[i].x2:2:2,s4);
               al_message(s1+'>'+s2+' and '+s3+'<='+s4);

                str(Pilka.y+Pilka.r:2:2,s1);
               str(obiekty[i].y1:2:2,s2);
               str(Pilka.y+Pilka.r+Pilka.py:2:2,s3);
               stR(Obiekty[i].y1:2:2,s4);
               al_message(s1+'<'+s2+' and '+s3+'>='+s4);

               str(Pilka.y-Pilka.r:2:2,s1);
               str(obiekty[i].y2:2:2,s2);
               str(Pilka.y-Pilka.r+Pilka.py:2:2,s3);
               stR(Obiekty[i].y2:2:2,s4);
               al_message(s1+'>'+s2+' and '+s3+'<='+s4);

              end; }

        end;

end;

procedure aktualizuj_polozenie_paletki(var Paletka:L);
begin
   if (Paletka.x_max+paletka.w_x<=0) then Paletka.x_max:=0
   else if (Paletka.x_max+Paletka.w_x+80>=800) then paletka.x_max:=800-80
   else begin


  Paletka.x_max:=Paletka.x_max+paletka.w_x;
   Paletka.y_max:=Paletka.y_max+paletka.w_y;

   end;

end;
procedure RUCH_PALETKI(var paletka:L;Pilka:P);
begin

      paletka.w_x:=0;
      paletka.w_y:=0;
               if  (AL_KEY[AL_KEY_A]<>0) then
                  begin
                     paletka.w_x:=-5;

                  end
                  else if (AL_KEY[AL_KEY_D]<>0) then
                  begin
                       paletka.w_x:=5;
                  end  ;



      aktualizuj_polozenie_paletki(paletka);


end;
procedure RUCH_PILKA(var Pilka:P);
var
kolizja:char;
s:string;
x:byte;
begin

    Pilka.timenow:=now;
    Pilka.deltatime:=MilliSecondsBetween(Pilka.timepast,Pilka.timenow);
    Pilka.timepast:=Pilka.timenow;
    Pilka.calkowityczas:=Pilka.calkowityczas+Pilka.deltatime;

    Pilka.px:=pilka.vxn*Pilka.predkosc;
    Pilka.py:=pilka.vyn*Pilka.predkosc;
   // normalizuj(Pilka);
    obiekty(Pilka);
     aktualizuj_polozenie_pilki(Pilka);
end;
//KONIEC FUNKCJI OD RUCHU
//*************************************************************
//FUNCKJE OD RYSOWANIA
//*************************************************************
procedure rysuj_postac(paletka1,bufor:AL_BITMAPptr;Paletka:L);
begin
     al_masked_blit(paletka1,bufor,0,0,Paletka.x_max,Paletka.y_max,80,10) ;

end;
procedure rysuj_pilke(pilkaB,bufor:AL_BITMAPptr;Pilka:P);
begin
     al_masked_blit(pilkaB,bufor,0,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r),10,10);
end;
procedure rysuj (paletka1,bufor:AL_BITMAPptr;Paletka:L;var Pilka:P; var frame:longint);
var
s:string;
begin

   al_clear_to_color(bufor,al_makecol(10,10,10));
   al_masked_blit(krzak, bufor, 0,0,400,300,krzak^.w, krzak^.h );
   rysuj_postac(paletka1,bufor,Paletka);
   rysuj_pilke(pilkaB,bufor,Pilka);

   frame:=frame+1;
    if Pilka.calkowityczas>=1000 then
    begin
       Pilka.licznikfps:=frame;
       Pilka.calkowityczas:=0;
       frame:=0;
    end;

   str(Pilka.licznikfps,s);
   al_textout_ex(bufor,al_font,s,370,10,al_makecol(255,11,4),-1);
   str(Pilka.px:2:2,s);
   s:=s+' <-px';
    al_textout_ex(bufor,al_font,s,400,20,al_makecol(255,11,4),-1);
    str(Pilka.py:2:2,s);
    s:=s+' <-py';
    al_textout_ex(bufor,al_font,s,400,40,al_makecol(255,11,4),-1);
     str(Pilka.vxn:2:2,s);
     s:=s+' <-vxn';
    al_textout_ex(bufor,al_font,s,400,60,al_makecol(255,11,4),-1);
     str(Pilka.vyn:2:2,s);
     s:=s+' <-vyn';
    al_textout_ex(bufor,al_font,s,400,80,al_makecol(255,11,4),-1);
     str(Pilka.kolix:2:2,s);
     s:=s+' <-koli x';
    al_textout_ex(bufor,al_font,s,400,100,al_makecol(255,11,4),-1);
     str(Pilka.koliy:2:2,s);
     s:=s+' <-koli y';
    al_textout_ex(bufor,al_font,s,400,120,al_makecol(255,11,4),-1);
   al_blit(bufor,al_screen,0,0,0,0,800,600);


end;

//KONIEC FUNKCJI OD RYSOWANIA
//*************************************************************
//FUNKCJE OGOLNE


procedure ruszamy (paletka1,bufor:AL_BITMAPptr);

var
   paletka:L;
   pilka:P;
  frame1:longint;
begin
paletka.x_max:=300;//lewy gorny x;
paletka.y_max:=500;
paletka.x_min:=paletka.x_max+80;
paletka.y_min:=paletka.y_max+10;
paletka.w_x:=0;
paletka.w_y:=0;
{wspolrzedne opisujace postac}
Pilka.x:=580;
Pilka.y:=15;
Pilka.r:=5;
Pilka.kolix:=0;
Pilka.koliy:=0;
Pilka.vx:=cos(45*pi/180);
Pilka.vy:=sin(45*pi/180);
Pilka.predkosc:=5;
normalizuj(Pilka);
Pilka.calkowityczas:=0;

{wspolrzedne pilka}
CnTicks:=0;
Pilka.timepast:=now;
      repeat

         while(cnticks>0) do
         begin
         RUCH_PALETKI(paletka,Pilka);
         RUCH_PILKA(Pilka);
         RYSUJ(paletka1,bufor,paletka,Pilka,frame1);
         dec(cnticks);
         end;

      until AL_KEY[AL_KEY_ESC]<>0 ;

end;
function zaladuj_bitmape(s:string):AL_BITMAPptr;
begin
      if (s<>'') then zaladuj_bitmape:=al_load_bmp(s, @al_default_palette)
      else   zaladuj_bitmape:=al_create_bitmap(800,600);
end;
procedure sprawdz_bitmape(x:AL_BITMAPptr);
begin
     if x = NIL then begin
      al_set_gfx_mode(AL_GFX_TEXT, 0,0,0,0);
      al_message('nie moge zaladowac obrazka 1 !');
      al_exit;
    end;
end;
procedure world;

begin
    paletka1:=zaladuj_bitmape('paletka.bmp');
    krzak:=zaladuj_bitmape('krzak.bmp');
    pilkaB:=zaladuj_bitmape('pilka.bmp');

    bufor:=zaladuj_bitmape('');
    ruszamy(paletka1,bufor);
    al_destroy_bitmap(paletka1);
    al_destroy_bitmap(bufor);
end;
//KONIEC FUNKCJI OGOLNYCH
//*************************************************************
begin
  inicjalizuj(800, 600);
  world;
  al_remove_int(@IntTicks);
  al_exit;
end.

