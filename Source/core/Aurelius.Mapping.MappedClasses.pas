unit Aurelius.Mapping.MappedClasses;

{$I Aurelius.inc}

interface

uses
  Rtti, Generics.Collections;

type
  TMappedClasses = class
  private
    class var FInstance: TMappedClasses;
  private
    FRegisteredClasses: TList<TClass>;
    FClassesSearched: Boolean;
    procedure AutoSearchClasses;
    function GetClasses: TEnumerable<TClass>;
    procedure PrivateCreate;
    procedure PrivateDestroy;
  protected
    procedure GetEntityClasses(AList: TList<TClass>);
    procedure Refresh;
  public
    class function GetInstance: TMappedClasses;
    procedure RegisterClass(Clazz: TClass);
    procedure UnregisterClass(Clazz: TClass);
    function FindByName(ClassName: string): TClass;
    property Classes: TEnumerable<TClass> read GetClasses;
  end;

implementation
uses
  SysUtils,
  Aurelius.Global.Config,
  Aurelius.Mapping.Attributes;

{ TMappedClasses }

procedure TMappedClasses.Refresh;
begin
  if TGlobalConfigs.GetInstance.AutoSearchMappedClasses then
    AutoSearchClasses;
end;

procedure TMappedClasses.RegisterClass(Clazz: TClass);
begin
  if not FRegisteredClasses.Contains(Clazz) then
    FRegisteredClasses.Add(Clazz);
end;

procedure TMappedClasses.AutoSearchClasses;
var
  EntityClassList: TList<TClass>;
  EntityClass: TClass;
begin
  EntityClassList := TList<TClass>.Create;
  try
    GetEntityClasses(EntityClassList);
    for EntityClass in EntityClassList do
      RegisterClass(EntityClass);
  finally
    EntityClassList.Free;
  end;
end;

procedure TMappedClasses.UnregisterClass(Clazz: TClass);
begin
  FRegisteredClasses.Remove(Clazz);
end;

function TMappedClasses.FindByName(ClassName: string): TClass;
begin
  for Result in Classes do
    if SameText(Result.ClassName, ClassName) then
      Exit;
  Result := nil;
end;

function TMappedClasses.GetClasses: TEnumerable<TClass>;
begin
  if not FClassesSearched then
  begin
    Refresh;
    FClassesSearched := true;
  end;
  Result := FRegisteredClasses;
end;

procedure TMappedClasses.GetEntityClasses(AList: TList<TClass>);
var
  Context: TRttiContext;
  AllTypes: TArray<TRttiType>;
  T: TRttiType;
  A: TCustomAttribute;
begin
  Context := TRttiContext.Create;
  try
    AllTypes := Context.GetTypes;
    for T in AllTypes do
      if T.IsInstance then
        for A in T.GetAttributes do
          if A is Entity then
            AList.Add(T.AsInstance.MetaclassType);
  finally
    Context.Free;
  end;
end;

class function TMappedClasses.GetInstance: TMappedClasses;
begin
  if FInstance = nil then
  begin
    FInstance := TMappedClasses.Create;
    FInstance.PrivateCreate;
  end;
  Result := FInstance;
end;

procedure TMappedClasses.PrivateCreate;
begin
  FRegisteredClasses := TList<TClass>.Create;
end;

procedure TMappedClasses.PrivateDestroy;
begin
  FRegisteredClasses.Free;
end;

initialization

finalization
  if TMappedClasses.FInstance <> nil then
  begin
    TMappedClasses.FInstance.PrivateDestroy;
    TMappedClasses.FInstance.Free;
    TMappedClasses.FInstance := nil;
  end;

end.
