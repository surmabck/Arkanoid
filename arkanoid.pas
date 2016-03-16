program arkanoid;
uses allegro,crt,sysutils,DateUtils,math,windows;
CONST pi=3.14159265359;
  m=25;
  n=40;
type

  rek=record
   score:integer;
   nick:string[10];
  end;
  L=record                      //paletka
    lvl,dl,wys:integer;
    vx,w_x,x1,x2,y1,y2:double;
    rozszerzona:float;
    tabx:array[1..80] of double;
    taby:array[1..80] of double;


end;
    E=record
     activity:boolean;
     time,t_anim:double;
     v:double;
     count:integer;
  end;
  P=record         //pilka
    r,licznikfps,sila,ilosc_celow:integer;
    x,y,x2,y2,vx,vy,vxn,vyn,deltatime,
    predkosc,calkowityczas,xpx,xpy,
    px,py:double;
    timenow,timepast:TDateTime; //Potrzebne do obliczenia delta time
    przyczepiona,magnez,extrapower,slowmo,zapora:E;
  end;
  O=record  //KLOCKI
   sz,wys,health,nr,powerupkind:integer;
   alive,powerup,powerupfly,anim:boolean;
   time_s,powerupx,powerupy,x1,x2,y1,y2:double;
   end;
  PL=record
   lvl,lives,score:integer;
   nick:string[10];
  end;


  OB=array [1..100] of O;
  MAP=array[1..n,1..m] of byte;
  RECORDS=array[1..20] of rek;
  msz=record
   x,y:real;
  end;

var
//zmienne globalne
  Player:PL;
  scores:records;
  CnTicks,ilosc_klockow:integer;
  mysz:msz;
 paletka1,pilkiA,pilkiB,klocki,info,wyniki,test,powerups,bufor,main,kursor: AL_BITMAPptr;
  menu:array[1..4] of AL_BITMAPptr;
  BackGround:AL_MIDIptr;
  col_sound,enter:AL_SAMPLEptr;
  font1,font2,font3 :al_fontptr;
  F:text;
  liczba:byte;
  mapa:map;
  f_past,f_now,f_time:double;
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
player.lvl:=0;
player.lives:=5;
player.nick:='';
player.score:=0;

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
pilka.przyczepiona.activity:=true;
Pilka.magnez.activity:=false;
Pilka.extrapower.activity:=false;
pilka.slowmo.activity:=false;
Pilka.x:=trunc(Paletka.x1+Paletka.dl/2);
Pilka.r:=7;
Pilka.y:=Paletka.y1-Pilka.r;
Pilka.vx:=0;
Pilka.vy:=-1;
Pilka.predkosc:=3;

normalizuj(Pilka);

Pilka.px:=pilka.vxn*Pilka.predkosc;
Pilka.py:=pilka.vyn*Pilka.predkosc;
Pilka.xpx:=pilka.px+pilka.x;
Pilka.xpy:=pilka.py+pilka.y;
Pilka.calkowityczas:=0;
Pilka.sila:=10;
end;
procedure inicjalizuj_pilke(var Pilka:P;Paletka:L);
begin
//Pilka;
Pilka.x:=trunc(Paletka.x1+Paletka.dl/2);
Pilka.r:=10;
Pilka.y:=Paletka.y1-Pilka.r;

Pilka.vx:=0;
Pilka.vy:=-1;
Pilka.predkosc:=3;
pilka.extrapower.activity:=false;
Pilka.extrapower.t_anim:=7000;
pilka.extrapower.count:=1;
pilka.magnez.activity:=false;
Pilka.magnez.t_anim:=7000;
pilka.magnez.count:=1;
Pilka.przyczepiona.activity:=true;
pilka.slowmo.v:=0.5;
Pilka.slowmo.t_anim:=5000;
pilka.slowmo.count:=1;
Pilka.zapora.activity:=false;
Pilka.zapora.t_anim:=6000;
pilka.zapora.count:=1;
normalizuj(Pilka);

Pilka.px:=pilka.vxn*Pilka.predkosc;
Pilka.py:=pilka.vyn*Pilka.predkosc;
Pilka.xpx:=pilka.px+pilka.x;
Pilka.xpy:=pilka.py+pilka.y;
Pilka.calkowityczas:=0;
Pilka.sila:=10;

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
           obiekty[k].health:=mapa[i,j]*10;
           obiekty[k].nr:=(mapa[i,j]-1)*32;

            obiekty[k].sz:=800 div m;
            obiekty[k].wys:=600 div n;
            obiekty[k].x1:=j*obiekty[k].sz-obiekty[k].sz;
            obiekty[k].y1:=i*obiekty[k].wys-obiekty[k].wys;
            obiekty[k].x2:=obiekty[k].x1+obiekty[k].sz;
            obiekty[k].y2:=obiekty[k].y1+obiekty[k].wys;
            obiekty[k].alive:=true;
            x:=random(101);
            if (x>90) then
            begin
                 obiekty[k].powerup:=true;
                 obiekty[k].powerupkind:=random(9)*32;
            end
            else
            begin
                 obiekty[k].powerup:=false;
                 obiekty[k].powerupkind:=0;
            end;
            obiekty[k].powerupfly:=false;
            obiekty[k].powerupx:=obiekty[k].x1;
            obiekty[k].powerupy:=obiekty[k].y1;
            obiekty[k].anim:=false;
            inc(k);
            end;

           end;

end;
procedure zapisz_rekordy();
var
  Plik:file of rek;
rekord:rek;

begin
rekord.score:=player.score;
rekord.nick:=player.nick;
assign(plik,'rekordy.dat');
reset(plik);
Seek(plik, FileSize(plik));
            write(plik,rekord);
close(plik);



end;
procedure wczytaj_rekordy();
var
i,j,p,amount:integer;
x:rek;
plik:file of rek;
rekord:rek;
begin
amount:=1;
assign(plik,'rekordy.dat');
reset(plik);
while not eof(plik) do
begin
     read(plik,rekord);
     if amount=20 then
         begin
          x:=scores[1];
          p:=1;
          for i:=1 to 20 do
          begin
             if scores[i].score<x.score then
                begin
                   x:=scores[i];
                   p:=i;
                end;
             scores[p]:=rekord;
           end;

     end
     else
     begin
           scores[amount]:=rekord;
          inc(amount);
     end;


     if (amount=20) then break;
end;
close(plik);
for j := amount-1 downto 1 do
 begin
   p := 1;
   for i := 1 to j do
     if scores[i].score < scores[i+1].score then
     begin
       x := scores[i];
       scores[i] := scores[i+1];
       scores[i+1] := x;
       p := 0;
     end;
   if p = 1 then break;
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
    if not al_install_sound(AL_DIGI_AUTODETECT,AL_MIDI_AUTODETECT) then
       begin
        al_message('Blad ustawiania dzwieku!');
        readln;
        halt;
       end;
    al_install_mouse();
end;

//*************************************************************
//FUNKCJE OD RUCHU
procedure graj_sample(c:string);
begin
if c='kolizja' then    al_play_sample(col_sound,255,127,1000,0)
else if c='enter' then al_play_sample(enter,255,127,1000,0);
end;
procedure wyswietl_ekran(s:string);
var
buff:AL_BITMAPptr;
begin
buff:=al_create_bitmap(800,600);
al_blit(al_screen,buff,0,0,0,0,800,600);
repeat
        al_textout_ex(bufor,font1,s,400-(length('PRESS ENTER')div 2)*28,200,al_makecol(255,255,255),-1);
        al_textout_ex(bufor,font1,'PRESS ENTER',400-(length('PRESS ENTER')div 2)*28,250,al_makecol(255,255,255),-1);
        al_blit(bufor,al_screen,0,0,0,0,800,600);
        al_readkey;

until al_key[al_key_enter]<>0;
graj_sample('enter');
al_blit(buff,al_screen,0,0,0,0,800,600);
al_destroy_bitmap(buff);
end;
procedure aktualizuj_polozenie_pilki(var Pilka:P) ;
begin

    Pilka.x2:=pilka.x;
    pilka.y2:=pilka.y;
    Pilka.x:=Pilka.x+Pilka.px;
    Pilka.y:=Pilka.y+Pilka.py;
    if Pilka.slowmo.activity=true then
       begin
         Pilka.px:=pilka.vxn*Pilka.slowmo.v;
         Pilka.py:=pilka.vyn*Pilka.slowmo.v;
       end
    else
    begin
         Pilka.px:=pilka.vxn*Pilka.predkosc;
         Pilka.py:=pilka.vyn*Pilka.predkosc;

    end;
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
   if ((Pilka.x+Pilka.r<=x1) and (Pilka.xpx+Pilka.r>=x1)) or
   ((Pilka.x-Pilka.r>=x2) and (Pilka.xpx-Pilka.r<=x2)) then coll:=1
   else if ((Pilka.y+Pilka.r<y1) and (Pilka.xpy+Pilka.r>=y1)) or
   ((Pilka.y-Pilka.r>y2) and (Pilka.xpy-Pilka.r<=y2))then coll:=2 ;
    graj_sample('kolizja');

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
      if(Pilka.magnez.activity=true) then Pilka.przyczepiona.activity:=true
      else Pilka.przyczepiona.activity:=false;

        graj_sample('kolizja');
     end;

end;
procedure klocek_zestrzelony(var obiekt:o;var Pilka:P);
begin
obiekt.alive:=false;
dec(Pilka.ilosc_celow);
if Obiekt.powerup=true then
Obiekt.powerupfly:=true;
player.score:=player.score+obiekt.nr+15;

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
    Pilka.vxn:=-Pilka.vxn;
end
   else if (Pilka.xpx-Pilka.r<=30) then
   begin
         Pilka.x:=31+Pilka.r;
          Pilka.vxn:=-Pilka.vxn ;
   end
      else if (Pilka.xpy-Pilka.r<=55) then
      begin
           Pilka.y:=56+Pilka.r;
            Pilka.vyn:=-Pilka.vyn ;
      end
         else if (Pilka.xpy+Pilka.r>=580) and (Pilka.zapora.activity=true) then
              begin
                Pilka.y:=579-Pilka.r;
                Pilka.vyn:=-Pilka.vyn ;
              end;
//KOLIZJE ZE SCIANAMI /\
//KOLIZJE Z KLOCKAMI \/
        for i:=1 to ilosc_klockow do
        if obiekty[i].alive=true then
        begin
          b:=  coll(Pilka,Obiekty[i].x1,Obiekty[i].x2,Obiekty[i].y1,Obiekty[i].y2) ;
          //ZDERZENIE W POZIOMIE \/
             if (b=1) and (Pilka.extrapower.activity=false) then
             begin
                if (Pilka.px<0)  then  //PILKA LECIALA W LEWO
                   begin
                     Pilka.vxn:=Pilka.vxn*(-1);
                   end
                else if (Pilka.px>0) then    //PILKA LECIALA W PRAWO
                   begin
                     Pilka.vxn:=Pilka.vxn*(-1);
                    end;
             end
             else if (b=1) then
             begin
              klocek_zestrzelony(obiekty[i],pilka);
             end

             //ZDERZENIE W POZIOMIE /\
             //ZDERZENIE W PIONIE \/
             else if (b=2) and (Pilka.extrapower.activity=false) then
               begin
                 if (Pilka.py<0)  then  //PILKA LECIALA W GORE
                    begin
                       Pilka.vyn:=Pilka.vyn*(-1);
                    end
                 else if (Pilka.py>0) then   //PILKA LECIALA W DOL
                      begin
                        Pilka.vyn:=Pilka.vyn*(-1);
                      end;
                 end
              else if (b=2) then
                  begin
                   klocek_zestrzelony(obiekty[i],pilka);
                  end;
              //ZDERZENIE W PIONIE
              if ((b=1) or (b=2)) and (Pilka.extrapower.activity=false) then
                 begin
                 Pilka.y:=Pilka.y-pilka.py;
                 Pilka.x:=Pilka.x-pilka.px;
                 obiekty[i].anim:=true;
                   obiekty[i].time_s:=f_time;
                   Obiekty[i].health:=Obiekty[i].health-Pilka.sila; //SPRAWDZAMY CZY USUNAC KLOCEK
                   if obiekty[i].health<=0 then
                       begin
                        klocek_zestrzelony(obiekty[i],pilka);
                       end;
                 break;
                 end;
        end;
//KOLIZJE Z KLOCKAMI /\

end;
procedure mysza(var mickeyx:real;var mickeyy:real);
var
  micx,micy:integer;
begin
  al_get_mouse_mickeys(micx,micy);
  al_position_mouse(400,300) ;
  mickeyx:=micx*0.5;
  mickeyy:=micy*0.5;
end;
procedure myszka(var z:integer;var k:integer);
var x,y:double;
begin
al_masked_blit(kursor, bufor, 0,0,trunc(mysz.x),trunc(mysz.y),25, 25 );
mysza(x,y);
if (mysz.x+x>0) and (mysz.x+x<800) then mysz.x:=mysz.x+x;
if (mysz.y+y>0) and (mysz.y+y<600) then mysz.y:=mysz.y+y;
if al_mouse_b=1 then k:=1;
if (mysz.x>=285) and (mysz.y<=517) then
begin
       if (mysz.y<226) and (mysz.y>132) then
          z:=1
          else if (mysz.y<346) and (mysz.y>254) then
             z:=2
             else if (mysz.y>374) and (mysz.y<466) then
                z:=3
                else if (mysz.y>494) and (mysz.y<586) then
                   z:=4;
end;

end;
procedure aktualizuj_polozenie_paletki(var Paletka:L;var Pilka:p);
var
  mickeyx,mickeyy:real;
begin
mysza(mickeyx,mickeyy);
Paletka.w_x:=mickeyx;

   if (paletka.x1+paletka.w_x>25) and (paletka.x1+paletka.w_x+paletka.dl<780) then
   begin
     if (paletka.x1<25) then
        begin
             paletka.x1:=25;
             paletka.x2:=paletka.x1+paletka.dl;
        end
        else if (paletka.x2>780) then
             begin
               paletka.x2:=780;
               paletka.x1:=paletka.x2-paletka.dl;
             end;
           if (Pilka.przyczepiona.activity=true) then
                     begin
                      Pilka.x:=Pilka.x+Paletka.w_x;
                     end;
   paletka.x1:=paletka.x1+paletka.w_x;
   paletka.x2:=paletka.x1+paletka.dl;
   end ;


end;

procedure RUCH_PALETKI(var paletka:L;var Pilka:P);
begin

      paletka.w_x:=0;
                 if (al_mouse_b<>0) then
                  begin
                        pilka.przyczepiona.activity:=false;
                  end ;
                  if (AL_KEY[AL_KEY_q]<>0) then
                  begin
                  if (pilka.magnez.activity<>true) and (pilka.magnez.count>0) then
                     begin
                          Pilka.magnez.activity:=true;
                          Pilka.magnez.time:=f_time;
                          dec(pilka.magnez.count);
                      end;
                  end  ;
                  if (AL_KEY[AL_KEY_w]<>0) then
                  begin
                  if (pilka.slowmo.activity<>true) and (pilka.slowmo.count>0) then
                      begin
                           Pilka.slowmo.activity:=true;
                           Pilka.slowmo.time:=f_time;
                           dec(pilka.slowmo.count);
                      end;

                  end;
                 if (AL_KEY[AL_KEY_e]<>0) then
                  begin
                  if (pilka.zapora.activity<>true) and (pilka.zapora.count>0) then
                           begin
                                Pilka.zapora.activity:=true;
                                Pilka.zapora.time:=f_time;
                                dec(pilka.zapora.count);
                           end;
                  end;
                  if (AL_KEY[AL_KEY_r]<>0) then
                  begin
                  if (pilka.extrapower.activity<>true) and (pilka.extrapower.count>0) then
                           begin
                                Pilka.extrapower.activity:=true;
                                Pilka.extrapower.time:=f_time;
                                dec(pilka.extrapower.count);
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
                    pilka.predkosc:=Pilka.predkosc+0.3;
                    Pilka.deltatime:=0;
               end;
           end;
end;
procedure RUCH_PILKA(var Pilka:P;Paletka:L;var Obiekty:OB);
begin
zwieksz_predkosc(pilka);
if (Pilka.przyczepiona.activity=false) then
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
     inc(Pilka.magnez.count);
 end;
 32:
 begin;
     inc(Pilka.zapora.count);
 end;
 64:
 begin
     Paletka.rozszerzona:=2;     //powerup rozszerzajacy paletke
     Paletka.dl:=80*2;
 end;
 96:
 begin
     inc(Pilka.slowmo.count);
 end;
 128:
 begin
      Paletka.vx:=Paletka.vx+0.2;      //powerup przyspieszajacy paletke
 end;
 160:
 begin
      if(Pilka.predkosc>1) then Pilka.predkosc:=Pilka.predkosc-1;      //powerup zwalniajacy pilke
 end;
 192:
 begin
      inc(player.lives);       //powerup zwiekszajacy hp
 end;
 224:
 begin
  inc(Pilka.extrapower.count);
 end;
 256:
 begin
      player.lives:=0;            //powerup powodujacy zgon
 end;
end;

end;
function KOL_POWERUP(var obiekt:o;y1,y2,x1,x2:double):boolean ;
begin
     KOL_POWERUP:=false;
     if (obiekt.powerupy+32>=y1) and (obiekt.powerupy<=y2) and (obiekt.powerupx+32>=x1) and (obiekt.powerupx<=x2) then
     begin
      KOL_POWERUP:=true;
      player.score:=player.score+32;
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
procedure animuj(var obiekty:ob);
var
  i:integer;
  between:double;
begin
for i:=1 to ilosc_klockow do
begin
    between:=f_time-obiekty[i].time_s  ;
    if obiekty[i].anim=true then
    begin
      if between<20 then
         al_masked_blit(test, bufor, 0+obiekty[i].nr*5,0,trunc(obiekty[i].x1),trunc(obiekty[i].y1),32, 15 )
      else  if between<40 then
           al_masked_blit(test, bufor, 32+obiekty[i].nr*5,0,trunc(obiekty[i].x1),trunc(obiekty[i].y1),32, 15 )
           else if between<60 then
                al_masked_blit(test, bufor, 64+obiekty[i].nr*5,0,trunc(obiekty[i].x1),trunc(obiekty[i].y1),32, 15 )
                else if between<80 then
                al_masked_blit(test, bufor, 96+obiekty[i].nr*5,0,trunc(obiekty[i].x1),trunc(obiekty[i].y1),32, 15 )
                      else if between<100 then
                      al_masked_blit(test, bufor, 128+obiekty[i].nr*5,0,trunc(obiekty[i].x1),trunc(obiekty[i].y1),32, 15 )
                else begin
                 obiekty[i].anim:=false;
                 if (obiekty[i].nr>0) then obiekty[i].nr:=obiekty[i].nr-32;

                end;
    end;
end;
end;
procedure animuj_zapora(var x:e);
var between:double;
  licznik:integer;
  bet:integer;
begin
licznik:=0;
between:=f_time-x.time;

if (x.activity=true) and (between<x.t_anim-1000) then
   begin
    bet:=ceil(between*0.06);
    if bet>=20 then bet:=20;
       while licznik<23 do
       begin
           al_masked_blit(klocki, bufor, 12*32,0,32+32*licznik,600-bet,32, 15 ) ;
           inc(licznik);
       end;
   end
else if (x.activity=true) and (between<x.t_anim) then
      begin
      bet:=ceil((between-(x.t_anim-1000))*0.06);
      if bet>=20 then bet:=20;
           while licznik<23 do
           begin
                al_masked_blit(klocki, bufor, 12*32,0,32+32*licznik,580+bet,32, 15 ) ;
                inc(licznik);
           end;

      end  ;
end;
procedure rysuj_postac(paletka1,bufor:AL_BITMAPptr;Paletka:L);
begin
     al_masked_blit(paletka1,bufor,trunc(Paletka.dl-80),0,trunc(Paletka.x1),trunc(Paletka.y1),paletka.dl,Paletka.wys) ;

end;
procedure rysuj_pilke(pilkiA,bufor:AL_BITMAPptr;Pilka:P);
var
  x_time:longint;
  ppilka:al_bitmapptr;
begin
if (pilka.magnez.activity=true) or (pilka.extrapower.activity=true) or (pilka.slowmo.activity=true) or (pilka.zapora.activity=true) then ppilka:=pilkib
else ppilka:=pilkia;
x_time:=trunc(f_time) mod 1000;
  if (x_time>=0) and (x_time<=125) then   al_masked_blit(ppilka,bufor,0,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15)
  else   if (x_time>0) and (x_time<=250) then     al_masked_blit(ppilka,bufor,20,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15)
  else if (x_time>250) and (x_time<=375) then     al_masked_blit(ppilka,bufor,40,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15)
  else if (x_time>375) and (x_time<=500) then     al_masked_blit(ppilka,bufor,60,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15)
  else if (x_time>500) and (x_time<=625) then     al_masked_blit(ppilka,bufor,80,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15)
  else if (x_time>625) and (x_time<=750) then     al_masked_blit(ppilka,bufor,100,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15)
  else if (x_time>750) and (x_time<=875) then     al_masked_blit(ppilka,bufor,120,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15)
  else if (x_time>875) and (x_time<=1000) then    al_masked_blit(ppilka,bufor,140,0,trunc(Pilka.x-Pilka.r),trunc(Pilka.y-Pilka.r), 20,15);

end;
procedure rysuj_obiekty(var obiekty:ob);
var i:integer;
begin
      for i:=1 to ilosc_klockow do
      begin
        if (obiekty[i].alive=true) then
         al_masked_blit(klocki, bufor, obiekty[i].nr,0,trunc(obiekty[i].x1),trunc(obiekty[i].y1),32, 15 )
        else if (obiekty[i].powerupfly=true) then
        begin
         al_masked_blit(powerups,bufor,obiekty[i].powerupkind,0,trunc(obiekty[i].powerupx),trunc(obiekty[i].powerupy),32,32);
        end;
      end;

end;
procedure rysuj_hud(paletka:L;pilka:p) ;
var
  s:string;
begin
    str(player.lives,s);
  s:='x'+s;
  al_textout_ex(bufor,font2,s,30,10,al_makecol(255,255,255),-1);
  al_masked_blit (pilkiA,bufor,100,0,10,10,20,15);
  al_masked_blit (powerups,bufor,0,0,480,0,32,32);
  al_masked_blit (powerups,bufor,32,0,560,0,32,32);
  al_masked_blit (powerups,bufor,96,0,640,0,32,32);
  al_masked_blit (powerups,bufor,224,0,720,0,32,32);
  str(Pilka.magnez.count,s);
  s:='= '+s;
  al_textout_ex(bufor,font2,s,520,10,al_makecol(255,255,255),-1);
  str(Pilka.zapora.count,s);
  s:='= '+s;
  al_textout_ex(bufor,font2,s,600,10,al_makecol(255,255,255),-1);
   str(Pilka.slowmo.count,s);
    s:='= '+s;
  al_textout_ex(bufor,font2,s,680,10,al_makecol(255,255,255),-1);
  str(Pilka.extrapower.count,s);
  s:='= '+s;
  al_textout_ex(bufor,font2,s,760,10,al_makecol(255,255,255),-1);




  str(player.score,s)  ;
  al_textout_ex(bufor,font2,'SCORE: '+s,60,5,al_makecol(255,255,255),-1);
  str(player.lvl,s);
  s:='LVL '+s;
  al_textout_ex(bufor,font1,s,340,-5,al_makecol(255,255,255),-1);


end;
procedure rysuj (var Paletka:L;var Pilka:P;var obiekty:ob);

begin

   al_blit(main,bufor,0,0,0,0,800,600);
   rysuj_postac(paletka1,bufor,Paletka);
   rysuj_pilke(pilkiA,bufor,Pilka);
   rysuj_obiekty(obiekty);
   rysuj_hud(paletka,pilka);
   animuj(obiekty);
   animuj_zapora(Pilka.zapora);


   al_blit(bufor,al_screen,0,0,0,0,800,600);


end;

//KONIEC FUNKCJI OD RYSOWANIA
//*************************************************************
procedure play_background(s:string);
begin
if s='play' then
al_play_midi(BackGround, true)
else if s='stop' then
al_stop_midi();
end;

function activity_check(var x:e):boolean;
var
between:double;
begin
activity_check:=false;
if x.activity=true then
   begin
   between:=f_time-x.time  ;

      if (between)>x.t_anim then
         begin
               x.activity:=false;
               activity_check:=true;
         end;

   end;
end;
procedure check(var Pilka:P;var Paletka:L);
begin
     activity_check(Pilka.slowmo);
     activity_check(Pilka.extrapower);
     activity_check(Pilka.zapora);
     if activity_check(Pilka.magnez) then
     begin
        Pilka.przyczepiona.activity:=false;
     end;
end;
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
procedure nextlvl(var Paletka:L;var Pilka:p;var obiekty:ob);
var
  s:string;
begin
               inc(player.lvl);
               str(player.lvl,s);
               s:='./lvle/mapa'+s+'.txt';
               wczytaj_mape(mapa,s);
               Pilka.ilosc_celow:=ilosc_klockow;
               inicjalizuj_obiekty(obiekty);
               gra_reset(pilka,paletka);
end;
function Sprawdz_stan(var Pilka:P;var Paletka:L;var obiekty:ob):byte;
var
  s:string;
begin
sprawdz_stan:=1;
   if (Pilka.y>=600) and (player.lives>0)then
   begin
        dec(player.lives);
        gra_reset(pilka,paletka);
   end
   else    if (player.lives=0) then
   begin
        player.score:=player.score+(player.lives*500)+(pilka.extrapower.count*80)+(pilka.magnez.count*80)+(pilka.zapora.count*80)+(pilka.slowmo.count*80);
        str(player.score,s);
        s:='SCORE: '+s;
        zapisz_rekordy();
          wczytaj_rekordy();
        wyswietl_ekran(s);
        sprawdz_stan:=2;
   end;
   if Pilka.ilosc_celow=0 then
   begin
    if (player.lvl<6) then
    begin
     nextlvl(paletka,pilka,obiekty);
     wyswietl_ekran('NEXTLVL')
    end
    else
      begin
        player.score:=player.score+(player.lives*500)+(pilka.extrapower.count*80)+(pilka.magnez.count*80)+(pilka.zapora.count*80)+(pilka.slowmo.count*80);
        str(player.score,s);
        s:='SCORE: '+s;
        zapisz_rekordy();
        wczytaj_rekordy();
        wyswietl_ekran(s);
      end;
     sprawdz_stan:=3;
   end;


end;

procedure podaj_nick(var Paletka:L;var Pilka:P;var obiekty:ob);
var
 newkey :integer;
 ASCII :byte;
 scancode:byte;
 s:string;
begin
s:='';

while (ASCII<>13) do
begin
rysuj(paletka,pilka,obiekty);
al_textout_ex(bufor,font1,'PODAJ NICK: '+s,400-(length('PODAJ NICK: '+s)div 2)*24,250,al_makecol(255,255,255),-1);
al_blit(bufor,al_screen,0,0,0,0,800,600);
  newkey   := al_readkey();
  ASCII    := newkey and ($0Fff);
  scancode := newkey shr 8;
  if(ASCII >= 32) and (ASCII <= 126) and (length(s)<10)  then
  begin
   s:=s+chr(ASCII);
  end
  else if (ASCII=8) and (length(s)>0) then
  begin
   s:=copy(s,1,length(s)-1);
  end;

end;
player.nick:=s;
end;

procedure gra(var Pilka:P;var Paletka:L;var obiekty:ob);
var x:byte;
s:string;
begin
inicjalizuj_paletke(Paletka);
inicjalizuj_pilke(Pilka,paletka);
nextlvl(paletka,pilka,obiekty);
podaj_nick(paletka,pilka,obiekty);
f_past:=now;
repeat

CnTicks:=0;
Pilka.timepast:=0;
Pilka.timenow:=0;
        repeat


              while(cnticks>0) do
              begin
                   check(Pilka,Paletka);
                    RUCH_PALETKI(paletka,pilka);
                    RUCH_PILKA(Pilka,paletka,obiekty);
                    RUCH_POWERUP(obiekty,paletka,pilka);
                    RYSUJ(paletka,Pilka,obiekty);
                    f_now:=now;
                    f_time:=millisecondsbetween(f_now,f_past);
                    dec(cnticks);
              end;

        x:=SPRAWDZ_STAN(pilka,paletka,obiekty);
        until ((AL_KEY[AL_KEY_ESC]<>0) or (x<>1));
 if(x=3) then
              if (player.lvl=6) then
              begin
              x:=2;

              end;
AL_CLEAR_keybuf;
until (x=2) or  (AL_KEY[AL_KEY_ESC]<>0);
end;
procedure menu_ ();

var
   paletka:L;
   pilka:P;
  obiekty:OB;
  x,w:integer;
  choice:integer;
  i:integer;
  s:string;
begin
x:=1;
repeat
   w:=0;
      repeat
            choice:=0;
            myszka(x,choice);
            al_blit(bufor,al_screen,0,0,0,0,800,600);
      until (w<>x) or (choice=1);
  w:=x;
  al_blit(menu[w],bufor,0,0,0,0,800,600) ;
  if (choice=1) then
  begin
  graj_sample('enter');
       if (x=1) then
       begin
            gra(Pilka,Paletka,obiekty);
       end;

       if (x=2) then
       begin
          al_masked_blit(wyniki,al_screen,0,0,35,70,730,460);
          al_textout_ex(al_screen,font3,'TOP SCORES:',250,120,al_makecol(0,0,0),-1);
           for i:=1 to 8 do
          begin
           if length(scores[i].nick)<>0 then
           begin

             str(i,s);
             al_textout_ex(al_screen,font3,s+':'+scores[i].nick,250,120+30*i,al_makecol(0,0,0),-1);
             str( scores[i].score,s);
             al_textout_ex(al_screen,font3,s,500,120+30*i,al_makecol(0,0,0),-1);
           end;


          end;
          al_readkey;
       end;
       if (x=3) then
       begin
           al_masked_blit(info,al_screen,0,0,35,70,730,460);
           al_readkey;
       end;
       if (x=4) then  x:=5;

  end;


until x=5;
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
    paletka1:=zaladuj_bitmape('./img/paletki.bmp');
    wyniki:=zaladuj_bitmape('./img/wyniki.bmp');
    kursor:=zaladuj_bitmape('./img/kursor.bmp');
    powerups:=zaladuj_bitmape('./img/powerups2.bmp');
    pilkiA:=zaladuj_bitmape('./img/pilki.bmp');
    pilkiB:=zaladuj_bitmape('./img/pilki2.bmp');
    klocki:=zaladuj_bitmape('./img/klocki.bmp');
    menu[1]:=zaladuj_bitmape('./img/MainMenu1.bmp');
    menu[2]:=zaladuj_bitmape('./img/MainMenu2.bmp');
    menu[3]:=zaladuj_bitmape('./img/MainMenu3.bmp');
    menu[4]:=zaladuj_bitmape('./img/MainMenu4.bmp');
    bufor:=zaladuj_bitmape('');
    main:=zaladuj_bitmape('./img/lvl1.bmp');
   test:=zaladuj_bitmape('./img/test.bmp');
   info:=zaladuj_bitmape('./img/info.bmp');
end;
if (c='usun') then
begin
     al_destroy_bitmap(powerups);
     al_destroy_bitmap(wyniki);
     al_destroy_bitmap(kursor);
    al_destroy_bitmap(paletka1);
    al_destroy_bitmap(bufor);
    al_destroy_bitmap(pilkiA);
    al_destroy_bitmap(pilkiB);
    al_destroy_bitmap(klocki);
    al_destroy_bitmap(main) ;
    al_destroy_bitmap(menu[1]) ;
    al_destroy_bitmap(menu[2]) ;
    al_destroy_bitmap(menu[3]) ;
    al_destroy_bitmap(menu[4]) ;
     al_destroy_bitmap(test);
     al_destroy_bitmap(info);
end;
end;
procedure muzyka(c:string);
begin
if c='zaladuj' then
begin
BackGround:=al_load_midi('./audio/background.mid');
play_background('play');
col_sound:=al_load_sample('./audio/kol.wav');
enter:=al_load_sample('./audio/enter.wav');
end ;
if c='usun' then
begin
     al_destroy_sample(col_sound );
    al_destroy_midi(BackGround);
    al_destroy_sample(enter);
end;
end;
procedure sprawdz_bitmape(x:AL_BITMAPptr);
begin
     if x = NIL then begin
      al_set_gfx_mode(AL_GFX_TEXT, 0,0,0,0);
      al_message('nie moge zaladowac obrazka !');
      al_exit;
    end;
end;
procedure world;

begin
      wczytaj_rekordy();
    font1:=al_load_font('./fonty/font1.pcx',NIL,NIL);
    font2:=al_load_font('./fonty/font2.pcx',NIL,NIL);
    font3:=al_load_font('./fonty/font3.pcx',NIL,NIL);
    mysz.x:=400;
    mysz.y:=300;
    grafika('zaladuj');
    muzyka('zaladuj');
    menu_();
    muzyka('usun');
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
{todo
ewentualnie edytor lvli
}

