unit Aurelius.Engine.DatabaseManager;

{$I Aurelius.inc}

interface

uses
  Generics.Defaults,
  Generics.Collections,
  Aurelius.Engine.AbstractManager,
  Aurelius.Mapping.MappedClasses,
  Aurelius.Sql.Commands;

type
  TDatabaseManager = class(TAbstractManager)
  private
    procedure ProcessBuildCommands(Commands: TList<TDDLCommand>);
    procedure ProcessDestroyCommands(Commands: TList<TDDLCommand>);
    function GetCommandSQL(Command: TDDLCommand): string;
    procedure ExecuteCommands(Commands: TList<TDDLCommand>; IgnoreErrors: boolean);
    function GetBuildDatabaseCommands: TList<TDDLCommand>;
    function GetDestroyDatabaseCommands: TList<TDDLCommand>;
  public
    procedure BuildDatabase;
    procedure DestroyDatabase;
  end;

implementation

uses
  Aurelius.Commands.AbstractCommandPerformer,
  Aurelius.Commands.ForeignKeyCreator,
  Aurelius.Commands.TableCreator,
  Aurelius.Commands.SequenceCreator,
  Aurelius.Engine.Exceptions,
  Aurelius.Sql.BaseTypes,
  Aurelius.Sql.Interfaces;

{ TDatabaseManager }

procedure TDatabaseManager.BuildDatabase;
var
  Commands: TList<TDDLCommand>;
begin
  Commands := GetBuildDatabaseCommands;
  try
    ExecuteCommands(Commands, False);
  finally
    Commands.Free;
  end;
end;

procedure TDatabaseManager.DestroyDatabase;
var
  Commands: TList<TDDLCommand>;
begin
  Commands := GetDestroyDatabaseCommands;
  try
    ProcessDestroyCommands(Commands);
    ExecuteCommands(Commands, True);
  finally
    Commands.Free;
  end;
end;

procedure TDatabaseManager.ExecuteCommands(Commands: TList<TDDLCommand>; IgnoreErrors: boolean);
var
  Command: TDDLCommand;
  SQL: string;
  SQLPerformer: TSQLPerformer;
begin
  for Command in Commands do
  begin
    SQL := GetCommandSQL(Command);
    SQLPerformer := FCommandFactory.GetCommand<TSQLPerformer>(TObject);
    try
      try
        SQLPerformer.ExecuteSQL(SQL);
      except
        if not IgnoreErrors then
          raise;
      end;
    finally
      SQLPerformer.Free;
    end;
  end;
end;

function TDatabaseManager.GetBuildDatabaseCommands: TList<TDDLCommand>;
var
  C: TClass;
  TableCreator: TTableCreator;
  FKCreator: TForeignKeyCreator;
  SequenceCreator: TSequenceCreator;
  Commands: TObjectList<TDDLCommand>;
begin
  Commands := TObjectList<TDDLCommand>.Create(true);
  try
    for C in TMappedClasses.GetInstance.Classes do
    begin
      if Explorer.HasTable(C) then
      begin
        TableCreator := FCommandFactory.GetCommand<TTableCreator>(C);
        try
          TableCreator.CreateTable(Commands);
        finally
          TableCreator.Free;
        end;
      end;
    end;

    for C in TMappedClasses.GetInstance.Classes do
    begin
      if Explorer.HasTable(C) then
      begin
        FKCreator := FCommandFactory.GetCommand<TForeignKeyCreator>(C);
        try
          FKCreator.CreateForeignKeys(Commands);
        finally
          FKCreator.Free;
        end;
      end;
    end;

    for C in TMappedClasses.GetInstance.Classes do
    begin
      if Explorer.HasSequence(C, False) then
      begin
        SequenceCreator := FCommandFactory.GetCommand<TSequenceCreator>(C);
        try
          SequenceCreator.CreateSequence(Commands);
        finally
          SequenceCreator.Free;
        end;
      end;
    end;

    ProcessBuildCommands(Commands);
    Result := Commands;
  except
    Commands.Free;
    raise;
  end;
end;

function TDatabaseManager.GetCommandSQL(Command: TDDLCommand): string;
var
  SQL: string;
begin
  if Command is TDropForeignKeyCommand then
    SQL := SQLGenerator.GenerateDropForeignKey(TDropForeignKeyCommand(Command))
  else
  if Command is TCreateTableCommand then
    SQL := SQLGenerator.GenerateCreateTable(TCreateTableCommand(Command))
  else
  if Command is TCreateSequenceCommand then
    SQL := SQLGenerator.GenerateCreateSequence(TCreateSequenceCommand(Command))
  else
  if Command is TCreateForeignKeyCommand then
    SQL := SQLGenerator.GenerateCreateForeignKey(TCreateForeignKeyCommand(Command))
  else
  if Command is TCreateFieldCommand then
    SQL := SQLGenerator.GenerateCreateField(TCreateFieldCommand(Command))
  else
  if Command is TDropTableCommand then
    SQL := SQLGenerator.GenerateDropTable(TDropTableCommand(Command))
  else
  if Command is TDropSequenceCommand then
    SQL := SQLGenerator.GenerateDropSequence(TDropSequenceCommand(Command))
  else
  if Command is TDropFieldCommand then
    SQL := SQLGenerator.GenerateDropField(TDropFieldCommand(Command))
  else
  if Command is TEnableForeignKeysCommand then
    SQL := SQLGenerator.GenerateEnableForeignKeys(TEnableForeignKeysCommand(Command))
  else
  if Command is TCreateUniqueKeyCommand then
    SQL := SQLGenerator.GenerateCreateUniqueKey(TCreateUniqueKeyCommand(Command))
  else
    raise EEngineInternalError.Create('Command is not a known DDL Command.');
  Result := SQL;
end;

function TDatabaseManager.GetDestroyDatabaseCommands: TList<TDDLCommand>;
var
  C: TClass;
  TableCreator: TTableCreator;
  FKCreator: TForeignKeyCreator;
  SequenceCreator: TSequenceCreator;
  Commands: TObjectList<TDDLCommand>;
begin
  Commands := TObjectList<TDDLCommand>.Create(true);
  try
    for C in TMappedClasses.GetInstance.Classes do
    begin
      if Explorer.HasTable(C) then
      begin
        FKCreator := FCommandFactory.GetCommand<TForeignKeyCreator>(C);
        try
          FKCreator.DropForeignKeys(Commands);
        finally
          FKCreator.Free;
        end;
      end;
    end;

    for C in TMappedClasses.GetInstance.Classes do
    begin
      if Explorer.HasTable(C) then
      begin
        TableCreator := FCommandFactory.GetCommand<TTableCreator>(C);
        try
          try
            TableCreator.DropTable(Commands);
          except
          end;
        finally
          TableCreator.Free;
        end;
      end;
    end;

    for C in TMappedClasses.GetInstance.Classes do
    begin
      if Explorer.HasSequence(C, False) then
      begin
        SequenceCreator := FCommandFactory.GetCommand<TSequenceCreator>(C);
        try
          try
            SequenceCreator.DropSequence(Commands);
          except
          end;
        finally
          SequenceCreator.Free;
        end;
      end;
    end;

    Result := Commands;
  except
    Commands.Free;
    raise;
  end;
end;

procedure TDatabaseManager.ProcessBuildCommands(Commands: TList<TDDLCommand>);
var
  Tables: TDictionary<string, TCreateTableCommand>;
  I: Integer;
  J: Integer;
  Key: string;
  TableCmd: TCreateTableCommand;
  FieldCmd: TCreateFieldCommand;
  ForeignCmd: TCreateForeignKeyCommand;
begin
  // Build a dictionary of the create table statements
  Tables := TDictionary<string, TCreateTableCommand>.Create;
  try
    I := 0;
    while I < Commands.Count do
    begin
      if Commands[I] is TCreateTableCommand then
      begin
        Key := SQLGenerator.GetFullTableName(TCreateTableCommand(Commands[I]).Table);
        if not Tables.ContainsKey(Key) then
          Tables.Add(Key, TCreateTableCommand(Commands[I]))
        else
          raise EEngineInternalError.Create('Duplicated Create Table statements when building database');
        Commands.Extract(Commands[I]);
      end else
        Inc(I);
    end;

    // Merge create field statements into the create table statements
    I := 0;
    while I < Commands.Count do
    begin
      if Commands[I] is TCreateFieldCommand then
      begin
        FieldCmd := TCreateFieldCommand(Commands[I]);
        Key := SQLGenerator.GetFullTableName(FieldCmd.Table);
        if Tables.ContainsKey(Key) then
        begin
          TableCmd := Tables[Key];
          TableCmd.Fields.Add(FieldCmd.Field.Clone);
          Commands.Delete(I);
        end
        else
          raise EEngineInternalError.Create('No previous Create Table found to merge Create Field statement');
      end else
        Inc(I);
    end;

    // Merge foreign key statements into the create table statements.
    // For now only SQLite requires that, because it doesn't have alter table command
    // For all other databases, we should stick to alter table, because we might have circular references in foreign keys,
    // so all tables must be created before we start creating the foreign keys.
    // SQLite doesn't have this problem, since it allows creating table with foreign keys to a tables that don't exist yet
    if not (TDBFeature.AlterTableForeignKey in SQLGenerator.SupportedFeatures) then
    begin
      I := 0;
      while I < Commands.Count do
      begin
        if Commands[I] is TCreateForeignKeyCommand then
        begin
          ForeignCmd := TCreateForeignKeyCommand(Commands[I]);
          Key := SQLGenerator.GetFullTableName(ForeignCmd.FromTable);
          if Tables.ContainsKey(Key) then
          begin
            TableCmd := Tables[Key];
            TableCmd.ForeignKeys.Add(ForeignCmd);
            Commands.Extract(ForeignCmd);
          end
          else
            raise EEngineInternalError.Create('No previous Create Table found to merge Foreign Key statement');
        end else
          Inc(I);
      end;
    end;

    // Now reinsert the create table commands in the beginning of commands list
    for TableCmd in Tables.Values do
      Commands.Insert(0, TableCmd);

    // If the database does not support unique keys in create table, then
    // iterate again through the create table commands and extract the unique keys
    // We will create it in separated commands.
    if not (TDBFeature.UniqueInCreateTable in SQLGenerator.SupportedFeatures) then
    begin
      I := 0;
      while I < Commands.Count do
      begin
        if Commands[I] is TCreateTableCommand then
        begin
          TableCmd := TCreateTableCommand(Commands[I]);
          J := 0;
          while J < TableCmd.UniqueConstraints.Count do
          begin
            // Add unique key as separated command
            Commands.Add(TableCmd.UniqueConstraints[J]);
            // Remove it from table command
            TableCmd.UniqueConstraints.Extract(TableCmd.UniqueConstraints[J]);
          end;
        end;
        Inc(I);
      end;
    end;

    // Sort the commands by dependency - create table statements come first than any other
    Commands.Sort(TComparer<TDDLCommand>.Construct(
      function (const Left, Right: TDDLCommand): integer
      var
        IsLeftTable, IsRightTable: boolean;
      begin
        IsLeftTable := Left is TCreateTableCommand;
        IsRightTable := Right is TCreateTableCommand;
        if IsLeftTable and not IsRightTable then
          Result := -1
        else
        if IsRightTable and not IsLeftTable then
          Result := 1
        else
          Result := 0;
      end
      )
    );
  finally
    Tables.Free;
  end;
end;

procedure TDatabaseManager.ProcessDestroyCommands(Commands: TList<TDDLCommand>);
var
  I: Integer;
begin
  // Remove drop foreign key statements if needed
  if not (TDBFeature.AlterTableForeignKey in SQLGenerator.SupportedFeatures) then
  begin
    I := 0;
    while I < Commands.Count do
    begin
      if Commands[I] is TDropForeignKeyCommand then
        Commands.Delete(I)
      else
        Inc(I);
    end;
  end;

  // Remove drop field statements - table is going to be dropped anyway
  I := 0;
  while I < Commands.Count do
  begin
    if Commands[I] is TDropFieldCommand then
      Commands.Delete(I)
    else
      Inc(I);
  end;

  // If there is no drop foreign key support in database, then we should add disable/enable foreign key commands
  if not (TDBFeature.AlterTableForeignKey in SQLGenerator.SupportedFeatures) then
  begin
    Commands.Insert(0, TEnableForeignKeysCommand.Create(false));
    Commands.Add(TEnableForeignKeysCommand.Create(true));
  end;
end;

end.
