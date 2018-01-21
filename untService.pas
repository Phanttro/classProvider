unit untService;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DBClient,
  untFuncoes,
  untBaseGeradora,
  System.Generics.collections;

type
  TService = class(TComponent, IGeradora)
  private
    FPacote: String;
    FTabela: String;
    FTabelaClasse: String;
    FClientDataSet: TClientDataSet;
    FSlGeradora: TStringList;
    FPath: String;
    FTabelasPais : TList<String>;
    FTabelasFilhas: TList<TTabelasFilhas>;
  public
    function getClientDataSet: TClientDataSet;
    function getPacote: String;
    function getPath: String;
    function getSlGeradora: TStringList;
    function getTabela: String;
    function getTabelaClasse: String;
    function getTabelasFilhas: TList<TTabelasFilhas>;
    function getTabelasPais: TList<String>;

    procedure setTabelasFilhas(const Value: TList<TTabelasFilhas>);
    procedure setTabelasPais(const Value: TList<String>);
    procedure setClientDataSet(const Value: TClientDataSet);
    procedure setPacote(const Value: String);
    procedure setPath(const Value: String);
    procedure setSlGeradora(const Value: TStringList);
    procedure setTabela(const Value: String);
    procedure setTabelaClasse(const Value: String);
    procedure gerarArquivo;dynamic;
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    property Pacote: String read getPacote write setPacote;
    property Tabela: String read getTabela write setTabela;
    property TabelaClasse: String read getTabelaClasse write setTabelaClasse;
    property ClientDataSet: TClientDataSet read getClientDataSet write setClientDataSet;
    property SlGeradora: TStringList read getSlGeradora write setSlGeradora;
    property Path: String read getPath write setPath;
  end;


implementation

function TService.getClientDataSet: TClientDataSet;
begin
  Result := FClientDataSet;
end;

function TService.getPacote: String;
begin
  Result := FPacote;
end;

function TService.getPath: String;
begin
  Result := FPath;
end;

function TService.getSlGeradora: TStringList;
begin
  Result := FSlGeradora;
end;

function TService.getTabela: String;
begin
  Result := FTabela;
end;

function TService.getTabelaClasse: String;
begin
  Result := FTabelaClasse;
end;

function TService.getTabelasFilhas: TList<TTabelasFilhas>;
begin
  Result := FTabelasFilhas;
end;

function TService.getTabelasPais: TList<String>;
begin
  if FTabelasPais = nil then
    FTabelasPais := TList<String>.Create;
  Result := FTabelasPais;
end;

procedure TService.setClientDataSet(const Value: TClientDataSet);
begin
  FClientDataSet := Value;
end;

procedure TService.setPacote(const Value: String);
begin
  FPacote := Value;
end;

procedure TService.setPath(const Value: String);
begin
  FPath := Value;
end;

procedure TService.setSlGeradora(const Value: TStringList);
begin
  FSlGeradora := Value;
end;

procedure TService.setTabela(const Value: String);
begin
  FTabela := Value;
end;

procedure TService.setTabelaClasse(const Value: String);
begin
  FTabelaClasse := Value;
end;

procedure TService.setTabelasFilhas(const Value: TList<TTabelasFilhas>);
begin
  FTabelasFilhas := Value;
end;

procedure TService.setTabelasPais(const Value: TList<String>);
begin
  FTabelasPais := Value;
end;

constructor TService.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSlGeradora := TStringList.Create;
end;

destructor TService.Destroy;
begin
  FreeAndNil(FSlGeradora);
  if FTabelasPais <> nil then
    FreeAndNil(FTabelasPais);

  inherited;
end;

procedure TService.gerarArquivo;
var
  I: Integer;
begin
  inherited;
  FTabelaClasse := StringReplace(TFunc.PrimeiraLetraMaiscula(FTabela), '_', '', [rfReplaceAll,rfIgnoreCase]);

  FSlGeradora.Add('package ' + FPacote + '.service;');
  FSlGeradora.Add('');

  ClientDataSet.Locate('COLUMN_KEY', 'PRI', []);
  FSlGeradora.Add('');


  FSlGeradora.Add('import java.io.Serializable;');
  FSlGeradora.Add('');
  FSlGeradora.Add('import javax.inject.Inject;');
  FSlGeradora.Add('');
  FSlGeradora.Add('import ' + FPacote + '.model.' + FTabelaClasse + ';');
  FSlGeradora.Add('import ' + FPacote + '.repository.' + FTabelaClasse + 'Repository;');
  FSlGeradora.Add('');
  FSlGeradora.Add('public class Cadastro' + FTabelaClasse + 'Service implements Serializable {');
  FSlGeradora.Add('');
  FSlGeradora.Add('	private static final long serialVersionUID = 1L;');
  FSlGeradora.Add('');
  FSlGeradora.Add('	@Inject');
  FSlGeradora.Add('	private ' + FTabelaClasse + 'Repository ' + LowerCase(FTabelaClasse) + 'Repository;');
  FSlGeradora.Add('');
  FSlGeradora.Add('	public ' + FTabelaClasse + ' salvar(' + FTabelaClasse + ' ' + LowerCase(FTabelaClasse) + ') {');

  if Assigned(FTabelasFilhas) then begin
    for I := 0 to FTabelasFilhas.Count - 1 do begin
      FSlGeradora.Add('		if(!' + LowerCase(FTabelaClasse) + '.get' + TFunc.PrimeiraLetraMaiscula(FTabelasFilhas[i].Nome) +'s().isEmpty()){');
      FSlGeradora.Add('			for(int i = 0; i < ' + LowerCase(FTabelaClasse) + '.get' + TFunc.PrimeiraLetraMaiscula(FTabelasFilhas[i].Nome) +'s().size(); i++){');
      FSlGeradora.Add('				' + LowerCase(FTabelaClasse) + '.get' + TFunc.PrimeiraLetraMaiscula(FTabelasFilhas[i].Nome) +'s().get(i).set' + FTabelaClasse + '(' + LowerCase(FTabelaClasse) + ');');
      FSlGeradora.Add('			}');
      FSlGeradora.Add('		}');
    end;
  end;


  FSlGeradora.Add('		' + FTabelaClasse + ' ' + LowerCase(FTabelaClasse) + 'Existente = ' + LowerCase(FTabelaClasse) + 'Repository.porId(' + LowerCase(FTabelaClasse) + '.get'+  TFunc.PrimeiraLetraMaiscula(ClientDataSet.FieldByName('COLUMN_NAME').AsString) + '());');
  FSlGeradora.Add('');
  FSlGeradora.Add('		if (' + LowerCase(FTabelaClasse) + 'Existente != null && !' + LowerCase(FTabelaClasse) + 'Existente.equals(' + LowerCase(FTabelaClasse) + ')) {');
  FSlGeradora.Add('			throw new NegocioException("Já existe um ' + LowerCase(FTabelaClasse) + ' com o código informado.");');
  FSlGeradora.Add('		}');
  FSlGeradora.Add('');
  FSlGeradora.Add('		return ' + LowerCase(FTabelaClasse) + 'Repository.guardar(' + LowerCase(FTabelaClasse) + ');');
  FSlGeradora.Add('	}');
  FSlGeradora.Add('');
  FSlGeradora.Add('}');
  CreateDir(FPath +'\service');
  FSlGeradora.SaveToFile(FPath +'\service\Cadastro'+FTabelaClasse+'Service.java');
end;

end.





