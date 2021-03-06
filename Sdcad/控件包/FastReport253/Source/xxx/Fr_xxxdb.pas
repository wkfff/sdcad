
{******************************************}
{                                          }
{     FastReport v2.4 - XXX components     }
{            Database component            }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_XXXDB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs, DB, UXXXDatabase;

type
  TfrXXXComponents = class(TComponent) // fake component
  end;

  TfrXXXDatabase = class(TfrNonVisualControl)
  private
    FDatabase: TXXXDatabase;
    procedure LinesEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefineProperties; override;
    property Database: TXXXDatabase read FDatabase;
  end;


implementation

uses FR_Utils, FR_Const, FR_LEdit, FR_DBLookupCtl, FR_XXXTable, FR_XXXQuery
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{$R FR_XXX.RES}


{ TfrXXXDatabase }

constructor TfrXXXDatabase.Create;
begin
  inherited Create;
  FDatabase := TXXXDataBase.Create(frDialogForm);
  Component := FDatabase;
  BaseName := 'Database';
  Bmp.LoadFromResourceName(hInstance, 'FR_XXXDB');
  Flags := Flags or flDontUndo;
end;

destructor TfrXXXDatabase.Destroy;
begin
  FDatabase.Free;
  inherited Destroy;
end;

procedure TfrXXXDatabase.DefineProperties;

  function GetAliasNames: String;
  var
    i: Integer;
    sl: TStringList;
  begin
    Result := '';
    sl := TStringList.Create;
    Session.GetAliasNames(sl);
    sl.Sort;
    for i := 0 to sl.Count - 1 do
      Result := Result + sl[i] + ';';
    sl.Free;
  end;

  function GetDriverNames: String;
  var
    i, j: Integer;
    sl: TStringList;
    s: String;
  begin
    Result := '';
    sl := TStringList.Create;
    Session.GetDriverNames(sl);
    sl.Sort;
    for i := 0 to sl.Count - 1 do
    begin
      s := sl[i];
      for j := 1 to Length(s) do
        if s[j] = ';' then
          s[j] := ',';
      Result := Result + s + ';';
    end;
    sl.Free;
  end;

begin
  inherited DefineProperties;
  AddEnumProperty('AliasName', GetAliasNames, [Null]);
  AddProperty('Connected', [frdtBoolean], nil);
  AddProperty('DatabaseName', [frdtString], nil);
  AddEnumProperty('DriverName', GetDriverNames, [Null]);
  AddProperty('LoginPrompt', [frdtBoolean], nil);
  AddProperty('Params', [frdtHasEditor, frdtOneObject], LinesEditor);
  AddProperty('Params.Count', [], nil);
end;

procedure TfrXXXDatabase.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'DATABASENAME' then
    FDatabase.DatabaseName := Value
  else if Index = 'DRIVERNAME' then
    FDatabase.DriverName := Value
  else if Index = 'LOGINPROMPT' then
    FDatabase.LoginPrompt := Value
  else if Index = 'CONNECTED' then
    FDatabase.Connected := Value
  else if Index = 'ALIASNAME' then
    FDatabase.AliasName := Value
  else if Index = 'PARAMS' then
    FDatabase.Params.Text := Value
end;

function TfrXXXDatabase.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATABASENAME' then
    Result := FDatabase.DatabaseName
  else if Index = 'DRIVERNAME' then
    Result := FDatabase.DriverName
  else if Index = 'LOGINPROMPT' then
    Result := FDatabase.LoginPrompt
  else if Index = 'CONNECTED' then
    Result := FDatabase.Connected
  else if Index = 'ALIASNAME' then
    Result := FDatabase.AliasName
  else if Index = 'PARAMS.COUNT' then
    Result := FDatabase.Params.Count
  else if Index = 'PARAMS' then
    Result := FDatabase.Params.Text
end;

function TfrXXXDataBase.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(FDataBase.Params, MethodName, 'PARAMS', Par1, Par2, Par3);
end;

procedure TfrXXXDatabase.LoadFromStream(Stream: TStream);
var
  s: String;
begin
  inherited LoadFromStream(Stream);
  FDatabase.DatabaseName := frReadString(Stream);
  s := frReadString(Stream);
  if s <> '' then
    FDatabase.AliasName := s;
  s := frReadString(Stream);
  if s <> '' then
    FDatabase.DriverName := s;
  FDatabase.LoginPrompt := frReadBoolean(Stream);
  frReadMemo(Stream, FDatabase.Params);
  FDatabase.Connected := frReadBoolean(Stream);
end;

procedure TfrXXXDatabase.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, FDatabase.DatabaseName);
  frWriteString(Stream, FDatabase.AliasName);
  frWriteString(Stream, FDatabase.DriverName);
  frWriteBoolean(Stream, FDatabase.LoginPrompt);
  frWriteMemo(Stream, FDatabase.Params);
  frWriteBoolean(Stream, FDatabase.Connected);
end;

procedure TfrXXXDatabase.LinesEditor(Sender: TObject);
var
  sl: TStringList;
  SaveConnected: Boolean;
begin
  sl := TStringList.Create;
  try
    Session.GetAliasParams(FDatabase.AliasName, sl);
  except;
  end;
  with TfrLinesEditorForm.Create(nil) do
  begin
    if FDatabase.Params.Text = '' then
      M1.Text := sl.Text else
      M1.Text := FDatabase.Params.Text;
    if (ShowModal = mrOk) and ((Restrictions and frrfDontModify) = 0) and
      M1.Modified then
    begin
      SaveConnected := FDatabase.Connected;
      FDatabase.Connected := False;
      FDatabase.Params.Text := M1.Text;
      FDatabase.Connected := SaveConnected;
      frDesigner.Modified := True;
    end;
    Free;
  end;
  sl.Free;
end;


var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_XXXDBCONTROL');
  frRegisterControl(TfrXXXDatabase, Bmp, IntToStr(SInsertDB));

finalization
  frUnRegisterObject(TfrXXXDatabase);
  Bmp.Free;

end.

