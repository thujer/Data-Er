Program Dataer;
Uses Crt,DOS,THApp,THString,CZ,THGS;
Const
  OEM='Dataer 2000';Ver='5.0';
  HelpFile='DATAER.HLP';

Type
     TZaznam=Record
               NazevPolozky:String[20];
               Data:Array[0..75,0..18] of Byte;
             end;
     TPolozka=Record
                Nazev:String[20];
                Cislo:LongInt;
                Soubor:String[80];
                Pocet:LongInt;
              end;
     TSoubor=Record
                Soubor:Array[0..1018] of String[12];
                Attr:Array[0..1018] of Byte;
                Size:Array[0..1018] of LongInt;
                Date:Array[0..1018] of LongInt;
                Dataer:Array[0..1018] of Boolean;
                Pocet:LongInt;
              end;
Var
  F:File of TZaznam;
  TestF:File of Char;
  Test:String[6];
  Zaznam:TZaznam;
  Polozka:TPolozka;
  Soubor:TSoubor;
  A,B,x,y,Locks0:Byte;
  I:LongInt;
  Obsah:Array[0..1018] of String[20];
  PuvAdr:String[80];
  FSize:LongInt;
  DT : DateTime;
  S:String;
  NO_I,NO_X,NO_Y:Integer;

Procedure InitScreen;
begin
  asm
  MOV AH,0
  MOV AL,3
  INT 10h
  MOV AH,5
  MOV AL,0
  INT 10h
  end;
  TextCursor(False);
  Window(1,2,80,24);
  TextColor(2);TextBackground(1);
  Window(1,1,80,25);
  For x:=1 to 80 do
  For y:=2 to 24 do
  begin
    TextColor(8);TextBackground(Random(2)+8);
    GotoXY(x,y);Write('±');
  end;
  InitDownMenu('',1);
  InitDownMenu('~F1~ Help  ~F3~ Open  ~Ctrl+R~ Refr  ~Alt+X~ Exit'+
  '  ~ScrLck~ Keyb  ~F10~ About  ',25);
  TextColor(10);GotoXY(35,1);Write('Dataer 2000');Delay(20);
  TextColor(0);GotoXY(35,1);Write('Dataer 2000');
end;


Procedure WriteTestText(TestFile:String);
begin
  Assign(TestF,TestFile);
  {$I-}Reset(TestF);{$I+}ErrorMessage;
  Test:=#0#0#0#0#0#0;
  If FileSize(TestF)>=6 then
  begin
    Seek(TestF,FileSize(TestF)-6);
    For I:=1 to 6 do Read(TestF,Test[I]);
  end;
  If Test<>'Dataer' then
  begin
    Test:='Dataer';
    Seek(TestF,FileSize(TestF));
    For I:=1 to 6 do Write(TestF,Test[I]);
  end;
  {$I-}Close(TestF);{$I+}ErrorMessage;
end;


Function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;


Procedure Edit;
Var
  Path,PSoubor:String;
  Pol:Byte;
  Pozice:LongInt;
  Saved:Boolean;

Procedure Name;
begin
  TextCursor(False);
  TextColor(15);TextBackground(1);
  GotoXY(5,3);Write(Polozka.Nazev,'                                         ');
  Repeat
    TextColor(15);TextBackground(1);InputTextLine(4,2,20,Polozka.Nazev);
  until (Vstup<>'')or(Scan=1);
  If Scan=28 then Polozka.Nazev:=Vstup;
  TextColor(10);TextBackground(1);
  GotoXY(5,3);Write(Polozka.Nazev,'                                     ');
  TextCursor(True);
  TextColor(15);TextBackground(0);
  GotoXY(3,5);
end;
Procedure Save;
begin
  Saved:=True;
  WriteDownMessage('Saving '+Polozka.Soubor+' ....');
  TextCursor(False);
  TextColor(0);TextBackground(0);
  For x:=0 to 75 do For y:=0 to 18 do
  begin
    GotoXY(x+3,y+5);
    begin
      Asm
      MOV AH,8
      MOV BH,0
      INT 10h
      MOV A,AL
      end;
      Zaznam.Data[x,y]:=A;
      Write(chr(Zaznam.Data[x,y]));
    end;
  end;
  PSoubor:='';
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(0);
  Zaznam.NazevPolozky:=Polozka.Nazev;
  Seek(F,Polozka.Cislo);

  {CODER}
  RandSeed:=100;
  With Zaznam do
  For NO_I:=1 to Length(NazevPolozky) do
  begin
    If NO_I>20 then Break;
    NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
  end;

  With Zaznam do
  For NO_Y:=0 to 18 do
  begin
    RandSeed:=235;
    For NO_X:=0 to 75 do Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
  end;


  Write(F,Zaznam);
  WriteTestText(Polozka.Soubor);

  {$I-}Close(F);{$I+}ErrorMessage;
  {$I-}Reset(F);{$I+}ErrorMessage;
  Scan:=0;
  Repeat until Port[$60]>128;
  TextColor(15);TextBackground(0);
  RandSeed:=100;
  With Zaznam do
  For NO_I:=1 to Length(NazevPolozky) do
  begin
    If NO_I>20 then Break;
    NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
  end;

  With Zaznam do
  For NO_Y:=0 to 18 do
  begin
    RandSeed:=235;
    For NO_X:=0 to 75 do Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
  end;
  For x:=0 to 75 do For y:=0 to 18 do
  begin GotoXY(x+3,y+5);Write(chr(Zaznam.Data[x,y]));end;
  ClearDownMessage;
  TextCursor(True);
end;

begin
  Saved:=True;
  GetScreen2(0);
  {$I-}Close(F);{$I+}ErrorMessage;
  Pozice:=0;Pol:=0;
  InitDownMenu('~F2~ Save  ~//'#27'/'#26'~ Move  ~Ctrl+N~ Name  '+
  '~ESC~ Cancel  ~ScrLck~ Keyb',25);
  Scan:=0;Ascii:=0;
  TextColor(15);TextBackground(0);
  Frame(1,1,78,23,129);
  GotoXY(2,4);
  Write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
  TextBackground(1);
  GotoXY(3,3);
  Write('                                                                            ');
  TextColor(10);GotoXY(5,3);Write(Polozka.Nazev,'         ');
  TextBackground(0);
  If Polozka.Nazev<>'' then
  begin
    Assign(F,Polozka.Soubor);
    {$I-}Reset(F);{$I+}ErrorMessage;
    If IORes=0 then
    begin
      Seek(F,Polozka.Cislo);
      {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

      RandSeed:=100;
      With Zaznam do
      For NO_I:=1 to Length(NazevPolozky) do
      begin
        If NO_I>20 then Break;
        NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
      end;
      With Zaznam do
      For NO_Y:=0 to 18 do
      begin
        RandSeed:=235;
        For NO_X:=0 to 75 do
          Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
      end;


      {$I-}Close(F);{$I+}ErrorMessage;
    end;
  end;
  TextColor(15);
  For x:=0 to 75 do For y:=0 to 18 do
  begin GotoXY(x+3,y+5);Write(chr(Zaznam.Data[x,y]));end;
  Scan:=0;
  If Polozka.Nazev<>'' then
  begin
    Assign(F,Polozka.Soubor);
    {$I-}Reset(F);{$I+}ErrorMessage;
  end;
  TextCursor(True);
  GotoXY(3,5);
  Repeat
    GetKey;
    If Scan=60 then Save;                  {F2}
    If (Scan=49)and(ASCII=14) then
    begin
      Saved:=False;
      Name;   {Ctrl+N}
    end;

    If (Scan=72)and(Ascii=224)and(WhereY>5) then GotoXY(WhereX,WhereY-1);{Up}
    If (Scan=80)and(Ascii=224)and(WhereY<23) then GotoXY(WhereX,WhereY+1);{Down}
    If (Scan=75)and(Ascii=224)and(WhereX>3) then GotoXY(WhereX-1,WhereY);{Left}
    If (Scan=77)and(Ascii=224)and(WhereX<78) then GotoXY(WhereX+1,WhereY);{Rigth}
    If WhereX>=79 then GotoXY(3,WhereY+1);
    If WhereY>=24 then GotoXY(3,5);
    If (Scan=14)and(WhereX>3) then
    begin GotoXY(WhereX-1,WhereY);Write(#0);GotoXY(WhereX-1,WhereY);end;
    If (Scan=82)and(Ascii=224)then
    begin
      Ascii:=0;Scan:=0;
    end;
    If (Scan=83)and(Ascii=224)then begin Ascii:=0;Scan:=0;end;
    If (Scan=71)and(Ascii=224)then begin Ascii:=0;Scan:=0;end;
    If (Scan=79)and(Ascii=224)then begin Ascii:=0;Scan:=0;end;
    If (Scan=73)and(Ascii=224)then begin Ascii:=0;Scan:=0;end;
    If (Scan=81)and(Ascii=224)then begin Ascii:=0;Scan:=0;end;
    If (Ascii>=32)and(Scan<>72)and(Scan<>75)and(Scan<>77)and(Scan<>80)then
    begin
      Write(chr(ASCII));
      Saved:=False;
    end;
  until (Scan=1);
  If not Saved then
  begin
    GetScreen2(2);
    OkMessage('Soubor byl zmˆnˆn, chcete zmˆny ulo‘it ?');
    If (Scan=28)or(UpCase(chr(ASCII))='A') then
    begin
      SetScreen2(2);
      Save;
    end
    else
    SetScreen2(2);
  end;
  For I:=0 to 1000 do Obsah[I]:='';I:=0;
  {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
  If FSize>1000 then FSize:=1000;
  For I:=0 to FSize-1 do
  begin
    {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

    RandSeed:=100;
    With Zaznam do
    For NO_I:=1 to Length(NazevPolozky) do
    begin
      If NO_I>20 then Break;
      NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
    end;
    With Zaznam do
    For NO_Y:=0 to 18 do
    begin
      RandSeed:=235;
      For NO_X:=0 to 75 do
        Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
    end;

    Obsah[I]:=Zaznam.NazevPolozky;
  end;
  Polozka.Pocet:=I;
  For I:=0 to 18 do
  begin
    while Pos(#7,Obsah[I+Pozice+Pol])>0 do
      Obsah[I+Pozice+Pol][Pos(#7,Obsah[I+Pozice+Pol])]:=#0;
    If Pol=I then
    begin Textbackground(7);TextColor(0);end
    else
    begin Textbackground(0);TextColor(10);end;
    GotoXY(31,I+5);Write('                      ');
    GotoXY(31,I+5);Write(Obsah[I+Pozice]+Fill(Obsah[I+Pozice],22))
  end;
  TextColor(15);TextBackground(1);Center(3,'                       ');
  {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
  GotoXY(38,3);Write(Pozice+Pol+1,'/',FSize);
  I:=0;
  {$I-}Close(F);{$I+}ErrorMessage;
  {$I-}Reset(F);{$I+}ErrorMessage;
  Repeat until Port[$60]>128;Scan:=0;
  Scan:=0;
  TextCursor(False);
  SetScreen2(0);
end;


Procedure Load;
Var
  Path,PSoubor:String;
  N: NameStr;
  E: ExtStr;
  P: PathStr;
  D: DirStr;
  Pol:Byte;
  Pozice:LongInt;
  DirInfo: SearchRec;
  Dir:String[80];

Procedure Exchange;
Var
  ZaznamCopy:TZaznam;
  PolozkaX,Code:Integer;
  Locks:Byte;

begin
  GetScreen2(0);
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(28,10,54,13,129+64);
  TextColor(0);
  GotoXY(31,12);Write('P©esunout na pozici');
  Repeat
    TextColor(15);TextBackground(1);
    InputNumLine(30,12,22,Polozka.Cislo+1);
    Val(Vstup,PolozkaX,Code);
  until ((Vstup<>'')and(PolozkaX>0)and(PolozkaX<=Polozka.Pocet+1))or(Scan=1);
  SetScreen2(2);
  If Scan=28 then
  begin
    WriteDownMessage('Moving [                                         ]');
    TextColor(1);TextBackground(7);
    Seek(F,Polozka.Cislo);Read(F,ZaznamCopy);

    If PolozkaX-Polozka.Cislo>0 then
    begin
      For I:=Polozka.Cislo to PolozkaX-2 do
      begin
        {$I-}Seek(F,I+1);Read(F,Zaznam);{$I+}ErrorMessage;
        {$I-}Seek(F,I);Write(F,Zaznam);{$I+}ErrorMessage;
        GotoXY(((Polozka.Pocet-I) div ((Polozka.Pocet-Polozka.Cislo) div 39+1)+12),25);
        Write('þ');
        For x:=0 to 75 do For y:=0 to 18 do Zaznam.Data[x,y]:=0;
      end;
      {$I-}Seek(F,PolozkaX-1);{$I+}ErrorMessage;
      {$I-}Write(F,ZaznamCopy);{$I+}ErrorMessage;
      {$I-}Close(F);Reset(F);{$I+}ErrorMessage;
    end;

    If PolozkaX-Polozka.Cislo<0 then
    begin
      For I:=Polozka.Cislo downto PolozkaX do
      begin
        {$I-}Seek(F,I-1);Read(F,Zaznam);{$I+}ErrorMessage;
        {$I-}Seek(F,I);Write(F,Zaznam);{$I+}ErrorMessage;
        GotoXY(((Polozka.Pocet-I) div ((Polozka.Pocet-Polozka.Cislo) div 39+1)+12),25);
        Write('þ');
        For x:=0 to 75 do For y:=0 to 18 do Zaznam.Data[x,y]:=0;
      end;
      {$I-}Seek(F,PolozkaX-1);{$I+}ErrorMessage;
      {$I-}Write(F,ZaznamCopy);{$I+}ErrorMessage;
      {$I-}Close(F);Reset(F);{$I+}ErrorMessage;
    end;
    WriteTestText(Polozka.Soubor);
    ClearDownMessage;
    I:=0;
    For I:=0 to 1000 do Obsah[I]:='';I:=0;
    Seek(F,0);
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    If FSize>1000 then FSize:=1000;
    For I:=0 to FSize-1 do
    begin
      {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

      RandSeed:=100;
      With Zaznam do
      For NO_I:=1 to Length(NazevPolozky) do
      begin
        If NO_I>20 then Break;
        NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
      end;
      With Zaznam do
      For NO_Y:=0 to 18 do
      begin
        RandSeed:=235;
        For NO_X:=0 to 75 do
          Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
      end;


      Obsah[I]:=Zaznam.NazevPolozky;
    end;
    Polozka.Pocet:=I;
    TextColor(15);TextBackground(1);Center(3,'                       ');
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    GotoXY(39,4);Write(Pozice+Pol+1,'/',FSize);
    For I:=0 to 18 do
    begin
      while Pos(#7,Obsah[I+Pozice+Pol])>0 do
        Obsah[I+Pozice+Pol][Pos(#7,Obsah[I+Pozice+Pol])]:=#0;
      If Pol=I then
      begin Textbackground(7);TextColor(0);end
      else
      begin Textbackground(0);TextColor(10);end;
      GotoXY(31,I+5);Write('                      ');
      GotoXY(31,I+5);Write(Obsah[I+Pozice]+Fill(Obsah[I+Pozice],22))
    end;
  end;
  {$I-}Close(F);{$I+}ErrorMessage;
  {$I-}Reset(F);{$I+}ErrorMessage;
  Repeat until Port[$60]>128;Scan:=0;
  I:=0;Scan:=0;
end;


Procedure Del;
begin
  GetScreen2(0);
  Sound(100);Delay(100);NoSound;
  OkMessage('Opravdu chcete polo‘ku "'+Polozka.Nazev+'" odstranit ?');
  Reset(F);
  SetScreen2(0);
  If (Scan=28)or(UpCase(chr(ASCII))='A') then
  begin
    Sound(100);Delay(100);NoSound;
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    I:=FSize-2;
    If FSize>1000 then I:=998;
    WriteDownMessage('Deleting [                                         ]');
    If FSize>1000 then FSize:=1000;
    TextColor(4);TextBackground(7);
    For I:=Polozka.Cislo to FSize-2 do
    begin
      Seek(F,I+1);Read(F,Zaznam);Seek(F,I);Write(F,Zaznam);
      GotoXY(((FSize-2-I) div ((FSize-2-Polozka.Cislo) div 39+1)+12),25);
      Write('þ');
    end;
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    If FSize>1000 then FSize:=1000;
    Seek(F,FSize-1);Truncate(F);
    Pozice:=0;Pol:=0;Polozka.Cislo:=0;
    Scan:=0;
    {$I-}Close(F);{$I+}ErrorMessage;
    WriteTestText(Polozka.Soubor);
    {$I-}Reset(F);{$I+}ErrorMessage;
    {$I-}Seek(F,0);{$I+}ErrorMessage;
    For I:=0 to 1000 do Obsah[I]:='';I:=0;
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    If FSize>1000 then FSize:=1000;
    For I:=0 to FSize-1 do
    begin
      {$I-}Read(F,Zaznam);{$I+}ErrorMessage;
      RandSeed:=100;
      With Zaznam do
      For NO_I:=1 to Length(NazevPolozky) do
      begin
        If NO_I>20 then Break;
        NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
      end;
      With Zaznam do
      For NO_Y:=0 to 18 do
      begin
        RandSeed:=235;
        For NO_X:=0 to 75 do
          Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
      end;


      Obsah[I]:=Zaznam.NazevPolozky;
    end;
    Polozka.Pocet:=I;
    For I:=0 to 18 do
    begin
      while Pos(#7,Obsah[I+Pozice+Pol])>0 do
        Obsah[I+Pozice+Pol][Pos(#7,Obsah[I+Pozice+Pol])]:=#0;
      If Pol=I then
      begin Textbackground(7);TextColor(0);end
      else
      begin Textbackground(0);TextColor(10);end;
      GotoXY(31,I+5);Write('                      ');
      GotoXY(31,I+5);Write(Obsah[I+Pozice]+Fill(Obsah[I+Pozice],22))
    end;
    TextColor(15);TextBackground(1);Center(3,'                       ');
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    GotoXY(39,4);Write(Pozice+Pol+1,'/',FSize);
    I:=0;
    WriteTestText(Polozka.Soubor);
    ClearDownMessage;
    Polozka.Cislo:=0;
    Polozka.Nazev:=Obsah[Pozice+Pol];
    Polozka.Soubor:=PSoubor;
  end;
  Close(F);Reset(F);
  Repeat until Port[$60]>128;Scan:=0;
end;


Procedure Ren;
begin
  GetScreen2(0);
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(28,10,55,13,129+64);
  TextColor(0);
  GotoXY(31,12);Write('P©ejmenovat polo‘ku na');
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(30,12,20,Polozka.Nazev);
  until (Vstup<>'')or(Scan=1);
  SetScreen2(0);
  If Scan=28 then
  begin
    GetScreen2(1);
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    For x:=0 to 75 do For y:=0 to 18 do Zaznam.Data[x,y]:=0;
    {$I-}Seek(F,Polozka.Cislo);{$I+}ErrorMessage;
    {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

    RandSeed:=100;
    With Zaznam do
    For NO_I:=1 to Length(NazevPolozky) do
    begin
      If NO_I>20 then Break;
      NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
    end;
    With Zaznam do
    For NO_Y:=0 to 18 do
    begin
      RandSeed:=235;
      For NO_X:=0 to 75 do
        Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
    end;


    If FSize>1000 then FSize:=1000;
    Zaznam.NazevPolozky:=Vstup;
    {$I-}Seek(F,Polozka.Cislo);{$I+}ErrorMessage;

    RandSeed:=100;
    With Zaznam do
    For NO_I:=1 to Length(NazevPolozky) do
    begin
      If NO_I>20 then Break;
      NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
    end;
    With Zaznam do
    For NO_Y:=0 to 18 do
    begin
      RandSeed:=235;
      For NO_X:=0 to 75 do
        Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
    end;


    {$I-}Write(F,Zaznam);{$I+}ErrorMessage;
    Inc(Polozka.Pocet);Polozka.Nazev:=Vstup;
    {$I-}Close(F);Reset(F);{$I+}ErrorMessage;
    SetScreen2(1);
  end;
  For I:=0 to 1000 do Obsah[I]:='';I:=0;
  Seek(F,0);
  {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
  If FSize>1000 then FSize:=1000;
  For I:=0 to FSize-1 do
  begin
    {$I-}Read(F,Zaznam);{$I+}ErrorMessage;
    RandSeed:=100;
    With Zaznam do
    For NO_I:=1 to Length(NazevPolozky) do
    begin
      If NO_I>20 then Break;
      NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
    end;
    With Zaznam do
    For NO_Y:=0 to 18 do
    begin
      RandSeed:=235;
      For NO_X:=0 to 75 do
        Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
    end;


    Obsah[I]:=Zaznam.NazevPolozky;
  end;
  Polozka.Pocet:=I;
  For I:=0 to 18 do
  begin
    while Pos(#7,Obsah[I+Pozice+Pol])>0 do
      Obsah[I+Pozice+Pol][Pos(#7,Obsah[I+Pozice+Pol])]:=#0;
    If Pol=I then
    begin Textbackground(7);TextColor(0);end
    else
    begin Textbackground(0);TextColor(10);end;
    GotoXY(31,I+5);Write('                      ');
    GotoXY(31,I+5);Write(Obsah[I+Pozice]+Fill(Obsah[I+Pozice],22))
  end;
  TextColor(15);TextBackground(1);Center(3,'                       ');
  {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
  GotoXY(39,4);Write(Pozice+Pol+1,'/',FSize);
  I:=0;
  {$I-}Close(F);{$I+}ErrorMessage;
  {$I-}Reset(F);{$I+}ErrorMessage;
  Repeat until Port[$60]>128;Scan:=0;
  Scan:=0;
end;


Procedure SortFile;
Var
  S:File of TZaznam;
  SortFiles:Array[0..1018] of String[20];
  Ch:Array[1..20] of Char;
  NO_Char:Array[1..20] of Byte;
  I,Pocet,NO_Sort:Integer;

begin
  GetScreen2(0);
  PSoubor:='';
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(24,10,56,13,129+64);
  TextColor(0);
  GotoXY(27,12);Write('Set©¡dit do souboru ');
  Assign(F,Soubor.Soubor[Pol+Polozka.Cislo]);
  {$I-}Reset(F);{$I+}ErrorMessage;
  {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
  If FSize=0 then
  begin
    GetScreen2(1);
    OKMessage('Nelze set©¡dit pr zdn˜ soubor');
    SetScreen2(1);
    Repeat until Port[$60]>128;
    Scan:=0;
    Close(F);
    Exit;
  end;
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(34,12,12,'');
    Vstup:=FExpand(Vstup);FSplit(Vstup,D,N,E);If E<>'.DAT' then E:='.DAT';
    Vstup:=N+E;
  until ((FSize>0)and(Vstup<>'')and(Vstup<>Soubor.Soubor[Pol+Polozka.Cislo]))or(Scan=1);

  If Scan=1 then
  begin
    Repeat until Port[$60]>128;
    Scan:=0;
    Exit;
  end;
  For I:=0 to 1018 do SortFiles[I]:='';
  For I:=0 to 1018 do Obsah[I]:='';
  WriteDownMessage('Prob¡h  t©¡dˆn¡ datab ze ...');
  Assign(S,Vstup);
  {$I-}Rewrite(S);{$I+}ErrorMessage;
  {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;

  If FSize>0 then
  begin
    For I:=0 to FSize-1 do
    begin
      If I<1000 then
      begin
        {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

        RandSeed:=100;
        With Zaznam do
        For NO_I:=1 to Length(NazevPolozky) do
        begin
          If NO_I>20 then Break;
          NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
        end;
        With Zaznam do
        For NO_Y:=0 to 18 do
        begin
          RandSeed:=235;
          For NO_X:=0 to 75 do
            Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
        end;


         Obsah[I]:=Zaznam.NazevPolozky;
      end;
    end;
  end;
  Pocet:=FSize-1;
  NO_Sort:=0;

  For Ch[1]:=#0 to #255 do
  begin
    For NO_Char[1]:=0 to Pocet do
    begin
      If Obsah[NO_Char[1]][1]=Ch[1] then
      begin
        For Ch[2]:=#0 to #255 do
        begin
          For NO_Char[2]:=0 to Pocet do
          begin
            If (Obsah[NO_Char[2]][1]=Ch[1])and(Obsah[NO_Char[2]][2]=Ch[2]) then
            begin
              For Ch[3]:=#0 to #255 do
              begin
                For NO_Char[3]:=0 to Pocet do
                begin
                  If (Obsah[NO_Char[3]][1]=Ch[1])and(Obsah[NO_Char[3]][2]=Ch[2])and
                     (Obsah[NO_Char[3]][3]=Ch[3])then
                  begin
                    For Ch[4]:=#0 to #255 do
                    begin
                      For NO_Char[4]:=0 to Pocet do
                      begin
                        If (Obsah[NO_Char[4]][1]=Ch[1])and(Obsah[NO_Char[4]][2]=Ch[2])and
                           (Obsah[NO_Char[4]][3]=Ch[3])and(Obsah[NO_Char[4]][4]=Ch[4])then
                        begin
                          For Ch[5]:=#0 to #255 do
                          begin
                            For NO_Char[5]:=0 to Pocet do
                            begin
                              If (Obsah[NO_Char[5]][1]=Ch[1])and(Obsah[NO_Char[5]][2]=Ch[2])and
                                 (Obsah[NO_Char[5]][3]=Ch[3])and(Obsah[NO_Char[5]][4]=Ch[4])and
                                 (Obsah[NO_Char[5]][5]=Ch[5])then
                              begin
                                For Ch[6]:=#0 to #255 do
                                begin
                                  For NO_Char[6]:=0 to Pocet do
                                  begin
                                    If (Obsah[NO_Char[6]][1]=Ch[1])and(Obsah[NO_Char[6]][2]=Ch[2])and
                                       (Obsah[NO_Char[6]][3]=Ch[3])and(Obsah[NO_Char[6]][4]=Ch[4])and
                                       (Obsah[NO_Char[6]][5]=Ch[5])and(Obsah[NO_Char[6]][6]=Ch[6])then
                                    begin
                                      For Ch[7]:=#0 to #255 do
                                      begin
                                        For NO_Char[7]:=0 to Pocet do
                                        begin
                                          If (Obsah[NO_Char[7]][1]=Ch[1])and(Obsah[NO_Char[7]][2]=Ch[2])and
                                             (Obsah[NO_Char[7]][3]=Ch[3])and(Obsah[NO_Char[7]][4]=Ch[4])and
                                             (Obsah[NO_Char[7]][5]=Ch[5])and(Obsah[NO_Char[7]][6]=Ch[6])and
                                             (Obsah[NO_Char[7]][7]=Ch[7])then
                                          begin
                                            For Ch[8]:=#0 to #255 do
                                            begin
                                              For NO_Char[8]:=0 to Pocet do
                                              begin
                                                If (Obsah[NO_Char[8]][1]=Ch[1])and(Obsah[NO_Char[8]][2]=Ch[2])and
                                                   (Obsah[NO_Char[8]][3]=Ch[3])and(Obsah[NO_Char[8]][4]=Ch[4])and
                                                   (Obsah[NO_Char[8]][5]=Ch[5])and(Obsah[NO_Char[8]][6]=Ch[6])and
                                                   (Obsah[NO_Char[8]][7]=Ch[7])and(Obsah[NO_Char[8]][8]=Ch[8])then
                                                begin
                                                  Seek(F,NO_Char[8]);
                                                  {$I-}Read(F,Zaznam);{$I+}
                                                  ErrorMessage;
                                                  Seek(S,NO_Sort);
                                                  {$I-}Write(S,Zaznam);{$I+}
                                                  ErrorMessage;
                                                  SortFiles[NO_Sort]:=Obsah[NO_Char[8]];
                                                  Inc(NO_Sort);
                                                end;
                                              end;
                                            end;
                                            Break;
                                          end;
                                        end;
                                      end;
                                      Break;
                                    end;
                                  end;
                                end;
                                Break;
                              end;
                            end;
                          end;
                          Break;
                        end;
                      end;
                    end;
                    Break;
                  end;
                end;
              end;
              Break;
            end;
          end;
        end;
        Break;
      end;
    end;
  end;
  {$I-}Close(F);{$I+}ErrorMessage;
  {$I-}Close(S);{$I+}ErrorMessage;
  WriteTestText(Vstup);
  ClearDownMessage;

  I:=0;
  FindFirst('*.*',$3F,DirInfo);
  while DosError=0 do
  begin
    If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;
  FindFirst('*.DAT',$3F,DirInfo);
  while DosError=0 do
  begin
    If DirInfo.Attr and $10<>$10 then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;
  Pol:=0;Pozice:=0;Soubor.Pocet:=I;
  Repeat until Port[$60]>128;
  Scan:=0;Ascii:=0;I:=0;
  SetScreen2(0);
end;

Procedure CreateNew;
Var
  XXX,YYY:Integer;

begin
  GetScreen2(0);
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(28,10,52,13,129+64);
  TextColor(0);
  GotoXY(31,12);Write('Vytvo©it novou slo‘ku');
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(30,12,20,'');
  until (Vstup<>'')or(Scan=1);
  SetScreen2(0);
  If Scan=28 then
  begin
    GetScreen2(0);
    {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
    If FSize>1000 then FSize:=1000;
    If FSize>0 then
    begin
      TextColor(15);TextBackground(1);
      Frame(20,10,60,15,129+64);
      TextColor(15);
      Center(11,'Nov  slo‘ka bude');
      Scan:=0;B:=0;
      Repeat
        If B=0 then
        begin
          TextColor(10);TextBackground(1);Center(12,'Na aktualn¡ pozici kurzoru');
          TextColor(7);TextBackground(0);Center(13,'Na konci seznamu');
        end
        else
        begin
          TextColor(7);TextBackground(0);Center(12,'Na aktualn¡ pozici kurzoru');
          TextColor(10);TextBackground(1);Center(13,'Na konci seznamu');
        end;
        GetKey;
        If Scan=80 then B:=0;
        If Scan=72 then B:=1;
      until (Scan=28)or(Scan=1);
    end
    else B:=0;
    If Scan=28 then
    begin
      For x:=0 to 75 do For y:=0 to 18 do Zaznam.Data[x,y]:=0;
      If B=0 then
      begin
        {Konec}
        {$I-}FSize:=FileSize(F);If FSize>1000 then FSize:=1000;
        Seek(F,FSize);{$I+}ErrorMessage;
      end
      else
      If B=1 then
      begin
        {Aktual}
        WriteDownMessage('Creating [                                         ]');
        TextColor(1);TextBackground(7);
        For I:=Polozka.Pocet downto Polozka.Cislo do
        begin
          {$I-}Seek(F,I);Read(F,Zaznam);{$I+}ErrorMessage;
          {$I-}Seek(F,I+1);Write(F,Zaznam);{$I+}ErrorMessage;

          GotoXY(((Polozka.Pocet-I) div ((Polozka.Pocet-Polozka.Cislo) div 39+1)+12),25);
          Write('þ');

          If IORes<>0 then Break;
        end;
        For x:=0 to 75 do For y:=0 to 18 do Zaznam.Data[x,y]:=0;
        {$I-}Seek(F,Polozka.Cislo);{$I+}ErrorMessage;
        ClearDownMessage;
      end;
      Zaznam.NazevPolozky:=Vstup;

      RandSeed:=100;
      With Zaznam do
      For NO_I:=1 to Length(NazevPolozky) do
      begin
        If NO_I>20 then Break;
        NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
      end;
      With Zaznam do
      For NO_Y:=0 to 18 do
      begin
        RandSeed:=235;
        For NO_X:=0 to 75 do
          Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
      end;


      {$I-}Write(F,Zaznam);{$I+}ErrorMessage;
      Inc(Polozka.Pocet);Polozka.Nazev:=Vstup;
      {$I-}Close(F);Reset(F);{$I+}ErrorMessage;
      For I:=0 to 1000 do Obsah[I]:='';I:=0;
      {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
      If FSize>1000 then FSize:=1000;
      For I:=0 to FSize-1 do
      begin
        {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

        RandSeed:=100;
        With Zaznam do
        For NO_I:=1 to Length(NazevPolozky) do
        begin
          If NO_I>20 then Break;
          NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
        end;
        With Zaznam do
        For NO_Y:=0 to 18 do
        begin
          RandSeed:=235;
          For NO_X:=0 to 75 do
            Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
        end;


        Obsah[I]:=Zaznam.NazevPolozky;
      end;
      Polozka.Pocet:=I;
      For I:=0 to 18 do
      begin
        while Pos(#7,Obsah[I+Pozice+Pol])>0 do
          Obsah[I+Pozice+Pol][Pos(#7,Obsah[I+Pozice+Pol])]:=#0;
        If Pol=I then
        begin Textbackground(7);TextColor(0);end
        else
        begin Textbackground(0);TextColor(10);end;
        GotoXY(31,I+5);Write('                      ');
        GotoXY(31,I+5);Write(Obsah[I+Pozice]+Fill(Obsah[I+Pozice],22))
      end;
      TextColor(15);TextBackground(1);Center(3,'                       ');
      {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
      GotoXY(39,4);Write(Pozice+Pol+1,'/',FSize);
      I:=0;
    end;
    SetScreen2(0);
  end;
  {$I-}Close(F);{$I+}ErrorMessage;
  WriteTestText(Polozka.Soubor);
  {$I-}Reset(F);{$I+}ErrorMessage;
  Repeat until Port[$60]>128;Scan:=0;
  Scan:=0;
end;



Procedure View;
begin
  GetScreen2(0);
  If Scan=28 then
  begin
    Window(1,25,80,25);TextBackground(7);ClrScr;Window(1,1,80,25);
    GotoXY(2,25);
    InitDownMenu('~+/-~ List  ~ESC~ Back',25);
    {$I-}Close(F);{$I+}ErrorMessage;
    Scan:=0;Ascii:=0;
    TextColor(7);TextBackground(0);
    Frame(1,2,78,23,129);
    If Polozka.Nazev<>'' then
    begin
      Assign(F,Polozka.Soubor);
      {$I-}Reset(F);{$I+}ErrorMessage;
      If IORes=0 then
      begin
        Seek(F,Polozka.Cislo);
        {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

        RandSeed:=100;
        With Zaznam do
        For NO_I:=1 to Length(NazevPolozky) do
        begin
          If NO_I>20 then Break;
          NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
        end;
        With Zaznam do
        For NO_Y:=0 to 18 do
        begin
          RandSeed:=235;
          For NO_X:=0 to 75 do
            Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
        end;


        {$I-}Close(F);{$I+}ErrorMessage;
      end;
    end;

    TextColor(15);
    For x:=0 to 75 do For y:=0 to 18 do
    begin
      GotoXY(x+3,y+5);Write(chr(Zaznam.Data[x,y]));
    end;
    Scan:=0;
    Assign(F,Polozka.Soubor);
    {$I-}Reset(F);{$I+}ErrorMessage;
    Repeat
      If Scan=74 then {-}
      begin
        {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
        If FSize>1000 then FSize:=1000;
        If Polozka.Cislo<=0 then Polozka.Cislo:=FSize;
        Polozka.Cislo:=Polozka.Cislo-1;
      end;
      If Scan=78 then {+}
      begin
        Polozka.Cislo:=Polozka.Cislo+1;
        {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
        If FSize>1000 then FSize:=1000;
        If Polozka.Cislo>=FSize then Polozka.Cislo:=0;
      end;
      If IORes=0 then
      begin
        {$I-}Seek(F,Polozka.Cislo);{$I+}ErrorMessage;
        {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

        RandSeed:=100;
        With Zaznam do
        For NO_I:=1 to Length(NazevPolozky) do
        begin
          If NO_I>20 then Break;
          NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
        end;
        With Zaznam do
        For NO_Y:=0 to 18 do
        begin
          RandSeed:=235;
          For NO_X:=0 to 75 do
            Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
        end;


      end;
      Polozka.Nazev:=Zaznam.NazevPolozky;
      TextColor(7);
      Center(2,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
      TextColor(10);Center(2,' '+Polozka.Nazev+' ');
      TextColor(15);
      For x:=0 to 75 do For y:=0 to 18 do
      begin GotoXY(x+3,y+5);Write(chr(Zaznam.Data[x,y]));end;
      GetKey;
      If Scan=68 then About(OEM,Ver);           {F10}
    until (Scan=1)or(Scan=28);
    TextColor(15);TextBackground(1);
  end;
  SetScreen2(0);
  Repeat until Port[$60]>128;
  Scan:=0;
end;


Procedure DeleteFile;
begin
  GetScreen2(0);
  Sound(100);Delay(100);NoSound;
  OkMessage('Opravdu chcete soubor "'+Soubor.Soubor[Pol+Polozka.Cislo]+'" odstranit ?');
  Assign(F,Soubor.Soubor[Pol+Polozka.Cislo]);
  {*******************************}
  {$I-}Reset(F);{$I+}ErrorMessage;

  If (Scan=28)or(UpCase(chr(ASCII))='A') then Erase(F);
  Repeat until Port[$60]>128;Scan:=0;
  SetScreen2(0);
  For I:=0 to 1000 do
  begin
    Soubor.Soubor[I]:='';
    Soubor.Attr[I]:=0;
    Soubor.Date[I]:=0;
  end;
  I:=0;Scan:=0;
  GetDir(0,Dir);
  If Length(Dir)<>3 then
  begin Soubor.Soubor[0]:='..';Soubor.Attr[0]:=$10;end else I:=-1;

  FindFirst('*.*',$3F,DirInfo);
  while DosError=0 do
  begin
    If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;

  FindFirst('*.DAT',$3F,DirInfo);
  while DosError=0 do
  begin
    If DirInfo.Attr and $10<>$10 then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;
  Pol:=0;Pozice:=0;Soubor.Pocet:=I;
  GetDir(0,Dir);
  Soubor.Pocet:=I;
  Pozice:=0;Pol:=0;
end;



Procedure NewFile;
Var
  Path,PSoubor:String;
  N: NameStr;
  E: ExtStr;
  P: PathStr;
  D: DirStr;
  Pol:Byte;
  Pozice:LongInt;
begin
  GetScreen2(0);
  PSoubor:='';
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(31,10,49,13,129+64);
  TextColor(0);
  GotoXY(34,12);Write('Zalo‘it soubor:');
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(34,12,12,'');
  until (Vstup<>'')or(Scan=1);
  Vstup:=FExpand(Vstup);
  FSplit(Vstup,D,N,E);
  If E<>'.DAT' then E:='.DAT';
  Vstup:=N+E;
  SetScreen2(0);
  If Scan=28 then
  begin
    GetScreen2(1);
    PSoubor:=Vstup;
    Assign(F,PSoubor);
    {$I-}Reset(F);{$I+}
    If IOResult<>0 then
    begin
      {$I-}Rewrite(F);{$I+}ErrorMessage;
    end
    else
    begin
      OKMessage('Soubor '+UpString(PSoubor)+' ji‘ exituje, P©epsat ?');
      If (Scan=28)or(UpCase(chr(ASCII))='A') then Rewrite(F)
      else
      begin
        NewFile;
      end;
    end;
    SetScreen2(1);
    GetScreen2(1);
    If IORes=0 then
    begin
      {$I-}Close(F);{$I+}ErrorMessage;

      WriteTestText(PSoubor);

      If IORes=0 then Message(0,'Vytvo©en nov˜ soubor '+UpString(PSoubor),0,7);
      GetKey;
    end;
    SetScreen2(1);
  end;
  Scan:=0;Ascii:=0;
  For I:=0 to 1000 do
  begin
    Soubor.Soubor[I]:='';
    Soubor.Attr[I]:=0;
    Soubor.Date[I]:=0;
  end;
  I:=0;Scan:=0;
  GetDir(0,Dir);
  If Length(Dir)<>3 then
  begin Soubor.Soubor[0]:='..';Soubor.Attr[0]:=$10;end else I:=-1;

  FindFirst('*.*',$3F,DirInfo);
  while DosError=0 do
  begin
    If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;

  FindFirst('*.DAT',$3F,DirInfo);
  while DosError=0 do
  begin
    If DirInfo.Attr and $10<>$10 then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;
  Pol:=0;Pozice:=0;
  GetDir(0,Dir);
  Soubor.Pocet:=I;
end;


Procedure RenameFile;
Var
  PSoubor:String[80];

begin
  GetScreen2(0);
  PSoubor:='';
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(24,10,56,13,129+64);
  TextColor(0);
  GotoXY(27,12);Write('P©ejmenovat "',Soubor.Soubor[Pol+Polozka.Cislo],'" na');
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(34,12,12,'');
  until (Vstup<>'')or(Scan=1);
  Vstup:=FExpand(Vstup);
  FSplit(Vstup,D,N,E);
  If E<>'.DAT' then E:='.DAT';
  Vstup:=N+E;

  SetScreen2(0);
  If Scan=28 then
  begin
    GetScreen2(0);
    PSoubor:=Vstup;
    Assign(F,PSoubor);
    {$I-}Reset(F);{$I+}
    If (IOResult<>0){or(PSoubor=Soubor.Soubor[Pol+Polozka.Cislo])} then
    begin
      Assign(F,Soubor.Soubor[Pol+Polozka.Cislo]);
      {$I-}Rename(F,PSoubor);{$I+}ErrorMessage;
    end
    else
    If Vstup<>Soubor.Soubor[Pol+Polozka.Cislo] then
    begin
      Close(F);
      OKMessage('Soubor '+UpString(PSoubor)+' ji‘ exituje, P©epsat ?');
      If (Scan=28)or(UpCase(chr(ASCII))='A') then
      begin
        Assign(F,Vstup);
        Erase(F);
        Assign(F,Soubor.Soubor[Pol+Polozka.Cislo]);
        Rename(F,Vstup)
      end
      else
      begin
        RenameFile;
      end;
    end;
    SetScreen2(0);
    GetScreen2(0);
    If IORes=0 then
    begin
      If IORes=0 then Message(0,'Soubor '+Soubor.Soubor[Pol+Polozka.Cislo]+' byl p©ejmenov n na '+UpString(PSoubor),0,7);
      GetKey;
      Assign(F,PSoubor);{$I-}Reset(F);{$I+}ErrorMessage;
    end;
    SetScreen2(0);
  end;
  For I:=0 to 1000 do
  begin
    Soubor.Soubor[I]:='';
    Soubor.Attr[I]:=0;
    Soubor.Date[I]:=0;
  end;
  I:=0;Scan:=0;
  GetDir(0,Dir);
  If Length(Dir)<>3 then
  begin Soubor.Soubor[0]:='..';Soubor.Attr[0]:=$10;end else I:=-1;

  FindFirst('*.*',$3F,DirInfo);
  while DosError=0 do
  begin
    If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;

  FindFirst('*.DAT',$3F,DirInfo);
  while DosError=0 do
  begin
    If DirInfo.Attr and $10<>$10 then
    begin
      Inc(I);
      Soubor.Soubor[I]:=DirInfo.Name;
      Soubor.Attr[I]:=DirInfo.Attr;
      Soubor.Size[I]:=DirInfo.Size;
      Soubor.Date[I]:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;
  Pol:=0;Pozice:=0;Soubor.Pocet:=I;
  GetDir(0,Dir);
  Soubor.Pocet:=I;
  Pozice:=0;Pol:=0;
  Repeat until Port[$60]>128;
  Scan:=0;Ascii:=0;
end;


{LOAD}
begin
  GetDir(0,Path);
  Repeat
    GetScreen;
    InitDownMenu('~F1~ Help  ~F6~ Rename  ~F7~ New  ~F8~ Delete  ~Alt+F1~ Disk  ~Alt+A~ Sort  ~ENTER~ OpenDat',25);
    Scan:=0;Ascii:=0;
    TextColor(0);TextBackground(7);
    For I:=0 to 1000 do
    begin
      Soubor.Soubor[I]:='';
      Soubor.Attr[I]:=0;
      Soubor.Date[I]:=0;
    end;
    I:=0;Scan:=0;
    GetDir(0,Dir);
    If Length(Dir)<>3 then
    begin Soubor.Soubor[0]:='..';Soubor.Attr[0]:=$10;end else I:=-1;

    FindFirst('*.*',$3F,DirInfo);
    while DosError=0 do
    begin
      If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
      begin
        Inc(I);
        Soubor.Soubor[I]:=DirInfo.Name;
        Soubor.Attr[I]:=DirInfo.Attr;
        Soubor.Size[I]:=DirInfo.Size;
        Soubor.Date[I]:=DirInfo.Time;
      end;
      FindNext(DirInfo);
    end;

    FindFirst('*.DAT',$3F,DirInfo);
    while DosError=0 do
    begin
      If DirInfo.Attr and $10<>$10 then
      begin
        Inc(I);
        Soubor.Soubor[I]:=DirInfo.Name;
        Soubor.Attr[I]:=DirInfo.Attr;
        Soubor.Size[I]:=DirInfo.Size;
        Soubor.Date[I]:=DirInfo.Time;
      end;
      FindNext(DirInfo);
    end;
    Pol:=0;Pozice:=0;Soubor.Pocet:=I;

    GetDir(0,Dir);
    Soubor.Pocet:=I;
    TextColor(15);TextBackground(1);
    Frame(20,2,61,23,129);
    TextColor(15);
    GotoXY(23,3);Write(' Jm‚no   Ext  Velikost   Datum    €as ');
    Pozice:=0;Pol:=0;
    Repeat
      For I:=0 to 18 do
      begin
        If Pol=I then Textbackground(8) else Textbackground(1);

        If Soubor.Attr[I+Pozice] and $10=$10 then TextColor(14)
        else TextColor(10);
        P:=Soubor.Soubor[I+Pozice];FSplit(P,D,N,E);

        GotoXY(22,I+5);
        If E='..' then
        begin
          TextColor(15);Write(' ..           <ADRESž>                 ');
        end
        else
        If E<>'' then
        begin
          {faReadOnly     ³ $01
faHidden       ³ $02
faSysFile      ³ $04
faVolumeID     ³ $08
faDirectory    ³ $10
faArchive      ³ $20
faAnyFile      ³ $3F
}
          Write(' '+N+Fill(N,8));
          If Soubor.Attr[I+Pozice] and 1=1 then
          begin GotoXY(31,I+5);Write('ù');end;
          If Soubor.Attr[I+Pozice] and 2=2 then
          begin GotoXY(31,I+5);Write('°');end;
          If Soubor.Attr[I+Pozice] and 4=4 then
          begin GotoXY(31,I+5);Write('÷');end;
          Write(Copy(E,2,3)+Fill(E,4));
          TextColor(11);GotoXY(36,I+5);Write('                          ');

          If Soubor.Attr[I+Pozice]and $10<>$10 then
          begin
            Str(Soubor.Size[I+Pozice]-6,S);
            GotoXY(45-Length(S),I+5);Write(S,' ');
            UnPackTime(Soubor.Date[I+Pozice],DT);
            GotoXY(47,I+5);Write(LeadingZero(DT.Day),'.',LeadingZero(DT.Month),
              '.',Copy(LeadingZero(DT.Year),3,2),' ',LeadingZero(DT.Hour),':',
              LeadingZero(DT.Min));
          end
          else
          begin
            TextColor(15);GotoXY(36,I+5);Write('<ADRESž>');
          end;
        end;
        If (E='')and(Copy(P,2,1)<>':') then
        begin
          TextColor(14);Write(' '+N+Fill(N,38));
          If N<>'' then
          begin
            TextColor(15);GotoXY(36,I+5);Write('<ADRESž>');
          end;
        end;
        If Copy(P,2,1)=':' then
        begin
          TextColor(12);Write('   -< '+P+' >-                          ');
        end;
      end;
      If Soubor.Pocet<0 then Soubor.Pocet:=0;
      I:=Soubor.Pocet;
      TextColor(15);TextBackground(1);Center(3,'                ');
      GotoXY(39,4);Write(Pozice+Pol+1,'/',I+1);
      Scan:=0;
      GetKey;
      If (Scan=71)and(ASCII=224) then{HOME}
      begin Pol:=0;Pozice:=0;end;

      If (Scan=79)and(ASCII=224) then{END}
      begin
        If I>18 then Pol:=18
        else Pol:=I;
        Pozice:=I-Pol;
      end;

      If (Scan=73)and(ASCII=224) then{PGUP}
      begin
        If Pozice-18>=0 then Pozice:=Pozice-18;
      end;

      If (Scan=81)and(ASCII=224) then{PGDOWN}
      begin If Pozice+18<Soubor.Pocet then Pozice:=Pozice+18;end;

      If (I>0)and(Scan=80) then Pol:=Pol+1;
      If (I>0)and(Scan=80)and(Pol>18)then
      begin Pozice:=Pozice+1;pol:=18;end;

      If (I>0)and(Scan=72)and(Pol=0)and(Pozice>0)then
      begin Pozice:=Pozice-1;Pol:=0;end;
      If (I>0)and(Scan=72)and(Pol>0) then Pol:=Pol-1;

      If (I>18)and((Pozice+Pol)>I) then
      begin Pol:=18;Pozice:=I-Pol;end;

      If (I<=18)and((Pozice+Pol)>I) then
      begin Pol:=I-Pozice;Pozice:=I-Pol;end;

      If Soubor.Attr[Pol+Polozka.Cislo]and $10<>$10 then
      begin
        If (Scan=30)and(ASCII=0) then SortFile; {Alt+A}
        If Scan=64 then RenameFile; {F6}
        If Scan=66 then DeleteFile; {F8}
      end;
      If Scan=65 then NewFile;      {F7}
      If Scan=59 then Help('FILELIST',HelpFile);     {F1}
      If Scan=68 then About(OEM,Ver);  {F10}
      If Scan=104 then              {Alt+F1}
      begin
        If Copy(Soubor.Soubor[Soubor.Pocet],2,1)<>':'then
        begin
          For I:=0 to 25 do
          begin
            B:=I;
            asm
            MOV AH,44h
            MOV AL,0Fh
            MOV BL,B
            INC BL
            INT 21h
            end;
            {$I-}
             FindFirst(chr(I+65)+':\*.*',$3F,DirInfo);
            {$I+}
            If DosError=0 then
            begin
              If Soubor.Soubor[Soubor.Pocet]='' then
              begin
                Soubor.Soubor[Soubor.Pocet]:=chr(I+65)+':';
                Soubor.Attr[Soubor.Pocet]:=$10;
                Inc(Soubor.Pocet);
              end
              else
              begin
                Inc(Soubor.Pocet);
                Soubor.Soubor[Soubor.Pocet]:=chr(I+65)+':';
                Soubor.Attr[Soubor.Pocet]:=$10;
              end;
            end;
            If (Soubor.Soubor[Soubor.Pocet]='')and(Soubor.Pocet>0)then
              Dec(Soubor.Pocet);
          end;
        end;
      end;

      If Scan=28 then
      begin
        Dir:=Soubor.Soubor[Pol+Pozice];
        If (Soubor.Attr[Pol+Pozice] and $10=$10)then
        begin
          For I:=0 to 1000 do
          begin
            Soubor.Soubor[I]:='';
            Soubor.Attr[I]:=0;
            Soubor.Date[I]:=0;
          end;
          I:=0;
          Scan:=0;
          If dir<>'..' then
          begin
            B:=ord(Dir[1])-65;
            asm
            MOV AH,44h
            MOV AL,0Fh
            MOV BL,B
            INC BL
            INT 21h
            end;
          end;
          ChDir(Dir);
          GetDir(0,Dir);

          If Length(Dir)<>3 then
          begin Soubor.Soubor[0]:='..';Soubor.Attr[0]:=$10;end else I:=-1;

          FindFirst('*.*',$3F,DirInfo);
          while DosError=0 do
          begin
            If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
            begin
              Inc(I);
              Soubor.Soubor[I]:=DirInfo.Name;
              Soubor.Attr[I]:=DirInfo.Attr;
              Soubor.Size[I]:=DirInfo.Size;
              Soubor.Date[I]:=DirInfo.Time;
            end;
            FindNext(DirInfo);
          end;

          FindFirst('*.DAT',$3F,DirInfo);
          while DosError=0 do
          begin
            If DirInfo.Attr and $10<>$10 then
            begin
              Inc(I);
              Soubor.Soubor[I]:=DirInfo.Name;
              Soubor.Attr[I]:=DirInfo.Attr;
              Soubor.Size[I]:=DirInfo.Size;
              Soubor.Date[I]:=DirInfo.Time;
            end;
            FindNext(DirInfo);
          end;
          Pol:=0;Pozice:=0;
          Soubor.Pocet:=I;
        end;
      end;
      If (Scan=28)and(Soubor.Soubor[Pol+Pozice]='')then Scan:=0;
    until (Scan=1)or(Scan=28);
    PSoubor:=FExpand(Soubor.Soubor[Pol]);

    SetScreen;
    If Scan=28 then
    begin
      Assign(TestF,PSoubor);
      {$I-}Reset(TestF);{$I+}ErrorMessage;
      Test:=#0#0#0#0#0#0;
      {$I-}FSize:=FileSize(TestF);{$I+}ErrorMessage;
      If IORes=0 then
      begin
        If FSize>=6 then
        begin
          Seek(TestF,FileSize(TestF)-6);
          For I:=1 to 6 do Read(TestF,Test[I]);
        end;
        {$I-}Close(TestF);{$I+}ErrorMessage;
        If Test<>'Dataer' then
        begin
          GetScreen;
          OKMessage('Upozornen¡: Tento soubor nen¡ datov˜ soubor programu DATAER !');
          SetScreen;
        end;

        Assign(F,PSoubor);
        {$I-}Reset(F);{$I+}ErrorMessage;
        GetScreen;
      end;
      If IORes=0 then
      begin
        WriteDownMessage('Loading [                                         ]');
        For I:=0 to 1000 do Obsah[I]:='';
        {$I-}Seek(F,0);{$I+}ErrorMessage;
        {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
        If FSize>1000 then
        begin
          OKMessage('Soubor obsahuje p©¡li¨ mnoho polo‘ek !');
          OKMessage('Bude na‡teno pouze prvn¡ch 1000 polo‘ek');
          FSize:=1000;
        end;
        I:=0;
        TextColor(1);TextBackground(7);
        If FSize>0 then
        begin
          For I:=0 to FSize-1 do
          begin
            If I<1000 then
            begin
              {$I-}Read(F,Zaznam);{$I+}ErrorMessage;

              RandSeed:=100;
              With Zaznam do
              For NO_I:=1 to Length(NazevPolozky) do
              begin
                If NO_I>20 then Break;
                NazevPolozky[NO_I]:=Chr(Ord(NazevPolozky[NO_I]) xor Random(256));
              end;
              With Zaznam do
              For NO_Y:=0 to 18 do
              begin
                RandSeed:=235;
                For NO_X:=0 to 75 do
                  Data[NO_X,NO_Y]:=Data[NO_X,NO_Y] xor Random(256);
              end;


               Obsah[I]:=Zaznam.NazevPolozky;
               GotoXY((I div 25+11),25);Write('þ');
            end;
          end;
        end;
        Polozka.Pocet:=I;
        SetScreen;
        GetScreen;
        InitDownMenu('~F1~ Help  ~F2~ Move  ~ENTER~ View  ~F4~ Edit  ~F6~ Rename  ~F7~ New  ~F8~ Del'+
        '  ~ESC~ Back  ',25);
        Scan:=0;Ascii:=0;
        TextColor(15);TextBackground(0);
        Frame(29,2,53,23,129);
        Center(02,' '+Soubor.Soubor[Pol+Pozice]+' ');
        Pozice:=0;Pol:=0;I:=0;
        TextColor(10);
        Repeat
          {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
          If FSize>1000 then FSize:=1000;
          If FSize>0 then
          begin
            If Scan=28 then View;
            If Scan=60 then Exchange;
            If Scan=62 then Edit;
            If Scan=64 then Ren;
            If Scan=66 then Del;
          end;
          If Scan=59 then HELP('DATALIST',HelpFile);
          If Scan=65 then CreateNew;
          If Scan=68 then About(OEM,Ver);
          For I:=0 to 18 do
          begin
            while Pos(#7,Obsah[I+Pozice+Pol])>0 do
              Obsah[I+Pozice+Pol][Pos(#7,Obsah[I+Pozice+Pol])]:=#0;
            while Pos(#13,Obsah[I+Pozice+Pol])>0 do
              Obsah[I+Pozice+Pol][Pos(#13,Obsah[I+Pozice+Pol])]:=#0;
            while Pos(#10,Obsah[I+Pozice+Pol])>0 do
              Obsah[I+Pozice+Pol][Pos(#10,Obsah[I+Pozice+Pol])]:=#0;
            while Pos(#8,Obsah[I+Pozice+Pol])>0 do
              Obsah[I+Pozice+Pol][Pos(#8,Obsah[I+Pozice+Pol])]:=#0;
            If Pol=I then
            begin Textbackground(7);TextColor(0);end
            else
            begin Textbackground(0);TextColor(10);end;
            GotoXY(31,I+5);Write(Obsah[I+Pozice]+Fill(Obsah[I+Pozice],22))
          end;
          TextColor(15);TextBackground(1);
          GotoXY(31,4);Write('                       ');
          I:=Polozka.pocet;
          GotoXY(39,4);
          {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
          If FSize>0 then Write(Pozice+Pol+1,'/',I+1)
          else Center(3,'Pr zdn˜ soubor');
          Polozka.Cislo:=Pozice+Pol;
          Polozka.Nazev:=Obsah[Pozice+Pol];
          Polozka.Soubor:=PSoubor;

          Scan:=0;
          GetKey;
          If FSize>0 then
          begin
            If ((Pozice+Pol)=I)and(Scan=80) then
            begin Sound(1000);Delay(2);NoSound;end;

            If (Scan=72)and(Pol<=0)and(Pozice<=0) then
            begin Pol:=0;Pozice:=0;Sound(1000);Delay(2);NoSound;end;

            If (I>0)and(Scan=80)and(Pozice+Pol<I) then Pol:=Pol+1;

            If (Scan=72)and(Pol>0)and(I>0) then Pol:=Pol-1;

            If (I+1>0)and(Pol>18)and(Scan=80)then
              begin Pozice:=Pozice+1;pol:=18;end;

            If (Pol=0)and(Scan=72)and(Pozice>0)then
              begin Pozice:=Pozice-1;end;

            If Scan=71 then begin Pozice:=0;Pol:=0;end;{Home}

            If Scan=79 then begin Pozice:=Polozka.Pocet;Pol:=0;end;{End}

            If ((Pozice+Pol)>I)and(I<=18) then
            begin
              If I>0 then Pol:=I;Pozice:=0;Sound(1000);Delay(2);NoSound;
            end;

            If (Scan=73)and(I>0) then{PageUp}
            begin
              If (Pol+Pozice>19) then
              begin Pozice:=Pozice-19+Pol;Pol:=0;end
              else begin Pol:=0;Pozice:=0;end;
            end;

            If (Scan=81)and(I>0) then{PageDown}
            begin
              If (Pol+Pozice<I-19) then
              begin Pozice:=Pozice+19;Pol:=0;end
              else begin Pol:=0;Pozice:=I;end;
            end;
          end;
        until (Scan=1);
        Scan:=0;
        {$I-}Close(F);{$I+}ErrorMessage;
        SetScreen;
      end
      else SetScreen;
    end;
    Repeat until Port[$60]>128;
  until (Scan=1);
  TextColor(8);TextBackground(1);
  Scan:=0;
end;



Begin
  GetDir(0,PuvAdr);
  Locks0:=Mem[0:$417];
  Mem[0:$417]:=Mem[0:$417] and (32+64+16);
  Writeln(#10#13'Inicializuji ‡e¨tinu...');
  LoadCZPage(10);
  Writeln('Inicializuji prost©ed¡...');
  InitScreen;
  If CestinaOK then SetASCIITab(10);
  About(OEM,Ver);
  Repeat
    GetKey;
    If Scan=59 then Help('MAIN',HelpFile);          {F1}
    If Scan=61 then Load;                           {F3}
    If Scan=68 then About(OEM,Ver);                 {F10}
    If (Ascii=18)and(Scan=19) then InitScreen;      {Ctrl+R}
  until (Scan=45)and(Ascii=0);
  While Keypressed do GetKey;
  TextColor(7);TextBackground(0);TextCursor(True);
  For I:=0 to 25 do
  begin
    Delay(30);RolDown(0,0,79,24,1,0);
  end;
  ClrScr;
  Writeln(#10#10#13'Copyright (c) 1998  Tom ¨ Hujer');
  {If CestinaOK then SetASCIITab(0);}
  ChDir(PuvAdr);
  Mem[0:$417]:=Locks0;
end.