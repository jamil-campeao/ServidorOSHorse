unit Controllers.OS;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT, Horse.Upload, System.Classes,
FMX.Graphics;

procedure RegistrarRotas;
procedure ListarOS(Req: THorseRequest; Res: THorseResponse);
procedure InserirEditarOS(Req: THorseRequest; Res: THorseResponse);


implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/os/sincronizacao', ListarOS);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Post('/os/sincronizacao', InserirEditarOS);
end;

procedure ListarOS(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal             : TDMGlobal;
  vDtUltSincronizacao  : String;
  vPagina, vCodUsuario : Integer;
begin
  try
    try
      DmGlobal    := TDMGlobal.Create(Nil);

      vCodUsuario := fGetUsuarioRequest(Req);

      try
        vDtUltSincronizacao := Req.Query['dt_ult_sincronizacao'];
      except
        vDtUltSincronizacao := '';
      end;

      try
        vPagina := Req.Query['pagina'].ToInteger;
      except
        vPagina := 1;
      end;

      Res.Send<TJsonArray>(DmGlobal.fListarOS(vDtUltSincronizacao, vCodUsuario, vPagina)).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure InserirEditarOS(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal           : TDMGlobal;
  vCodUsuario        : Integer;
  vBody, vJsonRet    : TJsonObject;
  vProdutos          : TJsonArray;
  vServicos          : TJsonArray;
  vServicosTerceiros : TJsonArray;
begin
  try
    try
      DmGlobal            := TDMGlobal.Create(Nil);
      vCodUsuario         := fGetUsuarioRequest(Req);
      vBody               := Req.Body<TJSONObject>;
      vProdutos           := vBody.GetValue<TJsonArray>('produtos');
      vServicos           := vBody.GetValue<TJsonArray>('servicos');
      vServicosTerceiros  := vBody.GetValue<TJsonArray>('servicos_terceiros');

      vJsonRet := DmGlobal.fInserirEditarOS(vCodUsuario,
                                            vbody.GetValue<integer>('cod_os_local',0),
                                            vbody.GetValue<integer>('func_codigo',0),
                                            vbody.GetValue<integer>('cli_codigo',0),
                                            vbody.GetValue<string>('os_dataabertura',''),
                                            vbody.GetValue<string>('os_horaabertura',''),
                                            vbody.GetValue<string>('os_solicitacao',''),
                                            vbody.GetValue<string>('os_situacao',''),
                                            vbody.GetValue<string>('os_dataencerramento',''),
                                            vbody.GetValue<integer>('fpg_codigo',0),
                                            vbody.GetValue<double>('os_totalservicos',0),
                                            vbody.GetValue<integer>('usu_codigo',0),
                                            vbody.GetValue<double>('os_totalprodutos',0),
                                            vbody.GetValue<double>('os_totalgeral',0),
                                            vbody.GetValue<integer>('emp_codigo',0),
                                            vbody.GetValue<integer>('usu_codigo_encerra',0),
                                            vbody.GetValue<integer>('os_codresponsavelabertura',0),
                                            vbody.GetValue<integer>('os_codresponsavelencerramento',0),
                                            vbody.GetValue<integer>('clas_codigo',0),
                                            vbody.GetValue<integer>('oss_codigo',0),
                                            vbody.GetValue<integer>('cod_os_oficial',0),
                                            vbody.GetValue<string>('dt_ult_sincronizacao',''),
                                            vProdutos,
                                            vServicos,
                                            vServicosTerceiros
                                            );

      vJsonRet.AddPair('cod_os_local', TJSONNumber.Create(vBody.GetValue<integer>('cod_os_local',0)));

      {"cod_pedido_local": 250, "cod_pedido_oficial": 4500}
      Res.Send<TJsonObject>(vJSonRet).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;


end.
