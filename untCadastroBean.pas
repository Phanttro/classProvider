unit untCadastroBean;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DBClient,
  untFuncoes,
  untBaseGeradora,
  System.Generics.collections,
  Math;

type
  TCadastroBean = class(TComponent, IGeradora)
  private
    FPacote: String;
    FTabela: String;
    FTabelaClasse: String;
    FClientDataSet: TClientDataSet;
    FSlGeradora: TStringList;
    FPath: String;
    FTabelasPais : TList<String>;
    FTabelasFilhas: TList<TTabelasFilhas>;
    FTop: Integer;
    function getTop: Integer;
  public
    ListaFormBean: TDictionary<String, TObject>;
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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Pacote: String read getPacote write setPacote;
    property Tabela: String read getTabela write setTabela;
    property TabelaClasse: String read getTabelaClasse write setTabelaClasse;
    property ClientDataSet: TClientDataSet read getClientDataSet write setClientDataSet;
    property SlGeradora: TStringList read getSlGeradora write setSlGeradora;
    property Path: String read getPath write setPath;
    property Top: Integer read getTop write FTop;
  end;

implementation

uses
  untPrincipal;



{ TConverter }

constructor TCadastroBean.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSlGeradora := TStringList.Create;
end;

destructor TCadastroBean.Destroy;
begin
  FreeAndNil(FSlGeradora);

  if FTabelasPais <> nil then
    FreeAndNil(FTabelasPais);

  inherited;
end;

procedure TCadastroBean.gerarArquivo;
var
  i, contObj: Integer;
  slItemUnit: TStringList;
  sFiltro,
  sOrderBy,
  item, prefixo, sufixo: String;
  focus: String;
  frmPrincipal: TfrmPrincipal;
begin
  inherited;

  Top := 0;
  contObj := Math.RandomRange(1, 99);
  slItemUnit := TStringList.Create;
  FTabelaClasse := StringReplace(TFunc.PrimeiraLetraMaiscula(FTabela), '_', '', [rfReplaceAll,rfIgnoreCase]);

  FSlGeradora.Add('inherited frmCad' + FTabelaClasse + ': TfrmCad' + FTabelaClasse + '');
  FSlGeradora.Add('  Caption = ''Cadastro de ' + FTabelaClasse + '''');
  FSlGeradora.Add('  Position = poMainFormCenter');
  FSlGeradora.Add('  ClientHeight = 432');
  FSlGeradora.Add('  ExplicitHeight = 470');
  FSlGeradora.Add('  PixelsPerInch = 96');
  FSlGeradora.Add('  TextHeight = 13');
  FSlGeradora.Add('  inherited pcCadastro: TsPageControl');
  FSlGeradora.Add('    inherited tsPrincipal: TsTabSheet');
  FSlGeradora.Add('      inherited sPageScroller: TsPageScroller');
  FSlGeradora.Add('        inherited PanelToolButtons: TsPanel');
  FSlGeradora.Add('          inherited btnPesquisar: TsSpeedButton');
  FSlGeradora.Add('            OnClick = btnPesquisarClick');
  FSlGeradora.Add('          end');
  FSlGeradora.Add('          inherited btnCancelar: TsSpeedButton');
  FSlGeradora.Add('            Enabled = False');
  FSlGeradora.Add('            OnClick = btnCancelarClick');
  FSlGeradora.Add('            ExplicitLeft = 203');
  FSlGeradora.Add('          end');
  FSlGeradora.Add('          inherited btnSalvar: TsSpeedButton');
  FSlGeradora.Add('            Enabled = False');
  FSlGeradora.Add('            OnClick = btnSalvarClick');
  FSlGeradora.Add('          end');
  FSlGeradora.Add('          inherited btnImprimir: TsSpeedButton');
  FSlGeradora.Add('            Enabled = False');
  FSlGeradora.Add('          end');
  FSlGeradora.Add('          inherited btnExcluir: TsSpeedButton');
  FSlGeradora.Add('            Enabled = False');
  FSlGeradora.Add('            OnClick = btnExcluirClick');
  FSlGeradora.Add('          end');
  FSlGeradora.Add('        end');
  FSlGeradora.Add('      end');
  FSlGeradora.Add('    end');
  FSlGeradora.Add('  end');
  FSlGeradora.Add('  inherited PanelContainer: TsPanel');
  FSlGeradora.Add('    Height = 357');
  FSlGeradora.Add('    ExplicitHeight = 357');
  FSlGeradora.Add('    inherited gbGeral: TsGroupBox');
  FSlGeradora.Add('      Height = 308');
  FSlGeradora.Add('      Margins.Left = 25');
  FSlGeradora.Add('      Caption = ''' + FTabelaClasse + '''');
  FSlGeradora.Add('      ExplicitHeight = 308');

  i := 0;

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if FClientDataSet.FieldByName('OCULTAR').AsString = 'S' then begin
      FClientDataSet.Next;
      Continue;
    end;

    if (FClientDataSet.FieldByName('CAMPO_PESQUISA').AsString = 'S') then begin
      inc(contObj);
      item := IntToStr(contObj);
      slItemUnit.Add('    spnl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsPanel;');
      FSlGeradora.Add('      object spnl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsPanel');
      FSlGeradora.Add('        Left = 19');
      FSlGeradora.Add('        Top = ' + IntToStr(Top));
      FSlGeradora.Add('        Width = 697');
      FSlGeradora.Add('        Height = 28');
      FSlGeradora.Add('        TabOrder = ' + IntToStr(i));
      inc(i);
      slItemUnit.Add('    lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX;');
      FSlGeradora.Add('        object lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX');
      FSlGeradora.Add('          Left = 23');
      FSlGeradora.Add('          Top = 5');
      FSlGeradora.Add('          Width = 37');
      FSlGeradora.Add('          Height = 17');
      FSlGeradora.Add('          Caption = ''' + FClientDataSet.FieldByName('NOME_FORMULARIO').AsString + '''');
      FSlGeradora.Add('          Angle = 0');
      FSlGeradora.Add('          Shadow.OffsetKeeper.LeftTop = -1');
      FSlGeradora.Add('          Shadow.OffsetKeeper.RightBottom = 3');
      FSlGeradora.Add('        end');
      FSlGeradora.Add('      end');
    end else if (Pos('text', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) or (Pos('blob', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0)
       or (Pos('long', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) then begin
      inc(contObj);
      item := IntToStr(contObj);
      slItemUnit.Add('    sPanel' + item + ': TsPanel;');
      FSlGeradora.Add('      object sPanel' + item + ': TsPanel');
      FSlGeradora.Add('        Left = 19');
      FSlGeradora.Add('        Top = ' + IntToStr(Top));
      FTop := FTop + 112;
      FSlGeradora.Add('        Width = 697');
      FSlGeradora.Add('        Height = 140');
      FSlGeradora.Add('        TabOrder = ' + IntToStr(i));
      inc(i);
      slItemUnit.Add('    lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX;');
      FSlGeradora.Add('        object lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX');
      FSlGeradora.Add('          Left = 23');
      FSlGeradora.Add('          Top = 6');
      FSlGeradora.Add('          Width = 62');
      FSlGeradora.Add('          Height = 17');
      FSlGeradora.Add('          Caption = ''' + FClientDataSet.FieldByName('NOME_FORMULARIO').AsString + '''');
      FSlGeradora.Add('          Angle = 0');
      FSlGeradora.Add('          Shadow.OffsetKeeper.LeftTop = -1');
      FSlGeradora.Add('          Shadow.OffsetKeeper.RightBottom = 3');
      FSlGeradora.Add('        end');
      slItemUnit.Add('    mm' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsMemo;');
      FSlGeradora.Add('        object mm' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsMemo');
      FSlGeradora.Add('          Left = 114');
      FSlGeradora.Add('          Top = 4');
      FSlGeradora.Add('          Width = 566');
      FSlGeradora.Add('          Height = 125');
      FSlGeradora.Add('          Color = clWhite');
      FSlGeradora.Add('          Font.Charset = DEFAULT_CHARSET');
      FSlGeradora.Add('          Font.Color = clBlack');
      FSlGeradora.Add('          Font.Height = -11');
      FSlGeradora.Add('          Font.Name = ''Tahoma''');
      FSlGeradora.Add('          Font.Style = []');
      FSlGeradora.Add('          ParentFont = False');
      FSlGeradora.Add('          TabOrder = 0');
      FSlGeradora.Add('        end');
      FSlGeradora.Add('      end');
    end else if (Pos('tring', TFunc.retornaTipo(FClientDataSet.FieldByName('DATA_TYPE').AsString)) > 0) then begin
      inc(contObj);
      item := IntToStr(contObj);

      slItemUnit.Add('    sPanel' + item + ': TsPanel;');
      FSlGeradora.Add('      object sPanel' + item + ': TsPanel');
      FSlGeradora.Add('        Left = 19');
      FSlGeradora.Add('        Top = ' + IntToStr(Top));
      FSlGeradora.Add('        Width = 697');
      FSlGeradora.Add('        Height = 28');
      FSlGeradora.Add('        TabOrder = ' + IntToStr(i));
      inc(i);

      slItemUnit.Add('    lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX;');

      FSlGeradora.Add('        object lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX');
      FSlGeradora.Add('          Left = 23');
      FSlGeradora.Add('          Top = 6');
      FSlGeradora.Add('          Width = 31');
      FSlGeradora.Add('          Height = 17');
      FSlGeradora.Add('          Caption = ''' + FClientDataSet.FieldByName('NOME_FORMULARIO').AsString + '''');
      FSlGeradora.Add('          Angle = 0');
      FSlGeradora.Add('          Shadow.OffsetKeeper.LeftTop = -1');
      FSlGeradora.Add('          Shadow.OffsetKeeper.RightBottom = 3');
      FSlGeradora.Add('        end');

      if (FClientDataSet.FieldByName('CHECK_BOX').AsString = 'S') then begin
        slItemUnit.Add('    chk' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsCheckBox;');
        FSlGeradora.Add('        object chk' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsCheckBox');
        FSlGeradora.Add('          Left = 162');
        FSlGeradora.Add('          Top = 6');
        FSlGeradora.Add('          Width = 20');
        FSlGeradora.Add('          Height = 16');
        FSlGeradora.Add('          TabOrder = 0');
        FSlGeradora.Add('          ImgChecked = 0');
        FSlGeradora.Add('          ImgUnchecked = 0');
        FSlGeradora.Add('        end');
        FSlGeradora.Add('      end');
      end else if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
        slItemUnit.Add('    scb' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsComboBox;');
        FSlGeradora.Add('        object scb' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsComboBox');
        FSlGeradora.Add('          Left = 122');
        FSlGeradora.Add('          Top = 4');
        FSlGeradora.Add('          Width = 194');
        FSlGeradora.Add('          Height = 21');
        FSlGeradora.Add('          Alignment = taLeftJustify');
        FSlGeradora.Add('          VerticalAlignment = taAlignTop');
        FSlGeradora.Add('          Style = csDropDownList');
        FSlGeradora.Add('          Color = clWhite');
        FSlGeradora.Add('          Font.Charset = DEFAULT_CHARSET');
        FSlGeradora.Add('          Font.Color = clBlack');
        FSlGeradora.Add('          Font.Height = -11');
        FSlGeradora.Add('          Font.Name = ''Tahoma''');
        FSlGeradora.Add('          Font.Style = []');
        FSlGeradora.Add('          ItemIndex = -1');
        FSlGeradora.Add('          ParentFont = False');
        FSlGeradora.Add('          TabOrder = 0');
        FSlGeradora.Add('        end');
        FSlGeradora.Add('      end');
      end else begin
        slItemUnit.Add('    edt' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsEdit;');
        FSlGeradora.Add('        object edt' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsEdit');
        FSlGeradora.Add('          Left = 114');
        FSlGeradora.Add('          Top = 4');
        FSlGeradora.Add('          Width = 567');
        FSlGeradora.Add('          Height = 21');
        FSlGeradora.Add('          Color = clWhite');
        FSlGeradora.Add('          Font.Charset = DEFAULT_CHARSET');
        FSlGeradora.Add('          Font.Color = clBlack');
        FSlGeradora.Add('          Font.Height = -11');
        FSlGeradora.Add('          Font.Name = ''Tahoma''');
        FSlGeradora.Add('          Font.Style = []');
        FSlGeradora.Add('          MaxLength = ' + FClientDataSet.FieldByName('CHAR_LENGTH').AsString);
        FSlGeradora.Add('          ParentFont = False');
        FSlGeradora.Add('          TabOrder = 0');
        FSlGeradora.Add('        end');
        FSlGeradora.Add('      end');
      end;
    end else if Pos('dat', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0 then begin
      inc(contObj);
      item := IntToStr(contObj);

      slItemUnit.Add('    sPanel' + item + ': TsPanel;');
      FSlGeradora.Add('      object sPanel' + item + ': TsPanel');
      FSlGeradora.Add('        Left = 19');
      FSlGeradora.Add('        Top = ' + IntToStr(Top));
      FSlGeradora.Add('        Width = 697');
      FSlGeradora.Add('        Height = 28');
      FSlGeradora.Add('        TabOrder = ' + IntToStr(i));
      inc(i);
      slItemUnit.Add('    lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX;');
      FSlGeradora.Add('        object lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX');
      FSlGeradora.Add('          Left = 23');
      FSlGeradora.Add('          Top = 6');
      FSlGeradora.Add('          Width = 85');
      FSlGeradora.Add('          Height = 17');
      FSlGeradora.Add('          Caption = '' ' + FClientDataSet.FieldByName('NOME_FORMULARIO').AsString + ' ''');
      FSlGeradora.Add('          Angle = 0');
      FSlGeradora.Add('          Shadow.OffsetKeeper.LeftTop = -1');
      FSlGeradora.Add('          Shadow.OffsetKeeper.RightBottom = 3');
      FSlGeradora.Add('        end');
      slItemUnit.Add('    dtEdit' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsDateEdit;');
      FSlGeradora.Add('        object dtEdit' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsDateEdit');
      FSlGeradora.Add('          Left = 114');
      FSlGeradora.Add('          Top = 4');
      FSlGeradora.Add('          Width = 86');
      FSlGeradora.Add('          Height = 21');
      FSlGeradora.Add('          AutoSize = False');
      FSlGeradora.Add('          Color = clWhite');
      FSlGeradora.Add('          EditMask = ''!99/99/9999;1; ''');
      FSlGeradora.Add('          Font.Charset = DEFAULT_CHARSET');
      FSlGeradora.Add('          Font.Color = clBlack');
      FSlGeradora.Add('          Font.Height = -11');
      FSlGeradora.Add('          Font.Name = ''Tahoma''');
      FSlGeradora.Add('          Font.Style = []');
      FSlGeradora.Add('          MaxLength = 10');
      FSlGeradora.Add('          ParentFont = False');
      FSlGeradora.Add('          TabOrder = 0');
      FSlGeradora.Add('          Text = ''  /  /    ''');
      FSlGeradora.Add('          GlyphMode.Blend = 0');
      FSlGeradora.Add('          GlyphMode.Grayed = False');
      FSlGeradora.Add('        end');
      FSlGeradora.Add('      end');
    end else if (Pos('int', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) or
                (Pos('number', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) then begin
      inc(contObj);
      item := IntToStr(contObj);

      slItemUnit.Add('    sPanel' + item + ': TsPanel;');
      FSlGeradora.Add('      object sPanel' + item + ': TsPanel');
      FSlGeradora.Add('        Left = 19');
      FSlGeradora.Add('        Top = ' + IntToStr(Top));
      FSlGeradora.Add('        Width = 697');
      FSlGeradora.Add('        Height = 28');
      FSlGeradora.Add('        TabOrder = ' + IntToStr(i));
      inc(i);
      slItemUnit.Add('    lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX;');
      FSlGeradora.Add('        object lbl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsLabelFX');
      FSlGeradora.Add('          Left = 23');
      FSlGeradora.Add('          Top = 5');
      FSlGeradora.Add('          Width = 37');
      FSlGeradora.Add('          Height = 17');
      FSlGeradora.Add('          Caption = ''' + FClientDataSet.FieldByName('NOME_FORMULARIO').AsString + '''');
      FSlGeradora.Add('          Angle = 0');
      FSlGeradora.Add('          Shadow.OffsetKeeper.LeftTop = -1');
      FSlGeradora.Add('          Shadow.OffsetKeeper.RightBottom = 3');
      FSlGeradora.Add('        end');
      slItemUnit.Add('    edt' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsCurrencyEdit;');
      FSlGeradora.Add('        object edt' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TsCurrencyEdit');
      FSlGeradora.Add('          Left = 114');
      FSlGeradora.Add('          Top = 4');
      FSlGeradora.Add('          Width = 80');
      FSlGeradora.Add('          Height = 21');
      FSlGeradora.Add('          AutoSize = False');
      FSlGeradora.Add('          Color = clWhite');
      FSlGeradora.Add('          Font.Charset = DEFAULT_CHARSET');
      FSlGeradora.Add('          Font.Color = clBlack');
      FSlGeradora.Add('          Font.Height = -11');

      if (Pos('int', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) then
        FSlGeradora.Add('          DisplayFormat = ''0000''')
      else
        FSlGeradora.Add('          DisplayFormat = '',0.00''');

      FSlGeradora.Add('          Font.Name = ''Tahoma''');
      FSlGeradora.Add('          Font.Style = []');
      FSlGeradora.Add('          ParentFont = False');
      FSlGeradora.Add('          TabOrder = 0');
      FSlGeradora.Add('          GlyphMode.Blend = 0');
      FSlGeradora.Add('          GlyphMode.Grayed = False');

      if (Pos('int', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) then
        FSlGeradora.Add('          DecimalPlaces = 0')
      else
        FSlGeradora.Add('          DecimalPlaces = 2');

      FSlGeradora.Add('        end');
      FSlGeradora.Add('      end');
    end;

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('    end');
  FSlGeradora.Add('    inherited pnlCabecalho: TsPanel');
  FSlGeradora.Add('      inherited lblDescricaoCabecalho: TsLabelFX');
  FSlGeradora.Add('        Left = 13');
  FSlGeradora.Add('        Top = 8');
  FSlGeradora.Add('        Width = 122');
  FSlGeradora.Add('        Height = 20');
  FSlGeradora.Add('        Caption = ''Cadastro de ' + FTabelaClasse + '''');
  FSlGeradora.Add('        ParentFont = False');
  FSlGeradora.Add('        Font.Height = -13');
  FSlGeradora.Add('        ExplicitLeft = 13');
  FSlGeradora.Add('        ExplicitTop = 8');
  FSlGeradora.Add('        ExplicitWidth = 122');
  FSlGeradora.Add('        ExplicitHeight = 20');
  FSlGeradora.Add('      end');
  FSlGeradora.Add('    end');
  FSlGeradora.Add('  end');
  FSlGeradora.Add('end');

  CreateDir(FPath +'\view');
  FSlGeradora.SaveToFile(FPath +'\view\untCadastro' + FTabelaClasse + '.dfm');

  FSlGeradora.Clear;

  FSlGeradora.Add('unit untCadastro' + FTabelaClasse + ';');
  FSlGeradora.Add('');
  FSlGeradora.Add('interface');
  FSlGeradora.Add('');
  FSlGeradora.Add('uses');

  FSlGeradora.Add('  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,');
  FSlGeradora.Add('  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,');
  FSlGeradora.Add('  untControle' + FTabelaClasse + ', untBaseCadastro, FireDAC.Stan.Intf,');
  FSlGeradora.Add('  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,');
  FSlGeradora.Add('  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,');
  FSlGeradora.Add('  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, sSpinEdit, acPNG, Vcl.ExtCtrls, acImage,');
  FSlGeradora.Add('  Vcl.StdCtrls, sEdit, FireDAC.Comp.UI, Data.DB, FireDAC.Comp.DataSet,');
  FSlGeradora.Add('  FireDAC.Comp.Client, sLabel, sGroupBox, Vcl.Buttons, sSpeedButton, sPanel,');
  FSlGeradora.Add('  acPageScroller, Vcl.ComCtrls, sPageControl, Vcl.Mask, sMaskEdit,');
  FSlGeradora.Add('  sCustomComboEdit, sToolEdit, untSearcher, sMemo, sCurrEdit, sCurrencyEdit, Math,');
  FSlGeradora.Add('  sCheckBox, untFuncoes, untDmPrincipal, cxCheckBox, untConstantes, cxGridCustomTableView,');
  FSlGeradora.Add('  sComboBox, cxTextEdit, cxMaskEdit, cxCurrencyEdit, cxMemo;');
  FSlGeradora.Add('');
  FSlGeradora.Add('type');
  FSlGeradora.Add('  TfrmCad' + FTabelaClasse + ' = class(TfrmBaseCadastro)');

  for i := 0 to slItemUnit.Count - 1 do begin
    FSlGeradora.Add(slItemUnit[i]);
  end;

  FSlGeradora.Add('    procedure btnSalvarClick(Sender: TObject);');
  FSlGeradora.Add('    procedure btnPesquisarClick(Sender: TObject);');
  FSlGeradora.Add('    procedure btnCancelarClick(Sender: TObject);');
  FSlGeradora.Add('    procedure btnExcluirClick(Sender: TObject);');
  FSlGeradora.Add('    procedure FormShow(Sender: TObject);');
  FSlGeradora.Add('    procedure edtIdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);');
  FSlGeradora.Add('    procedure FormClose(Sender: TObject; var Action: TCloseAction);');

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if FClientDataSet.FieldByName('OCULTAR').AsString = 'S' then begin
      FClientDataSet.Next;
      Continue;
    end;

    if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
      FSlGeradora.Add('    procedure ' + TFunc.PrimeiraLetraMaiscula(
      FClientDataSet.FieldByName('COLUMN_NAME').AsString) +  'GetDisplayText(Sender: TcxCustomGridTableItem;');
      FSlGeradora.Add('                                   ARecord: TcxCustomGridRecord; var AText: string);');
    end;

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('  private');
  FSlGeradora.Add('    src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + ': TSearcher;');

  sFiltro := FClientDataSet.Filter;
  FClientDataSet.Filtered := False;
  FClientDataSet.Filter := sFiltro + ' AND (CAMPO_PESQUISA = ''S'')';
  FClientDataSet.Filtered := True;
  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    FSlGeradora.Add('    bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TButtonSearcher;');
    FClientDataSet.Next;
  end;

  FSlGeradora.Add('    procedure ConfigurarCampos;');
  FSlGeradora.Add('    function SQLShr' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + ': TStrings;');

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    FSlGeradora.Add('    function SQLBsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TStrings;');
    FClientDataSet.Next;
  end;

  FClientDataSet.Filtered := False;
  FClientDataSet.Filter := sFiltro;
  FClientDataSet.Filtered := True;

  FSlGeradora.Add('    { Private declarations }');
  FSlGeradora.Add('  public');
  FSlGeradora.Add('    procedure Modo(AEnabled: Boolean);');
  FSlGeradora.Add('    { Public declarations }');
  FSlGeradora.Add('  end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('var');
  FSlGeradora.Add('  frmCad' + FTabelaClasse + ': TfrmCad' + FTabelaClasse + ';');
  FSlGeradora.Add('');
  FSlGeradora.Add('implementation');
  FSlGeradora.Add('');
  FSlGeradora.Add('{$R *.dfm}');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.ConfigurarCampos();');
  FSlGeradora.Add('var');
  FSlGeradora.Add('  campo: TCampoPesquisa;');
  FSlGeradora.Add('  i: Integer;');

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if FClientDataSet.FieldByName('OCULTAR').AsString = 'S' then begin
      FClientDataSet.Next;
      Continue;
    end;

    if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
      FSlGeradora.Add('  array' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TArrayTipoCombo;');
    end;

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('begin');

  sFiltro := FClientDataSet.Filter;
  FClientDataSet.Filtered := False;
  FClientDataSet.Filter := sFiltro + ' AND (COLUMN_NAME = ''ID'')';
  FClientDataSet.Filtered := True;

  sOrderBy := EmptyStr;

  if (FClientDataSet.RecordCount > 0) then
    sOrderBy := 'ID';

  FClientDataSet.Filtered := False;
  FClientDataSet.Filter := sFiltro + ' AND (COLUMN_NAME = ''NAME'')';
  FClientDataSet.Filtered := True;

  if (FClientDataSet.RecordCount > 0) then
    sOrderBy := sOrderBy + ';NAME';

  FClientDataSet.Filtered := False;
  FClientDataSet.Filter := sFiltro;
  FClientDataSet.Filtered := True;

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if (FClientDataSet.FieldByName('CAMPO_PESQUISA').AsString = 'S') then begin
      try
        frmPrincipal := TfrmPrincipal(ListaFormBean.Items[FClientDataSet.FieldByName('COLUMN_NAME').AsString]);
      except
      end;

      if (frmPrincipal <> nil) then begin
        FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ' := TButtonSearcher.Create(Self);');
        FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Searcher.Query.Connection := dmPrincipal.FDConnection;');
        FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Searcher.SQL.AddStrings(SQLBsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ');');
        FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Searcher.NomePesquisa := ''Pesquisa de ' + TFunc.PrimeiraLetraMaiscula(frmPrincipal.chkListTab.Items[frmPrincipal.chkListTab.ItemIndex]) + ''';');

        if (sOrderBy <> EmptyStr) then
          FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Searcher.OrderBy := ''' + sOrderBy + ''';');

        FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.ShowMsgAviso := False;');
        FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Parent := TWinControl(FindComponent(''' + 'spnl' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '''));');
        FSlGeradora.Add('  bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Top := 3;');
        FSlGeradora.Add('');
        FSlGeradora.Add('  if (FindComponent(''edtId'') <> nil) then');
        FSlGeradora.Add('    bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Left := TCustomEdit(FindComponent(''edtId'')).Left');
        FSlGeradora.Add('  else');
        FSlGeradora.Add('    bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Left := 103;');
        FSlGeradora.Add('');
        FSlGeradora.Add('  if (FindComponent(''edtId'') <> nil) then');
        FSlGeradora.Add('    bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.EdtCodigo.Width := TCustomEdit(FindComponent(''edtId'')).Width;');
        FSlGeradora.Add('');
        FSlGeradora.Add('  if (FindComponent(''edtNome'') <> nil) then');
        FSlGeradora.Add('    bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.EdtDescricao.Width := TCustomEdit(FindComponent(''edtNome'')).Width - ' + #13 +
          '      bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.EdtCodigo.Width - bsr' +
          TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.BtnPesquisa.Width - 2;');
        FSlGeradora.Add('');

        sFiltro := frmPrincipal.cdsDadosFB.Filter;
        frmPrincipal.cdsDadosFB.Filtered := False;
        frmPrincipal.cdsDadosFB.Filter := sFiltro + ' AND (COLUMN_NAME = ''ID'')';
        frmPrincipal.cdsDadosFB.Filtered := True;

        sOrderBy := EmptyStr;

        if (frmPrincipal.cdsDadosFB.RecordCount > 0) then
          sOrderBy := 'ID';

        frmPrincipal.cdsDadosFB.Filtered := False;
        frmPrincipal.cdsDadosFB.Filter := sFiltro + ' AND (COLUMN_NAME = ''NOME'')';
        frmPrincipal.cdsDadosFB.Filtered := True;

        if (frmPrincipal.cdsDadosFB.RecordCount > 0) then
          sOrderBy := sOrderBy + ';NOME';

        frmPrincipal.cdsDadosFB.Filtered := False;
        frmPrincipal.cdsDadosFB.Filter := sFiltro;

        if (sFiltro <> EmptyStr) then
          frmPrincipal.cdsDadosFB.Filtered := True;

        frmPrincipal.cdsDadosFB.First;

        while not frmPrincipal.cdsDadosFB.Eof do begin
          FSlGeradora.Add('  campo := TCampoPesquisa.Create(' + 'bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Searcher.CamposPesquisa);');
          FSlGeradora.Add('  campo.Name := ' + QuotedStr('cp' + TFunc.PrimeiraLetraMaiscula(frmPrincipal.cdsDadosFB.FieldByName('COLUMN_NAME').AsString)) + ';');
          FSlGeradora.Add('  campo.Caption := ' + QuotedStr(TFunc.PrimeiraLetraMaiscula(frmPrincipal.cdsDadosFB.FieldByName('NOME_FORMULARIO').AsString)) + ';');
          FSlGeradora.Add('  campo.FieldName := ' + QuotedStr(UpperCase(frmPrincipal.cdsDadosFB.FieldByName('COLUMN_NAME').AsString)) + ';');

          if (Pos('id', LowerCase(frmPrincipal.cdsDadosFB.FieldByName('COLUMN_NAME').AsString)) > 0) then
            FSlGeradora.Add('  campo.KeyField := True;');

          if (sOrderBy <> EmptyStr) then
            FSlGeradora.Add('  campo.OrderBy := ''' + sOrderBy + ''';');

          if (frmPrincipal.cdsDadosFB.FieldByName('KEY_DESCRIPTION').AsString = 'S') then
            FSlGeradora.Add('  campo.DescriptionField := True;');

          FSlGeradora.Add('  campo.Width := ' + frmPrincipal.cdsDadosFB.FieldByName('TAMANHO_COLUNA').AsString + ';');
          FSlGeradora.Add('  campo.MostrarNaPesquisa := ' + TFunc.ifthen(frmPrincipal.cdsDadosFB.FieldByName('APARECER_NA_PESQUISA').AsString = 'S', 'True;', 'False;'));
          FSlGeradora.Add('  campo.MostrarNaGride := ' + TFunc.ifthen(frmPrincipal.cdsDadosFB.FieldByName('APARECER_NA_GRID').AsString = 'S', 'True;', 'False;'));
          FSlGeradora.Add('  campo.PropertiesClassName := ''TcxTextEditProperties'';');
          FSlGeradora.Add('  TcxTextEditProperties(campo.Properties).ReadOnly := True;');
          FSlGeradora.Add('');

          frmPrincipal.cdsDadosFB.Next;
        end;
      end;
    end;

   FClientDataSet.Next;
  end;

  FSlGeradora.Add('');
  FSlGeradora.Add('  src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + ' := TSearcher.Create(Self);');
  FSlGeradora.Add('  src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.Query.Connection := dmPrincipal.FDConnection;');
  FSlGeradora.Add('  src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.SQL.AddStrings(SQLShr' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + ');');
  FSlGeradora.Add('');
  FSlGeradora.Add('  src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.NomePesquisa := ''Pesquisa de ' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + ''';');

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if FClientDataSet.FieldByName('OCULTAR').AsString = 'S' then begin
      FClientDataSet.Next;
      Continue;
    end;

    FSlGeradora.Add('  campo := TCampoPesquisa.Create(src' + FTabelaClasse + '.CamposPesquisa);');
    FSlGeradora.Add('  campo.Name := ' + QuotedStr('cp' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString)) + ';');
    FSlGeradora.Add('  campo.Caption := ' + QuotedStr(TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('NOME_FORMULARIO').AsString)) + ';');
    FSlGeradora.Add('  campo.FieldName := ' + QuotedStr(UpperCase(FClientDataSet.FieldByName('COLUMN_NAME').AsString)) + ';');

    if (Pos('id', FClientDataSet.FieldByName('COLUMN_NAME').AsString) > 0) then
      FSlGeradora.Add('  campo.KeyField := True;');

    FSlGeradora.Add('  campo.Width := ' + FClientDataSet.FieldByName('TAMANHO_COLUNA').AsString + ';');

    if (FClientDataSet.FieldByName('CAMPO_PESQUISA').AsString = 'S') then begin
      if (Pos('tring', TFunc.retornaTipo(FClientDataSet.FieldByName('DATA_TYPE').AsString)) > 0) then
        FSlGeradora.Add('  campo.ControleVisual := bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.EdtDescricao;')
      else
        FSlGeradora.Add('  campo.ControleVisual := bsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.EdtCodigo;');
    end else begin
      if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
        FSlGeradora.Add('  campo.ControleVisual := scb' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ';');
      end else if (FClientDataSet.FieldByName('CHECK_BOX').AsString = 'S') then begin
        FSlGeradora.Add('  campo.ControleVisual := chk' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ';');
      end else if Pos('dat', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0 then begin
        FSlGeradora.Add('  campo.ControleVisual := dtEdit' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ';');
      end else
        FSlGeradora.Add('  campo.ControleVisual := edt' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ';');
    end;

    FSlGeradora.Add('  campo.MostrarNaPesquisa := ' + TFunc.ifthen(FClientDataSet.FieldByName('APARECER_NA_PESQUISA').AsString = 'S', 'True;', 'False;'));
    FSlGeradora.Add('  campo.MostrarNaGride := ' + TFunc.ifthen(FClientDataSet.FieldByName('APARECER_NA_GRID').AsString = 'S', 'True;', 'False;'));

    if (FClientDataSet.FieldByName('CHECK_BOX').AsString = 'S') then begin
      FSlGeradora.Add('  campo.PropertiesClassName := ''TcxCheckBoxProperties'';');
      FSlGeradora.Add('  TcxCheckBoxProperties(campo.Properties).ReadOnly := True;');
      FSlGeradora.Add('  TcxCheckBoxProperties(campo.Properties).ValueChecked := ''S'';');
      FSlGeradora.Add('  TcxCheckBoxProperties(campo.Properties).ValueUnchecked := ''N'';');
    end else if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
      FSlGeradora.Add('  campo.OnGetDisplayText := ' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + 'GetDisplayText;');
      FSlGeradora.Add('  campo.PropertiesClassName := ''TcxComboBoxProperties'';');
      FSlGeradora.Add('  campo.TipoCombo := tp' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ';');
      FSlGeradora.Add('  TcxComboBoxProperties(campo.Properties).ReadOnly := True;');
      FSlGeradora.Add('');
      FSlGeradora.Add('  array' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ' := OrdenarTipo(tp' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ');');

      FSlGeradora.Add('  for i := 0 to High(array' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ') do begin');
      FSlGeradora.Add('    campo.StringsProperties.AddObject(array' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '[i].Value.Descricao, array' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '[i].Value);');
      FSlGeradora.Add('    scb' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.Items.AddObject(array' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '[i].Value.Descricao, array' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '[i].Value);');
      FSlGeradora.Add('  end;');
    end else begin
      FSlGeradora.Add('  campo.PropertiesClassName := ''TcxTextEditProperties'';');
      FSlGeradora.Add('  TcxTextEditProperties(campo.Properties).ReadOnly := True;');
    end;

    FSlGeradora.Add('');

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if FClientDataSet.FieldByName('OCULTAR').AsString = 'S' then begin
      FClientDataSet.Next;
      Continue;
    end;

    if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
      FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + 'GetDisplayText(');
      FSlGeradora.Add('  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;');
      FSlGeradora.Add('  var AText: string);');
      FSlGeradora.Add('var');
      FSlGeradora.Add('  item: TTipo;');
      FSlGeradora.Add('begin');
      FSlGeradora.Add('  if (DictionaryTipo.TryGetValue(AText + IntToStr(Integer(tp'
      + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ')), item)) then');
      FSlGeradora.Add('    AText := item.Descricao;');
      FSlGeradora.Add('end;');
      FSlGeradora.Add('');
    end;

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.btnCancelarClick(Sender: TObject);');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  inherited;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  Modo(False);');
  FSlGeradora.Add('  edtId.SetFocus;');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.btnPesquisarClick(Sender: TObject);');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  inherited;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  if (src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.ShowPesquisar(0)) then begin');
  FSlGeradora.Add('    Modo(True);');
  FSlGeradora.Add('    Habilitar(True);');
  FSlGeradora.Add('    SelectNext(ActiveControl, True, True);');
  FSlGeradora.Add('  end;');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.btnExcluirClick(Sender: TObject);');
  FSlGeradora.Add('var');
  FSlGeradora.Add('  controle: TControle' + FTabelaClasse + ';');
  FSlGeradora.Add('  erro: String;');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  controle := TControle' + FTabelaClasse + '.Create;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  try');
  FSlGeradora.Add('    if (controle.Excluir(edtId.AsInteger, erro)) then begin');
  FSlGeradora.Add('      MessageDlg(''Dados excluídos com sucesso!'', mtInformation, [mbOk], 0);');
  FSlGeradora.Add('      btnCancelarClick(Sender);');
  FSlGeradora.Add('    end else');
  FSlGeradora.Add('      raise Exception.CreateFmt(''Não foi possível excluir os dados! Erro: %s'', [erro]);');
  FSlGeradora.Add('  finally');
  FSlGeradora.Add('    FreeAndNil(controle);');
  FSlGeradora.Add('  end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  inherited;');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.btnSalvarClick(Sender: TObject);');
  FSlGeradora.Add('var');
  FSlGeradora.Add('  controle: TControle' + FTabelaClasse + ';');
  FSlGeradora.Add('  erro: String;');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  controle := TControle' + FTabelaClasse + '.Create;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  try');
  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if FClientDataSet.FieldByName('COLUMN_ID').AsString = '2' then begin
      focus := 'edt' + FClientDataSet.FieldByName('COLUMN_NAME').AsString + '.SetFocus;';
    end;

    if FClientDataSet.FieldByName('OCULTAR').AsString = 'S' then begin
      FClientDataSet.Next;
      Continue;
    end;

    prefixo := 'edt';
    sufixo := '.Text';

    if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
      prefixo := 'scb';
    end else if (Pos('text', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) or (Pos('blob', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0)
       or (Pos('long', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0) then begin
      prefixo := 'mm';
    end else if Pos('dat', FClientDataSet.FieldByName('DATA_TYPE').AsString) > 0 then begin
      prefixo := 'dtEdit';
      sufixo := '.Date';
    end;

    if (Pos('INT', UpperCase(TFunc.retornaTipo(FClientDataSet.FieldByName('DATA_TYPE').AsString))) > 0) then begin
      sufixo := '.AsInteger';
    end else if (Pos('DOUBLE', UpperCase(TFunc.retornaTipo(FClientDataSet.FieldByName('DATA_TYPE').AsString))) > 0) then begin
      sufixo := '.Value';
    end;

    if (FClientDataSet.FieldByName('COMBO_BOX').AsString = 'S') then begin
      FSlGeradora.Add('    if scb' +  TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.ItemIndex > -1 then');
      FSlGeradora.Add('      controle.' + FTabelaClasse + '.' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) +
      ' := TTipo(scb' +  TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) +
      '.Items.Objects[scb' +  TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.ItemIndex]).Codigo');
      FSlGeradora.Add('    else');
      FSlGeradora.Add('      controle.'
      + FTabelaClasse + '.'
      + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString)
      + ' := EmptyStr;');
      FSlGeradora.Add('');
    end else if (FClientDataSet.FieldByName('CHECK_BOX').AsString = 'S') then begin
      FSlGeradora.Add('    controle.'
      + FTabelaClasse + '.'
      + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString)
      + ' := TFunc.ifThen(Chk' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString)
      + '.Checked, ''S'', ''N'');');
    end else
      if (FClientDataSet.FieldByName('CAMPO_PESQUISA').AsString = 'S') then begin
        FSlGeradora.Add('    controle.' + FTabelaClasse + '.'
                       + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) +
                       ' := bsr' +  TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + '.EdtCodigo.AsInteger;');
      end else begin
        FSlGeradora.Add('    controle.' + FTabelaClasse + '.' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ' := ' + prefixo +
                       TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + sufixo + ';');
      end;

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('    controle.Sender := Self;');
  FSlGeradora.Add('');
  FSlGeradora.Add('    if (controle.Salvar(erro)) then begin');
  FSlGeradora.Add('      MessageDlg(''Dados salvos com sucesso!'' + sLineBreak + ''Código: '' + controle.' + FTabelaClasse + '.Id.ToString, mtInformation, [mbOk], 0);');
  FSlGeradora.Add('      btnCancelarClick(Sender);');
  FSlGeradora.Add('    end else');
  FSlGeradora.Add('      raise Exception.CreateFmt(''Não foi possível gravar os dados! Erro: %s'', [erro]);');
  FSlGeradora.Add('  finally');
  FSlGeradora.Add('    FreeAndNil(controle);');
  FSlGeradora.Add('  end;');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.edtIdKeyDown(Sender: TObject; var Key: Word;');
  FSlGeradora.Add('  Shift: TShiftState);');
  FSlGeradora.Add('');
  FSlGeradora.Add('  procedure SetarPropriedades;');
  FSlGeradora.Add('  begin');
  FSlGeradora.Add('    Habilitar(True);');
  FSlGeradora.Add('    Modo(True);');

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if (FClientDataSet.FieldByName('CAMPO_PRINCIPAL').AsString = 'S') then begin
      FSlGeradora.Add('    edt' + FClientDataSet.FieldByName('COLUMN_NAME').AsString + '.SetFocus;');
      FSlGeradora.Add('    edt' + FClientDataSet.FieldByName('COLUMN_NAME').AsString + '.SelectAll;');
    end;

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('  end;');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  inherited;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  if (Key = VK_RETURN) then begin');
  FSlGeradora.Add('    if (edtId.Value = 0) and (not btnSalvar.Enabled) then');
  FSlGeradora.Add('      SetarPropriedades');
  FSlGeradora.Add('    else begin');
  FSlGeradora.Add('      src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.CamposPesquisa.GetItemPeloNome(''cpId'').WhereItem.FieldName := src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.CamposPesquisa.GetItemPeloNome(''cpId'').Table +');
  FSlGeradora.Add('        src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.CamposPesquisa.GetItemPeloNome(''cpId'').FieldName;');
  FSlGeradora.Add('      src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.CamposPesquisa.GetItemPeloNome(''cpId'').WhereItem.ValorAPesquisar := edtId.Text;');
  FSlGeradora.Add('      src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.CamposPesquisa.GetItemPeloNome(''cpId'').WhereItem.OperadorComparativo := ocIgual;');
  FSlGeradora.Add('');
  FSlGeradora.Add('      if (src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + '.Pesquisar(''cpId'')) then');
  FSlGeradora.Add('        SetarPropriedades');
  FSlGeradora.Add('      else');
  FSlGeradora.Add('        MessageDlg(''Código não encontrado!'', mtInformation, [mbOk], 0);');
  FSlGeradora.Add('    end;');
  FSlGeradora.Add('  end;');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.FormClose(Sender: TObject; var Action: TCloseAction);');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  inherited;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  FreeAndNil(src' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + ');');
  FSlGeradora.Add('  frmCad' + FTabelaClasse + ' := nil;');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.FormShow(Sender: TObject);');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  ConfigurarCampos;');
  FSlGeradora.Add('  edtId.Tag := 1;');
  FSlGeradora.Add('  edtId.OnKeyDown := edtIdKeyDown;');
  FSlGeradora.Add('  btnCancelarClick(Sender);');
  FSlGeradora.Add('');
  FSlGeradora.Add('  inherited;');
  FSlGeradora.Add('');
  FSlGeradora.Add('  Sleep(100);');
  FSlGeradora.Add('  keybd_event(VK_TAB, 0, 0, 0);');
  FSlGeradora.Add('  keybd_event(VK_F2, 0, 0, 0);');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('procedure TfrmCad' + FTabelaClasse + '.Modo(AEnabled: Boolean);');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  inherited Modo(AEnabled);');
  FSlGeradora.Add('');
  FSlGeradora.Add('  if (edtId.Value > 0) and (AEnabled) then begin');
  FSlGeradora.Add('    btnExcluir.Enabled := True;');
  FSlGeradora.Add('    btnImprimir.Enabled := True;');
  FSlGeradora.Add('  end else begin');
  FSlGeradora.Add('    btnExcluir.Enabled := False;');
  FSlGeradora.Add('    btnImprimir.Enabled := False;');
  FSlGeradora.Add('  end;');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');
  FSlGeradora.Add('function TfrmCad' + FTabelaClasse + '.SQLShr' + TFunc.PrimeiraLetraMaiscula(FTabelaClasse) + ': TStrings;');
  FSlGeradora.Add('begin');
  FSlGeradora.Add('  Result := TStringList.Create;');
  FSlGeradora.Add('  Result.Add(''SELECT * FROM ' + UpperCase(FTabelaClasse) + ''');');
  FSlGeradora.Add('end;');
  FSlGeradora.Add('');

  FClientDataSet.First;

  while not FClientDataSet.Eof do begin
    if (FClientDataSet.FieldByName('CAMPO_PESQUISA').AsString = 'S') then begin
      try
        frmPrincipal := TfrmPrincipal(ListaFormBean.Items[FClientDataSet.FieldByName('COLUMN_NAME').AsString]);
      except
      end;

      if (frmPrincipal <> nil) then begin
        FSlGeradora.Add('function TfrmCad' + FTabelaClasse + '.SQLBsr' + TFunc.PrimeiraLetraMaiscula(FClientDataSet.FieldByName('COLUMN_NAME').AsString) + ': TStrings;');
        FSlGeradora.Add('begin');
        FSlGeradora.Add('  Result := TStringList.Create;');
        FSlGeradora.Add('  Result.Add(''SELECT * FROM ' + UpperCase(frmPrincipal.chkListTab.Items[frmPrincipal.chkListTab.ItemIndex]) + ''');');
        FSlGeradora.Add('end;');
        FSlGeradora.Add('');
      end;
    end;

    FClientDataSet.Next;
  end;

  FSlGeradora.Add('end.');
  FSlGeradora.SaveToFile(FPath +'\view\untCadastro' + FTabelaClasse + '.pas');
end;

function TCadastroBean.getClientDataSet: TClientDataSet;
begin
  Result := FClientDataSet;
end;

function TCadastroBean.getPacote: String;
begin
  Result := FPacote;
end;

function TCadastroBean.getPath: String;
begin
  Result := FPath;
end;

function TCadastroBean.getSlGeradora: TStringList;
begin
  Result := FSlGeradora;
end;

function TCadastroBean.getTabela: String;
begin
  Result := FTabela;
end;

function TCadastroBean.getTabelaClasse: String;
begin
  Result := FTabelaClasse;
end;

function TCadastroBean.getTabelasFilhas: TList<TTabelasFilhas>;
begin
  Result := FTabelasFilhas;
end;

function TCadastroBean.getTabelasPais: TList<String>;
begin
  if FTabelasPais = nil then
    FTabelasPais := TList<String>.Create;
  Result := FTabelasPais;
end;

function TCadastroBean.getTop: Integer;
begin
  if FTop = 0 then begin
    Result := 26;
    FTop := 26;
  end else begin
    FTop := FTop + 28;
    Result := FTop;
  end;
end;

procedure TCadastroBean.setClientDataSet(const Value: TClientDataSet);
begin
  FClientDataSet := Value;
end;

procedure TCadastroBean.setPacote(const Value: String);
begin
  FPacote := Value;
end;

procedure TCadastroBean.setPath(const Value: String);
begin
  FPath := Value;
end;

procedure TCadastroBean.setSlGeradora(const Value: TStringList);
begin
  FSlGeradora := Value;
end;

procedure TCadastroBean.setTabela(const Value: String);
begin
  FTabela := Value;
end;

procedure TCadastroBean.setTabelaClasse(const Value: String);
begin
  FTabelaClasse := Value;
end;

procedure TCadastroBean.setTabelasFilhas(const Value: TList<TTabelasFilhas>);
begin
  FTabelasFilhas := Value;
end;

procedure TCadastroBean.setTabelasPais(const Value: TList<String>);
begin
  FTabelasPais := Value;
end;

end.








