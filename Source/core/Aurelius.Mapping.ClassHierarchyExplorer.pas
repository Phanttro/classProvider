unit Aurelius.Mapping.ClassHierarchyExplorer;

{$I Aurelius.inc}

interface

uses
  Generics.Collections;

type
  TClassHierarchyExplorer = class
  private
    class var FInstance: TClassHierarchyExplorer;
  private
    FDirectSubClasses: TDictionary<TClass, TList<TClass>>;
    FAllSubClasses: TDictionary<TClass, TList<TClass>>;

    function FindSubClasses(Clazz: TClass): TList<TClass>;

    procedure PrivateCreate;
    procedure PrivateDestroy;
  public
    class function GetInstance: TClassHierarchyExplorer;

    // TODO: Improve to get only concrete classes
    function GetDirectSubClasses(Clazz: TClass): TEnumerable<TClass>;
    function GetAllSubClasses(Clazz: TClass): TEnumerable<TClass>;
  end;

implementation

uses
  Rtti,
  Aurelius.Mapping.MappedClasses,
  Aurelius.Mapping.Exceptions;

{ TClassHierarchyExplorer }

procedure TClassHierarchyExplorer.PrivateCreate;
var
  C: TClass;
begin
  FDirectSubClasses := TObjectDictionary<TClass, TList<TClass>>.Create([doOwnsValues]);
  FAllSubClasses := TObjectDictionary<TClass, TList<TClass>>.Create([doOwnsValues]);

  // Load direct classes lists
  for C in TMappedClasses.GetInstance.Classes do
    FDirectSubClasses.Add(C, TList<TClass>.Create);

  for C in TMappedClasses.GetInstance.Classes do
    if FDirectSubClasses.ContainsKey(C.ClassParent) then
      FDirectSubClasses[C.ClassParent].Add(C);

  // Load all classes list
  for C in TMappedClasses.GetInstance.Classes do
    FAllSubClasses.Add(C, FindSubClasses(C));
end;

procedure TClassHierarchyExplorer.PrivateDestroy;
begin
  FDirectSubClasses.Free;
  FAllSubClasses.Free;
end;

class function TClassHierarchyExplorer.GetInstance: TClassHierarchyExplorer;
begin
  if FInstance = nil then
  begin
    FInstance := TClassHierarchyExplorer.Create;
    FInstance.PrivateCreate;
  end;

  Result := FInstance;
end;

function TClassHierarchyExplorer.FindSubClasses(Clazz: TClass): TList<TClass>;
var
  C: TClass;
  SubClassesList: TList<TClass>;
begin
  Result := TList<TClass>.Create;

  Result.AddRange(GetDirectSubClasses(Clazz));

  for C in GetDirectSubClasses(Clazz) do
  begin
    SubClassesList := FindSubClasses(C);
    try
      Result.AddRange(SubClassesList);
    finally
      SubClassesList.Free;
    end;
  end;
end;

function TClassHierarchyExplorer.GetAllSubClasses(
  Clazz: TClass): TEnumerable<TClass>;
begin
  if not FAllSubClasses.ContainsKey(Clazz) then
    EClassNotRegistered.Create(Clazz);

  Result := FAllSubClasses[Clazz];
end;

function TClassHierarchyExplorer.GetDirectSubClasses(
  Clazz: TClass): TEnumerable<TClass>;
begin
  if not FDirectSubClasses.ContainsKey(Clazz) then
    EClassNotRegistered.Create(Clazz);

  Result := FDirectSubClasses[Clazz];
end;

initialization

finalization
  if TClassHierarchyExplorer.FInstance <> nil then
  begin
    TClassHierarchyExplorer.FInstance.PrivateDestroy;
    TClassHierarchyExplorer.FInstance.Free;
    TClassHierarchyExplorer.FInstance := nil;
  end;

end.
