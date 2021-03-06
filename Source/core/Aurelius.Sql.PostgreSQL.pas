unit Aurelius.Sql.PostgreSQL;

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
  TPostgreSQLGenerator = class(TAnsiSQLGenerator)
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

    // Database compatibility methods
    function GetSupportedFieldTypes: TFieldTypeSet; override;
    function ConvertValue(Value: Variant; FromType, ToType: TFieldType): Variant; override;
  end;

implementation
uses
  Variants, SysUtils;

{ TPostgreSQLGenerator }

function TPostgreSQLGenerator.ConvertValue(Value: Variant; FromType,
  ToType: TFieldType): Variant;
begin
//  if (FromType in [ftDate, ftTime, ftDateTime]) and (ToType in [ftDate, ftTime, ftDateTime]) then
//    Result := VarToDateTime(Value)
//  else
//  if (FromType = ftBlob) or (ToType = ftBlob) then
//    Result := Value
//  else
//    Result := inherited ConvertValue(Value, FromType, ToType);
  Result := inherited ConvertValue(Value, FromType, ToType);
end;

function TPostgreSQLGenerator.FieldTypeToSql(FieldDef: TSQLFieldDefinition): string;
begin
  Result := NumericTypeToSQL(FieldDef);
  if Result <> '' then
    Exit;

  case FieldDef.FieldType of
    ftLargeint:
      Result := 'BIGINT';

    ftWideString:
      Result := Format('VARCHAR(%d)', [FieldDef.Length]);
    ftFixedWideChar:
      Result := Format('CHAR(%d)', [FieldDef.Length]);

    ftBoolean:
      Result := 'BOOLEAN';
    ftMemo:
      Result := 'TEXT';
    ftWideMemo:
      Result := 'TEXT';
    ftBlob:
      Result := 'BYTEA';
    ftGuid:
      Result := 'UUID';
  else
    Result := inherited FieldTypeToSql(FieldDef);
  end;
end;

function TPostgreSQLGenerator.GenerateCreateSequence(Command: TCreateSequenceCommand): string;
begin
  Result := Format('CREATE SEQUENCE %s START WITH %s INCREMENT BY %s MAXVALUE 9999999999;',
    [Command.SequenceName, IntToStr(Command.InitialValue), IntToStr(Command.Increment)]);
end;

function TPostgreSQLGenerator.GenerateDropField(
  Command: TDropFieldCommand): string;
begin
  result := InternalGenerateDropField(Command, True);
end;

function TPostgreSQLGenerator.GenerateDropSequence(Command: TDropSequenceCommand): string;
begin
  Result := Format('DROP SEQUENCE %s;', [Command.SequenceName]);
end;

function TPostgreSQLGenerator.GenerateGetNextSequenceValue(Command: TGetNextSequenceValueCommand): string;
begin
  Result := Format('SELECT NEXTVAL(''%s'');', [Command.SequenceName]);
end;

function TPostgreSQLGenerator.GenerateLimitedSelect(SelectSql: TSelectSql;
  Command: TSelectCommand): string;
begin
  Result := GenerateRegularSelect(SelectSql) + #13#10;

  if Command.HasMaxRows then
    Result := Result + Format('LIMIT %d', [Command.MaxRows]);
  if Command.HasFirstRow then
    Result := Result + Format(' OFFSET %d', [Command.FirstRow]);
end;

function TPostgreSQLGenerator.GetSqlDialect: string;
begin
  Result := 'PostgreSQL';
end;

function TPostgreSQLGenerator.GetGeneratorName: string;
begin
  Result := 'PostgreSQL SQL Generator';
end;

function TPostgreSQLGenerator.GetMaxConstraintNameLength: Integer;
begin
  Result := 63;
end;

function TPostgreSQLGenerator.GetSupportedFeatures: TDBFeatures;
begin
  Result := AllDBFeatures - [TDBFeature.AutoGenerated];
end;

function TPostgreSQLGenerator.GetSupportedFieldTypes: TFieldTypeSet;
begin
  Result := inherited GetSupportedFieldTypes;
  Result := Result + [ftBoolean, ftGuid];
end;

initialization
  TSQLGeneratorRegister.GetInstance.RegisterGenerator(TPostgreSQLGenerator.Create);

end.
