unit Aurelius.Commands.Exceptions;

{$I Aurelius.inc}

interface

uses
  Aurelius.Global.Exceptions;

type
  ESelectAlreadyOpen = class(EOPFBaseException)
  public
    constructor Create;
  end;

  ESelectNotOpen = class(EOPFBaseException)
    constructor Create;
  end;

implementation

{ ESelectAlreadyOpen }

constructor ESelectAlreadyOpen.Create;
begin
  inherited Create('Cannot start selecting objects. A select operation has been already started.');
end;

{ ESelectNotOpen }

constructor ESelectNotOpen.Create;
begin
  inherited Create('Cannot fetch object. A select operation has not been started.');
end;

end.
