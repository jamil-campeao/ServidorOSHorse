unit Controllers.Cidade;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, Dm.Global,
System.JSON, Controllers.Auth, Horse.JWT, Horse.Upload, System.Classes,
FMX.Graphics;

procedure RegistrarRotas;
procedure ListarCidades(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/cidades/sincronizacao', ListarCidades);

end;

procedure ListarCidades(Req: THorseRequest; Res: THorseResponse);
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

      Res.Send<TJsonArray>(DmGlobal.fListarCidades(vPagina)).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;



end.
