unit Controllers.Cliente;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT;

procedure RegistrarRotas;
procedure ListarClientes(Req: THorseRequest; Res: THorseResponse);
//procedure InserirEditarCliente(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/clientes/sincronizacao', ListarClientes);

//  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
//  .Post('/clientes/sincronizacao', InserirEditarCliente);
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

//procedure InserirEditarCliente(Req: THorseRequest; Res: THorseResponse);
//var
//  DmGlobal: TDMGlobal;
//  vCodUsuario: Integer;
//  vBody, vJsonRet : TJsonObject;
//begin
//  try
//    try
//      DmGlobal    := TDMGlobal.Create(Nil);
//      vCodUsuario := fGetUsuarioRequest(Req);
//      vBody       := Req.Body<TJSONObject>;
//
//      vJsonRet := DmGlobal.fInserirEditarCliente(vCodUsuario,
//                                                vbody.GetValue<integer>('cod_cliente',0),
//                                                vbody.GetValue<string>('cnpj_cpf',''),
//                                                vbody.GetValue<string>('nome',''),
//                                                vbody.GetValue<string>('fone',''),
//                                                vbody.GetValue<string>('email',''),
//                                                vbody.GetValue<string>('endereco',''),
//                                                vbody.GetValue<string>('numero',''),
//                                                vbody.GetValue<string>('complemento',''),
//                                                vbody.GetValue<string>('bairro',''),
//                                                vbody.GetValue<string>('cidade',''),
//                                                vbody.GetValue<string>('uf',''),
//                                                vbody.GetValue<string>('cep',''),
//                                                vbody.GetValue<double>('latitude',0),
//                                                vbody.GetValue<double>('longitude',0),
//                                                vbody.GetValue<double>('limite_disponivel',0),
//                                                vbody.GetValue<integer>('cod_cliente_oficial',0),
//                                                vbody.GetValue<string>('dt_ult_sincronizacao','')
//                                                );
//
//      vJsonRet.AddPair('cod_cliente_local', TJSONNumber.Create(vBody.GetValue<integer>('cod_cliente_local',0)));
//
//      {"cod_cliente_local": 250, "cod_cliente_oficial": 4500}
//      Res.Send<TJsonObject>(vJSonRet).Status(200);
//
//    except on e: Exception do
//      Res.Send(e.Message).Status(500);
//    end;
//  finally
//    FreeAndNil(DmGlobal);
//  end;
//end;


end.
