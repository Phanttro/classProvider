unit DataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DB,
  Data.FMTBcd, Datasnap.Provider, Datasnap.DBClient, Data.Win.ADODB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.Oracle, FireDAC.Phys.OracleDef,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef;

type
  TDMPrincipal = class(TDataModule)
    FDConnection1: TFDConnection;
    SQLConnection: TFDConnection;
  private
    FUserName: String;
    FPassword: String;
    FDatabase: String;
    FServer: String;
    FDriverID: String;

    { Private declarations }
  public
    procedure OpenConnection;

    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property Database: String read FDatabase write FDatabase;
    property DriverID: String read FDriverID write FDriverID;
    property Server: String read FServer write FServer;
    { Public declarations }
  end;

var
  DMPrincipal: TDMPrincipal;

implementation



{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
procedure TDMPrincipal.OpenConnection;
begin
  SQLConnection.Close;
  SQLConnection.Params.Clear;
  SQLConnection.LoginPrompt := False;
  SQLConnection.DriverName := FDriverID;

  with SQLConnection do begin
    Params.Add('Database=' + FDatabase);
    Params.Add('User_Name=' + FUserName);
    Params.Add('Server=' + FServer);
    Params.Add('Password=' + FPassword);
    Params.Add('DriverID=' + FDriverID);
    Connected := True;
  end;
end;
end.
