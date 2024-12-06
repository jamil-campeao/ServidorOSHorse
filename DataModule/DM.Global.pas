unit DM.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait, System.IniFiles, FireDAC.Phys.IBBase, FireDac.DApt,
  System.JSON, DataSet.Serialize, uMD5;

type
  TDMGlobal = class(TDataModule)
    DM: TFDConnection;
    DriverLink: TFDPhysFBDriverLink;
    procedure DMBeforeConnect(Sender: TObject);
  private
    procedure fCarregaConfigDB(pConexao: TFDConnection);
    procedure fValidaLoginUsuario(pLogin: string; var vSQLQuery: TFDQuery; pEditando: Boolean; pCodUsuario: Integer = 0);
    function fListarProdutosOS(pCodPedido: Integer;
      pSQLQuery: TFDQuery): TJsonArray;
    function fListarServicosOS(pCodPedido: Integer;
      pSQLQuery: TFDQuery): TJsonArray;
    { Private declarations }
  public
    function fLogin(pCodUsuario: Integer; pSenha: String): TJsonObject;
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
        raise Exception.Create('Arquivo dbxconnections.ini não encontrado: ' + vArq);

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

procedure TDMGlobal.DMBeforeConnect(Sender: TObject);
begin
  fCarregaConfigDB(DM);
end;

function TDMGlobal.fLogin(pCodUsuario: Integer; pSenha: String): TJsonObject;
var
  vSQLQuery : TFDQuery;
begin
  if (pCodUsuario <= 0) or (pSenha = '') then
    raise Exception.Create('Parâmetro cod_usuário ou senha não informados');

  vSQLQuery := TFDQuery.Create(nil);
  try
    vSQLQuery.Connection := DM;
    vSQLQuery.SQL.Clear;

    vSQLQuery.SQL.Text := ' SELECT                         '+
                          ' USU_CODIGO,                    '+
                          ' USU_LOGIN                      '+
                          ' FROM USUARIO                   '+
                          ' WHERE USU_CODIGO = :USU_CODIGO '+
                          ' AND USU_SENHA =   :SENHA       ';

    vSQLQuery.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;
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
    raise Exception.Create('Parâmetros nome, login ou senha não informados');

  if (pSenha.Length < 8) then
    raise Exception.Create('Senha informada deve conter entre 8 a 20 caracteres');

  vSQLQueryInsert := TFDQuery.Create(nil);
  vSQLQuerySelect := TFDQuery.Create(nil);
  try
    vSQLQueryInsert.Connection := DM;
    vSQLQuerySelect.Connection := DM;

    vSQLQueryInsert.SQL.Clear;
    vSQLQuerySelect.SQL.Clear;

    fValidaLoginUsuario(pLogin, vSQLQuerySelect, False); //Validação de Login já existente

    vSQLQuerySelect.SQL.Text := ' SELECT MAX(USU_CODIGO) AS USU_CODIGO FROM USUARIO ';
    vSQLQuerySelect.Open;

    vSQLQueryInsert.SQL.Text := ' INSERT INTO USUARIO                                           '+
                                ' (USU_CODIGO, USU_NOME, USU_LOGIN, USU_SENHA, EMP_CODIGO)      '+
                                ' VALUES                                                        '+
                                ' (:USU_CODIGO, :USU_NOME, :USU_LOGIN, :USU_SENHA, :EMP_CODIGO) '+
                                ' RETURNING USU_CODIGO                                          ';

    vSQLQueryInsert.ParamByName('USU_CODIGO').AsInteger  := vSQLQuerySelect.FieldByName('USU_CODIGO').AsInteger + 1;
    vSQLQueryInsert.ParamByName('USU_NOME').AsString     := pNomeUsuario;
    vSQLQueryInsert.ParamByName('USU_LOGIN').AsString    := pLogin;
    vSQLQueryInsert.ParamByName('USU_SENHA').AsString    := fSaltPassword(pSenha);
    vSQLQueryInsert.ParamByName('EMP_CODIGO').AsInteger  := 1; {Estou setando fixo temporariamente, para
                                                                decidir depois como irá ser feito essa parte da empresa}

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
    raise Exception.Create('Informe o token_push do usuário');
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
    raise Exception.Create('Informe o nome e o login do usuário');
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
  //Validação do login
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
    raise Exception.Create('O login informado está em uso por outra conta de usuário');
end;

function TDMGlobal.fEditarSenha(pCodUsuario: Integer; pSenha: String) : TJSONObject;
var
  vSQLQuery : TFDQuery;
begin
  if pSenha.IsEmpty then
    raise Exception.Create('Informe a nova senha do usuário');

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
    raise Exception.Create('Parâmetro dt_ult_sincronizacao não informado');
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
    raise Exception.Create('Parâmetro dt_ult_sincronizacao não informado');
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
                                ' OS_DATA_ULTIMA_ALTERACAO                                   '+
                                ' FROM OS                                                    '+
                                ' WHERE OS_DATA_ULTIMA_ALTERACAO > :OS_DATA_ULTIMA_ALTERACAO '+
                                ' AND USU_CODIGO = :USU_CODIGO                               '+
                                ' ORDER BY 1                                                 ';

    vSQLQuerySelect.ParamByName('OS_DATA_ULTIMA_ALTERACAO').AsString := pDtUltSincronizacao;
    vSQLQuerySelect.ParamByName('FIRST').AsInteger                   := cQTD_REG_PAGINA_OS;
    vSQLQuerySelect.ParamByName('SKIP').AsInteger                    := (pPagina * cQTD_REG_PAGINA_OS) - cQTD_REG_PAGINA_OS;
    vSQLQuerySelect.ParamByName('USU_CODIGO').AsInteger              := pCodUsuario;


    vSQLQuerySelect.Active := True;

    vOS := vSQLQuerySelect.ToJSONArray;

    for I := 0 to vOS.Size - 1 do
        (vOS[i] as TJSONObject).AddPair('itens_produtos', fListarProdutosOS(vOS[i].GetValue<integer>('osCodigo', 0), vSQLQuerySelect));

    for I := 0 to vOS.Size - 1 do
        (vOS[i] as TJSONObject).AddPair('itens_servicos', fListarServicosOS(vOS[i].GetValue<integer>('osCodigo', 0), vSQLQuerySelect));


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





end.
