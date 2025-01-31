unit Controllers.Servico;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT;

procedure RegistrarRotas;
procedure ListarServicos(Req: THorseRequest; Res: THorseResponse);
procedure InserirEditarServico(Req: THorseRequest; Res: THorseResponse);
procedure ListarServicosLC(Req: THorseRequest; Res: THorseResponse);
//procedure InativarServico(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
//  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
//                  .Delete('/usuarios/:cod_usuario', InativarUsuario);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSecret, THorseJWTConfig.New.SessionClass(TMyClaims)))
                  .Post('/servicos/sincronizacao', InserirEditarServico);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSecret, THorseJWTConfig.New.SessionClass(TMyClaims)))
                  .Get('/servicos/sincronizacao', ListarServicos);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSecret, THorseJWTConfig.New.SessionClass(TMyClaims)))
                  .Get('/servicos/lc/sincronizacao', ListarServicosLC);
end;

procedure ListarServicos(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal: TDMGlobal;
  vDtUltSincronizacao: String;
  vPagina : Integer;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);

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

      Res.Send<TJsonArray>(DmGlobal.fListarServicos(vDtUltSincronizacao, vPagina)).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure InserirEditarServico(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal        : TDMGlobal;
  vCodUsuario     : Integer;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal    := TDMGlobal.Create(Nil);
      vCodUsuario := fGetUsuarioRequest(Req);
      vBody       := Req.Body<TJSONObject>;

      vJsonRet := DmGlobal.fInserirEditarServico(vbody.GetValue<integer>('se_codigo_local',0),
                                                 vbody.GetValue<string>('se_descricao',''),
                                                 vbody.GetValue<currency>('se_valor',0),
                                                 vbody.GetValue<integer>('lc_codigo',0),
                                                 vbody.GetValue<integer>('se_codigo_oficial',0),
                                                 vbody.GetValue<string>('se_dtultimaalteracao',''),
                                                 vbody.GetValue<integer>('emp_id',0)
                                                 );

      vJsonRet.AddPair('se_codigo_local', TJSONNumber.Create(vBody.GetValue<integer>('se_codigo_local',0)));

      {"se_produto_local": 250, "se_produto_oficial": 4500}
      Res.Send<TJsonObject>(vJSonRet).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure ListarServicosLC(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal: TDMGlobal;
  vPagina : Integer;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);

      try
        vPagina := Req.Query['pagina'].ToInteger;
      except
        vPagina := 1;
      end;

      Res.Send<TJsonArray>(DmGlobal.fListarServicosLC(vPagina)).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;


end.
