unit Controllers.Usuario;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils,
System.JSON, Horse.JWT, DM.Global, Controllers.Auth;

procedure RegistrarRotas;
procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse);
procedure Login(Req: THorseRequest; Res: THorseResponse);
procedure Push(Req: THorseRequest; Res: THorseResponse);
procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.Post('/usuarios', InserirUsuario);
  THorse.Post('/usuarios/login', Login);
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSecret, THorseJWTConfig.New.SessionClass(TMyClaims)))
                    .Post('/usuarios/push', Push);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
                    .Put('/usuarios', EditarUsuario);

end;

procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal        : TDMGlobal;
  vNomeUsuario    : String;
  vNomeLogin      : String;
  vSenha          : String;
  vCodUsuario     : Integer;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);

      vBody        := Req.Body<TJSONObject>;
      vNomeUsuario := vBody.GetValue<string>('nome_usuario','');
      vNomeLogin   := vBody.GetValue<string>('login','');
      vSenha       := vBody.GetValue<string>('senha','');

      vJsonRet := DMGlobal.fInserirUsuario(vNomeUsuario, vNomeLogin, vSenha);

      vJsonRet.AddPair('login', vNomeLogin);

      vCodUsuario := vJsonRet.GetValue<Integer>('usuCodigo',0);

      //Gero o token contendo o cod_usuario
      vJsonRet.AddPair('token', fCriarToken(vCodUsuario));

      Res.Send<TJsonObject>(vJSonRet).Status(201);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure Push(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal        : TDMGlobal;
  vTokenPush      : String;
  vCodUsuario     : Integer;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);

      vCodUsuario := fGetUsuarioRequest(Req);
      vBody       := Req.Body<TJSONObject>;
      vTokenPush  := vBody.GetValue<string>('token_push','');

      vJsonRet := DMGlobal.fPush(vCodUsuario, vTokenPush);

      Res.Send<TJsonObject>(vJSonRet).Status(200);
    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure Login(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal        : TDMGlobal;
  vCodUsuario     : Integer;
  vSenha          : String;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal     := TDMGlobal.Create(Nil);

      vBody        := Req.Body<TJSONObject>;
      vCodUsuario  := vBody.GetValue<integer>('cod_usuario',0);
      vSenha       := vBody.GetValue<string>('senha','');

      vJsonRet     := DMGlobal.fLogin(vCodUsuario, vSenha);

      if vJsonRet.Size = 0 then
        Res.Send('{"erro": "Usuário ou senha inválida"}').Status(401) // Não deu certo
      else
      begin
        vCodUsuario := vJsonRet.GetValue<Integer>('cod_usuario',0);

        //Gero o token contendo o cod_usuario
        vJsonRet.AddPair('token', fCriarToken(vCodUsuario));

        Res.Send<TJsonObject>(vJSonRet).Status(200); //Deu certo o Login
      end;

    except on e: Exception do
      Res.Send(e.Message).Status(500); //Caso de TimeOut ou outro erro
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal        : TDMGlobal;
  vNome           : String;
  vLogin          : String;
  vCodUsuario     : Integer;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal    := TDMGlobal.Create(Nil);

      vCodUsuario := fGetUsuarioRequest(Req);
      vBody       := Req.Body<TJSONObject>;
      vNome       := vBody.GetValue<string>('nome','');
      vLogin      := vBody.GetValue<string>('login','');

      vJsonRet    := DMGlobal.fEditarUsuario(vCodUsuario, vNome, vLogin);

      Res.Send<TJsonObject>(vJSonRet).Status(200);
    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;
end.
