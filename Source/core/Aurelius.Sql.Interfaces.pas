unit Aurelius.Sql.Interfaces;

{$I Aurelius.inc}

interface

uses
  Generics.Collections, DB,
  Aurelius.Sql.Commands,
  Aurelius.Sql.BaseTypes,
  Aurelius.Drivers.Interfaces;

type
  TFieldTypeSet = set of TFieldType;

  TDBFeature = (Sequences, AutoGenerated, AlterTableForeignKey, UniqueInCreateTable);
  TDBFeatures = set of TDBFeature;

  TFieldTypeEquivalence = record
  public
    NotSupportedType: TFieldType;
    EquivalentType: TFieldType;
    EquivalentLenth: Integer;
    EquivalentPrecision: Integer;
    EquivalentScale: Integer;
  end;

  TFieldTypeEquivArray = array of TFieldTypeEquivalence;

  ISQLGenerator = interface
    ['{8F53DC09-2A7B-4DAF-8430-8AE5B424E210}']

    // Generators
    function GetGeneratorName: string;
    property GeneratorName: string read GetGeneratorName;

    // Mapping to the connection driver
    function GetSqlDialect: string;
    property SqlDialect: string read GetSqlDialect;

    // standard DML methods
    function GenerateSelect(Command: TSelectCommand): string;
    function GenerateInsert(Command: TInsertCommand): string;
    function GenerateUpdate(Command: TUpdateCommand): string;
    function GenerateDelete(Command: TDeleteCommand): string;
    function GetQualifiedColumnName(Field: TSQLSelectField): string;

    // specific DML methods
    function GenerateGetNextSequenceValue(Command: TGetNextSequenceValueCommand): string;
    function GenerateGetLastInsertId(SQLField: TSQLField): string;

    // DDL methods
    function GenerateCreateTable(Command: TCreateTableCommand): string;
    function GenerateCreateForeignKey(Command: TCreateForeignKeyCommand): string;
    function GenerateCreateSequence(Command: TCreateSequenceCommand): string;
    function GenerateCreateUniqueKey(Command: TCreateUniqueKeyCommand): string;
    function GenerateDropTable(Command: TDropTableCommand): string;
    function GenerateDropForeignKey(Command: TDropForeignKeyCommand): string;
    function GenerateDropSequence(Command: TDropSequenceCommand): string;
    function GenerateCreateField(Command: TCreateFieldCommand): string;
    function GenerateDropField(Command: TDropFieldCommand): string;

    // Disable/Enable foreign keys
    function GenerateEnableForeignKeys(Command: TEnableForeignKeysCommand): string;

    // Types/constants methods
    function GetSqlLiteral(AValue: Variant; AType: TFieldType): string;

    // Methods for compatibility between different databases
    function GetSupportedFeatures: TDBFeatures;
    property SupportedFeatures: TDBFeatures read GetSupportedFeatures;

    // Methods for field type/value conversion
    function GetSupportedFieldTypes: TFieldTypeSet;
    property SupportedFieldTypes: TFieldTypeSet read GetSupportedFieldTypes;
    function GetEquivalentFieldTypes: TFieldTypeEquivArray;
    property EquivalentFieldTypes: TFieldTypeEquivArray read GetEquivalentFieldTypes;
    function ConvertValue(Value: Variant; FromType, ToType: TFieldType): Variant;

    // Methods for fields/param naming
    function GetDefaultParamName(Field: TSQLField): string;
    function GetDefaultColumnName(Field: TSQLSelectField): string;

    function GetForeignKeyName(Command: TCreateForeignKeyCommand): string;
    function GetFullTableName(ATable: TSQLTable): string;

    // Function to be called right before each command is executed
    procedure ProcessCommand(var SQL: string);
  end;

  ISQLPerformer = interface
    function Execute(SQL: string; Params: TList<TDBParam>; IsQuery: Boolean): IDBResultSet;
  end;

  ICommandPerformer = interface(ISQLPerformer)
    function CreateSQLTable: TSQLTable;
  end;

implementation

end.