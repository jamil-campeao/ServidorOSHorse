unit Controllers.Produto;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, Dm.Global,
System.JSON, Controllers.Auth, Horse.JWT, Horse.Upload, System.Classes,
FMX.Graphics;

procedure RegistrarRotas;
procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse);
procedure InserirEditarProduto(Req: THorseRequest; Res: THorseResponse);
procedure ListarFoto(Req: THorseRequest; Res: THorseResponse);
procedure EditarFoto(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/produtos/sincronizacao', ListarProdutos);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Post('/produtos/sincronizacao', InserirEditarProduto);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/produtos/foto/:prod_codigo', ListarFoto);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Put('/produtos/foto/:prod_codigo', EditarFoto);
end;


procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse);
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

      Res.Send<TJsonArray>(DmGlobal.fListarProdutos(vDtUltSincronizacao, vPagina)).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure InserirEditarProduto(Req: THorseRequest; Res: THorseResponse);
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

      vJsonRet := DmGlobal.fInserirEditarProduto(vbody.GetValue<integer>('prod_codigo_local',0),
                                                 vbody.GetValue<string>('prod_descricao',''),
                                                 vbody.GetValue<double>('prod_valorvenda',0),
                                                 vbody.GetValue<double>('prod_estoque',0),
                                                 vbody.GetValue<integer>('prod_codigo_oficial',0),
                                                 vbody.GetValue<string>('prod_dtultimaalteracao','')
                                                 );

      vJsonRet.AddPair('prod_codigo_local', TJSONNumber.Create(vBody.GetValue<integer>('prod_codigo_local',0)));

      {"cod_produto_local": 250, "cod_produto_oficial": 4500}
      Res.Send<TJsonObject>(vJSonRet).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure ListarFoto(Req: THorseRequest; Res: THorseResponse);
var
  DmGlobal: TDMGlobal;
  vDtUltSincronizacao: String;
  vCodProduto : Integer;
  vFoto : TStream;
begin
  try
    try
      DmGlobal := TDMGlobal.Create(Nil);

      try
        vCodProduto := Req.Params.Items['prod_codigo'].ToInteger;
      except
        vCodProduto := 0;
      end;

      vFoto := DmGlobal.fListarFoto(vCodProduto);

      if vFoto <> nil then
        Res.Send<TStream>(vFoto).Status(200)
      else
        Res.Send('Produto sem foto').Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure EditarFoto(Req: THorseRequest; Res: THorseResponse);
var
  vUploadConfig : TUploadConfig;
  vCodProduto   : Integer;
  vFoto         : TBitmap;
  DMGlobal      : TDMGlobal;
begin
  try
    vCodProduto := Req.Params.Items['prod_codigo'].ToInteger;
  except
    vCodProduto := 0;
  end;

  vUploadConfig               := TUploadConfig.Create(ExtractFilePath(ParamStr(0)) + 'Fotos');
  vUploadConfig.ForceDir      := True;
  vUploadConfig.OverrideFiles := True;

  vUploadConfig.UploadFileCallBack :=
  procedure(Sender: TObject; AFile: TUploadFileInfo)
  begin
    try
      DmGlobal := TDMGlobal.Create(nil);
      vFoto    := TBitmap.CreateFromFile(AFile.fullpath);

      DmGlobal.fEditarFoto(vCodProduto, vFoto);

      FreeAndNil(vFoto);
    finally
      FreeAndNil(DmGlobal);

    end;

  end;

  Res.Send<TUploadConfig>(vUploadConfig);
end;

end.
