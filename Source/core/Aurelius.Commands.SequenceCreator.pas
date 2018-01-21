unit Aurelius.Commands.SequenceCreator;

{$I Aurelius.inc}

interface

uses
  Generics.Collections,
  Aurelius.Commands.AbstractCommandPerformer,
  Aurelius.Sql.Commands;


type
  TSequenceCreator = class(TAbstractCommandPerformer)
  public
    procedure CreateSequence(ACommands: TList<TDDLCommand>);
    procedure DropSequence(ACommands: TList<TDDLCommand>);
  end;

implementation

uses
  Aurelius.Global.Config,
  Aurelius.Mapping.Metadata,
  Aurelius.Sql.Interfaces;

{ TSequenceCreator }

procedure TSequenceCreator.CreateSequence(ACommands: TList<TDDLCommand>);
var
  Sequence: TSequence;
  Command: TCreateSequenceCommand;
begin
  if not (TDBFeature.Sequences in SQLGenerator.SupportedFeatures) then
    Exit;

  Sequence := Explorer.GetSequence(Self.Clazz, False);

  Command := TCreateSequenceCommand.Create;
  ACommands.Add(Command);
  Command.SequenceName := Sequence.SequenceName;
  Command.InitialValue := Sequence.InitialValue;
  Command.Increment := Sequence.Increment;
end;

procedure TSequenceCreator.DropSequence(ACommands: TList<TDDLCommand>);
var
  Sequence: TSequence;
  Command: TDropSequenceCommand;
begin
  if not (TDBFeature.Sequences in SQLGenerator.SupportedFeatures) then
    Exit;

  Sequence := Explorer.GetSequence(Self.Clazz, False);

  Command := TDropSequenceCommand.Create;
  ACommands.Add(Command);
  Command.SequenceName := Sequence.SequenceName;
end;

end.
