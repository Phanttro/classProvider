unit Aurelius.Sql.AnsiSQLGenerator;

{$I Aurelius.inc}

interface

uses
  Generics.Defaults, Generics.Collections, DB,
  Aurelius.Sql.AbstractSQLGenerator,
  Aurelius.Sql.BaseTypes,
  Aurelius.Sql.Commands,
  Aurelius.Sql.Interfaces;

type
  TSelectSQL = class
  public
    SelectClause: string;
    FromClause: string;
    WhereClause: string;
    HavingClause: string;
    GroupClause: string;
    OrderClause: string;
  end;

  TAnsiSQLGenerator = class(TAbstractSQLGenerator)
  protected
    function GetFullTableName(ATable: TSQLTable): string; override;

    function GetFieldNames(Fields: TList<TSQLField>; IncludeAliases: Boolean): TList<string>; virtual;

    // Methods for converting types/enumerations to SQL:
    function WhereOperatorToSQL(WhereOperator: TWhereOperator): string; virtual;
    function AggregateFunctionToSQL(AggregateFunction: TAggregateFunction): string; virtual;
    function FieldTypeToSQL(FieldDef: TSQLFieldDefinition): string; virtual;
    function NumericTypeToSQL(FieldDef: TSQLFieldDefinition): string;

    // Supported features
    function GetSupportedWhereOperators: TWhereOperationSet; virtual;
    function GetSupportedAggregateFunctions: TAggregateFunctionSet; virtual;

    // Common SQL generator
    function GenerateSelectClause(Fields: TList<TSQLSelectField>; ACustomStatement: string): string; virtual;
    function GenerateFromClause(Command: TSelectCommand): string; virtual;
    function GenerateWhereClause(Fields: TList<TSQLWhereField>; UseAliases: Boolean; ACustomStatement: string): string; virtual;
    function GenerateGroupByClause(Fields: TList<TSQLField>; ACustomStatement: string): string; virtual;
    function GenerateHavingClause(ACustomStatement: string): string; virtual;
    function GenerateOrderByClause(Fields: TList<TSQLOrderField>; ACustomStatement: string): string; virtual;
    function GenerateLimitedSelect(SelectSql: TSelectSql; Command: TSelectCommand): string; virtual;
    function GenerateRegularSelect(SelectSql: TSelectSql): string; virtual;

    // Specific database SQL generation
    function GetMaxConstraintNameLength: Integer; virtual;

    // Helper functions for the descendants
    function InternalGenerateDropField(Command: TDropFieldCommand; AUseColumnWord: boolean): string;

    // Generator identifier
    function GetGeneratorName: string; override;

    // Standard DML methods
    function GenerateSelect(Command: TSelectCommand): string; override;
    function GenerateInsert(Command: TInsertCommand): string; override;
    function GenerateUpdate(Command: TUpdateCommand): string; override;
    function GenerateDelete(Command: TDeleteCommand): string; override;

    // DDL methods
    function GenerateCreateTable(Command: TCreateTableCommand): string; override;
    function GenerateCreateForeignKey(Command: TCreateForeignKeyCommand): string; override;
    function GenerateCreateUniqueKey(Command: TCreateUniqueKeyCommand): string; override;
    function GenerateDropTable(Command: TDropTableCommand): string; override;
    function GenerateDropForeignKey(Command: TDropForeignKeyCommand): string; override;
    function GenerateCreateField(Command: TCreateFieldCommand): string; override;
    function GenerateDropField(Command: TDropFieldCommand): string; override;

    // DDL methods for pieces of SQL. These methods are called by GenerateCreateTable and other methods to build the SQL statements
    function GenerateFieldDefinition(Field: TSQLFieldDefinition): string; virtual;
    function GeneratePrimaryKey(APkName: string; AFields: TList<string>): string; virtual;
    function GenerateForeignKeyDefinition(Command: TCreateForeignKeyCommand): string; virtual;
    function GenerateUniqueKeyDefinition(Command: TCreateUniqueKeyCommand): string; virtual;

    // Disable/Enable foreign keys
    function GenerateEnableForeignKeys(Command: TEnableForeignKeysCommand): string; override;

    // Types/constants methods
    function GetSqlLiteral(AValue: Variant; AType: TFieldType): string; override;

    // Database compatibility methods
    function GetSupportedFieldTypes: TFieldTypeSet; override;
    function GetEquivalentFieldTypes: TFieldTypeEquivArray; override;
    function ConvertValue(Value: Variant; FromType, ToType: TFieldType): Variant; override;

    // Database-specific methods. Must be overriden or ignored
    function GenerateGetNextSequenceValue(Command: TGetNextSequenceValueCommand): string; override;
    function GenerateGetLastInsertId(SQLField: TSQLField): string; override;
    function GenerateCreateSequence(Command: TCreateSequenceCommand): string; override;
    function GenerateDropSequence(Command: TDropSequenceCommand): string; override;

    function GetQualifiedColumnName(Field: TSQLSelectField): string; override;

    function GetForeignKeyName(Command: TCreateForeignKeyCommand): string; override;
    function GetUniqueKeyName(Command: TCreateUniqueKeyCommand): string; virtual;

    function AllDBFeatures: TDBFeatures;
  end;

implementation

uses
  Variants,
  SysUtils,
  Classes,
  Aurelius.Global.Utils,
  Aurelius.Sql.Exceptions;

{ TAnsiSQLGenerator }

function TAnsiSQLGenerator.GenerateCreateField(
  Command: TCreateFieldCommand): string;
begin
  Result := 'ALTER TABLE ';

  Result := Result + GetFullTablename(Command.Table) + #13#10'  ADD ' +
    Command.Field.FieldName + ' ' + FieldTypeToSQL(Command.Field);

  if Command.Field.NotNull then
    Result := Result + ' NOT NULL';

  Result := Result + ';';
end;

function TAnsiSQLGenerator.GenerateCreateForeignKey(
  Command: TCreateForeignKeyCommand): string;
begin
  Result := 'ALTER TABLE ';
  Result := Result + GetFullTableName(Command.FromTable) + ' ADD CONSTRAINT '#13#10'  ' +
    GenerateForeignKeyDefinition(Command);
end;

function TAnsiSQLGenerator.GenerateCreateSequence(
  Command: TCreateSequenceCommand): string;
begin
  raise ESequencesNotSupported.Create(Self);
end;

function TAnsiSQLGenerator.GenerateCreateTable(
  Command: TCreateTableCommand): string;
var
  I: Integer;
  PkName: string;
  ForeignKey: TCreateForeignKeyCommand;
begin
  Result := 'CREATE TABLE ';

  Result := Result + GetFullTableName(Command.Table) + ' ('#13#10'  ';

  for I := 0 to Command.Fields.Count - 1 do
  begin
    if I > 0 then
      Result := Result + ','#13#10'  ';
    Result := Result + GenerateFieldDefinition(Command.Fields[I]);
  end;

  // Primary Key
  if Command.IdFields.Count > 0 then
  begin
    PkName := 'PK_';
    if Command.Table.Schema <> '' then
      PkName := PkName + Command.Table.Schema + '_';
    PkName := PkName + Command.Table.Name;
    PkName := Copy(PkName, 1, GetMaxConstraintNameLength);
    Result := Result + ','#13#10'  CONSTRAINT ' + GeneratePrimaryKey(PkName, Command.IdFields);
  end;

  // Foreign Keys
  for ForeignKey in Command.ForeignKeys do
    Result := Result + ','#13#10'  CONSTRAINT ' + GenerateForeignKeyDefinition(ForeignKey);

  // Unique Constraints
  for I := 0 to Command.UniqueConstraints.Count - 1 do
  begin
    Result := Result + ','#13#10'  CONSTRAINT ' + GenerateUniqueKeyDefinition(Command.UniqueConstraints[I]);
  end;

  Result := Result + ');';
end;

function TAnsiSQLGenerator.GenerateCreateUniqueKey(
  Command: TCreateUniqueKeyCommand): string;
begin

end;

function TAnsiSQLGenerator.GenerateDelete(Command: TDeleteCommand): string;
begin
  Result := 'DELETE FROM ';

  Result := Result + GetFullTableName(Command.Table);

  Result := Result + #13#10 + GenerateWhereClause(Command.WhereFields, False, '');

  Result := Result + ';';
end;

function TAnsiSQLGenerator.GenerateDropField(
  Command: TDropFieldCommand): string;
begin
  Result := InternalGenerateDropField(Command, false);
end;

function TAnsiSQLGenerator.GenerateDropForeignKey(
  Command: TDropForeignKeyCommand): string;
begin
  Result := 'ALTER TABLE ';

  Result := Result + GetFullTableName(Command.FromTable) + #13#10'  DROP CONSTRAINT ' +
    GetForeignKeyName(Command) + ';';
end;

function TAnsiSQLGenerator.GenerateDropSequence(
  Command: TDropSequenceCommand): string;
begin
  raise ESequencesNotSupported.Create(Self);
end;

function TAnsiSQLGenerator.GenerateDropTable(
  Command: TDropTableCommand): string;
begin
  Result := 'DROP TABLE ';

  Result := Result + GetFullTableName(Command.Table) + ';';
end;

function TAnsiSQLGenerator.GenerateEnableForeignKeys(Command: TEnableForeignKeysCommand): string;
begin
  Result := '';
end;

function TAnsiSQLGenerator.GenerateFieldDefinition(
  Field: TSQLFieldDefinition): string;
begin
  Result := Field.FieldName + ' ' + FieldTypeToSQL(Field);
  if Field.NotNull then
    Result := Result + ' NOT NULL';
end;

function TAnsiSQLGenerator.GenerateForeignKeyDefinition(Command: TCreateForeignKeyCommand): string;
begin
  Result :=
    GetForeignKeyName(Command) +
    ' FOREIGN KEY (' +
    TUtils.ConcatStrings(Command.FromFields, ', ') +
    ') REFERENCES ' + GetFullTableName(Command.ToTable) + ' (' +
    TUtils.ConcatStrings(Command.ToFields, ', ') + ')';
end;

function TAnsiSQLGenerator.GenerateFromClause(Command: TSelectCommand): string;
var
  I, J: integer;
begin
  // Removed the "AS" in the FROM clause since Oracle doesn't support it,
  // and all other databases (so far) accept it without the "AS". So this is default now
  Result := Result + GetFullTableName(Command.Table) + ' ' + Command.Table.Alias;
//  Result := Result + Command.Table.Name + ' AS ' + Command.Table.Alias;

  for I := 0 to Command.Joins.Count - 1 do
  begin
    Assert(Command.Joins[I].Segments.Count > 0);

    case Command.Joins[I].JoinType of
      TJoinType.Inner: Result := Result + #13#10'  INNER JOIN ';
      TJoinType.Left:  Result := Result + #13#10'  LEFT JOIN ';
    end;

    Result := Result + GetFullTableName(Command.Joins[I].Segments[0].PKField.Table) +
      ' ' + Command.Joins[I].Segments[0].PKField.Table.Alias + ' ON (';
//    Result := Result + Command.Joins[I].Segments[0].PKField.Table.Name +
//      ' AS ' + Command.Joins[I].Segments[0].PKField.Table.Alias + ' ON (';

    for J := 0 to Command.Joins[I].Segments.Count - 1 do
    begin
      if J > 0 then
        Result := Result + ' AND ';

      Result := Result +
        Command.Joins[I].Segments[J].PKField.Table.Alias + '.' +
        Command.Joins[I].Segments[J].PKField.Field + ' = ' +
        Command.Joins[I].Segments[J].FKField.Table.Alias + '.' +
        Command.Joins[I].Segments[J].FKField.Field;
    end;
    Result := Result + ')';
  end;

  Result := 'FROM ' + Result;
end;

function TAnsiSQLGenerator.GetForeignKeyName(Command: TCreateForeignKeyCommand): string;
begin
  Result := 'FK_';

  if Command.FromTable.Schema <> '' then
    Result := Result + Command.FromTable.Schema + '_';

  Result := Result + Command.FromTable.Name + '_';

  if Command.ToTable.Schema <> '' then
    Result := Result + Command.ToTable.Schema + '_';

  Result := Result + Command.ToTable.Name + '_' +
    TUtils.ConcatStrings(Command.FromFields, '_');

  Result := Copy(Result, 1, GetMaxConstraintNameLength);
end;

function TAnsiSQLGenerator.GetFullTableName(ATable: TSQLTable): string;
begin
  Result := '';
  if ATable.Schema <> '' then
    Result := Result + ATable.Schema + '.';
  Result := Result + ATable.Name;
end;

function TAnsiSQLGenerator.GenerateGetLastInsertId(SQLField: TSQLField): string;
begin
  raise EAutoGeneratedValuesNotSupported.Create(Self);
end;

function TAnsiSQLGenerator.GenerateGetNextSequenceValue(
  Command: TGetNextSequenceValueCommand): string;
begin
  raise ESequencesNotSupported.Create(Self);
end;

function TAnsiSQLGenerator.GenerateGroupByClause(Fields: TList<TSQLField>;
  ACustomStatement: string): string;
var
  groupByClause: string;
  groupByFields: TList<string>;
begin
  if (Fields.Count = 0) and (ACustomStatement = '') then
    Exit('');

  groupByClause := '';
  if Fields.Count > 0 then
  begin
    groupByFields := GetFieldNames(Fields, True);
    try
      groupByClause := groupByClause + TUtils.ConcatStrings(groupByFields);
    finally
      groupByFields.Free;
    end;
  end;

  if ACustomStatement <> '' then
  begin
    if groupByClause <> '' then
      groupByClause := groupByClause + ', '#13#10;
    groupByClause := groupByClause + ' ' + ACustomStatement;
  end;

  Result := 'GROUP BY ' + groupByClause;
end;

function TAnsiSQLGenerator.GenerateHavingClause(
  ACustomStatement: string): string;
begin
  if (ACustomStatement = '') then
    Exit('');

  Result := 'HAVING ' + ACustomStatement;
end;

function TAnsiSQLGenerator.GenerateInsert(Command: TInsertCommand): string;
var
  FieldNames: TList<string>;
  I: Integer;
begin
  Assert(Command.InsertFields.Count > 0);

  FieldNames := GetFieldNames(Command.InsertFields, False);
  try
    Result := 'INSERT INTO ';

    Result := Result + GetFullTableName(Command.Table) + ' ('#13#10'  ' +
      TUtils.ConcatStrings(FieldNames) + ')'#13#10'VALUES ('#13#10'  ';

    for I := 0 to Command.InsertFields.Count - 1 do
    begin
      if I > 0 then
        Result := Result + ', ';

      Result := Result + ':' + GetDefaultParamName(Command.InsertFields[I]);
    end;

    Result := Result + ');';
  finally
    FieldNames.Free;
  end;
end;

function TAnsiSQLGenerator.GenerateLimitedSelect(SelectSql: TSelectSql; Command: TSelectCommand): string;
begin
  raise ELimitsNotSupported.Create(Self);
end;

function TAnsiSQLGenerator.GenerateOrderByClause(Fields: TList<TSQLOrderField>;
  ACustomStatement: string): string;
var
  orderByClause: string;
  I: integer;
begin
  if (Fields.Count = 0) and (ACustomStatement = '') then
    Exit('');

  orderByClause := '';
  if Fields.Count > 0 then
  begin
    for I := 0 to Fields.Count - 1 do
    begin
      if I > 0 then
        orderByClause := orderByClause + ', ';

      orderByClause := orderByClause + Fields[I].Table.Alias + '.' + Fields[I].Field;

      case Fields[I].Direction of
        TOrderDirection.Ascendant:  orderByClause := orderByClause + ' ASC';
        TOrderDirection.Descendant: orderByClause := orderByClause + ' DESC';
      end;
    end;
  end;

  if ACustomStatement <> '' then
  begin
    if orderByClause <> '' then
      orderByClause := orderByClause + ', '#13#10;
    orderByClause := orderByClause + ' ' + ACustomStatement;
  end;

  Result := 'ORDER BY ' + orderByClause;
end;

function TAnsiSQLGenerator.GeneratePrimaryKey(APkName: string;
  AFields: TList<string>): string;
begin
  Result := APkName + ' PRIMARY KEY (';
  Result := Result + TUtils.ConcatStrings(AFields, ', ');
  Result := Result + ')';
end;

function TAnsiSQLGenerator.GenerateRegularSelect(SelectSql: TSelectSql): string;
begin
  Result := SelectSql.SelectClause +
    #13#10 + SelectSql.FromClause;
  if SelectSql.WhereClause <> '' then
    Result := Result + #13#10 + SelectSql.WhereClause;
  if SelectSql.GroupClause <> '' then
    Result := Result + #13#10 + SelectSql.GroupClause;
  if SelectSql.HavingClause <> '' then
    Result := Result + #13#10 + SelectSql.HavingClause;
  if SelectSql.OrderClause <> '' then
    Result := Result + #13#10 + SelectSql.OrderClause;
end;

function TAnsiSQLGenerator.GenerateSelect(Command: TSelectCommand): string;
var
  SelectSql: TSelectSql;
begin
  SelectSql := TSelectSql.Create;
  try
    SelectSql.SelectClause := GenerateSelectClause(Command.SelectFields, Command.SelectStatement);
    SelectSql.FromClause := GenerateFromClause(Command);
    SelectSql.WhereClause := GenerateWhereClause(Command.WhereFields, True, Command.WhereStatement);
    SelectSql.GroupClause := GenerateGroupByClause(Command.GroupByFields, Command.GroupByStatement);
    SelectSql.HavingClause := GenerateHavingClause(Command.HavingStatement);
    SelectSql.OrderClause := GenerateOrderByClause(Command.OrderByFields, Command.OrderByStatement);

  if (Command.HasLimits) then
    Result := GenerateLimitedSelect(SelectSql, Command)
  else
    Result := GenerateRegularSelect(SelectSql);
  finally
    SelectSql.Free;
  end;
end;

function TAnsiSQLGenerator.GenerateUniqueKeyDefinition(Command: TCreateUniqueKeyCommand): string;
begin
  Result := GetUniqueKeyName(Command) + ' UNIQUE (' +
    TUtils.ConcatStrings(Command.Fields, ', ') + ')';
end;

function TAnsiSQLGenerator.GenerateUpdate(Command: TUpdateCommand): string;
var
  I: Integer;
begin
  Assert(Command.UpdateFields.Count > 0);

  Result := 'UPDATE ';

  Result := Result + GetFullTableName(Command.Table) + ' SET'#13#10'  ';

  for I := 0 to Command.UpdateFields.Count - 1 do
  begin
    if I > 0 then
      Result := Result + ', '#13#10'  ';

    Result := Result + Command.UpdateFields[I].Field + ' = :' +
      GetDefaultParamName(Command.UpdateFields[I]);
  end;

  Result := Result + #13#10 + GenerateWhereClause(Command.WhereFields, False, '');

  Result := Result + ';';
end;

function TAnsiSQLGenerator.GenerateWhereClause(Fields: TList<TSQLWhereField>;
  UseAliases: Boolean; ACustomStatement: string): string;
var
  I: Integer;
  J: integer;
  leftOperand: string;
  rightOperand: string;
  whereClause: string;
  ParamNames: TStrings;
begin
  if (Fields.Count = 0) and (ACustomStatement = '') then
    Exit('');

  whereClause := '';
  for I := 0 to Fields.Count - 1 do
  begin
    if not (Fields[I].WhereOperator in GetSupportedWhereOperators) then
      raise EUnsupportedWhereOperator.Create(
        Self, Fields[I].WhereOperator);

    if I > 0 then
      whereClause := whereClause + #13#10'  AND ';

    leftOperand := '';
    if UseAliases then
      leftOperand := leftOperand + Fields[I].Table.Alias + '.';
    leftOperand := leftOperand + Fields[I].Field;

    rightOperand := '';
    if not (Fields[I].WhereOperator in [TWhereOperator.woIsNull, TWhereOperator.woIsNotNull]) then
    begin
      case Fields[I].WhereOperator of
        TWhereOperator.woIn:
          begin
            ParamNames := TStringList.Create;
            try
              ExtractStrings([',', ';'], [' '], PChar(Fields[I].ParamName), ParamNames);
              for J := 0 to ParamNames.Count - 1 do
              begin
                if J > 0 then
                  rightOperand := rightOperand + ', ';
                rightOperand := rightOperand + ':' + ParamNames[J];
              end;
              rightOperand := '(' + rightOperand + ')';
            finally
              ParamNames.Free;
            end;
          end
      else
//        woEqual, woDifferent, woGreater, woLess, woGreaterOrEqual,
//        woLessOrEqual, woLike, woIsNull, woIsNotNull:
        rightOperand := rightOperand + ':' + Fields[I].ParamName;
      end;
      rightOperand := ' ' + rightOperand;
    end;

    whereClause := whereClause + Format('%s %s%s',
      [leftOperand,
       WhereOperatorToSQL(Fields[I].WhereOperator),
       rightOperand]);
  end;

  Result := 'WHERE ' + whereClause;
  if ACustomStatement <> '' then
  begin
    if whereClause <> '' then
      Result := Result + #13#10' AND';
    Result := Result + ' ' + ACustomStatement;
  end;
end;

function TAnsiSQLGenerator.GetEquivalentFieldTypes: TFieldTypeEquivArray;
begin
  SetLength(Result, 2);

  Result[0].NotSupportedType := ftBoolean;
  Result[0].EquivalentType := ftFixedChar;
  Result[0].EquivalentLenth := 1;

  Result[1].NotSupportedType := ftGuid;
  Result[1].EquivalentType := ftFixedChar;
  Result[1].EquivalentLenth := 38;
end;

function TAnsiSQLGenerator.GetFieldNames(Fields: TList<TSQLField>; IncludeAliases: Boolean): TList<string>;
var
  I: Integer;
begin
  Result := TList<string>.Create;

  if IncludeAliases then
  begin
    for I := 0 to Fields.Count - 1 do
      Result.Add(Fields[I].Table.Alias + '.' + Fields[I].Field);
  end
  else
  begin
    for I := 0 to Fields.Count - 1 do
      Result.Add(Fields[I].Field);
  end;
end;

function TAnsiSQLGenerator.GetGeneratorName: string;
begin
  Result := 'ANSI SQL Generator';
end;

function TAnsiSQLGenerator.GetMaxConstraintNameLength: Integer;
begin
  Result := 50; // I dont't know what is the correct value in ANSI, so 50 is nice. ;)
end;

function TAnsiSQLGenerator.GetQualifiedColumnName(
  Field: TSQLSelectField): string;
begin
  if not (Field.AggregateFuntion in GetSupportedAggregateFunctions) then
    raise EUnsupportedAggregateFunction.Create(
      Self, Field.AggregateFuntion);

  Result := '';
  if Field.IsAggregated then
  begin
    Result := Result + AggregateFunctionToSQL(Field.AggregateFuntion) +
      '(' + Field.Table.Alias + '.' + Field.Field + ')';
  end
  else
  begin
    Result := Result + Field.Table.Alias + '.' + Field.Field;
  end;
end;

function TAnsiSQLGenerator.GenerateSelectClause(Fields: TList<TSQLSelectField>;
  ACustomStatement: string): string;
var
  I: Integer;
  QualifiedField: string;
begin
  Assert((Fields.Count > 0) or (ACustomStatement <> ''));

  Result := 'SELECT ';

  for I := 0 to Fields.Count - 1 do
  begin

    if I > 0 then
      Result := Result + ', ';

    QualifiedField := GetQualifiedColumnName(Fields[I]);

    Result := Result + QualifiedField + ' AS ' + GetDefaultColumnName(Fields[I]);
  end;

  if ACustomStatement <> '' then
  begin
    if Fields.Count > 0 then
      Result := Result + ', ';
    Result := Result + ACustomStatement;
  end;
end;

function TAnsiSQLGenerator.GetSqlLiteral(AValue: Variant;
  AType: TFieldType): string;
var
  FmtSettings: TFormatSettings;
begin
  case AType of
    ftString, ftFixedChar, ftWideString, ftFmtMemo,
    ftMemo, ftFixedWideChar, ftWideMemo:
      Result := Format('''%s''', [VarToStr(AValue)]);

    ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc,
    ftLongWord, ftShortint, ftByte:
      Result := Format('%s', [IntToStr(Integer(AValue))]);

    ftBoolean:
      if Boolean(AValue) then
        result := 'True'
      else
        result := 'False';

    ftFloat, ftCurrency, ftBCD, ftExtended, ftSingle:
      begin
        {$IFDEF DELPHIXE_LVL}
        FmtSettings := TFormatSettings.Create;
        {$ELSE}
        GetLocaleFormatSettings(0, FmtSettings);
        {$ENDIF}
        FmtSettings.DecimalSeparator := '.';
        Result := FloatToStr(AValue, FmtSettings);
      end;

    ftDate:
      Result := Format('DATE ''%s''',
        [FormatDateTime('yyyy-mm-dd ', VarToDateTime(AValue))]);
    ftTime:
      Result := Format('TIME ''%s''',
        [FormatDateTime('hh:nn:ss', VarToDateTime(AValue))]);
    ftDateTime,ftTimeStamp:
      Result := Format('TIMESTAMP ''%s''',
        [FormatDateTime('yyyy-mm-dd hh:nn:ss', VarToDateTime(AValue))]);
  else
//    ftGuid:
//    ftUnknown, ftBytes, ftVarBytes, ftBlob, ftGraphic,
//    ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
//    ftADT, ftArray, ftReference, ftDataSet, ftOraBlob,
//    ftOraClob, ftVariant, ftInterface, ftIDispatch,
//    ftFMTBcd, ftOraTimeStamp, ftOraInterval, ftConnection,
//    ftParams, ftStream, ftTimeStampOffset, ftObject
    raise EUnsupportedLiteralType.Create(AType);
  end;
end;

function TAnsiSQLGenerator.GetSupportedAggregateFunctions: TAggregateFunctionSet;
begin
  Result := [TAggregateFunction.Count, TAggregateFunction.Sum, TAggregateFunction.Average,
    TAggregateFunction.Max, TAggregateFunction.Min];
end;

function TAnsiSQLGenerator.GetSupportedFieldTypes: TFieldTypeSet;
begin
  // ftBoolean was removed so no boolean by default
  Result := [
//    ftByte,
//    ftShortint,
    ftSmallint,
//    ftWord,
    ftInteger,
//    ftLongWord,
    ftLargeint,
    ftString,
    ftWideString,
    ftFixedChar,
//    ftFixedWideChar,
    ftMemo,
    ftWideMemo,
    ftDate,
    ftTime,
    ftDateTime,
    ftFloat,
//    ftSingle,
//    ftExtended,
    ftCurrency,
//    ftFMTBcd,
    ftBlob
    ];
end;

function TAnsiSQLGenerator.GetSupportedWhereOperators: TWhereOperationSet;
begin
  Result := [TWhereOperator.woEqual, TWhereOperator.woDifferent, TWhereOperator.woGreater, TWhereOperator.woLess, TWhereOperator.woGreaterOrEqual,
    TWhereOperator.woLessOrEqual, TWhereOperator.woLike, TWhereOperator.woIsNull, TWhereOperator.woIsNotNull, TWhereOperator.woIn];
end;

function TAnsiSQLGenerator.GetUniqueKeyName(
  Command: TCreateUniqueKeyCommand): string;
var
  I, Hash: integer;
  Comparer: IEqualityComparer<string>;
begin
  Result := 'UK_';

  Comparer := TEqualityComparer<string>.Default;
  Hash := Comparer.GetHashCode(Command.Table.Name);
  for I := 0 to Command.Fields.Count - 1 do
    Hash := Hash xor Comparer.GetHashCode(Command.Fields[I]);

  Result := Result + IntToHex(Hash, 8) + '_';

  if Command.Table.Schema <> '' then
    Result := Result + Command.Table.Schema + '_';
  Result := Result + Command.Table.Name;
  Result := Copy(Result, 1, GetMaxConstraintNameLength);
end;

function TAnsiSQLGenerator.InternalGenerateDropField(Command: TDropFieldCommand;
  AUseColumnWord: boolean): string;
var
  columnWord: string;
begin
  Result := 'ALTER TABLE ';

  columnWord := '';
  if AUseColumnWord then
    columnWord := 'COLUMN ';

  Result := Format(
    'ALTER TABLE %s ' + #13#10 +
    '  DROP %s%s;',
    [GetFullTableName(Command.Table),
     columnWord,
     Command.FieldName]);
end;

function TAnsiSQLGenerator.NumericTypeToSQL(
  FieldDef: TSQLFieldDefinition): string;
begin
  Result := '';
  if (FieldDef.Precision > 0) then
  begin
    if FieldDef.FieldType in [ftByte, ftShortint, ftSmallint, ftWord, ftInteger, ftLongWord, ftLargeint] then
      Exit(Format('NUMERIC(%s)', [IntToStr(FieldDef.Precision)]))
    else
    if FieldDef.FieldType in [ftFloat, ftSingle, ftExtended, ftCurrency{, ftFMTBcd}] then
      Exit(Format('NUMERIC(%s,%s)', [IntToStr(FieldDef.Precision), IntToStr(FieldDef.Scale)]));
  end;
end;

function TAnsiSQLGenerator.WhereOperatorToSQL(
  WhereOperator: TWhereOperator): string;
begin
  case WhereOperator of
    TWhereOperator.woEqual:          Result := '=';
    TWhereOperator.woDifferent:      Result := '<>';
    TWhereOperator.woGreater:        Result := '>';
    TWhereOperator.woLess:           Result := '<';
    TWhereOperator.woGreaterOrEqual: Result := '>=';
    TWhereOperator.woLessOrEqual:    Result := '<=';
    TWhereOperator.woLike:           Result := 'LIKE';
    TWhereOperator.woIsNull:         Result := 'IS NULL';
    TWhereOperator.woIsNotNull:      Result := 'IS NOT NULL';
    TWhereOperator.woIn:             Result := 'IN';
  else
    raise EUnexpectedWhereOperator.Create(WhereOperator);
  end;
end;

function TAnsiSQLGenerator.AggregateFunctionToSQL(
  AggregateFunction: TAggregateFunction): string;
begin
  case AggregateFunction of
    TAggregateFunction.Count:   Result := 'COUNT';
    TAggregateFunction.Sum:     Result := 'SUM';
    TAggregateFunction.Average: Result := 'AVG';
    TAggregateFunction.Max:     Result := 'MAX';
    TAggregateFunction.Min:     Result := 'MIN';
  else
    raise EUnexpectedAggregateFunction.Create(AggregateFunction);
  end;
end;

function TAnsiSQLGenerator.AllDBFeatures: TDBFeatures;
begin
  Result := [TDBFeature.Sequences, TDBFeature.AutoGenerated,
    TDBFeature.AlterTableForeignKey, TDBFeature.UniqueInCreateTable];
end;

function TAnsiSQLGenerator.ConvertValue(Value: Variant; FromType, ToType: TFieldType): Variant;
begin
  if (FromType = ftBoolean) and (ToType = ftFixedChar) then
  begin
    if Value = True then
      Result := 'T' // T = True
    else
      Result := 'F'; // F = False
  end
  else
  if (FromType in [ftFixedChar, ftString, ftWideString]) and (ToType = ftBoolean) then
  begin
    Result := UpperCase(Value) = 'T';
  end
  else
  if (FromType = ftGuid) and (ToType in [ftFixedChar, ftFixedWideChar, ftString, ftWideString]) then
  begin
    Result := GuidToString(TUtils.VariantToGuid(Value));
  end
  else
  if (FromType in [ftFixedChar, ftFixedWideChar, ftString, ftWideString]) and (ToType = ftGuid) then
  begin
    Result := TUtils.GuidToVariant(StringToGUID(Value));
  end
  else
    raise ECannotConvertFieldType.Create(Self, FromType, ToType);
end;

function TAnsiSQLGenerator.FieldTypeToSQL(
  FieldDef: TSQLFieldDefinition): string;
begin
  Result := NumericTypeToSQL(FieldDef);
  if Result <> '' then
    Exit;

  case FieldDef.FieldType of
    ftByte:
      Result := 'SMALLINT';
    ftShortint:
      Result := 'SMALLINT';
    ftSmallint:
      Result := 'SMALLINT';
    ftWord:
      Result := 'SMALLINT';
    ftInteger:
      Result := 'INTEGER';
    ftLongWord:
      Result := 'INTEGER';
    ftLargeint:
      Result := 'NUMERIC(20)';

    ftString:
      Result := Format('VARCHAR(%d)', [FieldDef.Length]);
    ftWideString:
      Result := Format('NVARCHAR(%d)', [FieldDef.Length]);
    ftFixedChar:
      Result := Format('CHAR(%d)', [FieldDef.Length]);
    ftFixedWideChar:
      Result := Format('NCHAR(%d)', [FieldDef.Length]);

    ftDate:
      Result := 'DATE';
    ftTime:
      Result := 'TIME';
    ftDateTime:
      Result := 'TIMESTAMP';

    ftFloat:
      Result := 'DOUBLE PRECISION';
    ftSingle:
      Result := 'REAL';
    ftExtended:
      Result := 'DOUBLE PRECISION';
    ftCurrency:
      Result := 'NUMERIC(20, 4)';
//    ftFMTBcd:
//      Result := 'NUMERIC(20, 10)'; // Arbitrary precision.

//    ftBoolean:
//      Result := 'BIT'; // not supported by all databases
//    ftMemo:
//      Result := ''; // no ansi equivalent
//    ftWideMemo:
//      Result := ''; // no ansi equivalent
//    ftBlob:
//      Result := ''; // no ansi equivalent
  else
    raise EUnsupportedFieldType.Create(Self, FieldDef.FieldType);
  end;
end;

end.


