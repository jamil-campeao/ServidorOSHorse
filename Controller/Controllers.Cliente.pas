unit Controllers.Cliente;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT;

procedure RegistrarRotas;
procedure ListarClientes(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/clientes/sincronizacao', ListarClientes);
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


end.
