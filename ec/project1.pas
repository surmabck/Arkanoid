program project1;
uses allegro,crt,sysutils,DateUtils,math,windows;
CONST pi=3.14159265359;
  m=25;
  n=40;
type


  L=record                      //paletka
    x1,x2,y1,y2,w_x,vx,lvl,dl,wys,lives:integer;
    rozszerzona:float;
    tabx:array[1..80] of double;
    taby:array[1..80] of double;


end;
  P=record         //pilka
    r,licznikfps,sila,ilosc_celow:integer;
    x,y,vx,vy,vxn,vyn,deltatime,
    predkosc,calkowityczas,xpx,xpy,
    px,py:double;
    timenow,timepast:TDateTime; //Potrzebne do obliczenia delta time
    przyczepiona,magnez,extrapower:boolean;
  end;
  O=record  //KLOCKI
   x1,x2,y1,y2,sz,wys,health,nr,powerupx,powerupy,powerupkind:integer;
   alive,powerup,powerupfly:boolean;
   end;
  OB=array [1..100] of O;
  MAP=array[1..n,1..m] of byte;


var
//zmienne globalne
  CnTicks,ilosc_klockow:integer;
 paletka1,pilkaB,klocki,gameover,youwin,poswiata,powerups,bufor,main,sklep,nextlevel: AL_BITMAPptr;
  menu:array[1..4] of AL_BITMAPptr;
  F:text;
  liczba:byte;
  mapa:map;
  hajs:integer;
procedure IntTicks;CDECL;
begin
    INC(CnTicks);
end;
procedure normalizuj(var Pilka:P);
var
dl:double;
begin
if (Pilka.vx<>0) or (Pilka.vy<>0) then
begin
dl:=sqrt(power(Pilka.vx,2)+power(Pilka.vy,2));
Pilka.vxn:=(Pilka.vx/dl);
Pilka.vyn:=(Pilka.vy/dl);
end
else
begin
  Pilka.vxn:=0;
Pilka.vyn:=0;
end;

end;
procedure inicjalizuj_paletke(var Paletka:L);
var
  i:integer;
begin
paletka.rozszerzona:=1;
paletka.dl:=trunc(80*Paletka.rozszerzona);
paletka.wys:=10;
paletka.x1:=300;//lewy gorny x;
paletka.y1:=500;
paletka.x2:=paletka.x1+paletka.dl ;
paletka.y2:=paletka.y1+paletka.wys;
paletka.w_x:=0;

paletka.vx:=2;
paletka.lvl:=1;
paletka.lives:=5;

for i:=1 to 80 do
    begin
        Paletka.taby[i]:=-sin(i*2*pi/180);
        Paletka.tabx[i]:=-cos(i*2*pi/180);
    end;
end;
procedure gra_reset(var Pilka:P;var Paletka:L);
begin
        paletka.rozszerzona:=1;
paletka.dl:=trunc(80*Paletka.rozszerzona);
paletka.wys:=10;
paletka.x1:=300;//lewy gorny x;
paletka.y1:=500;
paletka.x2:=paletka.x1+paletka.dl ;
paletka.y2:=paletka.y1+paletka.wys;
paletka.w_x:=0;

paletka.vx:=2;
        Pilka.x:=trunc(Paletka.x1+Paletka.dl/2);
        Pilka.y:=Paletka.y1-Pilka.r;
        pilka.przyczepiona:=true;
        Pilka.magnez:=false;
        Pilka.extrapower:=false;

        Pilka.x:=trunc(Paletka.x1+Paletka.dl/2);
Pilka.r:=7;
Pilka.y:=Paletka.y1-Pilka.r;

Pilka.vx:=0;
Pilka.vy:=-1;
Pilka.predkosc:=3;
pilka.extrapower:=false;
pilka.magnez:=false;

normalizuj(Pilka);

Pilka.px:=pilka.vxn*Pilka.predkosc;
Pilka.py:=pilka.vyn*Pilka.predkosc;
Pilka.xpx:=pilka.px+pilka.x;
Pilka.xpy:=pilka.py+pilka.y;
Pilka.calkowityczas:=0;
Pilka.sila:=11;
Pilka.przyczepiona:=true;

end;
procedure inicjalizuj_pilke(var Pilka:P;Paletka:L);
begin
//Pilka;
Pilka.x:=trunc(Paletka.x1+Paletka.dl/2);
Pilka.r:=7;
Pilka.y:=Paletka.y1-Pilka.r;

Pilka.vx:=0;
Pilka.vy:=-1;
Pilka.predkosc:=3;
pilka.extrapower:=false;
pilka.magnez:=false;

normalizuj(Pilka);

Pilka.px:=pilka.vxn*Pilka.predkosc;
Pilka.py:=pilka.vyn*Pilka.predkosc;
Pilka.xpx:=pilka.px+pilka.x;
Pilka.xpy:=pilka.py+pilka.y;
Pilka.calkowityczas:=0;
Pilka.sila:=10;
Pilka.przyczepiona:=true;
end;
procedure inicjalizuj_obiekty(var Obiekty:ob);
var
i,j,k,x:integer;
begin
k:=1;
        for i:=1 to n do
        for j:=1 to m do
        begin
           if (mapa[i,j]>0) then
           begin
           if (mapa[i,j]=1) then
           begin
            obiekty[k].nr:=0;
            obiekty[k].health:=10
           end
           else            if (mapa[i,j]=2) then
           begin
           obiekty[k].nr:=1*32;
            obiekty[k].health:=20
           end
           else           if (mapa[i,j]=3) then
           begin
           obiekty[k].nr:=2*32;
            obiekty[k].health:=30
           end
           else           if (mapa[i,j]=4) then
           begin
           obiekty[k].nr:=3*32;
            obiekty[k].health:=40
           end
           else           if (mapa[i,j]=5) then
           begin
           obiekty[k].nr:=4*32;
            obiekty[k].health:=50
           end
           else           if (mapa[i,j]=6) then
           begin
           obiekty[k].nr:=5*32;
            obiekty[k].health:=60
           end
           else           if (mapa[i,j]=7) then
           begin
           obiekty[k].nr:=6*32;
            obiekty[k].health:=70
           end
           else           if (mapa[i,j]=8) then
           begin
           obiekty[k].nr:=7*32  ;
            obiekty[k].health:=80
           end
           else           if (mapa[i,j]=9) then
           begin
           obiekty[k].nr:=8*32;
            obiekty[k].health:=90

           end
           else           if (mapa[i,j]=10) then
           begin
           obiekty[k].nr:=9*32;
            obiekty[k].health:=100
           end
           else           if (mapa[i,j]=11) then
           begin
           obiekty[k].nr:=10*32 ;
            obiekty[k].health:=110
           end
           else           if (mapa[i,j]=12) then
           begin
           obiekty[k].nr:=11*32;
            obiekty[k].health:=110
           end
           else           if (mapa[i,j]=13) then
           begin
            obiekty[k].health:=120;
           obiekty[k].nr:=12*32;
           end;

            obiekty[k].sz:=800 div m;
            obiekty[k].wys:=600 div n;
            obiekty[k].x1:=j*obiekty[k].sz-obiekty[k].sz;
            obiekty[k].y1:=i*obiekty[k].wys-obiekty[k].wys;
            obiekty[k].x2:=obiekty[k].x1+obiekty[k].sz;
            obiekty[k].y2:=obiekty[k].y1+obiekty[k].wys;
            obiekty[k].alive:=true;
            x:=random(101);
            if (x>70) then
            begin
                 obiekty[k].powerup:=true;
                 obiekty[k].powerupkind:=random(10)*32;
            end
            else
            begin
                 obiekty[k].powerup:=false;
                 obiekty[k].powerupkind:=0;
            end;
            obiekty[k].powerupfly:=false;
            obiekty[k].powerupx:=obiekty[k].x1;
            obiekty[k].powerupy:=obiekty[k].y1;
            inc(k);
            end;

           end;

end;

//*************************************************************
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

//*************************************************************
//FUNKCJE OD RUCHU
function wyswietl_ekran(s:string;ticks:integer):integer;
var
x:integer;
buff:AL_BITMAPptr;
begin
wyswietl_ekran:=ticks;
buff:=al_create_bitmap(800,600);
al_blit(al_screen,buff,0,0,0,0,800,600);
repeat
     if s='gameover' then
        begin
             al_masked_blit(gameover, bufor, 0,0,200,150,400,300 );

        end
     else if s='youwin' then
        begin
            al_masked_blit(youwin, bufor,0,0,200,150,400,300  );
        end
     else if s='sklep' then
        begin
         al_masked_blit(sklep, bufor, 0,0,200,150,400,300 );
        end
     else if s='nextlevel' then
        begin
          al_masked_blit(nextlevel, bufor, 0,0,200,150,400,300 );
        end;
      al_blit(bufor,al_screen,0,0,0,0,800,600);
until AL_KEY[AL_KEY_J]<>0;
al_blit(buff,al_screen,0,0,0,0,800,600);
al_destroy_bitmap(buff);
end;

procedure aktualizuj_polozenie_pilki(var Pilka:P) ;
begin
         Pilka.x:=Pilka.x+Pilka.px;
         Pilka.y:=Pilka.y+Pilka.py;  ;
    Pilka.px:=pilka.vxn*Pilka.predkosc;
    Pilka.py:=pilka.vyn*Pilka.predkosc;
    Pilka.xpx:=pilka.x+pilka.px;
    Pilka.xpy:=pilka.y+pilka.py;

end;
function coll(Pilka:P; x1,x2,y1,y2:double):byte;
begin
coll:=0;

if ((Pilka.xpx + Pilka.r >= x1)
and (Pilka.xpx - Pilka.r <= x2))
and ((Pilka.xpy + Pilka.r >= y1)
and (Pilka.xpy - Pilka.r <= y2)) then


begin
   if ((Pilka.x+Pilka.r<x1) and (Pilka.xpx+Pilka.r>=x1)) or
   ((Pilka.x-Pilka.r>x2) and (Pilka.xpx-Pilka.r<=x2)) then coll:=1;
   if ((Pilka.y+Pilka.r<y1) and (Pilka.xpy+Pilka.r>=y1)) or
   ((Pilka.y-Pilka.r>y2) and (Pilka.xpy-Pilka.r<=y2))then coll:=2 ;
end;

end;
function collpaddle(var Pilka:P; Paletka:L):integer;
var
 x:double;
 roznica:integer;
begin
x:=Pilka.x+Pilka.r ;
if ((Pilka.xpx + Pilka.r >= Paletka.x1)
and (Pilka.xpx- Pilka.r <= Paletka.x2))
and ((Pilka.xpy+ Pilka.r >= Paletka.y1)
and (Pilka.xpy - Pilka.r <= Paletka.y2)) then
    begin
        roznica:=trunc((x-Paletka.x1+1)/paletka.rozszerzona);
        if roznica<20 then
            begin
                 Pilka.vx:=Paletka.tabx[20];
                 Pilka.vy:=Paletka.taby[20];
            end
        else if roznica>60  then
            begin
                 Pilka.vx:=Paletka.tabx[60];
                 Pilka.vy:=Paletka.taby[60];
            end
        else
        begin
             Pilka.vx:=Paletka.tabx[roznica];
             Pilka.vy:=Paletka.taby[roznica];

        end;
        normalizuj(Pilka);
      if(Pilka.magnez=true) then Pilka.przyczepiona:=true;
     end;

end;
procedure klocek_zestrzelony(var obiekt:o;var Pilka:P);
begin
obiekt.alive:=false;
dec(Pilka.ilosc_celow);
if Obiekt.powerup=true then
Obiekt.powerupfly:=true;
hajs:=hajs+obiekt.nr+15;

end;

procedure kolizje(var Pilka:P;var Obiekty:OB);

var
  i:integer;
  b:byte;
begin
//KOLIZJE ZE SCIANAMI \/
if (Pilka.xpx+Pilka.r>=770) then
begin
    Pilka.x:=769-Pilka.r;
    Pilka.vxn:=-Pilka.vxn
end
   else if (Pilka.xpx-Pilka.r<=30) then
   begin
         Pilka.x:=31+Pilka.r;
          Pilka.vxn:=-Pilka.vxn
   end
      else if (Pilka.xpy-Pilka.r<=55) then
      begin
           Pilka.y:=56+Pilka.r;
            Pilka.vyn:=-Pilka.vyn
      end;
//KOLIZJE ZE SCIANAMI /\
//KOLIZJE Z KLOCKAMI \/
        for i:=1 to ilosc_klockow do
        if obiekty[i].alive=true then
        begin
          b:=  coll(Pilka,Obiekty[i].x1,Obiekty[i].x2,Obiekty[i].y1,Obiekty[i].y2) ;
          //ZDERZENIE W POZIOMIE \/
             if (b=1) and (Pilka.extrapower=false) then
             begin
                if (Pilka.px<0)  then  //PILKA LECIALA W LEWO
                   begin
                     Pilka.x:=Obiekty[i].x2+Pilka.r;
                     Pilka.vxn:=Pilka.vxn*(-1);
                   end
                   else if (Pilka.px>0) then    //PILKA LECIALA W PRAWO
                        begin
                             Pilka.x:=Obiekty[i].x1-Pilka.r;
                             Pilka.vxn:=Pilka.vxn*(-1);
                        end;
                if (obiekty[i].nr>0) then obiekty[i].nr:=obiekty[i].nr-32;
                Obiekty[i].health:=Obiekty[i].health-Pilka.sila;    //SPRAWDZAMY CZY USUNAC KLOCEK
                if obiekty[i].health<=0 then
                 begin
                    klocek_zestrzelony(obiekty[i],pilka);
                 end;
             end
             else if (b=1) then
             begin
              klocek_zestrzelony(obiekty[i],pilka);
             end;

             //ZDERZENIE W POZIOMIE /\
             //ZDERZENIE W PIONIE \/
              if (b=2) and (Pilka.extrapower=false) then
               begin
                 if (Pilka.py<0)  then  //PILKA LECIALA W GORE
                    begin
                       Pilka.y:=Obiekty[i].y2+Pilka.r;
                       Pilka.vyn:=Pilka.vyn*(-1);
                    end
                    else if (Pilka.py>0) then   //PILKA LECIALA W DOL
                         begin
                              Pilka.y:=Obiekty[i].y1-Pilka.r;
                              Pilka.vyn:=Pilka.vyn*(-1);
                         end;
                    if (obiekty[i].nr>0) then obiekty[i].nr:=obiekty[i].nr-32;
                   Obiekty[i].health:=Obiekty[i].health-Pilka.sila; //SPRAWDZAMY CZY USUNAC KLOCEK
                   if obiekty[i].health<=0 then
                       begin
                        klocek_zestrzelony(obiekty[i],pilka);
                       end;

                 end
              else if (b=2) then
                  begin
                   klocek_zestrzelony(obiekty[i],pilka);
                  end;
              //ZDERZENIE W PIONIE
        end;
//KOLIZJE Z KLOCKAMI /\

end;

procedure aktualizuj_polozenie_paletki(var Paletka:L;var Pilka:p);
begin
   if (Paletka.x1+paletka.w_x<=30) then Paletka.x1:=30
   else if (Paletka.x2+Paletka.w_x>=770) then paletka.x1:=770-Paletka.dl
   else begin


        Paletka.x1:=Paletka.x1+paletka.w_x;
        Paletka.x2:=Paletka.x1+paletka.dl;
           if (Pilka.przyczepiona=true) then
                     begin
                      Pilka.x:=Pilka.x+Paletka.w_x;
                     end;


   end;

end;
procedure RUCH_PALETKI(var paletka:L;var Pilka:P);
begin

      paletka.w_x:=0;
               if  (AL_KEY[AL_KEY_A]<>0) then
                  begin
                     paletka.w_x:=-paletka.vx;

                  end
                  else if (AL_KEY[AL_KEY_D]<>0) then
                  begin
                       paletka.w_x:=paletka.vx;
                  end
                  else if (AL_KEY[AL_KEY_SPACE]<>0) then
                  begin
                        pilka.przyczepiona:=false;
                  end
                  else if (AL_KEY[AL_KEY_u]<>0) then
                  begin
                       if(hajs-100>=0) then
                           begin
                               Pilka.sila:=Pilka.sila+20;
                               hajs:=hajs-100;
                           end;
                  end
                  else if (AL_KEY[AL_KEY_i]<>0) then
                  begin
                           if(hajs-200>=0) then
                           begin
                               Paletka.vx:=Paletka.vx+1;
                               hajs:=hajs-200;
                           end;
                  end
                  else if (AL_KEY[AL_KEY_o]<>0) then
                  begin
                           if(hajs-300>=0) then
                           begin
                               Pilka.predkosc:=Pilka.predkosc-1;
                               hajs:=hajs-300;
                           end;
                  end;



      aktualizuj_polozenie_paletki(paletka,pilka);


end;
procedure zwieksz_predkosc(var Pilka:P);
begin
  if (Pilka.timenow=0) then
        begin
          Pilka.timenow:=now;   ;
        end
       else
           begin

               Pilka.timepast:=Pilka.timenow;
               Pilka.timenow:=now;
               Pilka.deltatime:=Pilka.deltatime+millisecondsbetween(Pilka.timepast,Pilka.timenow);
               if (Pilka.deltatime>2000) then
               begin
                    pilka.predkosc:=Pilka.predkosc+0.1;
                    Pilka.deltatime:=0;
               end;
           end;
end;

procedure RUCH_PILKA(var Pilka:P;Paletka:L;var Obiekty:OB);
begin


zwieksz_predkosc(pilka);
if (Pilka.przyczepiona=false) then
begin

   // normalizuj(Pilka);
    kolizje(Pilka,obiekty);
    collpaddle(Pilka,Paletka);
     aktualizuj_polozenie_pilki(Pilka);
end;
end;
procedure POWERUP_BONUS(var Paletka:L;var Pilka:P;x:integer);
var
  s:string;
begin
str(1,s);
 case x of
 0:
 begin
      Pilka.magnez:=true;         //Powerup wlaczajacy magnez
 end;
 32:
 begin;
     // al_message(s+'costam');
 end;
 64:
 begin
     Paletka.rozszerzona:=2;     //powerup rozszerzajacy paletke
     Paletka.dl:=80*2;
 end;
 96:
 begin
     Pilka.sila:=25;        //powerup zwiekszajacy sile uderzenia pilki
 end;
 128:
 begin
      Pilka.predkosc:=4;;     //powerup przyspieszajacy pilke
 end;
 160:
 begin
      Pilka.predkosc:=3;      //powerup zwalniajacy pilke
 end;
 192:
 begin
      inc(Paletka.lives);       //powerup zwiekszajacy hp
 end;
 224:
 begin
  Pilka.extrapower:=true;       //powerup wlaczajacy brak kolizji z obiektami i super sile
 end;
 256:
 begin
      Paletka.lives:=0;            //powerup powodujacy zgon
 end;
 288:
begin
    //al_message(s+'kilka pilek');
end;
end;

end;
function KOL_POWERUP(var obiekt:o;y1,y2,x1,x2:integer):boolean ;
begin
     KOL_POWERUP:=false;
     if (obiekt.powerupy+32>=y1) and (obiekt.powerupy<=y2) and (obiekt.powerupx+32>=x1) and (obiekt.powerupx<=x2) then
     begin
      KOL_POWERUP:=true;
      hajs:=hajs+32;
     end;
end;
procedure RUCH_POWERUP(var obiekty:ob;var Paletka:L;var Pilka:P);
var
  i:integer;
begin
 for i:=1 to ilosc_klockow do
     begin
         if (obiekty[i].powerupfly=true) then
         begin

            obiekty[i].powerupy:=obiekty[i].powerupy+1;

          if (KOL_POWERUP(obiekty[i],Paletka.y1,Paletka.y1+Paletka.wys,Paletka.x1,Paletka.x1+Paletka.dl)=true) then
          begin
          POWERUP_BONUS(paletka,pilka,Obiekty[i].powerupkind);
           obiekty[i].powerupfly:=false;
          end
          else if (obiekty[i].powerupy>=600) then obiekty[i].powerupfly:=false;

         end;


     end;
end;

//KONIEC FUNKCJI OD RUCHU
//*************************************************************
//FUNCKJE OD RYSOWANIA
//*************************************************************
procedure rysuj_postac(paletka1,bufor:AL_BITMAPptr;Paletka:L);
begin
     al_masked_blit(paletka1,bufor,Paletka.dl-80,0,Paletka.x1,Paletka.y1,paletka.dl,Paletka.wys) ;

end;
procedure rysuj_pilke(pilkaB,bufor:AL_BITMAPptr;Pilka:P);
begin
     al_masked_blit(pilkaB,bufor,0,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r),Pilka.r*2,Pilka.r*2);
end;
procedure rysuj_obiekty(obiekty:ob);
var i:integer;
begin
      for i:=1 to ilosc_klockow do
      begin
        if (obiekty[i].alive=true) then
         al_masked_blit(klocki, bufor, obiekty[i].nr,0,obiekty[i].x1,obiekty[i].y1,32, 15 )
        else if (obiekty[i].powerupfly=true) then
        begin
         al_masked_blit(powerups,bufor,obiekty[i].powerupkind,0,obiekty[i].powerupx,obiekty[i].powerupy,32,32);
        end;
      end;
end;
procedure rysuj_hud(paletka:L) ;
var
  s:string;
begin
    str(Paletka.lives,s);
  s:='x'+s;
  al_masked_blit (Pilkab,bufor,0,0,10,10,14,14);
  al_textout_ex(bufor,al_font,s,30,15,al_makecol(255,255,255),-1);
  str(hajs,s)  ;
  al_textout_ex(bufor,al_font,s+':HAJSU',30,5,al_makecol(255,255,255),-1);
  str(Paletka.lvl,s);
  s:='LVL '+s;
  al_textout_ex(bufor,al_font,s,390,15,al_makecol(255,255,255),-1);

end;
procedure rysuj (var Paletka:L;var Pilka:P; var frame:longint;obiekty:ob);

begin

   al_blit(main,bufor,0,0,0,0,800,600);
   rysuj_postac(paletka1,bufor,Paletka);
   rysuj_pilke(pilkaB,bufor,Pilka);
   rysuj_obiekty(obiekty);
   rysuj_hud(paletka);


   al_blit(bufor,al_screen,0,0,0,0,800,600);


end;

//KONIEC FUNKCJI OD RYSOWANIA
//*************************************************************
//FUNKCJE OGOLNE


procedure wczytaj_mape(var mapa:MAP;s:string);
var
  i,j,z,k:integer;
begin
 assign (F,s);
 reset(F);
 z:=0;
 k:=0;
// while not eof (f) do
 begin
  for i:=1 to n do
  begin
  writeln() ;
      for j:=1 to m do
          begin
               read(f,liczba);
               mapa[i,j]:=liczba;
               write(liczba,' ');
               inc(z);
               if (liczba<>0) then inc(k);
          end;
  end;
  end;
 writeln();
 writeln(z);
 writeln(k);
 ilosc_klockow:=k;
 close(F);
end;
function Sprawdz_stan(var Pilka:P;var Paletka:L):byte;
begin
sprawdz_stan:=1;
   if (Pilka.y>=600) and (Paletka.lives>0)then
   begin
        dec(Paletka.lives);
        gra_reset(pilka,paletka);
   end
   else    if (Paletka.lives=0) then
   begin
        cnticks:=wyswietl_ekran('gameover',cnticks);
        sprawdz_stan:=2;
   end;
   if Pilka.ilosc_celow=0 then
   begin
    if (Paletka.lvl<3) then
     cnticks:=wyswietl_ekran('nextlevel',cnticks)
    else cnticks:=wyswietl_ekran('youwin',cnticks);
     sprawdz_stan:=3;
   end;

end;
procedure gra(var Pilka:P;var Paletka:L;var obiekty:ob;var frame1:longint);
var x:byte;
s:string;
begin

str(Paletka.lvl,s);
s:='mapa'+s+'.txt';
wczytaj_mape(mapa,s);
Pilka.ilosc_celow:=ilosc_klockow;
inicjalizuj_paletke(Paletka);
inicjalizuj_pilke(Pilka,paletka);
inicjalizuj_obiekty(obiekty);
hajs:=200;

repeat
CnTicks:=0;
Pilka.timepast:=0;
Pilka.timenow:=0;
        repeat


              while(cnticks>0) do
              begin
                    RUCH_PALETKI(paletka,pilka);
                    RUCH_PILKA(Pilka,paletka,obiekty);
                    RUCH_POWERUP(obiekty,paletka,pilka);
                    RYSUJ(paletka,Pilka,frame1,obiekty);

                    dec(cnticks);
              end;

        x:=SPRAWDZ_STAN(pilka,paletka);
        until ((AL_KEY[AL_KEY_ESC]<>0) or (x<>1));
 if(x=3) then
         begin
              if (Paletka.lvl<3) then
              begin
               inc(Paletka.lvl);
               str(Paletka.lvl,s);
               s:='mapa'+s+'.txt';
               wczytaj_mape(mapa,s);
               Pilka.ilosc_celow:=ilosc_klockow;
               inicjalizuj_obiekty(obiekty);
               gra_reset(pilka,paletka);
              end
              else
              x:=2;

         end;
until (x=2) or  (AL_KEY[AL_KEY_ESC]<>0);
end;

procedure ruszamy ();

var
   paletka:L;
   pilka:P;
  frame1:longint;
  obiekty:OB;
  x:integer;
  choice:integer;
begin


//czas i framy


//czas i framy
// MENU  \/
x:=1;
repeat
paletka.lvl:=1;
al_blit(menu[x],al_screen,0,0,0,0,800,600);
  choice:=al_readkey;
  if(choice shr 8) = AL_KEY_s then inc(x)       //nacisniete s
  else if(choice shr 8) = AL_KEY_w then dec(x);               //nacisniete w
  if (x>4) then x:=1
  else if (x<1) then x:=4;
  //KLIKNIECIE ENTERA  \/
  if (choice shr 8) =AL_KEY_ENTER then
  begin
       if (x=1) then  // WYBOR GRAJ
       begin
            gra(Pilka,Paletka,obiekty,frame1);
       end;
       if (x=4) then  x:=5;        //WYBOR WYJSCIE


  end;
  //KLIKNIECIE ENTERA /\
choice:=1;

until x=5;
//MENU   /\
end;
function zaladuj_bitmape(s:string):AL_BITMAPptr;
begin
      if (s<>'') then zaladuj_bitmape:=al_load_bmp(s, @al_default_palette)
      else   zaladuj_bitmape:=al_create_bitmap(800,600);
end;
procedure grafika(c:string);
begin
if (c='zaladuj') then
begin
    paletka1:=zaladuj_bitmape('paletki.bmp');
    powerups:=zaladuj_bitmape('powerups.bmp');
    pilkaB:=zaladuj_bitmape('pilka.bmp');
    klocki:=zaladuj_bitmape('klocki.bmp');
    gameover:=zaladuj_bitmape('gameover.bmp');
    youwin:=zaladuj_bitmape('youwin.bmp');
    menu[1]:=zaladuj_bitmape('MainMenu1.bmp');
    menu[2]:=zaladuj_bitmape('MainMenu2.bmp');
    menu[3]:=zaladuj_bitmape('MainMenu3.bmp');
    menu[4]:=zaladuj_bitmape('MainMenu4.bmp');
    bufor:=zaladuj_bitmape('');
    main:=zaladuj_bitmape('lvl1.bmp');
   sklep:=zaladuj_bitmape('sklep.bmp');
   nextlevel:=zaladuj_bitmape('nextlevel.bmp');
end;
if (c='usun') then
begin
     al_destroy_bitmap(powerups);
    al_destroy_bitmap(paletka1);
    al_destroy_bitmap(bufor);
    al_destroy_bitmap(pilkab);
    al_destroy_bitmap(klocki);
    al_destroy_bitmap(gameover);
    al_destroy_bitmap(youwin) ;
    al_destroy_bitmap(main) ;
    al_destroy_bitmap(menu[1]) ;
    al_destroy_bitmap(menu[2]) ;
    al_destroy_bitmap(menu[3]) ;
    al_destroy_bitmap(menu[4]) ;
    al_destroy_bitmap(sklep) ;
    al_destroy_bitmap(nextlevel) ;
end;
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

    grafika('zaladuj');
    ruszamy();
    grafika('usun');

end;
//KONIEC FUNKCJI OGOLNYCH
//*************************************************************
begin
  //

  randomize;
  inicjalizuj(800, 600);
  world;
  al_remove_int(@IntTicks);
  al_exit;
end.

