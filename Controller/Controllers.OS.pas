unit Controllers.OS;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT, Horse.Upload, System.Classes,
FMX.Graphics;

procedure RegistrarRotas;
procedure ListarOS(Req: THorseRequest; Res: THorseResponse);


implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/os/sincronizacao', ListarOS);

//  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
//  .Post('/pedidos/sincronizacao', InserirEditarPedido);
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


end.
