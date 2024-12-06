unit Controllers.Cliente;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT;

procedure RegistrarRotas;
procedure ListarClientes(Req: THorseRequest; Res: THorseResponse);
procedure InserirEditarCliente(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/clientes/sincronizacao', ListarClientes);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Post('/clientes/sincronizacao', InserirEditarCliente);
end;


procedure ListarClientes(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal        : TDMGlobal;
  vDtUltAlteracao : String;
  vPagina         : Integer;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);

      try
        vDtUltAlteracao := Req.Query['dt_ult_sincronizacao'];
      except
        vDtUltAlteracao := '';
      end;

      try
        vPagina := Req.Query['pagina'].ToInteger;
      except
        vPagina := 1;
      end;

      Res.Send<TJsonArray>(DmGlobal.fListarClientes(vDtUltAlteracao, vPagina)).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure InserirEditarCliente(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal: TDMGlobal;
  vCodUsuario: Integer;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal    := TDMGlobal.Create(Nil);
      vCodUsuario := fGetUsuarioRequest(Req);
      vBody       := Req.Body<TJSONObject>;

      vJsonRet := DmGlobal.fInserirEditarCliente(vbody.GetValue<integer>('cli_codigo_local',0),
                                                 vbody.GetValue<integer>('cid_codigo',0),
                                                 vbody.GetValue<string>('cli_nome',''),
                                                 vbody.GetValue<string>('cli_endereco',''),
                                                 vbody.GetValue<string>('cli_numero',''),
                                                 vbody.GetValue<string>('cli_bairro',''),
                                                 vbody.GetValue<string>('cli_complemento',''),
                                                 vbody.GetValue<string>('cli_email',''),
                                                 vbody.GetValue<string>('cli_telefone',''),
                                                 vbody.GetValue<string>('cli_cel',''),
                                                 vbody.GetValue<string>('cli_cpf',''),
                                                 vbody.GetValue<string>('cli_data_ult_alteracao',''),
                                                 vbody.GetValue<string>('cli_rg',''),
                                                 vbody.GetValue<string>('cli_cnpj',''),
                                                 vbody.GetValue<string>('cli_ie',''),
                                                 vbody.GetValue<string>('cli_im',''),
                                                 vbody.GetValue<string>('cli_data_nasc',''),
                                                 vbody.GetValue<string>('cli_cep',''),
                                                 vbody.GetValue<string>('cli_razaosocial',''),
                                                 vbody.GetValue<string>('cli_empresa',''),
                                                 vbody.GetValue<string>('cli_empresafone',''),
                                                 vbody.GetValue<string>('cli_empresaender',''),
                                                 vbody.GetValue<string>('cli_empresanumero',''),
                                                 vbody.GetValue<string>('cli_empresabairro',''),
                                                 vbody.GetValue<string>('cli_empresacomple',''),
                                                 vbody.GetValue<integer>('cid_empresa'),
                                                 vbody.GetValue<string>('cli_tipopessoa',''),
                                                 vbody.GetValue<string>('cli_situacaoreceita',''),
                                                 vbody.GetValue<string>('cli_datasituacao',''),
                                                 vbody.GetValue<string>('cli_classificacao',''),
                                                 vbody.GetValue<string>('cli_datacadastro',''),
                                                 vbody.GetValue<integer>('usu_codigo_cadastro'),
                                                 vbody.GetValue<string>('cli_situacao',''),
                                                 vbody.GetValue<string>('cli_regimetributatio',''),
                                                 vbody.GetValue<string>('cli_obs',''),
                                                 vbody.GetValue<string>('cli_sexo',''),
                                                 vbody.GetValue<integer>('cod_cliente_oficial',0),
                                                 vCodUsuario
                                                );

      vJsonRet.AddPair('cli_codigo_local', TJSONNumber.Create(vBody.GetValue<integer>('cli_codigo_local',0)));

      {"cod_cliente_local": 250, "cod_cliente_oficial": 4500}
      Res.Send<TJsonObject>(vJSonRet).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;


end.
