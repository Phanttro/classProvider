unit untPrincipal;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  Vcl.DBGrids,
  Datasnap.DBClient,
  Datasnap.Provider,
  FireDAC.Comp.Client,
  FireDAC.Phys.MySQL,
  FireDAC.Comp.UI,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.CheckLst,
  Vcl.ExtCtrls,
  DataModule,
  vcl.themes,
  System.IniFiles,
  System.Generics.Collections,
  untModel,
  untRepository,
  untConverter,
  untService,
  untCadastroBean,
  untXHTML,
  untBaseGeradora,
  untPesquisa,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  Vcl.ImgList,
  FireDAC.Phys,
  Vcl.ToolWin,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.VCLUI.Wait,
  Vcl.Grids,
  FireDAC.Comp.DataSet, FireDAC.Phys.MySQLDef, sSkinManager, Vcl.Buttons,
  sSpeedButton, sPanel, acPageScroller, sPageControl, acAlphaImageList,
  untFuncoes,
  Vcl.Graphics,
  Generics.Collections;


type
  TfrmPrincipal = class(TForm)
    qryDados: TFDQuery;
    dspBases: TDataSetProvider;
    cdsDados: TClientDataSet;
    dsBases: TDataSource;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    ImageList: TImageList;
    qryTabelas: TFDQuery;
    pgPrincipal: TPageControl;
    tsPrincipal: TTabSheet;
    tsConfiguracoes: TTabSheet;
    Panel1: TPanel;
    chkListTab: TCheckListBox;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    edtPacote: TEdit;
    Panel4: TPanel;
    edtPath: TEdit;
    Panel5: TPanel;
    Label1: TLabel;
    Panel6: TPanel;
    cbSkin: TComboBox;
    Panel7: TPanel;
    Label2: TLabel;
    Panel2: TPanel;
    lblPacote: TLabel;
    Panel8: TPanel;
    pnTabFilhas: TPanel;
    lbOrigem: TListBox;
    lbDestino: TListBox;
    gbMetaDados: TGroupBox;
    DBGrid1: TDBGrid;
    Splitter: TSplitter;
    SplitterTabFilhas: TSplitter;
    Panel9: TPanel;
    Memo1: TMemo;
    ImageList32: TsAlphaImageList;
    pcCadastro: TsPageControl;
    sTabSheet1: TsTabSheet;
    sPageScroller: TsPageScroller;
    PanelToolButtons: TsPanel;
    sSpeedButton12: TsSpeedButton;
    btnFechar: TsSpeedButton;
    btnSalvar: TsSpeedButton;
    sSpeedButton3: TsSpeedButton;
    sPanel6: TsPanel;
    sSkinManager1: TsSkinManager;
    sSpeedButton1: TsSpeedButton;
    btnMarcarTodos: TsSpeedButton;
    cdsDadosIS_NULLABLE: TStringField;
    cdsDadosDATA_TYPE: TStringField;
    cdsDadosCHAR_LENGTH: TStringField;
    cdsDadosCOLUMN_KEY: TStringField;
    cdsDadosNOME_FORMULARIO: TStringField;
    cdsDadosMOEDA: TStringField;
    cdsDadosAPARECER_NA_PESQUISA: TStringField;
    cdsDadosAPARECER_NA_GRID: TStringField;
    cdsDadosTABLE_NAME: TStringField;
    cdsDadosOCULTAR: TStringField;
    cdsDadosCHECK_BOX: TStringField;
    cdsDadosCOLUMN_NAME: TStringField;
    cdsDadosCOLUMN_ID: TStringField;
    cdsDadosTAMANHO_COLUNA: TStringField;
    cdsDadosCOMBO_BOX: TStringField;
    cdsDadosFB: TClientDataSet;
    dbpFB: TDataSetProvider;
    qryTabelasFB: TFDQuery;
    qryDadosFB: TFDQuery;
    cdsDadosFBOCULTAR: TStringField;
    cdsDadosFBCHECK_BOX: TStringField;
    cdsDadosFBCOMBO_BOX: TStringField;
    cdsDadosFBTABLE_NAME: TWideStringField;
    cdsDadosFBMOEDA: TStringField;
    cdsDadosFBAPARECER_NA_PESQUISA: TStringField;
    cdsDadosFBAPARECER_NA_GRID: TStringField;
    cdsDadosFBCOLUMN_KEY: TStringField;
    cdsDadosFBTAMANHO_COLUNA: TStringField;
    cdsDadosFBCOLUMN_ID: TSmallintField;
    cdsDadosFBCOLUMN_NAME: TWideStringField;
    cdsDadosFBNOME_FORMULARIO: TWideStringField;
    cdsDadosFBCHAR_LENGTH: TSmallintField;
    cdsDadosFBDATA_TYPE: TStringField;
    cdsDadosFBIS_NULLABLE: TStringField;
    cdsDadosFBFIELD_CHARSET: TWideStringField;
    cdsDadosFBFIELD_COLLATION: TWideStringField;
    cdsDadosFBFIELD_DEFAULT: TMemoField;
    cdsDadosFBFIELD_CHECK: TMemoField;
    cdsDadosFBFIELD_DESCRIPTION: TMemoField;
    cdsDadosFBCAMPO_PESQUISA: TStringField;
    cdsDadosFBKEY_DESCRIPTION: TStringField;
    cdsDadosFBCAMPO_PRINCIPAL: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure cbSkinChange(Sender: TObject);
    procedure chkListTabClick(Sender: TObject);
    procedure edtPacoteExit(Sender: TObject);
    procedure lbDestinoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbDestinoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sSpeedButton1Click(Sender: TObject);
    procedure btnMarcarTodosClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure cdsDadosFBCAMPO_PESQUISAChange(Sender: TField);
  private
    FCampo: String;
    indexAtual: Integer;
    FfrmPrincipal: TfrmPrincipal;
    ListaForm: TDictionary<String, TfrmPrincipal>;
    mapTabelasFilhas: TDictionary<String, TList<TTabelasFilhas>>;
    procedure salvarConf;
    procedure FiltrarDados(AIndex: Integer = -1);
    procedure AjustarDadosFK;
    procedure Gerar;
    procedure processoOracle;
    procedure processoFireBird;
    { Private declarations }
  public
    property Campo: String read FCampo write FCampo;
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;
  StartingPoint : TPoint;

implementation

{$R *.dfm}

procedure TfrmPrincipal.salvarConf;
var
  IniFile: TMemIniFile;
begin

  if not FileExists(ExtractFilePath(Application.ExeName) + 'ConfigGeradorHangar31.ini') then
    Exit;
  try
    IniFile := TMemIniFile.Create(ExtractFilePath(Application.ExeName) + 'ConfigGeradorHangar31.ini');

    IniFile.WriteString('skin', 'nome', cbSkin.Text);
    IniFile.WriteString('confg', 'path', edtPath.Text);
    IniFile.WriteString('confg', 'pacote', edtPacote.Text);

    IniFile.UpdateFile;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TfrmPrincipal.sSpeedButton1Click(Sender: TObject);
begin
  with TFileOpenDialog.Create(nil) do
    try
      Title := 'Select Directory';
      Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
      OkButtonLabel := 'Select';
      if Execute then
        edtPath.Text := FileName;
    finally
      Free;
    end;
  salvarConf;
end;

procedure TfrmPrincipal.btnMarcarTodosClick(Sender: TObject);
begin
  if btnMarcarTodos.Caption = 'Marcar Todos' then begin
    chkListTab.CheckAll(cbChecked);
    btnMarcarTodos.Caption := 'Desmarcar';
  end else begin
    chkListTab.CheckAll(cbUnchecked);
    btnMarcarTodos.Caption := 'Marcar Todos';
  end;
end;

procedure TfrmPrincipal.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
begin
  Gerar;
end;

procedure TfrmPrincipal.cbSkinChange(Sender: TObject);
begin
  try
    TStyleManager.TrySetStyle(cbSkin.Text);
    salvarConf;
  except

  end;
end;

procedure TfrmPrincipal.cdsDadosFBCAMPO_PESQUISAChange(Sender: TField);
var
  s: string;
begin
  s := sender.AsString;
end;

procedure TfrmPrincipal.chkListTabClick(Sender: TObject);
begin
  FiltrarDados;
  AjustarDadosFK;
  indexAtual := chkListTab.ItemIndex;
end;

procedure TfrmPrincipal.DBGrid1DblClick(Sender: TObject);
var
  campoPesquisa: Boolean;
begin
  if (TFunc.Base = FeatBase.ftFireBird) then begin
    campoPesquisa := cdsDadosFBCAMPO_PESQUISA.Value = 'S';
  end;

  if (ListaForm = nil) then begin
    ListaForm := TDictionary<String, TfrmPrincipal>.Create;
  end;

  if (campoPesquisa) then begin
    if not (ListaForm.ContainsKey(cdsDadosFBCOLUMN_NAME.AsString)) then
      FfrmPrincipal := TfrmPrincipal.Create(Self)
    else
      FfrmPrincipal := ListaForm.Items[cdsDadosFBCOLUMN_NAME.AsString];

    if (TFunc.Base = FeatBase.ftFireBird) then
      FfrmPrincipal.Campo := cdsDadosFBCOLUMN_NAME.AsString;
    if not (ListaForm.ContainsKey(cdsDadosFBCOLUMN_NAME.AsString)) then
      ListaForm.Add(cdsDadosFBCOLUMN_NAME.AsString, FfrmPrincipal);
    FfrmPrincipal.ShowModal;
  end;
end;

procedure TfrmPrincipal.AjustarDadosFK;
var
  I: Integer;
  tabelaFilha : TTabelasFilhas;
  listaTabelasFilhas: TList<TTabelasFilhas>;
  key: String;
begin
  if (lbDestino.Count > 0) or (mapTabelasFilhas.Count > 0) then begin
    listaTabelasFilhas:= TList<TTabelasFilhas>.Create;
    for I := 0 to lbDestino.Count - 1 do begin
      tabelaFilha := TTabelasFilhas.Create(Self);
      tabelaFilha.Nome := lbDestino.Items[i];
      listaTabelasFilhas.Add(tabelaFilha);
    end;
    mapTabelasFilhas.AddOrSetValue(chkListTab.Items[indexAtual], listaTabelasFilhas);
    lbDestino.Clear;

    listaTabelasFilhas:= TList<TTabelasFilhas>.Create;
    mapTabelasFilhas.TryGetValue(chkListTab.Items[chkListTab.ItemIndex], listaTabelasFilhas);
    if Assigned(listaTabelasFilhas) then
      for I := 0 to listaTabelasFilhas.Count - 1 do begin
        lbDestino.Items.Add(TTabelasFilhas(listaTabelasFilhas.Items[i]).Nome);
      end;
  end;
end;

procedure TfrmPrincipal.edtPacoteExit(Sender: TObject);
begin
  salvarConf;
end;

procedure TfrmPrincipal.FiltrarDados(AIndex: Integer);
begin
  if (TFunc.Base = FeatBase.ftFireBird) then begin
    cdsDadosfb.Filtered := False;
    if AIndex = -1 then
      cdsDadosfb.Filter := 'TABLE_NAME = ' + QuotedStr(chkListTab.Items[chkListTab.ItemIndex]) + ' AND OCULTAR = ''N'''
    else
      cdsDadosfb.Filter := 'TABLE_NAME = ' + QuotedStr(chkListTab.Items[AIndex]) + ' AND OCULTAR = ''N''';

    dsBases.DataSet := cdsDadosfb;
    cdsdadosfb.Filtered := True;
    cdsDadosfb.Active := True;
  end else begin
    cdsDados.Filtered := False;
    if AIndex = -1 then
      cdsDados.Filter := 'TABLE_NAME = ' + QuotedStr(chkListTab.Items[chkListTab.ItemIndex]) + ' AND OCULTAR = ''N'''
    else
      cdsDados.Filter := 'TABLE_NAME = ' + QuotedStr(chkListTab.Items[AIndex]) + ' AND OCULTAR = ''N''';
    dsBases.DataSet := cdsDados;
    cdsdados.Filtered := True;
    cdsDados.Active := True;
  end;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(mapTabelasFilhas);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  IniFile: TMemIniFile;
  skin:String;

begin
  if not FileExists(ExtractFilePath(Application.ExeName) + 'ConfigGeradorHangar31.ini') then
    Exit;

  IniFile := TMemIniFile.Create(ExtractFilePath(Application.ExeName) + 'ConfigGeradorHangar31.ini');

  edtPath.Text         := LowerCase(IniFile.ReadString('confg', 'path', ''));
  edtPacote.Text       := LowerCase(IniFile.ReadString('confg', 'pacote', ''));
  DMPrincipal.PassWord := LowerCase(IniFile.ReadString('confg', 'senha', ''));
  DMPrincipal.DataBase := LowerCase(IniFile.ReadString('confg', 'database', ''));
  DMPrincipal.UserName := LowerCase(IniFile.ReadString('confg', 'username', ''));
  DMPrincipal.DriverID := LowerCase(IniFile.ReadString('confg', 'driverid', ''));
  DMPrincipal.Server   := LowerCase(IniFile.ReadString('confg', 'server', ''));

  if (DMPrincipal.DriverID = 'fb') then
    TFunc.Base := FeatBase.ftFireBird
  else
    TFunc.Base := untFuncoes.FeatBase.ftOracle;


  try
    skin := LowerCase(IniFile.ReadString('skin', 'nome', ''));
    TStyleManager.TrySetStyle(skin);
    cbSkin.ItemIndex := cbSkin.Items.IndexOf(skin);
  except
    TStyleManager.TrySetStyle('Amakrits');
  end;

  DMPrincipal.OpenConnection;

  if (TFunc.Base = FeatBase.ftFireBird) then begin
    processoFireBird;
    dsBases.DataSet := cdsDadosfb;
  end else begin
    processoOracle;
    dsBases.DataSet := cdsDados;
  end;



  pgPrincipal.ActivePage := tsPrincipal;
  mapTabelasFilhas := TDictionary<String, TList<TTabelasFilhas>>.Create;
end;

procedure TfrmPrincipal.processoOracle;
begin
  qryTabelas.Close;
  qryTabelas.ParamByName('OWNER').AsString := DMPrincipal.UserName;
  qryTabelas.Active := True;

  qryTabelas.First;
  while not qryTabelas.Eof do begin
    lbOrigem.Items.Add(qryTabelas.FieldByName('TABLE_NAME').AsString);
    chkListTab.Items.Add(qryTabelas.FieldByName('TABLE_NAME').AsString);
    qryTabelas.Next;
  end;

  qryDados.Close;
  qryDados.Active := True;

  cdsDados.Active   := False;
  cdsDados.Filtered := False;
  cdsDados.Filter   := 'TABLE_NAME = ' + QuotedStr(chkListTab.Items[0]); //+ ' AND OCULTAR = ''N''';

  cdsdados.Filtered := True;
  cdsDados.Active   := True;
  dsBases.DataSet := cdsDados;
end;

procedure TfrmPrincipal.processoFireBird;
begin
  qryTabelasfb.Close;
  qryTabelasfb.Active := True;

  qryTabelasfb.First;
  while not qryTabelasfb.Eof do begin
    lbOrigem.Items.Add(qryTabelasfb.FieldByName('TABLE_NAME').AsString);
    chkListTab.Items.Add(qryTabelasfb.FieldByName('TABLE_NAME').AsString);
    qryTabelasfb.Next;
  end;

  qryDadosfb.Close;
  qryDadosfb.Active := True;


  cdsDadosfb.Active   := False;
  cdsDadosfb.Filtered := False;
  cdsDadosfb.Filter   := 'TABLE_NAME = ' + QuotedStr(chkListTab.Items[0]); //+ ' AND OCULTAR = ''N''';

  cdsdadosfb.Filtered := True;
  cdsDadosfb.Active   := True;
  dsBases.DataSet := cdsDadosfb;
end;


procedure TfrmPrincipal.lbDestinoDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  Item : String;
  PosDrop : Integer;
begin
  if Source <> Sender then begin
    with (Source as TListbox) do begin
      Item := Items[ItemIndex];
      Items.Delete(ItemIndex);
    end;
    (Sender as TListBox).Items.Add(Item);
  end
  else
    with (Sender as TListbox) do begin
      PosDrop := ItemAtPos(Point(X,Y),True);
      if PosDrop < 0  then
        PosDrop := Items.Count-1;
      Items.Move(ItemIndex,PosDrop);
      ItemIndex := PosDrop;
    end;

end;

procedure TfrmPrincipal.lbDestinoDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TListBox);
end;

procedure TfrmPrincipal.Gerar;
var
  i: Integer;
  bChecado: Boolean;
  killer: TModel;
  bean: TCadastroBean;
  listaTabelasFilhas: TList<TTabelasFilhas>;
  filtroComum: String;
  procedure GerarArquivo(AClass: IGeradora);
  var key: String;
      j: Integer;
  begin
    AClass.Tabela := chkListTab.Items[i];

    if (TFunc.Base = FeatBase.ftOracle) then begin
      cdsDados.Filtered := False;
      cdsDados.Filter   := filtroComum;
      cdsdados.Filtered := True;
    end;



    if mapTabelasFilhas.count > 0 then
       if mapTabelasFilhas.TryGetValue(chkListTab.Items[i], listaTabelasFilhas) then
         AClass.setTabelasFilhas(listaTabelasFilhas);

    for key in mapTabelasFilhas.Keys do begin
      mapTabelasFilhas.TryGetValue(key, listaTabelasFilhas);
      if listaTabelasFilhas <> nil then
        for j := 0 to listaTabelasFilhas.Count - 1 do begin
          if listaTabelasFilhas[j] <> nil then
            if listaTabelasFilhas[j].Nome = AClass.Tabela then begin
              AClass.getTabelasPais.Add(key);
            end;
        end;
    end;


    AClass.Pacote        := edtPacote.Text;
    if (TFunc.Base = FeatBase.ftOracle) then begin
      AClass.ClientDataSet := cdsDados
    end else begin
      AClass.ClientDataSet := cdsDadosFB;
    end;
    AClass.Path          := edtPath.Text;
    AClass.gerarArquivo;
  end;

begin

  killer := TModel.Create(nil);
  bChecado := False;
  for i := 0 to chkListTab.Count - 1 do begin
    if chkListTab.Checked[i] then begin
      bChecado := True;
      Break;
    end;
  end;

  if not bChecado then begin
    Application.MessageBox(PWideChar('Favor selecione alguma tabela!'), 'Atenção');
    Exit;
  end;


  AjustarDadosFK;

  if edtPacote.Text = EmptyStr then begin
    Application.MessageBox(PWideChar('Favor informar o pacote!'), 'Atenção');
    Exit;
  end;

  bean := TCadastroBean.Create(killer);
  bean.ListaFormBean := TDictionary<String, TObject>(ListaForm);

  for i := 0 to chkListTab.Items.Count - 1 do begin
    if chkListTab.Checked[i] then begin
      FiltrarDados(i);
      filtroComum := cdsDados.Filter;
      GerarArquivo(TModel.Create(killer));
      GerarArquivo(bean);
    end;
  end;
  MessageDlg('Processo finalizado com sucesso!', mtInformation, [mbOK], 0);
  FreeAndNil(killer);
end;

end.
