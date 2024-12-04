unit Controllers.Usuario;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils,
System.JSON, Horse.JWT;

procedure fRegistrarRotas;
procedure fInserirUsuario(Req: THorseRequest; Res: THorseResponse);
procedure fLogin(Req: THorseRequest; Res: THorseResponse);

implementation

procedure fRegistrarRotas;
begin
  THorse.Post('/usuarios', fInserirUsuario);
  THorse.Post('/usuarios/login', fLogin);
end;

procedure fInserirUsuario(Req: THorseRequest; Res: THorseResponse);
begin

end;

procedure fLogin(Req: THorseRequest; Res: THorseResponse);
begin

end;

end.
