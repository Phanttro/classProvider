unit Aurelius.Drivers.Interfaces;

{$I Aurelius.inc}

interface

uses
  Generics.Collections, DB;

type
  TDBParam = class
  private
    FParamType: TFieldType;
    FParamName: string;
    FParamValue: Variant;
  public
    property ParamName: string read FParamName write FParamName;
    property ParamType: TFieldType read FParamType write FParamType;
    property ParamValue: Variant read FParamValue write FParamValue;
    constructor Create(PName: string; PType: TFieldType; PValue: Variant);
  end;

  TDBUtils = class
    class function GetValidParamName(AParams: TList<TDBParam>; ABaseName: string = ''): string;
  end;

  IDBResultSet = interface
    ['{AE0D2270-3689-4484-9468-188785FED30A}']
    function Next: Boolean;
    function GetFieldValue(FieldIndex: Integer): Variant; overload;
    function GetFieldValue(FieldName: string): Variant; overload;
  end;

  IDBStatement = interface
    ['{D3BB4DF3-A08C-490C-AF34-7BA154534257}']
    procedure SetSQLCommand(SQLCommand: string);
    procedure SetParams(Params: TEnumerable<TDBParam>);
    procedure Execute;
    function ExecuteQuery: IDBResultSet;
  end;

  IDBTransaction = interface
    ['{698F608A-B5FA-43A5-B6BD-BC510A58804A}']
    procedure Commit;
    procedure Rollback;
  end;

  IDBConnection = interface
    ['{E55D4BCC-63A5-4C76-93C4-3AF77B00F20D}']
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    function CreateStatement: IDBStatement;
    function BeginTransaction: IDBTransaction;
    function SqlDialect: string;
  end;

implementation
uses
  SysUtils;

{ TDBParam }

constructor TDBParam.Create(PName: string; PType: TFieldType;
  PValue: Variant);
begin
  FParamName := PName;
  FParamType := PType;
  FParamValue := PValue;
end;

{ TDBUtils }

class function TDBUtils.GetValidParamName(AParams: TList<TDBParam>; ABaseName: string = ''): string;
var
  param: TDBParam;
  found: boolean;
  i: integer;
begin
  if ABaseName = '' then
    ABaseName := 'p';
  i := AParams.Count; // optimization
  repeat
    Result := Format('%s_%d', [ABaseName, i]);

    // Ensure that the param name is unique in the AParams list
    found := false;
    for param in AParams do
      if SameText(param.ParamName, Result) then
      begin
        found := true;
        inc(i);
        break;
      end;
  until not found;
end;

end.
