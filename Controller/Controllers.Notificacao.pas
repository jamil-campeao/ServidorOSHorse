unit Controllers.Notificacao;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT;

procedure RegistrarRotas;
procedure ListarNotificacoes(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/notificacoes', ListarNotificacoes);
end;


procedure ListarNotificacoes(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal    : TDMGlobal;
  vCodUsuario : Integer;
begin
  try
    try
      DmGlobal    := TDMGlobal.Create(Nil);

      vCodUsuario := fGetUsuarioRequest(Req);

      Res.Send<TJsonArray>(DmGlobal.fListarNotificacoes(vCodUsuario)).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;


end.
