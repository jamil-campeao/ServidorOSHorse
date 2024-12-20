unit DM.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait, System.IniFiles, FireDAC.Phys.IBBase, FireDac.DApt,
  System.JSON, DataSet.Serialize.Config, DataSet.Serialize, uMD5;

type
  TDMGlobal = class(TDataModule)
    DM: TFDConnection;
    DriverLink: TFDPhysFBDriverLink;
    procedure DMBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure fCarregaConfigDB(pConexao: TFDConnection);
    procedure fValidaLoginUsuario(pLogin: string; var vSQLQuery: TFDQuery; pEditando: Boolean; pCodUsuario: Integer = 0);
    function fListarProdutosOS(pCodPedido: Integer;
      pSQLQuery: TFDQuery): TJsonArray;
    function fListarServicosOS(pCodPedido: Integer;
      pSQLQuery: TFDQuery): TJsonArray;
    function fListarServicosTerceirosOS(pCodPedido: Integer;
      pSQLQuery: TFDQuery): TJsonArray;
    { Private declarations }
  public
    function fLogin(pLogin, pSenha: String): TJsonObject;
    function fInserirUsuario(pNomeUsuario, pLogin, pSenha: String): TJsonObject;
    function fPush(pCodUsuario: Integer; pTokenPush: String) : TJSONObject;
    function fEditarUsuario(pCodUsuario: Integer; pNome,
      pLogin: String): TJSONObject;
    function fEditarSenha(pCodUsuario: Integer; pSenha: String): TJSONObject;
    function fListarNotificacoes(pCodUsuario: Integer): TJSONArray;
    function fListarClientes(pDtUltSincronizacao: String;
      pPagina: Integer): TJSONArray;
    function fListarOS(pDtUltSincronizacao: String; pCodUsuario,
      pPagina: Integer): TJSONArray;
    function fInserirEditarCliente(pCodClienteLocal, pCidCodigo: Integer;
pCliNome, pCliEndereco, pCliNumero, pCliBairro, pCliComplemento, pCliEmail, pCliTelefone, pCliCel, pCliCPF, pCliDtUltAlteracao, pCliRG,
pCliCNPJ, pCliIE, pCliIM, pCliDtNasc, pCliCEP, pCliRazaoSocial, pCliEmp, pCliEmpFone, pCliEmpEndereco, pCliEmpNumero, pCliEmpBairro, pCliEmpCompl: String;
pCidEmpresa: Integer; pCliTipo, pCliSitReceita, pCliDtSit, pCliClass, pCliDtCadastro: String;
pUsuCodCadastro: Integer; pCliSit, pCliRegime, pCliOBS, pCliSexo: String;
pCodClienteOficial, pCodUsuario: Integer): TJSONObject;
    function fInativarUsuario(pCodUsuario: Integer): TJSONObject;
    function fInserirEditarOS(pCodUsuario, pCodOSLocal, pFuncCodigo, pCliCodigo: Integer;
pOSDataAbertura, pOSHoraAbertura, pOSSolicitacao, pOSSituacao, pOSDataEncerramento: String;
pFpgCodigo :Integer; pOsTotalServicos: Double;
pUsuCodigo : Integer; pOSTotalProdutos, pOSTotalGeral: Double;
pEmpCodigo, pUsuCodigoEncerra, pOSCodResponsavelAbertura, pOSCodResponsavelEncerramento, pClasCodigo, pOSSCodigo, pCodOSOficial: Integer;
pDtUltSincronizacao: String; pProdutos, pServicos, pServicosTerceiros: TJSonArray): TJSONObject;
    function fListarProdutos(pDtUltSincronizacao: String;
      pPagina: Integer): TJSONArray;
    function fInserirEditarProduto(pCodigoProdLocal, pGruCodigo,
      pFabCodigo: Integer; pUniSigla, pProdCodigoBarra, pProdReferencia,
      pProdDescricao: String; pProdValorCusto, pProdLucro,
      pProdValorVenda: Double; pProdSituacao: String; pProdValorCompra: Double;
      pUniSiglaCompra, pProdNCM: String; pProdPesoLiq, pProdPesoBruto: Double;
      pProdDtUltOS: String; pTipoCodigo: Integer; pProdDtUltAlt, pProdInfAdic,
      pProdOBS, pProdCEST: String; pCodigoProdOficial: Integer): TJSONObject;

    { Public declarations }
  end;

var
  DMGlobal: TDMGlobal;

const
  cQTD_REG_PAGINA_CLIENTE = 5;
  cQTD_REG_PAGINA_PRODUTO = 5;
  cQTD_REG_PAGINA_OS      = 5;
implementation

procedure TDMGlobal.fCarregaConfigDB(pConexao: TFDConnection);
var
    vIni : TIniFile;
    vArq: string;
begin
  try
    // Caminho do vIni...
    vArq := ExtractFilePath(ParamStr(0)) + 'dbxconnections.ini';

    // Validar arquivo vIni...
    if NOT FileExists(vArq) then
        raise Exception.Create('Arquivo dbxconnections.ini n�o encontrado: ' + vArq);

    // Instanciar arquivo vIni...
    vIni := TIniFile.Create(vArq);
    pConexao.DriverName := vIni.ReadString('GERENCIALOS', 'DriverID', '');

    // Buscar dados do arquivo fisico...
    with pConexao.Params do
    begin
      Clear;
      Add('DriverID=' + vIni.ReadString('GERENCIALOS', 'DriverID', ''));
      Add('Database=' + vIni.ReadString('GERENCIALOS', 'Database', ''));
      Add('User_Name=' + vIni.ReadString('GERENCIALOS', 'User_name', ''));
      Add('Password=' + vIni.ReadString('GERENCIALOS', 'Password', ''));

      if vIni.ReadString('GERENCIALOS', 'Port', '') <> '' then
          Add('Port=' + vIni.ReadString('GERENCIALOS', 'Port', ''));

      if vIni.ReadString('GERENCIALOS', 'Server', '') <> '' then
          Add('Server=' + vIni.ReadString('GERENCIALOS', 'Server', ''));

      if vIni.ReadString('GERENCIALOS', 'Protocol', '') <> '' then
          Add('Protocol=' + vIni.ReadString('GERENCIALOS', 'Protocol', ''));

      if vIni.ReadString('GERENCIALOS', 'VendorLib', '') <> '' then
          DriverLink.VendorLib := vIni.ReadString('GERENCIALOS', 'VendorLib', '');
    end;

  finally
    if Assigned(vIni) then
      vIni.DisposeOf;
  end;
end;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDMGlobal.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
  DM.Connected := True;
end;

procedure TDMGlobal.DMBeforeConnect(Sender: TObject);
begin
  fCarregaConfigDB(DM);
end;

function TDMGlobal.fLogin(pLogin, pSenha: String): TJsonObject;
var
  vSQLQuery : TFDQuery;
begin
  if (pLogin = '') or (pSenha = '') then
    raise Exception.Create('Par�metro login ou senha n�o informados');

  vSQLQuery := TFDQuery.Create(nil);
  try
    vSQLQuery.Connection := DM;
    vSQLQuery.SQL.Clear;

    vSQLQuery.SQL.Text := ' SELECT                         '+
                          ' USU_CODIGO,                    '+
                          ' USU_NOME,                      '+
                          ' USU_LOGIN                      '+
                          ' FROM USUARIO                   '+
                          ' WHERE USU_LOGIN = :USU_LOGIN   '+
                          ' AND USU_SENHA =   :SENHA       ';

    vSQLQuery.ParamByName('USU_LOGIN').AsString   := pLogin;
    vSQLQuery.ParamByName('SENHA').AsString       := fSaltPassword(pSenha);

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONObject;
  finally
    FreeAndNil(vSQLQuery);
  end;

end;

function TDMGlobal.fInserirUsuario(pNomeUsuario, pLogin, pSenha: String): TJsonObject;
var
  vSQLQueryInsert : TFDQuery;
  vSQLQuerySelect : TFDQuery;
begin
  if (pNomeUsuario = '') or (pLogin = '') or (pSenha = '') then
    raise Exception.Create('Par�metros nome, login ou senha n�o informados');

  if (pSenha.Length < 8) then
    raise Exception.Create('Senha informada deve conter entre 8 a 20 caracteres');

  vSQLQueryInsert := TFDQuery.Create(nil);
  vSQLQuerySelect := TFDQuery.Create(nil);
  try
    vSQLQueryInsert.Connection := DM;
    vSQLQuerySelect.Connection := DM;

    vSQLQueryInsert.SQL.Clear;
    vSQLQuerySelect.SQL.Clear;

    fValidaLoginUsuario(pLogin, vSQLQuerySelect, False); //Valida��o de Login j� existente

    vSQLQuerySelect.SQL.Text := ' SELECT MAX(USU_CODIGO) AS USU_CODIGO FROM USUARIO ';
    vSQLQuerySelect.Open;

    vSQLQueryInsert.SQL.Text := ' INSERT INTO USUARIO                                                           '+
                                ' (USU_CODIGO, USU_NOME, USU_LOGIN, USU_SENHA, EMP_CODIGO, USU_SITUACAO)        '+
                                ' VALUES                                                                        '+
                                ' (:USU_CODIGO, :USU_NOME, :USU_LOGIN, :USU_SENHA, :EMP_CODIGO, :USU_SITUACAO)  '+
                                ' RETURNING USU_CODIGO                                                          ';

    vSQLQueryInsert.ParamByName('USU_CODIGO').AsInteger   := vSQLQuerySelect.FieldByName('USU_CODIGO').AsInteger + 1;
    vSQLQueryInsert.ParamByName('USU_NOME').AsString      := pNomeUsuario;
    vSQLQueryInsert.ParamByName('USU_LOGIN').AsString     := pLogin;
    vSQLQueryInsert.ParamByName('USU_SENHA').AsString     := fSaltPassword(pSenha);
    vSQLQueryInsert.ParamByName('USU_SITUACAO').AsString  := 'Ativo';
    vSQLQueryInsert.ParamByName('EMP_CODIGO').AsInteger   := 1; {Estou setando fixo temporariamente, para
                                                                decidir depois como ir� ser feito essa parte da empresa}

    vSQLQueryInsert.Open;

    Result := vSQLQueryInsert.ToJSONObject;
  finally
    FreeAndNil(vSQLQueryInsert);
  end;

end;

function TDMGlobal.fPush(pCodUsuario: Integer; pTokenPush: String) : TJSONObject;
var
  vSQLQuery : TFDQuery;
begin
  if pTokenPush.IsEmpty then
    raise Exception.Create('Informe o token_push do usu�rio');
  try
    vSQLQuery := TFDQuery.Create(nil);
    vsQLQuery.Connection := DM;

    vSQLQuery.SQL.Clear;
    vSQLQuery.SQL.Text := ' UPDATE USUARIO                      '+
                          ' SET USU_TOKENPUSH = :USU_TOKENPUSH  '+
                          ' WHERE USU_CODIGO = :USU_CODIGO      '+
                          ' RETURNING USU_CODIGO                ';

    vSQLQuery.ParamByName('USU_TOKENPUSH').AsString := pTokenPush;
    vSQLQuery.ParamByName('USU_CODIGO').AsInteger   := pCodUsuario;

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONObject;
  finally
    FreeAndNil(vSQLQuery);
  end;
end;

function TDMGlobal.fEditarUsuario(pCodUsuario: Integer; pNome, pLogin: String): TJSONObject;
var
  vSQLQuery : TFDQuery;
begin
  if (pNome.IsEmpty) or (pLogin.IsEmpty) then
    raise Exception.Create('Informe o nome e o login do usu�rio');
  try
    vSQLQuery := TFDQuery.Create(nil);
    vsQLQuery.Connection := DM;

    fValidaLoginUsuario(pLogin, vSQLQuery, True, pCodUsuario);

    vSQLQuery.SQL.Clear;
    vSQLQuery.SQL.Text := ' UPDATE USUARIO                   '+
                          ' SET USU_NOME = :USU_NOME,        '+
                          ' USU_LOGIN    = :USU_LOGIN        '+
                          ' WHERE USU_CODIGO = :USU_CODIGO   '+
                          ' RETURNING USU_CODIGO             ';

    vSQLQuery.ParamByName('USU_NOME').AsString    := pNome;
    vSQLQuery.ParamByName('USU_LOGIN').AsString   := pLogin;
    vSQLQuery.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONObject;
  finally
    FreeAndNil(vSQLQuery);
  end;

end;

procedure TDMGlobal.fValidaLoginUsuario(pLogin: string; var vSQLQuery: TFDQuery; pEditando: Boolean; pCodUsuario: Integer = 0);
begin
  //Valida��o do login
  vSQLQuery.SQL.Clear;
  vSQLQuery.SQL.Text := ' SELECT USU_CODIGO            ' +
                        ' FROM USUARIO                 ' +
                        ' WHERE USU_LOGIN = :USU_LOGIN ';
  if pEditando then
  begin
    vSQLQuery.SQL.Add(' AND USU_CODIGO <> :USU_CODIGO');
    vSQLQuery.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;
  end;

  vSQLQuery.ParamByName('USU_LOGIN').AsString := pLogin;

  vSQLQuery.Open;
  if vSQLQuery.RecordCount > 0 then
    raise Exception.Create('O login informado est� em uso por outra conta de usu�rio');
end;

function TDMGlobal.fEditarSenha(pCodUsuario: Integer; pSenha: String) : TJSONObject;
var
  vSQLQuery : TFDQuery;
begin
  if pSenha.IsEmpty then
    raise Exception.Create('Informe a nova senha do usu�rio');

  if pSenha.Length < 8 then
    raise Exception.Create('A senha deve conter entre 8 a 20 caracteres');

  vSQLQuery := TFDQuery.Create(nil);
  try
    vsQLQuery.Connection := DM;

    vSQLQuery.SQL.Clear;
    vSQLQuery.SQL.Text := ' UPDATE USUARIO                  '+
                          ' SET USU_SENHA    = :USU_SENHA   '+
                          ' WHERE USU_CODIGO = :USU_CODIGO  '+
                          ' RETURNING USU_CODIGO            ';

    vSQLQuery.ParamByName('USU_SENHA').AsString   := fSaltPassword(pSenha);
    vSQLQuery.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONObject;
  finally
    FreeAndNil(vSQLQuery);
  end;

end;

function TDMGlobal.fListarNotificacoes(pCodUsuario: Integer) : TJSONArray;
var
  vSQLQuerySelect  : TFDQuery;
  vSQLQueryInsert  : TFDQuery;
begin
  try
    vSQLQuerySelect            := TFDQuery.Create(nil);
    vSQLQueryInsert            := TFDQuery.Create(nil);
    vSQLQuerySelect.Connection := DM;
    vSQLQueryInsert.Connection := DM;

    vSQLQuerySelect.SQL.Clear;
    vSQLQuerySelect.SQL.Text := ' SELECT                       '+
                                ' NOT_CODIGO,                  '+
                                ' NOT_DATA,                    '+
                                ' NOT_TITULO,                  '+
                                ' NOT_TEXTO                    '+
                                ' FROM NOTIFICACAO             '+
                                ' WHERE NOT_IND_LIDO = ''N''   '+
                                ' AND USU_CODIGO = :USU_CODIGO ';

    vSQLQuerySelect.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;

    vSQLQuerySelect.Open;

    Result := vSQLQuerySelect.ToJSONArray;

    //Marca as mensagens como lidas...
    vSQLQueryInsert.SQL.Clear;
    vSQLQueryInsert.SQL.Text :=  ' UPDATE NOTIFICACAO            '+
                                 ' SET NOT_IND_LIDO    = ''S''   '+
                                 ' WHERE NOT_IND_LIDO  = ''N''   '+
                                 ' AND USU_CODIGO = :USU_CODIGO  ';

    vSQLQueryInsert.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;

    vSQLQueryInsert.ExecSQL;

  finally
    FreeAndNil(vSQLQuerySelect);
    FreeAndNil(vSQLQueryInsert);
  end;

end;

function TDMGlobal.fListarClientes(pDtUltSincronizacao: String; pPagina: Integer) : TJSONArray;
var
  vSQLQuerySelect  : TFDQuery;
begin
  if pDtUltSincronizacao = '' then
    raise Exception.Create('Par�metro dt_ult_sincronizacao n�o informado');
  try
    vSQLQuerySelect            := TFDQuery.Create(nil);
    vSQLQuerySelect.Connection := DM;

    vSQLQuerySelect.SQL.Clear;
    vSQLQuerySelect.SQL.Text := ' SELECT FIRST :FIRST SKIP :SKIP *                       '+
                                ' FROM CLIENTE                                           '+
                                ' WHERE CLI_DATA_ULT_ALTERACAO > :CLI_DATA_ULT_ALTERACAO '+
                                ' ORDER BY 1                                             ';

    vSQLQuerySelect.ParamByName('CLI_DATA_ULT_ALTERACAO').AsString := pDtUltSincronizacao;
    vSQLQuerySelect.ParamByName('FIRST').AsInteger                 := cQTD_REG_PAGINA_CLIENTE;
    vSQLQuerySelect.ParamByName('SKIP').AsInteger                  := (pPagina * cQTD_REG_PAGINA_CLIENTE) - cQTD_REG_PAGINA_CLIENTE;

    vSQLQuerySelect.Open;
    Result := vSQLQuerySelect.ToJSONArray;

  finally
    FreeAndNil(vSQLQuerySelect);
  end;

end;

function TDMGlobal.fListarOS(pDtUltSincronizacao: String; pCodUsuario, pPagina: Integer) : TJSONArray;
var
  vSQLQuerySelect : TFDQuery;
  vOS             : TJsonArray;
  i               : Integer;
begin
  if pDtUltSincronizacao = '' then
    raise Exception.Create('Par�metro dt_ult_sincronizacao n�o informado');
  try
    vSQLQuerySelect := TFDQuery.Create(nil);
    vSQLQuerySelect.Connection := DM;

    vSQLQuerySelect.Active := False;
    vSQLQuerySelect.SQL.Clear;
    vSQLQuerySelect.SQL.Text := ' SELECT FIRST :FIRST SKIP :SKIP                             '+
                                ' OS_CODIGO,                                                 '+
                                ' CLI_CODIGO,                                                '+
                                ' OS_DATAABERTURA,                                           '+
                                ' OS_HORAABERTURA,                                           '+
                                ' OS_SOLICITACAO,                                            '+
                                ' OS_SITUACAO,                                               '+
                                ' OS_TOTALGERAL,                                             '+
                                ' OS_DATAULTIMAALTERACAO                                     '+
                                ' FROM OS                                                    '+
                                ' WHERE OS_DATAULTIMAALTERACAO > :OS_DATAULTIMAALTERACAO     '+
                                ' AND USU_CODIGO = :USU_CODIGO                               '+
                                ' ORDER BY 1                                                 ';

    vSQLQuerySelect.ParamByName('OS_DATAULTIMAALTERACAO').AsString := pDtUltSincronizacao;
    vSQLQuerySelect.ParamByName('FIRST').AsInteger                   := cQTD_REG_PAGINA_OS;
    vSQLQuerySelect.ParamByName('SKIP').AsInteger                    := (pPagina * cQTD_REG_PAGINA_OS) - cQTD_REG_PAGINA_OS;
    vSQLQuerySelect.ParamByName('USU_CODIGO').AsInteger              := pCodUsuario;


    vSQLQuerySelect.Active := True;

    vOS := vSQLQuerySelect.ToJSONArray;

    for I := 0 to vOS.Size - 1 do
        (vOS[i] as TJSONObject).AddPair('itens_produtos', fListarProdutosOS(vOS[i].GetValue<integer>('osCodigo', 0), vSQLQuerySelect));

    for I := 0 to vOS.Size - 1 do
        (vOS[i] as TJSONObject).AddPair('itens_servicos', fListarServicosOS(vOS[i].GetValue<integer>('osCodigo', 0), vSQLQuerySelect));

    for I := 0 to vOS.Size - 1 do
        (vOS[i] as TJSONObject).AddPair('itens_servicos_terceiros', fListarServicosTerceirosOS(vOS[i].GetValue<integer>('osCodigo', 0), vSQLQuerySelect));


    Result := vOS;

  finally
    FreeAndNil(vSQLQuerySelect);
  end;

end;

function TDMGlobal.fListarProdutosOS(pCodPedido: Integer; pSQLQuery: TFDQuery): TJsonArray;
begin
  pSQLQuery.SQL.Clear;
  pSQLQuery.SQL.Text := ' SELECT                          ' +
                        ' PROD_CODIGO,                    ' +
                        ' PROD_DESCRICAO,                 ' +
                        ' OSP_QUANTIDADE,                 ' +
                        ' OSP_VALOR,                      ' +
                        ' OSP_TOTAL                       ' +
                        ' FROM OSPRODUTO                  ' +
                        ' WHERE OS_CODIGO = :OS_CODIGO    ' +
                        ' ORDER BY 1                      ';

  pSQLQuery.ParamByName('OS_CODIGO').AsInteger := pCodPedido;
  pSQLQuery.Open;

  Result := pSQLQuery.ToJSONArray;

end;

function TDMGlobal.fListarServicosOS(pCodPedido: Integer; pSQLQuery: TFDQuery): TJsonArray;
begin
  pSQLQuery.SQL.Clear;
  pSQLQuery.SQL.Text := ' SELECT                        ' +
                        ' OSS_CODIGO,                   ' +
                        ' SE_CODIGO,                    ' +
                        ' OSS_DESCRICAO,                ' +
                        ' OSS_QUANTIDADE,               ' +
                        ' OSS_VALOR,                    ' +
                        ' OSS_TOTAL                     ' +
                        ' FROM OSSERVICO                ' +
                        ' WHERE OS_CODIGO = :OS_CODIGO  ' +
                        ' ORDER BY 1                    ';

  pSQLQuery.ParamByName('OS_CODIGO').AsInteger := pCodPedido;
  pSQLQuery.Open;

  Result := pSQLQuery.ToJSONArray;

end;

function TDMGlobal.fListarServicosTerceirosOS(pCodPedido: Integer; pSQLQuery: TFDQuery): TJsonArray;
begin
  pSQLQuery.SQL.Clear;
  pSQLQuery.SQL.Text := ' SELECT                        ' +
                        ' OSST_CODIGO,                  ' +
                        ' SE_CODIGO,                    ' +
                        ' OSST_DESCRICAO,               ' +
                        ' OSST_QUANTIDADE,              ' +
                        ' OSST_VALOR,                   ' +
                        ' OSST_TOTAL                    ' +
                        ' FROM OSSERVICOTERCEIROS       ' +
                        ' WHERE OS_CODIGO = :OS_CODIGO  ' +
                        ' ORDER BY 1                    ';

  pSQLQuery.ParamByName('OS_CODIGO').AsInteger := pCodPedido;
  pSQLQuery.Open;

  Result := pSQLQuery.ToJSONArray;

end;


function TDMGlobal.fInserirEditarCliente(pCodClienteLocal, pCidCodigo: Integer;
pCliNome, pCliEndereco, pCliNumero, pCliBairro, pCliComplemento, pCliEmail, pCliTelefone, pCliCel, pCliCPF, pCliDtUltAlteracao, pCliRG,
pCliCNPJ, pCliIE, pCliIM, pCliDtNasc, pCliCEP, pCliRazaoSocial, pCliEmp, pCliEmpFone, pCliEmpEndereco, pCliEmpNumero, pCliEmpBairro, pCliEmpCompl: String;
pCidEmpresa: Integer; pCliTipo, pCliSitReceita, pCliDtSit, pCliClass, pCliDtCadastro: String;
pUsuCodCadastro: Integer; pCliSit, pCliRegime, pCliOBS, pCliSexo: String;
pCodClienteOficial, pCodUsuario: Integer): TJSONObject;
var
  vSQLQuery          : TFDQuery;
  vProxCodigoCliente : Integer;
begin
  if (pCliTipo <> 'J') and (pCliTipo <> 'F') then
    raise Exception.Create('par�metro cli_tipopessoa informado incorretamente');

  try
    try
      vSQLQuery            := TFDQuery.Create(nil);
      vsQLQuery.Connection := DM;
      DM.StartTransaction;

      vSQLQuery.SQL.Clear;
      {$REGION 'INSERT'}
      if pCodClienteOficial = 0 then
      begin
        vSQLQuery.SQL.Text := ' SELECT MAX(CLI_CODIGO) AS CLI_CODIGO FROM CLIENTE ';
        vSQLQuery.Open;
        vProxCodigoCliente := vSQLQuery.FieldByName('CLI_CODIGO').AsInteger;

        vSQLQuery.SQL.Clear;
        vSQLQuery.SQL.Text := ' INSERT INTO CLIENTE (                        '+
                              '     CLI_CODIGO,                              '+
                              '     CID_CODIGO,                              '+
                              '     CLI_NOME,                                '+
                              '     CLI_ENDERECO,                            '+
                              '     CLI_NUMERO,                              '+
                              '     CLI_BAIRRO,                              '+
                              '     CLI_COMPLEMENTO,                         '+
                              '     CLI_EMAIL,                               '+
                              '     CLI_TELEFONE,                            '+
                              '     CLI_CEL,                                 '+
                              '     CLI_CPF,                                 '+
                              '     CLI_DATA_ULT_ALTERACAO,                  '+
                              '     CLI_RG,                                  '+
                              '     CLI_CNPJ,                                '+
                              '     CLI_IE,                                  '+
                              '     CLI_IM,                                  '+
                              '     CLI_DATA_NASC,                           '+
                              '     CLI_CEP,                                 '+
                              '     CLI_RAZAOSOCIAL,                         '+
                              '     CLI_EMPRESA,                             '+
                              '     CLI_EMPRESAFONE,                         '+
                              '     CLI_EMPRESAENDER,                        '+
                              '     CLI_EMPRESANUMERO,                       '+
                              '     CLI_EMPRESABAIRRO,                       '+
                              '     CLI_EMRPESACOMPLE,                       '+
                              '     CID_EMPRESA,                             '+
                              '     CLI_TIPOPESSOA,                          '+
                              '     CLI_SITUACAORECEITA,                     '+
                              '     CLI_DATASITUACAO,                        '+
                              '     CLI_CLASSIFICACAO,                       '+
                              '     CLI_DATACADASTRO,                        '+
                              '     USU_CODIGO_CADASTRO,                     '+
                              '     CLI_SITUACAO,                            '+
                              '     CLI_REGIMETRIBUTARIO,                    '+
                              '     CLI_OBS,                                 '+
                              '     CLI_SEXO                                 '+
                              ' ) VALUES (                                   '+
                              '     :CLI_CODIGO,                             '+
                              '     :CID_CODIGO,                             '+
                              '     :CLI_NOME,                               '+
                              '     :CLI_ENDERECO,                           '+
                              '     :CLI_NUMERO,                             '+
                              '     :CLI_BAIRRO,                             '+
                              '     :CLI_COMPLEMENTO,                        '+
                              '     :CLI_EMAIL,                              '+
                              '     :CLI_TELEFONE,                           '+
                              '     :CLI_CEL,                                '+
                              '     :CLI_CPF,                                '+
                              '     :CLI_DATA_ULT_ALTERACAO,                 '+
                              '     :CLI_RG,                                 '+
                              '     :CLI_CNPJ,                               '+
                              '     :CLI_IE,                                 '+
                              '     :CLI_IM,                                 '+
                              '     :CLI_DATA_NASC,                          '+
                              '     :CLI_CEP,                                '+
                              '     :CLI_RAZAOSOCIAL,                        '+
                              '     :CLI_EMPRESA,                            '+
                              '     :CLI_EMPRESAFONE,                        '+
                              '     :CLI_EMPRESAENDER,                       '+
                              '     :CLI_EMPRESANUMERO,                      '+
                              '     :CLI_EMPRESABAIRRO,                      '+
                              '     :CLI_EMRPESACOMPLE,                      '+
                              '     :CID_EMPRESA,                            '+
                              '     :CLI_TIPOPESSOA,                         '+
                              '     :CLI_SITUACAORECEITA,                    '+
                              '     :CLI_DATASITUACAO,                       '+
                              '     :CLI_CLASSIFICACAO,                      '+
                              '     :CLI_DATACADASTRO,                       '+
                              '     :USU_CODIGO_CADASTRO,                    '+
                              '     :CLI_SITUACAO,                           '+
                              '     :CLI_REGIMETRIBUTARIO,                   '+
                              '     :CLI_OBS,                                '+
                              '     :CLI_SEXO                                '+
                              ' )                                            '+
                              ' RETURNING CLI_CODIGO AS CLI_CODIGO_OFICIAL   ';

        vSQLQuery.ParamByName('CLI_CODIGO').AsInteger           := vProxCodigoCliente + 1;
      end
      {$ENDREGION}
      {$REGION 'UPDATE'}
      else
      begin
        vSQLQuery.SQL.Text := ' UPDATE CLIENTE                                        '+
                              ' SET                                                   '+
                              '     CID_CODIGO = :CID_CODIGO,                         '+
                              '     CLI_NOME = :CLI_NOME,                             '+
                              '     CLI_ENDERECO = :CLI_ENDERECO,                     '+
                              '     CLI_NUMERO = :CLI_NUMERO,                         '+
                              '     CLI_BAIRRO = :CLI_BAIRRO,                         '+
                              '     CLI_COMPLEMENTO = :CLI_COMPLEMENTO,               '+
                              '     CLI_EMAIL = :CLI_EMAIL,                           '+
                              '     CLI_TELEFONE = :CLI_TELEFONE,                     '+
                              '     CLI_CEL = :CLI_CEL,                               '+
                              '     CLI_CPF = :CLI_CPF,                               '+
                              '     CLI_DATA_ULT_ALTERACAO = :CLI_DATA_ULT_ALTERACAO, '+
                              '     CLI_RG = :CLI_RG,                                 '+
                              '     CLI_CNPJ = :CLI_CNPJ,                             '+
                              '     CLI_IE = :CLI_IE,                                 '+
                              '     CLI_IM = :CLI_IM,                                 '+
                              '     CLI_DATA_NASC = :CLI_DATA_NASC,                   '+
                              '     CLI_CEP = :CLI_CEP,                               '+
                              '     CLI_RAZAOSOCIAL = :CLI_RAZAOSOCIAL,               '+
                              '     CLI_EMPRESA = :CLI_EMPRESA,                       '+
                              '     CLI_EMPRESAFONE = :CLI_EMPRESAFONE,               '+
                              '     CLI_EMPRESAENDER = :CLI_EMPRESAENDER,             '+
                              '     CLI_EMPRESANUMERO = :CLI_EMPRESANUMERO,           '+
                              '     CLI_EMPRESABAIRRO = :CLI_EMPRESABAIRRO,           '+
                              '     CLI_EMRPESACOMPLE = :CLI_EMRPESACOMPLE,           '+
                              '     CID_EMPRESA = :CID_EMPRESA,                       '+
                              '     CLI_TIPOPESSOA = :CLI_TIPOPESSOA,                 '+
                              '     CLI_SITUACAORECEITA = :CLI_SITUACAORECEITA,       '+
                              '     CLI_DATASITUACAO = :CLI_DATASITUACAO,             '+
                              '     CLI_CLASSIFICACAO = :CLI_CLASSIFICACAO,           '+
                              '     CLI_DATACADASTRO = :CLI_DATACADASTRO,             '+
                              '     USU_CODIGO_CADASTRO = :USU_CODIGO_CADASTRO,       '+
                              '     CLI_SITUACAO = :CLI_SITUACAO,                     '+
                              '     CLI_REGIMETRIBUTARIO = :CLI_REGIMETRIBUTARIO,     '+
                              '     CLI_OBS = :CLI_OBS,                               '+
                              '     CLI_SEXO = :CLI_SEXO                              '+
                              ' WHERE CLI_CODIGO = :CLI_CODIGO                        '+
                              ' RETURNING CLI_CODIGO AS CLI_CODIGO_OFICIAL            ';

        vSQLQuery.ParamByName('CLI_CODIGO').AsInteger         := pCodClienteOficial;
      end;
      {$ENDREGION}
      if pCliTipo = 'F' then
      begin
        if pCidCodigo > 0 then
          vSQLQuery.ParamByName('CID_CODIGO').AsInteger              := pCidCodigo
        else
        begin
          vSQLQuery.ParamByName('CID_CODIGO').DataType               := ftInteger;
          vSQLQuery.ParamByName('CID_CODIGO').Clear;
        end;

        vSQLQuery.ParamByName('CLI_NOME').AsString                   := pCliNome;
        vSQLQuery.ParamByName('CLI_ENDERECO').AsString               := pCliEndereco;
        vSQLQuery.ParamByName('CLI_NUMERO').AsString                 := pCliNumero;
        vSQLQuery.ParamByName('CLI_BAIRRO').AsString                 := pCliBairro;
        vSQLQuery.ParamByName('CLI_COMPLEMENTO').AsString            := pCliComplemento;
        vSQLQuery.ParamByName('CLI_EMAIL').AsString                  := pCliEmail;
        vSQLQuery.ParamByName('CLI_TELEFONE').AsString               := pCliTelefone;
        vSQLQuery.ParamByName('CLI_CEL').AsString                    := pCliCel;
        vSQLQuery.ParamByName('CLI_CPF').AsString                    := pCliCPF;
        vSQLQuery.ParamByName('CLI_DATA_ULT_ALTERACAO').AsString     := pCliDtUltAlteracao;
        vSQLQuery.ParamByName('CLI_RG').AsString                     := pCliRG;
      end
      else
      begin
        vSQLQuery.ParamByName('CLI_CNPJ').AsString                   := pCliCNPJ;
        vSQLQuery.ParamByName('CLI_IE').AsString                     := pCliIE;
        vSQLQuery.ParamByName('CLI_IM').AsString                     := pCliIM;
        vSQLQuery.ParamByName('CLI_DATA_NASC').AsString              := pCliDtNasc;
        vSQLQuery.ParamByName('CLI_CEP').AsString                    := pCliCEP;
        vSQLQuery.ParamByName('CLI_RAZAOSOCIAL').AsString            := pCliRazaoSocial;
        vSQLQuery.ParamByName('CLI_EMPRESA').AsString                := pCliEMP;
        vSQLQuery.ParamByName('CLI_EMPRESAFONE').AsString            := pCliEMPFone;
        vSQLQuery.ParamByName('CLI_EMPRESAENDER').AsString           := pCliEMPEndereco;
        vSQLQuery.ParamByName('CLI_EMPRESANUMERO').AsString          := pCliEMPNumero;
        vSQLQuery.ParamByName('CLI_EMPRESABAIRRO').AsString          := pCliEmpBairro;
        vSQLQuery.ParamByName('CLI_EMRPESACOMPLE').AsString          := pCliEMPCompl;

        if pCidEmpresa > 0 then
          vSQLQuery.ParamByName('CID_EMPRESA').AsInteger               := pCidEmpresa
        else
        begin
          vSQLQuery.ParamByName('CID_EMPRESA').DataType                := ftInteger;
          vSQLQuery.ParamByName('CID_EMPRESA').Clear;
        end;
      end;

      vSQLQuery.ParamByName('CLI_TIPOPESSOA').AsString             := pCliTipo;
      vSQLQuery.ParamByName('CLI_SITUACAORECEITA').AsString        := pCliSitReceita;
      vSQLQuery.ParamByName('CLI_DATASITUACAO').AsString           := pCliDtSit;
      vSQLQuery.ParamByName('CLI_CLASSIFICACAO').AsString          := pCliClass;
      vSQLQuery.ParamByName('CLI_DATACADASTRO').AsString           := pCliDtCadastro;
      vSQLQuery.ParamByName('USU_CODIGO_CADASTRO').AsInteger       := pCodUsuario;
      vSQLQuery.ParamByName('CLI_SITUACAO').AsString               := pCliSit;
      vSQLQuery.ParamByName('CLI_REGIMETRIBUTARIO').AsString       := pCliRegime;
      vSQLQuery.ParamByName('CLI_OBS').AsString                    := pCliOBS;
      vSQLQuery.ParamByName('CLI_SEXO').AsString                   := pCliSexo;

      vSQLQuery.Open;
      DM.Commit;
      Result := vSQLQuery.ToJSONObject;

    except on e:Exception do
      begin
        DM.Rollback;
        raise Exception.Create('Erro ao atualizar ou inserir cliente: ' + e.Message);
      end;
    end;
  finally
    FreeAndNil(vSQLQuery);
  end;
end;

function TDMGlobal.fInativarUsuario(pCodUsuario: Integer): TJSONObject;
var
  vSQLQuery  : TFDQuery;
begin
  try
    vSQLQuery            := TFDQuery.Create(nil);
    vsQLQuery.Connection := DM;
    DM.StartTransaction;
    {$REGION 'INATIVA USUARIO'}
    try
      vSQLQuery.SQL.Clear;
      vSQLQuery.SQL.Text := ' UPDATE USUARIO                                          '+
                            ' SET USU_NOME = :USU_NOME, USU_LOGIN = :USU_LOGIN,       '+
                            ' USU_SENHA = :USU_SENHA, USU_TOKENPUSH = :USU_TOKENPUSH, '+
                            ' USU_SITUACAO = :USU_SITUACAO                            '+
                            ' WHERE USU_SITUACAO = ''Ativo''                          '+
                            ' AND USU_CODIGO = :USU_CODIGO                            '+
                            ' RETURNING USU_CODIGO                                    ';

      vSQLQuery.ParamByName('USU_NOME').AsString         := 'Usu�rio Exclu�do';
      vSQLQuery.ParamByName('USU_LOGIN').AsString        := 'Usu�rio Exclu�do';
      vSQLQuery.ParamByName('USU_SENHA').AsString        := 'Usu�rio Exclu�do';
      vSQLQuery.ParamByName('USU_TOKENPUSH').AsString    := 'Usu�rio Exclu�do';
      vSQLQuery.ParamByName('USU_CODIGO').AsInteger      := pCodUsuario;
      vSQLQuery.ParamByName('USU_SITUACAO').AsString     := 'Inativo';

      vSQLQuery.Open;

      Result := vSQLQuery.ToJSONObject;
     {$ENDREGION}

      {$REGION 'DELETA NOTIFICA��ES'}
      vSQLQuery.SQL.Clear;
      vSQLQuery.SQL.Text := ' DELETE FROM NOTIFICACAO         '+
                            ' WHERE USU_CODIGO = :USU_CODIGO  ';

      vSQLQuery.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;


      vSQLQuery.ExecSQL;
      {$ENDREGION}

      DM.Commit;
    except on e:Exception do
      begin
        DM.Rollback;
        raise Exception.Create('Erro ao deletar dados do usu�rio: ' + e.Message);
      end;

    end;
  finally
    FreeAndNil(vSQLQuery);
  end;

end;

function TDMGlobal.fInserirEditarOS(pCodUsuario, pCodOSLocal, pFuncCodigo, pCliCodigo: Integer;
pOSDataAbertura, pOSHoraAbertura, pOSSolicitacao, pOSSituacao, pOSDataEncerramento: String;
pFpgCodigo :Integer; pOsTotalServicos: Double;
pUsuCodigo : Integer; pOSTotalProdutos, pOSTotalGeral: Double;
pEmpCodigo, pUsuCodigoEncerra, pOSCodResponsavelAbertura, pOSCodResponsavelEncerramento, pClasCodigo, pOSSCodigo, pCodOSOficial: Integer;
pDtUltSincronizacao: String; pProdutos, pServicos, pServicosTerceiros: TJSonArray): TJSONObject;
var
  vSQLQueryCabecalho : TFDQuery;
  vSQLQueryDetalhe   : TFDQuery;
  i                  : Integer;
  vCodOS             : Integer;
begin
  try
    try
      DM.StartTransaction;

      vSQLQueryCabecalho := TFDQuery.Create(nil);
      vSQLQueryDetalhe   := TFDQuery.Create(nil);

      vSQLQueryCabecalho.Connection := DM;
      vSQLQueryDetalhe.Connection   := DM;

      {$REGION 'CABE�ALHO DA OS'}

      vSQLQueryCabecalho.SQL.Clear;

      if pCodOSOficial = 0 then
      begin
        vSQLQueryCabecalho.SQL.Text := ' SELECT MAX(OS_CODIGO) AS OS_CODIGO FROM OS ';
        vSQLQueryCabecalho.Open;

        vCodOS := vSQLQueryCabecalho.FieldByName('OS_CODIGO').AsInteger;

        vSQLQueryCabecalho.SQL.Text :=  ' INSERT INTO OS                                                                         '+
                                        ' (OS_CODIGO, FUNC_CODIGO, CLI_CODIGO, OS_DATAABERTURA, OS_HORAABERTURA,                 '+
                                        ' OS_SOLICITACAO, OS_SITUACAO, OS_DATAENCERRAMENTO, FPG_CODIGO, OS_TOTALSERVICOS,        '+
                                        ' USU_CODIGO, OS_TOTALPRODUTOS, OS_TOTALGERAL, EMP_CODIGO, USU_CODIGO_ENCERRA,           '+
                                        ' OS_CODRESPONSAVELABERTURA, OS_CODRESPONSAVELENCERRAMENTO, CLAS_CODIGO, OSS_CODIGO,     '+
                                        ' OS_CODIGOLOCAL, OS_DATAULTIMAALTERACAO)                                                '+
                                        ' VALUES                                                                                 '+
                                        ' (:OS_CODIGO, :FUNC_CODIGO, :CLI_CODIGO, :OS_DATAABERTURA, :OS_HORAABERTURA,            '+
                                        ' :OS_SOLICITACAO, :OS_SITUACAO, :OS_DATAENCERRAMENTO, :FPG_CODIGO, :OS_TOTALSERVICOS,   '+
                                        ' :USU_CODIGO, :OS_TOTALPRODUTOS, :OS_TOTALGERAL, :EMP_CODIGO, :USU_CODIGO_ENCERRA,      '+
                                        ' :OS_CODRESPONSAVELABERTURA, :OS_CODRESPONSAVELENCERRAMENTO, :CLAS_CODIGO, :OSS_CODIGO, '+
                                        ' :OS_CODIGOLOCAL, :OS_DATAULTIMAALTERACAO)                                              '+
                                        ' RETURNING OS_CODIGO                                                                    ';

        vSQLQueryCabecalho.ParamByName('OS_CODIGO').AsInteger         := vCodOS + 1;
        vSQLQueryCabecalho.ParamByName('OS_CODIGOLOCAL').AsInteger    := pCodOSLocal;
      end
      else
      begin
        vSQLQueryCabecalho.SQL.Text :=  ' UPDATE OS                                                                                                                   '+
                                        ' SET FUNC_CODIGO = :FUNC_CODIGO, CLI_CODIGO = :CLI_CODIGO, OS_DATAABERTURA = :OS_DATAABERTURA,                               '+
                                        ' OS_HORAABERTURA = :OS_HORAABERTURA, OS_SOLICITACAO = :OS_SOLICITACAO, OS_SITUACAO = :OS_SITUACAO,                           '+
                                        ' OS_DATAENCERRAMENTO = :OS_DATAENCERRAMENTO, FPG_CODIGO = :FPG_CODIGO, OS_TOTALSERVICOS = :OS_TOTALSERVICOS,                 '+
                                        ' USU_CODIGO = :USU_CODIGO, OS_TOTALPRODUTOS = :OS_TOTALPRODUTOS, OS_TOTALGERAL = :OS_TOTALGERAL,                             '+
                                        ' EMP_CODIGO = :EMP_CODIGO, USU_CODIGO_ENCERRA = :USU_CODIGO_ENCERRA, OS_CODRESPONSAVELABERTURA = :OS_CODRESPONSAVELABERTURA, '+
                                        ' OS_CODRESPONSAVELENCERRAMENTO = :OS_CODRESPONSAVELENCERRAMENTO, CLAS_CODIGO = :CLAS_CODIGO, OSS_CODIGO = :OSS_CODIGO,       '+
                                        ' OS_DATAULTIMAALTERACAO = :OS_DATAULTIMAALTERACAO                                                                            '+
                                        ' WHERE OS_CODIGO = :OS_CODIGO                                                                                                '+
                                        ' RETURNING OS_CODIGO                                                                                                         ';

        vSQLQueryCabecalho.ParamByName('OS_CODIGO').AsInteger := pCodOSOficial;
      end;

      vSQLQueryCabecalho.ParamByName('FUNC_CODIGO').AsInteger                    := pFuncCodigo;
      vSQLQueryCabecalho.ParamByName('CLI_CODIGO').AsInteger                     := pCliCodigo;
      vSQLQueryCabecalho.ParamByName('OS_SOLICITACAO').AsString                  := pOSSolicitacao;
      vSQLQueryCabecalho.ParamByName('OS_SITUACAO').AsString                     := pOSSituacao;
      vSQLQueryCabecalho.ParamByName('OS_TOTALSERVICOS').AsFloat                 := pOsTotalServicos;
      vSQLQueryCabecalho.ParamByName('OS_TOTALPRODUTOS').AsFloat                 := pOSTotalProdutos;
      vSQLQueryCabecalho.ParamByName('OS_TOTALGERAL').AsFloat                    := pOSTotalGeral;
      vSQLQueryCabecalho.ParamByName('EMP_CODIGO').AsInteger                     := pEmpCodigo;
      vSQLQueryCabecalho.ParamByName('OS_DATAULTIMAALTERACAO').AsString          := pDtUltSincronizacao;

      if pOSDataAbertura <> '' then
        vSQLQueryCabecalho.ParamByName('OS_DATAABERTURA').AsString               := pOSDataAbertura
      else
      begin
        vSQLQueryCabecalho.ParamByName('OS_DATAABERTURA').DataType               := ftString;
        vSQLQueryCabecalho.ParamByName('OS_DATAABERTURA').Clear;
      end;

      if pOSHoraAbertura <> '' then
        vSQLQueryCabecalho.ParamByName('OS_HORAABERTURA').AsString               := pOSHoraAbertura
      else
      begin
        vSQLQueryCabecalho.ParamByName('OS_HORAABERTURA').DataType               := ftString;
        vSQLQueryCabecalho.ParamByName('OS_HORAABERTURA').Clear;
      end;

      if pOSDataEncerramento <> '' then
        vSQLQueryCabecalho.ParamByName('OS_DATAENCERRAMENTO').AsString           := pOSDataEncerramento
      else
      begin
        vSQLQueryCabecalho.ParamByName('OS_DATAENCERRAMENTO').DataType           := ftString;
        vSQLQueryCabecalho.ParamByName('OS_DATAENCERRAMENTO').Clear;
      end;

      if pOSCodResponsavelAbertura <> 0 then
        vSQLQueryCabecalho.ParamByName('OS_CODRESPONSAVELABERTURA').AsInteger    := pOSCodResponsavelAbertura
      else
      begin
        vSQLQueryCabecalho.ParamByName('OS_CODRESPONSAVELABERTURA').DataType     := ftInteger;
        vSQLQueryCabecalho.ParamByName('OS_CODRESPONSAVELABERTURA').Clear;
      end;

      if pOSCodResponsavelEncerramento <> 0 then
        vSQLQueryCabecalho.ParamByName('OS_CODRESPONSAVELENCERRAMENTO').AsInteger:= pOSCodResponsavelEncerramento
      else
      begin
        vSQLQueryCabecalho.ParamByName('OS_CODRESPONSAVELENCERRAMENTO').DataType := ftInteger;
        vSQLQueryCabecalho.ParamByName('OS_CODRESPONSAVELENCERRAMENTO').Clear;
      end;

      if pFpgCodigo <> 0 then
        vSQLQueryCabecalho.ParamByName('FPG_CODIGO').AsInteger                   := pFpgCodigo
      else
      begin
        vSQLQueryCabecalho.ParamByName('FPG_CODIGO').DataType                    := ftInteger;
        vSQLQueryCabecalho.ParamByName('FPG_CODIGO').Clear;
      end;

      if pOSSCodigo <> 0 then
        vSQLQueryCabecalho.ParamByName('OSS_CODIGO').AsInteger                   := pOSSCodigo
      else
      begin
        vSQLQueryCabecalho.ParamByName('OSS_CODIGO').DataType                    := ftInteger;
        vSQLQueryCabecalho.ParamByName('OSS_CODIGO').Clear;
      end;

      if pClasCodigo <> 0 then
        vSQLQueryCabecalho.ParamByName('CLAS_CODIGO').AsInteger                  := pClasCodigo
      else
      begin
        vSQLQueryCabecalho.ParamByName('CLAS_CODIGO').DataType                   := ftInteger;
        vSQLQueryCabecalho.ParamByName('CLAS_CODIGO').Clear;
      end;

      if pUsuCodigo <> 0 then
        vSQLQueryCabecalho.ParamByName('USU_CODIGO').AsInteger                   := pUsuCodigo
      else
      begin
        vSQLQueryCabecalho.ParamByName('USU_CODIGO').DataType                    := ftInteger;
        vSQLQueryCabecalho.ParamByName('USU_CODIGO').Clear;
      end;

      if pUsuCodigoEncerra <> 0 then
        vSQLQueryCabecalho.ParamByName('USU_CODIGO_ENCERRA').AsInteger           := pUsuCodigoEncerra
      else
      begin
        vSQLQueryCabecalho.ParamByName('USU_CODIGO_ENCERRA').DataType            := ftInteger;
        vSQLQueryCabecalho.ParamByName('USU_CODIGO_ENCERRA').Clear;
      end;

      vSQLQueryCabecalho.Open;

      pCodOSOficial := vSQLQueryCabecalho.FieldByName('OS_CODIGO').AsInteger;

      Result := vSQLQueryCabecalho.ToJSONObject;
      {$ENDREGION}


      {$REGION 'DETALHES DA OS'}

      {$REGION 'EXCLUS�O DOS PRODUTOS/SERVICOS/SERVICOSTERCEIROS'}
      vSQLQueryDetalhe.SQL.Clear;

      vSQLQueryDetalhe.SQL.Text :=    ' DELETE FROM OSPRODUTO        '+
                                      ' WHERE OS_CODIGO = :OS_CODIGO ';

      vSQLQueryDetalhe.ParamByName('OS_CODIGO').AsInteger := pCodOSOficial;
      vSQLQueryDetalhe.ExecSQL;

      vSQLQueryDetalhe.SQL.Clear;

      vSQLQueryDetalhe.SQL.Text :=    ' DELETE FROM OSSERVICO        '+
                                      ' WHERE OS_CODIGO = :OS_CODIGO ';

      vSQLQueryDetalhe.ParamByName('OS_CODIGO').AsInteger := pCodOSOficial;
      vSQLQueryDetalhe.ExecSQL;

      vSQLQueryDetalhe.SQL.Clear;

      vSQLQueryDetalhe.SQL.Text :=    ' DELETE FROM OSSERVICOTERCEIROS  '+
                                      ' WHERE OS_CODIGO = :OS_CODIGO    ';

      vSQLQueryDetalhe.ParamByName('OS_CODIGO').AsInteger := pCodOSOficial;
      vSQLQueryDetalhe.ExecSQL;
      {$ENDREGION}

      {$REGION 'PRODUTOS'}
      for I := 0 to pProdutos.Size - 1 do
      begin
        vSQLQueryDetalhe.SQL.Clear;

        vSQLQueryDetalhe.SQL.Text :=    ' INSERT INTO OSPRODUTO                                        '+
                                        ' (OS_CODIGO, PROD_CODIGO, PROD_DESCRICAO, OSP_QUANTIDADE,     '+
                                        ' OSP_VALOR, OSP_CODIGO, OSP_TOTAL)                            '+
                                        ' VALUES                                                       '+
                                        ' (:OS_CODIGO, :PROD_CODIGO, :PROD_DESCRICAO, :OSP_QUANTIDADE, '+
                                        ' :OSP_VALOR, :OSP_CODIGO, :OSP_TOTAL)                         ';

        vSQLQueryDetalhe.ParamByName('OS_CODIGO').AsInteger       := pCodOSOficial;
        vSQLQueryDetalhe.ParamByName('OSP_CODIGO').AsInteger      := I + 1;
        vSQLQueryDetalhe.ParamByName('PROD_CODIGO').AsInteger     := pProdutos[i].GetValue<integer>('prod_codigo',0);
        vSQLQueryDetalhe.ParamByName('PROD_DESCRICAO').AsString   := pProdutos[i].GetValue<string>('prod_descricao','');
        vSQLQueryDetalhe.ParamByName('OSP_QUANTIDADE').AsFloat    := pProdutos[i].GetValue<double>('osp_quantidade',0);
        vSQLQueryDetalhe.ParamByName('OSP_VALOR').AsFloat         := pProdutos[i].GetValue<double>('osp_valor',0);
        vSQLQueryDetalhe.ParamByName('OSP_TOTAL').AsFloat         := pProdutos[i].GetValue<double>('osp_total',0);

        vSQLQueryDetalhe.ExecSQL;
      end;
      {$ENDREGION}

      {$REGION 'SERVICOS'}
      for I := 0 to pServicos.Size - 1 do
      begin
        vSQLQueryDetalhe.SQL.Clear;

        vSQLQueryDetalhe.SQL.Text :=    ' INSERT INTO OSSERVICO                                             '+
                                        ' (OSS_CODIGO, OS_CODIGO, SE_CODIGO, OSS_DESCRICAO, OSS_VALOR,      '+
                                        ' OSS_QUANTIDADE, FUNC_CODIGO, OSS_TOTAL)                           '+
                                        ' VALUES                                                            '+
                                        ' (:OSS_CODIGO, :OS_CODIGO, :SE_CODIGO, :OSS_DESCRICAO, :OSS_VALOR, '+
                                        ' :OSS_QUANTIDADE, :FUNC_CODIGO, :OSS_TOTAL)                        ';

        vSQLQueryDetalhe.ParamByName('OSS_CODIGO').AsInteger    := I + 1;
        vSQLQueryDetalhe.ParamByName('OS_CODIGO').AsInteger     := pCodOSOficial;
        vSQLQueryDetalhe.ParamByName('SE_CODIGO').AsInteger     := pServicos[i].GetValue<integer>('se_codigo',0);
        vSQLQueryDetalhe.ParamByName('OSS_DESCRICAO').AsString  := pServicos[i].GetValue<string>('oss_descricao','');
        vSQLQueryDetalhe.ParamByName('OSS_QUANTIDADE').AsFloat  := pServicos[i].GetValue<double>('oss_quantidade',0);
        vSQLQueryDetalhe.ParamByName('OSS_VALOR').AsFloat       := pServicos[i].GetValue<double>('oss_valor',0);
        vSQLQueryDetalhe.ParamByName('OSS_TOTAL').AsFloat       := pServicos[i].GetValue<double>('oss_total',0);

        vSQLQueryDetalhe.ExecSQL;
      end;
      {$ENDREGION}

      {$REGION 'SERVICOS TERCEIROS'}
      if pServicosTerceiros.Size > 1 then
      begin
        for I := 0 to pServicosTerceiros.Size - 1 do
          begin
            vSQLQueryDetalhe.SQL.Clear;

            vSQLQueryDetalhe.SQL.Text :=    ' INSERT INTO OSSERVICOTERCEIROS                                    '+
                                            ' (OSST_CODIGO, OS_CODIGO, SE_CODIGO, OST_DESCRICAO, OST_VALOR,     '+
                                            ' OST_QUANTIDADE, FUNC_CODIGO, OST_TOTAL)                           '+
                                            ' VALUES                                                            '+
                                            ' (:OSS_CODIGO, :OS_CODIGO, :SE_CODIGO, :OST_DESCRICAO, :OST_VALOR, '+
                                            ' :OST_QUANTIDADE, :FUNC_CODIGO, :OST_TOTAL)                        ';

            vSQLQueryDetalhe.ParamByName('OSST_CODIGO').AsInteger    := I + 1;
            vSQLQueryDetalhe.ParamByName('OS_CODIGO').AsInteger      := pCodOSOficial;
            vSQLQueryDetalhe.ParamByName('SE_CODIGO').AsInteger      := pServicosTerceiros[i].GetValue<integer>('se_codigo',0);
            vSQLQueryDetalhe.ParamByName('OST_DESCRICAO').AsString   := pServicosTerceiros[i].GetValue<string>('ost_descricao','');
            vSQLQueryDetalhe.ParamByName('OST_QUANTIDADE').AsFloat   := pServicosTerceiros[i].GetValue<double>('ost_quantidade',0);
            vSQLQueryDetalhe.ParamByName('OST_VALOR').AsFloat        := pServicosTerceiros[i].GetValue<double>('ost_valor',0);
            vSQLQueryDetalhe.ParamByName('OST_TOTAL').AsFloat        := pServicosTerceiros[i].GetValue<double>('ost_total',0);

            vSQLQueryDetalhe.ExecSQL;
          end;
      end;
      {$ENDREGION}

      {$ENDREGION}

      DM.Commit;

    except on e:Exception do
      begin
        DM.Rollback;
        raise Exception.Create('Erro ao inserir ou atualizar OS: ' + e.Message);
      end;
    end;
  finally
    FreeAndNil(vSQLQueryCabecalho);
  end;
end;


function TDMGlobal.fListarProdutos(pDtUltSincronizacao: String; pPagina: Integer) : TJSONArray;
var
  vSQLQuery  : TFDQuery;
begin
  if pDtUltSincronizacao = '' then
    raise Exception.Create('Par�metro dt_ult_sincronizacao n�o informado');
  try
    vSQLQuery            := TFDQuery.Create(nil);
    vsQLQuery.Connection := DM;

    vSQLQuery.SQL.Clear;
    vSQLQuery.SQL.Text := ' SELECT FIRST :FIRST SKIP :SKIP                                                          '+
                          ' PROD_CODIGO, PROD_DESCRICAO, GRU_CODIGO, FAB_CODIGO, UNI_SIGLA, UNI_SIGLACOMPRA,        '+
                          ' PROD_REFERENCIA, PROD_VALORCUSTO, PROD_VALORVENDA, PROD_VALORCOMPRA, PROD_SITUACAO,     '+
                          ' PROD_NCM, PROD_CEST, PROD_OBS, PROD_PESOLIQUIDO, PROD_PESOBRUTO, PROD_DTULTIMAALTERACAO '+
                          ' FROM PRODUTO                                                                            '+
                          ' WHERE PROD_DTULTIMAALTERACAO > :PROD_DTULTIMAALTERACAO                                  '+
                          ' ORDER BY 1                                                                              ';

    vSQLQuery.ParamByName('PROD_DTULTIMAALTERACAO').AsString := pDtUltSincronizacao;
    vSQLQuery.ParamByName('FIRST').AsInteger                 := cQTD_REG_PAGINA_PRODUTO;
    vSQLQuery.ParamByName('SKIP').AsInteger                  := (pPagina * cQTD_REG_PAGINA_PRODUTO) - cQTD_REG_PAGINA_PRODUTO;

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONArray;

  finally
    FreeAndNil(vSQLQuery);
  end;

end;

function TDMGlobal.fInserirEditarProduto(pCodigoProdLocal, pGruCodigo, pFabCodigo: Integer;
pUniSigla, pProdCodigoBarra, pProdReferencia, pProdDescricao: String;
pProdValorCusto, pProdLucro, pProdValorVenda: Double; pProdSituacao: String;
pProdValorCompra: Double; pUniSiglaCompra, pProdNCM: String;
pProdPesoLiq, pProdPesoBruto: Double; pProdDtUltOS: String;
pTipoCodigo: Integer; pProdDtUltAlt, pProdInfAdic, pProdOBS, pProdCEST: String;
pCodigoProdOficial: Integer): TJSONObject;
var
  vSQLQuery   : TFDQuery;
  vCodProdAux : Integer;
begin
  try
    vSQLQuery            := TFDQuery.Create(nil);
    vsQLQuery.Connection := DM;
    vSQLQuery.SQL.Clear;

    if pCodigoProdOficial = 0 then
    begin
      vSQLQuery.SQL.Text := ' SELECT MAX(PROD_CODIGO) AS PROD_CODIGO FROM PRODUTO ';
      vSQLQuery.Open;
      vCodProdAux := vSQLQuery.FieldByName('PROD_CODIGO').AsInteger;

      vSQLQuery.SQL.Text := ' INSERT INTO PRODUTO                                                                                           '+
                            ' (PROD_CODIGO, GRU_CODIGO, FAB_CODIGO, UNI_SIGLA, PROD_CODIGO_BARRA, PROD_REFERENCIA, PROD_DESCRICAO,          '+
                            ' PROD_VALORCUSTO, PROD_LUCRO, PROD_VALORVENDA, PROD_SITUACAO, PROD_VALORCOMPRA, UNI_SIGLACOMPRA,               '+
                            ' PROD_NCM, PROD_PESOLIQUIDO, PROD_PESOBRUTO, PROD_DTULTIMAOS, PTIPO_CODIGO, PROD_DTULTIMAALTERACAO,            '+
                            ' PROD_INFADICIONAIS, PROD_OBS, PROD_CEST)                                                                      '+
                            ' VALUES                                                                                                        '+
                            ' (:PROD_CODIGO, :GRU_CODIGO, :FAB_CODIGO, :UNI_SIGLA, :PROD_CODIGO_BARRA, :PROD_REFERENCIA, :PROD_DESCRICAO,   '+
                            ' :PROD_VALORCUSTO, :PROD_LUCRO, :PROD_VALORVENDA, :PROD_SITUACAO, :PROD_VALORCOMPRA, :UNI_SIGLACOMPRA,         '+
                            ' :PROD_NCM, :PROD_PESOLIQUIDO, :PROD_PESOBRUTO, :PROD_DTULTIMAOS, :PTIPO_CODIGO, :PROD_DTULTIMAALTERACAO,      '+
                            ' :PROD_INFADICIONAIS, :PROD_OBS, :PROD_CEST)                                                                   '+
                            ' RETURNING PROD_CODIGO                                                                                         ';

      vSQLQuery.ParamByName('PROD_CODIGO').AsInteger := vCodProdAux + 1;
    end
    else
    begin
      vSQLQuery.SQL.Text := ' UPDATE PRODUTO                                                                                                                                                  '+
                            ' SET GRU_CODIGO = :GRU_CODIGO, FAB_CODIGO = :FAB_CODIGO, UNI_SIGLA = :UNI_SIGLA, PROD_CODIGO_BARRA = :PROD_CODIGO_BARRA,                                         '+
                            ' PROD_REFERENCIA = :PROD_REFERENCIA, PROD_DESCRICAO = :PROD_DESCRICAO, PROD_VALORCUSTO = :PROD_VALORCUSTO, PROD_LUCRO = :PROD_LUCRO,                             '+
                            ' PROD_VALORVENDA = :PROD_VALORVENDA, PROD_SITUACAO = :PROD_SITUACAO, PROD_VALORCOMPRA = :PROD_VALORCOMPRA, UNI_SIGLACOMPRA = :UNI_SIGLACOMPRA,                   '+
                            ' PROD_NCM = :PROD_NCM, PROD_PESOLIQUIDO = :PROD_PESOLIQUIDO, PROD_PESOBRUTO = :PROD_PESOBRUTO, PROD_DTULTIMAOS = :PROD_DTULTIMAOS, PTIPO_CODIGO = :PTIPO_CODIGO, '+
                            ' PROD_DTULTIMAALTERACAO = :PROD_DTULTIMAALTERACAO, PROD_INFADICIONAIS = :PROD_INFADICIONAIS, PROD_OBS = :PROD_OBS, PROD_CEST = :PROD_CEST                        '+
                            ' WHERE PROD_CODIGO = :PROD_CODIGO                                                                                                                                '+
                            ' RETURNING PROD_CODIGO                                                                                                                                           ';

      vSQLQuery.ParamByName('PROD_CODIGO').AsInteger := pCodigoProdOficial;
    end;

    if pGruCodigo <> 0 then
      vSQLQuery.ParamByName('GRU_CODIGO').AsInteger           := pGruCodigo
    else
    begin
      vSQLQuery.ParamByName('GRU_CODIGO').DataType            := ftInteger;
      vSQLQuery.ParamByName('GRU_CODIGO').Clear;
    end;

    if pFabCodigo <> 0 then
      vSQLQuery.ParamByName('FAB_CODIGO').AsInteger           := pFabCodigo
    else
    begin
      vSQLQuery.ParamByName('FAB_CODIGO').DataType            := ftInteger;
      vSQLQuery.ParamByName('FAB_CODIGO').Clear;
    end;

    if pUniSigla <> '' then
      vSQLQuery.ParamByName('UNI_SIGLA').AsString             := pUniSigla
    else
    begin
      vSQLQuery.ParamByName('UNI_SIGLA').DataType             := ftString;
      vSQLQuery.ParamByName('UNI_SIGLA').Clear;
    end;

    if pProdCodigoBarra <> '' then
      vSQLQuery.ParamByName('PROD_CODIGO_BARRA').AsString     := pProdCodigoBarra
    else
    begin
      vSQLQuery.ParamByName('PROD_CODIGO_BARRA').DataType     := ftString;
      vSQLQuery.ParamByName('PROD_CODIGO_BARRA').Clear;
    end;

    if pProdReferencia <> '' then
      vSQLQuery.ParamByName('PROD_REFERENCIA').AsString       := pProdReferencia

    else
    begin
      vSQLQuery.ParamByName('PROD_REFERENCIA').DataType       := ftString;
      vSQLQuery.ParamByName('PROD_REFERENCIA').Clear;
    end;


    vSQLQuery.ParamByName('PROD_DESCRICAO').AsString          := pProdDescricao;
    vSQLQuery.ParamByName('PROD_VALORCUSTO').AsFloat          := pProdValorCusto;
    vSQLQuery.ParamByName('PROD_LUCRO').AsFloat               := pProdLucro;
    vSQLQuery.ParamByName('PROD_VALORVENDA').AsFloat          := pProdValorVenda;
    vSQLQuery.ParamByName('PROD_SITUACAO').AsString           := pProdSituacao;
    vSQLQuery.ParamByName('PROD_VALORCOMPRA').AsFloat         := pProdValorCompra;

    if pUniSiglaCompra <> '' then
      vSQLQuery.ParamByName('UNI_SIGLACOMPRA').AsString       := pUniSiglaCompra
    else
    begin
      vSQLQuery.ParamByName('UNI_SIGLACOMPRA').DataType       := ftString;
      vSQLQuery.ParamByName('UNI_SIGLACOMPRA').Clear;
    end;

    vSQLQuery.ParamByName('PROD_NCM').AsString                := pProdNCM;
    vSQLQuery.ParamByName('PROD_PESOLIQUIDO').AsFloat         := pProdPesoLiq;
    vSQLQuery.ParamByName('PROD_PESOBRUTO').AsFloat           := pProdPesoBruto;

    if pProdDtUltOS <> '' then
      vSQLQuery.ParamByName('PROD_DTULTIMAOS').AsString       := pProdDtUltOS
    else
    begin
      vSQLQuery.ParamByName('PROD_DTULTIMAOS').DataType       := ftString;
      vSQLQuery.ParamByName('PROD_DTULTIMAOS').Clear;
    end;

    if pTipoCodigo <> 0 then
      vSQLQuery.ParamByName('PTIPO_CODIGO').AsInteger         := pTipoCodigo
    else
    begin
      vSQLQuery.ParamByName('PTIPO_CODIGO').DataType          := ftInteger;
      vSQLQuery.ParamByName('PTIPO_CODIGO').Clear;
    end;

    if pProdDtUltAlt <> '' then
      vSQLQuery.ParamByName('PROD_DTULTIMAALTERACAO').AsString  := pProdDtUltAlt
    else
    begin
      vSQLQuery.ParamByName('PROD_DTULTIMAALTERACAO').DataType  := ftString;
      vSQLQuery.ParamByName('PROD_DTULTIMAALTERACAO').Clear;
    end;

    vSQLQuery.ParamByName('PROD_INFADICIONAIS').AsString      := pProdInfAdic;
    vSQLQuery.ParamByName('PROD_OBS').AsString                := pProdOBS;
    vSQLQuery.ParamByName('PROD_CEST').AsString               := pProdCEST;

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONObject;
  finally
    FreeAndNil(vSQLQuery);
  end;
end;


end.
