program toyint;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
                  {$ENDIF}
  Classes,
  cLables,
  cStack,
  SysUtils,
  cVars { you can add units after this };

type
  TWords = (wAdd, wSub, wMult, wDiv, wDecDiv, wMOD,
    wAnd, wOr, wXor, wNot, wLT, wGT, wLeq, wGeq, wEq, wNeq,
    wJmp, wJnz, wJz, wUpperCase, wAsc, wLeft, wRight, wConcat,
    wCopy, wLen, wDelete, wSubPos, wLowerCase, wDup, wDrop, wPrint,
    wRead, wPrintLN, wChar, wIsAlpha, wIsDigit, wIsUpper, wIsLower,
    wNow, wDate, wCustomDateTime, wMax, wMin,
    wSwap, wShl, wShr, wRnd, wToINT, wTime, wCall, wRet,
    wExit, wLineBreak, wError);

var
  Source: TStringList;
  CompiledWords: TStringList;
  lzFile: string;
  stack: TMyStack;
  rs: TMyStack;
  lables: TLabelCollection;
  vars: TVariable;
  IP: integer;
  IsRunning: boolean;
  SkipCompErrMsg: boolean;

const
  MAX_STACK_SIZE = 256;


  procedure Abort(code: integer; Msg: string);
  begin

    IsRunning := False;

    Writeln('Tiny Int v1.0');
    writeln('Error: ' + IntToStr(code));

    case code of
      0:
      begin
        writeln(Msg);
      end;
      1:
      begin
        writeln('There Was An Error Compileing');
      end;
      2:
      begin
        writeln('Unknown Token, ' + Msg);
      end;
      3:
      begin
        writeln('Label Already Found, ' + Msg);
      end;
    end;

  end;

  function Max(A, B: integer): integer;
  begin
    if a > b then
    begin
      Result := A;
    end
    else
    begin
      Result := B;
    end;
  end;

  function Min(A, B: integer): integer;
  begin
    if a < b then
    begin
      Result := A;
    end
    else
    begin
      Result := B;
    end;
  end;

  function BoolToInt(V: boolean): integer;
  begin
    Result := 0;
    if V then Result := 1;
  end;

  function IsCharConst(S: string): boolean;
  begin
    Result := False;

    if (LeftStr(S, 1) = '''') and (RightStr(S, 1) = '''') then
    begin
      if Length(S) = 3 then Result := True;
    end;

  end;

  function IsNum(S: string): boolean;
  var
    I: byte;
    isGood: boolean;
  begin

    isGood := True;

    for I := 1 to Length(S) do
    begin
      if not (S[I] in ['0'..'9', '-', '.']) then
      begin
        isGood := False;
        break;
      end;
    end;
    Result := isGood;
  end;

  procedure SplitWords(Delimiter: char; Str: string; ListOfStrings: TStrings);
  begin
    ListOfStrings.Clear;
    ListOfStrings.Delimiter := Delimiter;
    ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
    ListOfStrings.DelimitedText := Str;
  end;

  procedure LoadSourceFile(Filename: string);
  begin
    Source := TStringList.Create;
    Source.LoadFromFile(Filename);
  end;

  function LexScanner: boolean;
  var
    IsGood: boolean;
    I, J: integer;
    sLine, word: string;
    Temp: TStringList;
  begin

    Temp := TStringList.Create;
    word := '';

    for I := 0 to Source.Count - 1 do
    begin
      sLine := Trim(Source[I]);

      if (Length(sLine) > 0) and (LeftStr(sLine, 1) <> ';') then
      begin
        SplitWords(' ', sLine, Temp);

        for J := 0 to Temp.Count - 1 do
        begin

          word := Temp[J];

          if leftstr(word, 1) <> '$' then
          begin
            word := Trim(word);
          end;

          if Length(word) > 0 then
          begin

            if RightStr(word, 1) = ':' then
            begin
              //Delete the :
              Delete(word, Length(word), 1);
              if not lables.LabelExsits(word) then
              begin
                lables.AddNewLabel(word, CompiledWords.Count - 1);
              end
              else
              begin
                Abort(3, word);
                Result := False;
                SkipCompErrMsg := True;
                exit;
              end;
            end
            else
            begin
              CompiledWords.Add(word);
            end;
          end;
        end;
      end;
    end;

    Temp.Clear;
    sLine := '';

    IsGood := (CompiledWords.Count > 0);
    Result := IsGood;
  end;

  function GetWordID(S: string): integer;
  begin

    if S = '+' then
    begin
      Result := Ord(wAdd);
    end
    else if S = '-' then
    begin
      Result := Ord(wSub);
    end
    else if S = '*' then
    begin
      Result := Ord(wMult);
    end
    else if S = '&' then
    begin
      Result := Ord(wConcat);
    end
    else if S = 'DIV' then
    begin
      Result := Ord(wDiv);
    end
    else if S = '/' then
    begin
      Result := Ord(wDecDiv);
    end
    else if S = 'MOD' then
    begin
      Result := Ord(wMOD);
    end
    else if S = 'JMP' then
    begin
      Result := Ord(wJmp);
    end
    else if S = 'JNZ' then
    begin
      Result := Ord(wJnz);
    end
    else if S = 'JZ' then
    begin
      Result := Ord(wJz);
    end
    else if S = 'AND' then
    begin
      Result := Ord(wAnd);
    end
    else if S = 'OR' then
    begin
      Result := Ord(wOr);
    end
    else if S = 'XOR' then
    begin
      Result := Ord(wXor);
    end
    else if S = 'NOT' then
    begin
      Result := Ord(wNot);
    end
    else if S = '<' then
    begin
      Result := Ord(wLT);
    end
    else if S = '>' then
    begin
      Result := Ord(wGT);
    end
    else if S = '<=' then
    begin
      Result := Ord(wLeq);
    end
    else if S = '>=' then
    begin
      Result := Ord(wGeq);
    end
    else if S = '=' then
    begin
      Result := Ord(wEq);
    end
    else if S = '<>' then
    begin
      Result := Ord(wNeq);
    end
    else if S = 'UPPERCASE' then
    begin
      Result := Ord(wUpperCase);
    end
    else if S = 'LOWERCASE' then
    begin
      Result := Ord(wLowerCase);
    end
    else if S = 'ASC' then
    begin
      Result := Ord(wAsc);
    end
    else if S = 'LEFT' then
    begin
      Result := Ord(wLeft);
    end
    else if S = 'RIGHT' then
    begin
      Result := Ord(wRight);
    end
    else if S = 'COPY' then
    begin
      Result := Ord(wCopy);
    end
    else if S = 'LENGTH' then
    begin
      Result := Ord(wLen);
    end
    else if S = 'DELETE' then
    begin
      Result := Ord(wDelete);
    end
    else if S = 'STRPOS' then
    begin
      Result := Ord(wSubPos);
    end
    else if S = 'DUP' then
    begin
      Result := Ord(wDup);
    end
    else if S = 'DROP' then
    begin
      Result := Ord(wDrop);
    end
    else if S = 'CHAR' then
    begin
      Result := Ord(wChar);
    end
    else if S = 'ISALPHA' then
    begin
      Result := Ord(wIsAlpha);
    end
    else if S = 'ISDIGIT' then
    begin
      Result := Ord(wIsDigit);
    end
    else if S = 'ISUPPER' then
    begin
      Result := Ord(wIsUpper);
    end
    else if S = 'ISLOWER' then
    begin
      Result := Ord(wIsLower);
    end
    else if S = 'PRINT' then
    begin
      Result := Ord(wPrint);
    end
    else if S = 'READ' then
    begin
      Result := Ord(wRead);
    end
    else if S = 'PRINTLN' then
    begin
      Result := Ord(wPrintLN);
    end
    else if S = '@LINEBREAK' then
    begin
      Result := Ord(wLineBreak);
    end
    else if S = '@NOW' then
    begin
      Result := Ord(wNow);
    end
    else if S = '@DATE' then
    begin
      Result := Ord(wDate);
    end
    else if S = '@TIME' then
    begin
      Result := Ord(wTime);
    end
    else if S = '@DATETIMEFRMT' then
    begin
      Result := Ord(wCustomDateTime);
    end
    else if S = 'MAX' then
    begin
      Result := Ord(wMax);
    end
    else if S = 'MIN' then
    begin
      Result := Ord(wMin);
    end
    else if S = 'SWAP' then
    begin
      Result := Ord(wSwap);
    end
    else if S = 'SHL' then
    begin
      Result := Ord(wShl);
    end
    else if S = 'SHR' then
    begin
      Result := Ord(wShr);
    end
    else if S = 'RND' then
    begin
      Result := Ord(wRnd);
    end
    else if S = 'TOINT' then
    begin
      Result := Ord(wToINT);
    end
    else if S = 'CALL' then
    begin
      Result := Ord(wCall);
    end
    else if S = 'RET' then
    begin
      Result := Ord(wRet);
    end
    else if S = 'EXIT' then
    begin
      Result := Ord(wExit);
    end
    else
    begin
      Result := Ord(wError);
    end;
  end;

  procedure Run;
  var
    sWord: string;
    opcode: TWords;
    vT, ch: char;
    vName: string;
    sTemp, sTemp1, lLable, sRead: string;
    First, Second: double;
  begin

    stack := TMyStack.Create(MAX_STACK_SIZE);
    rs := TMyStack.Create(MAX_STACK_SIZE);

    IP := 0;
    IsRunning := True;

    while IsRunning do
    begin

      sWord := UpperCase(CompiledWords[IP]);

      opcode := TWords(GetWordID(sWord));

      if opcode <> wError then
      begin
        case opcode of
          wAdd:
          begin
            Second := double(stack.Pop());
            First := double(stack.Pop());
            stack.Push(Second + First);
          end;
          wSub:
          begin
            Second := double(stack.Pop());
            First := double(stack.Pop());
            stack.Push(First - Second);
          end;
          wMult:
          begin
            Second := double(stack.Pop());
            First := double(stack.Pop());
            stack.Push(Second * First);
          end;
          wDiv:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Trunc(First) div Trunc(Second));
          end;
          wDecDiv:
          begin
            Second := double(stack.Pop());
            First := double(stack.Pop());
            stack.Push(First / Second);
          end;
          wMOD:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Trunc(First) mod Trunc(Second));
          end;
          wMax:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Max(Trunc(First), Trunc(Second)));
          end;
          wMin:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Min(Trunc(First), Trunc(Second)));
          end;
          wSwap:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Second);
            stack.Push(First);
          end;
          wShl:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Trunc(First) shl Trunc(Second));
          end;
          wShr:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Trunc(First) shr Trunc(Second));
          end;
          wRnd:
          begin
            First := integer(stack.Pop());
            Stack.Push(Random(Trunc(First)));
          end;
          wJmp:
          begin
            Inc(IP);
            lLable := CompiledWords[IP];
            if lables.LabelExsits(lLable) then
            begin
              IP := lables.GetLabelID(lLable);
            end;
          end;
          wJnz:
          begin
            Inc(IP);
            lLable := CompiledWords[IP];
            if lables.LabelExsits(lLable) then
            begin
              if stack.Pop() <> 0 then
              begin
                IP := lables.GetLabelID(lLable);
              end;
            end;
          end;
          wJz:
          begin
            Inc(IP);
            lLable := CompiledWords[IP];
            if lables.LabelExsits(lLable) then
            begin
              if stack.Pop() = 0 then
              begin
                IP := lables.GetLabelID(lLable);
              end;
            end;
          end;
          wAnd:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Trunc(Second) and Trunc(First));
          end;
          wOr:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Trunc(Second) or Trunc(First));
          end;
          wXor:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(Trunc(Second) xor Trunc(First));
          end;
          wNot:
          begin
            stack.Push(not stack.Pop());
          end;
          wLT:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(BoolToInt(First < Second));
          end;
          wGT:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(BoolToInt(First > Second));
          end;
          wLeq:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(BoolToInt(First <= Second));
          end;
          wGeq:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(BoolToInt(First >= Second));
          end;
          wEq:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(BoolToInt(First = Second));
          end;
          wNeq:
          begin
            Second := integer(stack.Pop());
            First := integer(stack.Pop());
            stack.Push(BoolToInt(First <> Second));
          end;
          wUpperCase:
          begin
            stack.Push(UpperCase(stack.Pop()));
          end;
          wLowerCase:
          begin
            stack.Push(LowerCase(stack.Pop()));
          end;
          wAsc:
          begin
            sTemp := stack.Pop();
            if Length(sTemp) = 1 then
            begin
              stack.Push(Ord(sTemp[1]));
            end;
          end;
          wLeft:
          begin
            First := stack.Pop();
            sTemp := stack.Pop();
            stack.Push(LeftStr(sTemp, Trunc(First)));
          end;
          wRight:
          begin
            First := stack.Pop();
            sTemp := stack.Pop();
            stack.Push(RightStr(sTemp, Trunc(First)));
          end;
          wCopy:
          begin
            Second := stack.Pop();
            First := stack.Pop();
            sTemp := stack.Pop();
            stack.Push(Copy(sTemp, Trunc(First), Trunc(Second)));
          end;
          wLen:
          begin
            stack.Push(Length(stack.Pop()));
          end;
          wDelete:
          begin
            Second := stack.Pop();
            First := stack.Pop();
            sTemp := stack.Pop();
            Delete(sTemp, Trunc(First), trunc(Second));
            stack.Push(sTemp);
          end;
          wSubPos:
          begin
            sTemp1 := stack.Pop();
            sTemp := stack.Pop();
            stack.Push(integer(Pos(sTemp1, sTemp)));
          end;
          wConcat:
          begin
            sTemp := stack.Pop();
            stack.Push(stack.Pop() + sTemp);
          end;
          wDup:
          begin
            First := stack.Pop();
            stack.Push(First);
            stack.Push(First);
          end;
          wDrop:
          begin
            stack.Pop();
          end;
          wToINT:
          begin
            stack.Push(integer(stack.Pop()));
          end;
          wChar:
          begin
            stack.Push(chr(stack.Pop()));
          end;
          wIsAlpha:
          begin
            ch := char(stack.Pop());
            stack.Push(BoolToInt(ch in ['A'..'Z', 'a'..'z']));
          end;
          wIsDigit:
          begin
            ch := char(stack.Pop());
            stack.Push(BoolToInt(ch in ['0'..'9']));
          end;
          wIsUpper:
          begin
            ch := char(stack.Pop());
            stack.Push(BoolToInt(ch in ['A'..'Z']));
          end;
          wIsLower:
          begin
            ch := char(stack.Pop());
            stack.Push(BoolToInt(ch in ['a'..'z']));
          end;
          wPrint:
          begin
            Write(stack.Pop());
          end;
          wPrintLN:
          begin
            Writeln(stack.Pop());
          end;
          wRead:
          begin
            Readln(sRead);
            stack.Push(sRead);
          end;
          wLineBreak:
          begin
            stack.Push(sLineBreak);
          end;
          wNow:
          begin
            stack.Push(Now);
          end;
          wTime:
          begin
            stack.Push(FormatDateTime('HH:MM:SS', Now));
          end;
          wDate:
          begin
            stack.Push(FormatDateTime('DD/MM/YYYY', Now));
          end;
          wCustomDateTime:
          begin
            stack.Push(FormatDateTime(stack.Pop(), Now));
          end;
          wCall:
          begin
            Inc(IP);
            rs.Push(IP);
            lLable := CompiledWords[IP];
            if lables.LabelExsits(lLable) then
            begin
              IP := lables.GetLabelID(lLable);
            end;
          end;
          wRet:
          begin
            IP := integer(rs.Pop());
          end;
          wExit:
          begin
            IsRunning := False;
          end;
        end;
      end
      else
      begin
        //Check if number.
        if IsNum(CompiledWords[IP]) then
        begin
          stack.Push(StrToFloat(CompiledWords[IP]));
        end
        else if vars.IsVar(sWord) then
        begin
          vT := sWord[1];
          vName := vars.GetVarName(sWord);

          //See what we are doing
          if vT = '!' then
          begin
            //Set var
            vars.SetVar(vName, stack.Pop());
          end;

          if vT = '&' then
          begin
            //Get var data on the stack
            stack.Push(vars.GetVarData(vName));
          end;
        end
        else if LeftStr(sWord, 1) = '$' then
        begin
          sTemp := CompiledWords[IP];
          Delete(sTemp, 1, 1);
          //Push the string onto the stack.
          stack.Push(sTemp);
        end
        else if IsCharConst(sWord) then
        begin
          sTemp := CompiledWords[IP];
          //Extract char
          Delete(sTemp, 1, 1);
          Delete(sTemp, Length(sTemp), 1);
          stack.Push(char(sTemp[1]));
        end
        else
        begin
          Abort(2, CompiledWords[IP]);
        end;
      end;
      Inc(IP);
    end;
  end;

  procedure ClearUp;
  begin
    stack.Free;
    lables.Free;
    vars.Free;
    rs.Free;
    CompiledWords.Clear;
  end;

begin
  vars := TVariable.Create(256);
  lables := TLabelCollection.Create(256);

  Randomize;
  SkipCompErrMsg := False;

  if paramcount > 0 then
  begin
    lzFile := ParamStr(1);

    if not FileExists(lzFile) then
    begin
      Abort(0, 'File Not Found : ' + lzFile);
      exit;
    end
    else
    begin
      CompiledWords := TStringList.Create;
      LoadSourceFile(lzFile);
      if not LexScanner then
      begin
        if not SkipCompErrMsg then
        begin
          Abort(1, '');
          exit;
        end;
      end
      else
      begin
        Run;
        ClearUp;
      end;
    end;
  end;
end.
