unit untFuncoes;

interface
  uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, Mask, DBCtrls, Provider, DBClient,
  ADODB, ComCtrls;

type
  FeatBase = (ftFireBird, ftOracle);
  TFunc = Class
  private
    { Private declarations }
  public
    class function isNullable(val1: String): String; static;
    class function PrimeiraLetraMaiscula(Str: string): string; static;
    class function ifthen(clausula: boolean; val1, val2: String): String; static;
    class function retornaTipo(tipo: String): String;
    class var Base: FeatBase;
    { Public declarations }
  end;

implementation

class function TFunc.PrimeiraLetraMaiscula(Str: string): string;
var
  i: integer;
  esp: boolean;
begin
  str := LowerCase(Trim(str));
  for i := 1 to Length(str) do
  begin
    if i = 1 then
      str[i] := UpCase(str[i])
    else
      begin
        if i <> Length(str) then
        begin
          esp := (str[i] = ' ');
          if esp then
            str[i+1] := UpCase(str[i+1]);
        end;
      end;
  end;
  Result := Str;
end;

class function Tfunc.ifthen(clausula:boolean; val1:String; val2:String):String;
begin
  if clausula then
    result := val1
  else
    result := val2;
end;

class function Tfunc.isNullable(val1:String):String;
begin
  if UpperCase(val1) = 'YES' then
    result := 'true'
  else
    result := 'false';
end;

class function Tfunc.retornaTipo(tipo: String): String;
begin
  //int, bigint ou smallint
  if (Pos('int', tipo) > 0)
  or (Pos('serial', tipo) > 0)then
  begin
    result := 'Integer';
  end;

  if (Pos('double', tipo) > 0)
  or (Pos('money', tipo) > 0)
  or (Pos('number', tipo) > 0)
  or (Pos('numeric', tipo) > 0)
  or (Pos('decimal', tipo) > 0)
  or (Pos('real', tipo) > 0) then
  begin
    result := 'Double';
  end;


    //char , character ou character variant
  if (Pos('char', tipo) > 0)
  or (Pos('text', tipo)> 0)
  or (Pos('long', tipo)> 0)
  or (Pos('blob', tipo)> 0) then
  begin
    result := 'String';
  end;

  //boolean
  if (Pos('bool', tipo) > 0)
  or (Pos('bit', tipo) > 0) then
  begin
    result := 'Boolean';
  end;

  //date
  if Pos('date', tipo) > 0 then
  begin
    result := 'TDate';
  end;
end;



end.
