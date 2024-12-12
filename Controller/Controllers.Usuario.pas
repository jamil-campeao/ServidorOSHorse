unit Controllers.Usuario;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT;

procedure RegistrarRotas;
procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse);
procedure Login(Req: THorseRequest; Res: THorseResponse);
procedure Push(Req: THorseRequest; Res: THorseResponse);
procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse);
procedure EditarSenha(Req: THorseRequest; Res: THorseResponse);
procedure ObterDataServidor(Req: THorseRequest; Res: THorseResponse);
procedure InativarUsuario(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.Post('/usuarios', InserirUsuario);
  THorse.Post('/usuarios/login', Login);
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSecret, THorseJWTConfig.New.SessionClass(TMyClaims)))
                    .Post('/usuarios/push', Push);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
                    .Put('/usuarios', EditarUsuario);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
                    .Put('/usuarios/senha', EditarSenha);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
                    .Get('/usuarios/horario', ObterDataServidor);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
                    .Delete('/usuarios/:cod_usuario', InativarUsuario);
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
      DmGlobal     := TDMGlobal.Create(Nil);

      vBody        := Req.Body<TJSONObject>;
      vNomeUsuario := vBody.GetValue<string>('nome_usuario','');
      vNomeLogin   := vBody.GetValue<string>('login','');
      vSenha       := vBody.GetValue<string>('senha','');

      vJsonRet := DMGlobal.fInserirUsuario(vNomeUsuario, vNomeLogin, vSenha);

      vJsonRet.AddPair('usu_nome', vNomeUsuario);
      vJsonRet.AddPair('usu_login', vNomeLogin);

      vCodUsuario := vJsonRet.GetValue<Integer>('usu_codigo',0);

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
  vLogin          : String;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal     := TDMGlobal.Create(Nil);

      vBody        := Req.Body<TJSONObject>;
      vLogin       := vBody.GetValue<String>('login','');
      vSenha       := vBody.GetValue<string>('senha','');

      vJsonRet     := DMGlobal.fLogin(vLogin, vSenha);

      if vJsonRet.Size = 0 then
        Res.Send('{"erro": "Login ou senha inválida"}').Status(401) // Não deu certo
      else
      begin
        vCodUsuario := vJsonRet.GetValue<Integer>('usu_codigo',0);

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

procedure EditarSenha(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal        : TDMGlobal;
  vSenha          : String;
  vCodUsuario     : Integer;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal    := TDMGlobal.Create(Nil);
      vCodUsuario := fGetUsuarioRequest(Req);
      vBody       := Req.Body<TJSONObject>;
      vSenha      := vBody.GetValue<string>('senha','');

      vJsonRet    := DMGlobal.fEditarSenha(vCodUsuario, vSenha);

      Res.Send<TJsonObject>(vJSonRet).Status(200);
    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure ObterDataServidor(Req: THorseRequest; Res: THorseResponse);
begin
  Res.Send(FormatDateTime('yyyy-mm-dd hh:nn:ss', now)).Status(200);
end;

procedure InativarUsuario(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal          : TDMGlobal;
  vCodUsuario       : Integer;
  vJsonRet          : TJsonObject;
  vCodUsuarioParam  : Integer;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);
      vCodUsuario := fGetUsuarioRequest(Req);

      try
        vCodUsuarioParam := Req.Params.Items['cod_usuario'].ToInteger
      except
        vCodUsuarioParam := 0;
      end;

      if vCodUsuario <> vCodUsuarioParam then
        raise Exception.Create('Operação não permitida');

      vJsonRet := DMGlobal.fInativarUsuario(vCodUsuario);

      Res.Send<TJsonObject>(vJSonRet).Status(200);
    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

end.
