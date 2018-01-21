unit untRepository;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DBClient,
  untFuncoes,
  untBaseGeradora,
  System.Generics.collections;

type
  TRepository = class(TComponent, IGeradora)
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


{ TRepository }

constructor TRepository.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSlGeradora := TStringList.Create;
end;

destructor TRepository.Destroy;
begin
  FreeAndNil(FSlGeradora);
  if FTabelasPais <> nil then
    FreeAndNil(FTabelasPais);

  inherited;
end;

procedure TRepository.gerarArquivo;
begin
  inherited;
  FTabelaClasse := StringReplace(TFunc.PrimeiraLetraMaiscula(FTabela), '_', '', [rfReplaceAll,rfIgnoreCase]);

  FSlGeradora.Add('package ' + FPacote + '.repository;');
  FSlGeradora.Add('');

  ClientDataSet.Locate('COLUMN_KEY', 'PRI', []);
  FSlGeradora.Add('import java.io.Serializable;');
  FSlGeradora.Add('import java.util.List;');
  FSlGeradora.Add('');
  FSlGeradora.Add('import javax.inject.Inject;');
  FSlGeradora.Add('import javax.persistence.EntityManager;');
  FSlGeradora.Add('import javax.persistence.NoResultException;');
  FSlGeradora.Add('import javax.persistence.PersistenceException;');
  FSlGeradora.Add('');
  FSlGeradora.Add('import org.hibernate.Criteria;');
  FSlGeradora.Add('import org.hibernate.Session;');
  FSlGeradora.Add('import org.hibernate.criterion.MatchMode;');
  FSlGeradora.Add('import org.hibernate.criterion.Order;');
  FSlGeradora.Add('import ' + FPacote + '.repository.filter.*;');
  FSlGeradora.Add('import org.hibernate.criterion.Restrictions;');
  FSlGeradora.Add('import javax.persistence.EntityTransaction;');
  FSlGeradora.Add('import org.apache.commons.lang3.StringUtils;');
  FSlGeradora.Add('');
  FSlGeradora.Add('import ' + FPacote + '.model.'+ FTabelaClasse + ';');

  FSlGeradora.Add('import ' + FPacote + '.service.NegocioException;');
  FSlGeradora.Add('');
  FSlGeradora.Add('public class '+ FTabelaClasse + 'Repository implements Serializable {');
  FSlGeradora.Add('');
  FSlGeradora.Add('	private static final long serialVersionUID = 1L;');
  FSlGeradora.Add('');
  FSlGeradora.Add('	@Inject');
  FSlGeradora.Add('	private EntityManager manager;');
  FSlGeradora.Add(' 	private EntityTransaction trx;');

  FSlGeradora.Add('	public '+ FTabelaClasse + ' guardar('+ FTabelaClasse + ' '+ LowerCase(FTabelaClasse) + ') {');
  FSlGeradora.Add('	    '+ FTabelaClasse + ' ' + Copy(LowerCase(FTabelaClasse),1,2) + ';');
  if Assigned(FTabelasFilhas) then
    if FTabelasFilhas.Count > 0 then
      FSlGeradora.Add('	    getEntityTransaction().begin();');

  FSlGeradora.Add('	    '+ Copy(LowerCase(FTabelaClasse), 1, 2) +' = manager.merge('+ LowerCase(FTabelaClasse) + ');');

  if Assigned(FTabelasFilhas) then
    if FTabelasFilhas.Count > 0 then
      FSlGeradora.Add('	    getEntityTransaction().commit();');

  FSlGeradora.Add('	    return '+ Copy(LowerCase(FTabelaClasse), 1, 2) +';');
  FSlGeradora.Add('	}');
  FSlGeradora.Add('');
  FSlGeradora.Add('	public void remover('+ FTabelaClasse + ' '+ LowerCase(FTabelaClasse) + ') {');
  FSlGeradora.Add('		try {');
  FSlGeradora.Add('			'+ LowerCase(FTabelaClasse) + ' = porId('+ LowerCase(FTabelaClasse) + '.getId());');
  if Assigned(FTabelasFilhas) then
    if FTabelasFilhas.Count > 0 then
      FSlGeradora.Add('			getEntityTransaction().begin();');
  FSlGeradora.Add('			manager.remove('+ LowerCase(FTabelaClasse) + ');');

  if Assigned(FTabelasFilhas) then
    if FTabelasFilhas.Count > 0 then
      FSlGeradora.Add('			getEntityTransaction().commit();');

  FSlGeradora.Add('		} catch (PersistenceException e) {');
  FSlGeradora.Add('			throw new NegocioException("'+ FTabelaClasse + ' não pode ser excluído.");');
  FSlGeradora.Add('		}');
  FSlGeradora.Add('	}');
  FSlGeradora.Add('');


  FSlGeradora.Add('	public '+ FTabelaClasse + ' porId(Long id) {');
  FSlGeradora.Add('		return manager.find('+ FTabelaClasse + '.class, id);');
  FSlGeradora.Add('	}');

  FSlGeradora.Add('');
  FSlGeradora.Add('  	private EntityTransaction getEntityTransaction(){');
  FSlGeradora.Add('		if(trx != null)');
  FSlGeradora.Add('		    trx = null;');
  FSlGeradora.Add('	   trx = manager.getTransaction();');
  FSlGeradora.Add('');
  FSlGeradora.Add('		return trx;');
  FSlGeradora.Add('	}');
  FSlGeradora.Add('');
  FSlGeradora.Add('	@SuppressWarnings("unchecked")');
  FSlGeradora.Add('	public List<'+ FTabelaClasse + '> filtrados('+ FTabelaClasse + 'Filter filtro) {');
  FSlGeradora.Add('		Session session = manager.unwrap(Session.class);');
  FSlGeradora.Add('		Criteria criteria = session.createCriteria('+ FTabelaClasse + '.class);');
  FSlGeradora.Add('');

  FClientDataSet.First;
  while not FClientDataSet.Eof do
  begin
    if FClientDataSet.FieldByName('APARECER_NA_PESQUISA').AsString = 'S'  then begin
      FSlGeradora.Add('		if (StringUtils.isNotBlank(filtro.get' +  TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '())) {');
      FSlGeradora.Add('			criteria.add(Restrictions.ilike("'+FClientDataSet.FieldByName('COLUMN_NAME').AsString+'", filtro.get' +  TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '(), MatchMode.ANYWHERE));');
      FSlGeradora.Add('		}');
      FSlGeradora.Add('');
    end;
    FClientDataSet.Next;
  end;
  FSlGeradora.Add('		return criteria.list();');
  FSlGeradora.Add('	}');
  FSlGeradora.Add('}');


  CreateDir(FPath +'\repository');
  FSlGeradora.SaveToFile(FPath +'\repository\'+FTabelaClasse+'Repository.java');
end;


function TRepository.getClientDataSet: TClientDataSet;
begin
  Result := FClientDataSet;
end;

function TRepository.getPacote: String;
begin
  Result := FPacote;
end;

function TRepository.getPath: String;
begin
  Result := FPath;
end;

function TRepository.getSlGeradora: TStringList;
begin
  Result := FSlGeradora;
end;

function TRepository.getTabela: String;
begin
  Result := FTabela;
end;

function TRepository.getTabelaClasse: String;
begin
  Result := FTabelaClasse;
end;

function TRepository.getTabelasFilhas: TList<TTabelasFilhas>;
begin
  Result := FTabelasFilhas;
end;

function TRepository.getTabelasPais: TList<String>;
begin
  if FTabelasPais = nil then
    FTabelasPais := TList<String>.Create;
  Result := FTabelasPais;
end;

procedure TRepository.setClientDataSet(const Value: TClientDataSet);
begin
  FClientDataSet := Value;
end;

procedure TRepository.setPacote(const Value: String);
begin
  FPacote := Value;
end;

procedure TRepository.setPath(const Value: String);
begin
  FPath := Value;
end;

procedure TRepository.setSlGeradora(const Value: TStringList);
begin
  FSlGeradora := Value;
end;

procedure TRepository.setTabela(const Value: String);
begin
  FTabela := Value;
end;

procedure TRepository.setTabelaClasse(const Value: String);
begin
  FTabelaClasse := Value;
end;

procedure TRepository.setTabelasFilhas(const Value: TList<TTabelasFilhas>);
begin
  FTabelasFilhas := Value;
end;

procedure TRepository.setTabelasPais(const Value: TList<String>);
begin
  FTabelasPais := Value;
end;

end.






