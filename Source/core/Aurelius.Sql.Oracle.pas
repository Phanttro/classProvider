unit Aurelius.Sql.Oracle;

{$I Aurelius.inc}

interface

uses
  DB,
  Aurelius.Sql.AnsiSqlGenerator,
  Aurelius.Sql.BaseTypes,
  Aurelius.Sql.Commands,
  Aurelius.Sql.Interfaces,
  Aurelius.Sql.Register;

type
  TOracleSQLGenerator = class(TAnsiSQLGenerator)
  protected
    function GetMaxConstraintNameLength: Integer; override;
    function FieldTypeToSQL(FieldDef: TSQLFieldDefinition): string; override;

    function GetGeneratorName: string; override;
    function GetSqlDialect: string; override;

    function GenerateGetNextSequenceValue(Command: TGetNextSequenceValueCommand): string; override;
    function GenerateCreateSequence(Command: TCreateSequenceCommand): string; override;
    function GenerateDropSequence(Command: TDropSequenceCommand): string; override;
    function GenerateDropField(Command: TDropFieldCommand): string; override;
    function GenerateLimitedSelect(SelectSql: TSelectSql; Command: TSelectCommand): string; override;

    function GetSupportedFeatures: TDBFeatures; override;
    procedure ProcessCommand(var SQL: string); override;

    // Database compatibility methods
    function GetSupportedFieldTypes: TFieldTypeSet; override;
    function GetEquivalentFieldTypes: TFieldTypeEquivArray; override;
    function ConvertValue(Value: Variant; FromType, ToType: TFieldType): Variant; override;
  end;

implementation
uses
  Variants, SysUtils;

{ TOracleSQLGenerator }

function TOracleSQLGenerator.ConvertValue(Value: Variant; FromType,
  ToType: TFieldType): Variant;
begin
  if (FromType in [ftDate, ftTime, ftDateTime]) and (ToType in [ftDate, ftTime, ftDateTime]) then
    Result := VarToDateTime(Value)
  else
  if (FromType = ftBlob) or (ToType = ftBlob) then
    Result := Value
  else
  if (FromType = ftWideMemo) or (ToType = ftWideMemo) then
    Result := Value
  else
  if (FromType = ftMemo) or (ToType = ftMemo) then
    Result := Value
  else
    Result := inherited ConvertValue(Value, FromType, ToType);
end;

function TOracleSQLGenerator.FieldTypeToSQL(FieldDef: TSQLFieldDefinition): string;
begin
  Result := NumericTypeToSQL(FieldDef);
  if Result <> '' then
    Exit(StringReplace(Result, 'NUMERIC', 'NUMBER', [rfIgnoreCase]));

  case FieldDef.FieldType of
    ftByte:
      Result := 'NUMBER(3)';
    ftShortint:
      Result := 'NUMBER(3)';
    ftSmallint:
      Result := 'NUMBER(5)';
    ftWord:
      Result := 'NUMBER(5)';
    ftInteger:
      Result := 'NUMBER(10)';
    ftLongWord:
      Result := 'NUMBER(10)';
    ftLargeint:
      Result := 'NUMBER(20)';

    ftString:
      Result := Format('VARCHAR2(%d)', [FieldDef.Length]);
    ftWideString:
      Result := Format('NVARCHAR2(%d)', [FieldDef.Length]);

    ftTime:
      Result := 'DATE';
    ftDateTime:
      Result := 'DATE';

    ftFloat:
      Result := 'NUMBER';
    ftSingle:
      Result := 'NUMBER';
    ftExtended:
      Result := 'NUMBER';
    ftCurrency:
      Result := 'NUMBER(20, 4)';
//    ftFMTBcd:
//      Result := 'NUMBER'; // Arbitrary precision.

    ftMemo:
      Result := 'CLOB';
    ftWideMemo:
      Result := 'NCLOB';
    ftOraBlob:
      Result := 'BLOB';
  else
    Result := inherited FieldTypeToSQL(FieldDef);
  end;
end;

function TOracleSQLGenerator.GenerateCreateSequence(Command: TCreateSequenceCommand): string;
begin
  Result := Format('CREATE SEQUENCE %s START WITH %s INCREMENT BY %s MAXVALUE 9999999999;',
    [Command.SequenceName, IntToStr(Command.InitialValue), IntToStr(Command.Increment)]);
end;

function TOracleSQLGenerator.GenerateDropField(
  Command: TDropFieldCommand): string;
begin
  result := InternalGenerateDropField(Command, True);
end;

function TOracleSQLGenerator.GenerateDropSequence(Command: TDropSequenceCommand): string;
begin
  Result := Format('DROP SEQUENCE %s;', [Command.SequenceName]);
end;

function TOracleSQLGenerator.GenerateGetNextSequenceValue(Command: TGetNextSequenceValueCommand): string;
begin
  Result := Format('SELECT CAST(%s.NEXTVAL AS NUMBER(10)) FROM DUAL;', [Command.SequenceName]);
end;

function TOracleSQLGenerator.GenerateLimitedSelect(SelectSql: TSelectSql;
  Command: TSelectCommand): string;
var
  SubSql: string;
begin
  SubSql := GenerateRegularSelect(SelectSql);
  if Command.HasMaxRows and Command.HasFirstRow then
  begin
    Result := Format(
      'SELECT * FROM (  '#13#10 +
      'SELECT rownum rnum, A.* FROM ( '#13#10 +
      SubSql + ') A '#13#10 +
      'WHERE rownum <= %d) '#13#10 +
      'WHERE rnum >= %d',
      [Command.LastRow + 1, Command.FirstRow + 1]);
  end
  else
  if Command.HasFirstRow then
  begin
    Result := Format(
      'SELECT * FROM (  '#13#10 +
      'SELECT rownum rnum, A.* FROM ( '#13#10 +
      SubSql + ') A )'#13#10 +
      'WHERE rnum >= %d',
      [Command.FirstRow + 1]);
  end else
  begin
    Result := Format(
      'SELECT * FROM (  '#13#10 +
      SubSql + ') '#13#10 +
      'WHERE rownum <= %d',
      [Command.MaxRows]);
  end;
end;

function TOracleSQLGenerator.GetSqlDialect: string;
begin
  Result := 'Oracle';
end;

function TOracleSQLGenerator.GetEquivalentFieldTypes: TFieldTypeEquivArray;
var
  Arr: TFieldTypeEquivArray;
  c: Integer;
begin
  Arr := inherited GetEquivalentFieldTypes;
  SetLength(Result, Length(Arr) + 3);

  Result[0].NotSupportedType := ftDate;
  Result[0].EquivalentType := ftDateTime;
  Result[1].NotSupportedType := ftTime;
  Result[1].EquivalentType := ftDateTime;
  Result[2].NotSupportedType := ftBlob;
  Result[2].EquivalentType := ftOraBlob;

  for c := 0 to Length(Arr) - 1 do
    Result[c + 3] := Arr[c];
end;

function TOracleSQLGenerator.GetGeneratorName: string;
begin
  Result := 'Oracle SQL Generator';
end;

function TOracleSQLGenerator.GetMaxConstraintNameLength: Integer;
begin
  Result := 30;
end;

function TOracleSQLGenerator.GetSupportedFeatures: TDBFeatures;
begin
  Result := AllDBFeatures - [TDBFeature.AutoGenerated];
end;

function TOracleSQLGenerator.GetSupportedFieldTypes: TFieldTypeSet;
begin
  Result := inherited GetSupportedFieldTypes;
  Result := Result - [ftDate, ftTime, ftBlob{, ftMemo, ftWideMemo}];
end;

procedure TOracleSQLGenerator.ProcessCommand(var SQL: string);
begin
  // remove the final ";" from the sql - was causing invalid char errors
  if (Length(SQL) > 1) and (SQL[Length(SQL)] = ';') then
    Delete(SQL, Length(SQL), 1);
end;

initialization
  TSQLGeneratorRegister.GetInstance.RegisterGenerator(TOracleSQLGenerator.Create);

end.
