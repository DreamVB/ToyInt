unit cVars;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  Item = packed record
    Name: string;
    Data: variant;
  end;

type
  TVariable = class
  private
    mList: array of Item;
    Counter: integer;
  public
    procedure SetVar(Key: string; Data: variant);
    function GetVarData(Key: string): variant;
    function GetVarID(Key: string): integer;
    function IsVar(Name: string): boolean;
    function GetVarName(V: string): string;
    procedure Free;
    constructor Create(Size: integer);
  end;

implementation

constructor TVariable.Create(Size: integer);
begin
  Counter := 0;
  SetLength(mList, Size + 1);
end;

procedure TVariable.SetVar(Key: string; Data: variant);
var
  idx: integer;
  sKey: string;
begin

  sKey := Key;
  idx := GetVarID(sKey);

  if idx = -1 then
  begin
    mList[Counter].Name := sKey;
    mList[Counter].Data := Data;
    Inc(Counter);
  end
  else
  begin
    mList[idx].Data := Data;
  end;
end;

function TVariable.GetVarID(Key: string): integer;
var
  I: integer;
  idx: integer;
begin
  idx := -1;

  for I := 0 to Counter - 1 do
  begin
    if UpperCase(mList[I].Name) = UpperCase(Key) then
    begin
      idx := I;
      break;
    end;
  end;

  if idx = -1 then
  begin
    Result := -1;
  end
  else
  begin
    Result := idx;
  end;
end;

function TVariable.GetVarData(Key: string): variant;
var
  idx: integer;
begin
  idx := GetVarID(Key);

  if idx <> -1 then
  begin
    Result := mList[idx].Data;
  end;

end;

function TVariable.IsVar(Name: string): boolean;
var
  T: char;
begin
  Result := False;

  if Length(Name) > 0 then
  begin
    T := Name[1];
    Result := (T = '!') or (T = '&');
  end;
end;

function TVariable.GetVarName(V: string): string;
var
  Temp: string;
begin

  Temp := V;

  if IsVar(Temp) then
  begin
    Delete(Temp, 1, 1);
  end;
  Result := Temp;
end;

procedure TVariable.Free;
begin
  Counter := 0;
  SetLength(mList, Counter);
end;

end.
