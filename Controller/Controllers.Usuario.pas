unit Controllers.Usuario;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils,
System.JSON, Horse.JWT, DM.Global;

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
var
  DmGlobal        : TDMGlobal;
  vNome           : String;
  vSenha          : String;
  vCodUsuario     : Integer;
  vBody, vJsonRet : TJsonObject;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);

      vBody   := Req.Body<TJSONObject>;
      vNome  := vBody.GetValue<string>('nome','');
      vSenha := vBody.GetValue<string>('senha','');

//      vJsonRet := DMGlobal.InserirUsuario(vNome, vSenha);

      vJsonRet.AddPair('nome', vNome);
      vJsonRet.AddPair('email', vSenha);

      vCodUsuario := vJsonRet.GetValue<Integer>('cod_usuario',0);

      //Gero o token contendo o cod_usuario
//      vJsonRet.AddPair('token', CriarToken(vCodUsuario));


      Res.Send<TJsonObject>(vJSonRet).Status(201);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure fLogin(Req: THorseRequest; Res: THorseResponse);
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
//        vJsonRet.AddPair('token', CriarToken(vCodUsuario));

        Res.Send<TJsonObject>(vJSonRet).Status(200); //Deu certo o Login
      end;

    except on e: Exception do
      Res.Send(e.Message).Status(500); //Caso de TimeOut ou outro erro
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

end.
