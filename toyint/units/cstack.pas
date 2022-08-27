unit cStack;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TCompareMode = (Text, Binary);

type
  TMyStack = class

  private
    //Hold stack size and stack position.
    Stack_size, StackPtr: integer;
    //This hold items for our stack
    //Stack items
    T_Items: array of variant;
    //Compare mode.
    CmpMode: TCompareMode;
    //Set compare mode.
    procedure SetCompare(Value: TCompareMode);
    //get compare mode.
    function GetCompare(): TCompareMode;
  public
    //To create the stack
    constructor Create(Size: integer);
    //Return stack count
    property Count: integer read Stack_size;
    property Compare: TCompareMode read GetCompare write SetCompare;
    //Push items onto stack
    procedure Push(Item: variant);
    //Pop items of stack
    function Pop(): variant;
    //Peek at the first item.
    function Peek(): variant;
    //Tells us if stack id full.
    function IsFull(): boolean;
    //Tells us if stack empry.
    function IsEmpty(): boolean;
    //Check for item in stack.
    function Contains(Item: variant): boolean;
    procedure Free;
  end;

implementation

constructor TMyStack.Create(Size: integer);
begin
  StackPtr := 0;
  Stack_size := Size;
  //Set size of stack
  SetLength(T_Items, Stack_size);
end;

function TMyStack.GetCompare(): TCompareMode;
begin
  //Set compare mode.
  Result := CmpMode;
end;

procedure TMyStack.SetCompare(Value: TCompareMode);
begin
  //Get compare mode.
  CmpMode := Value;
end;

procedure TMyStack.Push(Item: variant);
begin
  if not IsFull then
  begin
    //Push items on the stack.
    T_Items[StackPtr + 1] := Item;
    StackPtr := StackPtr + 1;
  end;
end;

function TMyStack.Pop(): variant;
begin
  if not IsEmpty then
  begin
    //Return item from stack.
    Result := T_Items[StackPtr];
    StackPtr := StackPtr - 1;
  end;
end;

function TMyStack.Peek(): variant;
begin
  Peek := T_Items[StackPtr + 1];
end;

function TMyStack.IsFull(): boolean;
begin
  IsFull := (StackPtr = Stack_size);
end;

function TMyStack.IsEmpty(): boolean;
begin
  Result := (StackPtr = 0);
end;

function TMyStack.Contains(Item: variant): boolean;
var
  X: integer;
  Found: boolean;
  sItem1, sItem2: variant;
begin
  Found := False;
  //Look for item in stack.
  for X := low(T_Items) to high(T_Items) do
  begin
    //Compare mode for text.
    if (cmpMode = TCompareMode.Text) then
    begin
      sItem1 := LowerCase(T_Items[x]);
      sItem2 := LowerCase(Item);
    end;
    //Compare mode for binary.
    if (cmpMode = TcompareMode.Binary) then
    begin
      sItem1 := T_Items[X];
      sItem2 := Item;
    end;
    //Check for item in stack.
    if (sItem1 = sItem2) then
    begin
      Found := True;
      break;
    end;
  end;

  Contains := Found;
end;

procedure TMyStack.Free();
begin
  Stack_size := 0;
  StackPtr := 0;
  SetLength(T_Items, 0);
end;

end.
