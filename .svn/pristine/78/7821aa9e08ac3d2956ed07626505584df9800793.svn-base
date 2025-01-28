unit Controllers.Produto;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, Dm.Global,
System.JSON, Controllers.Auth, Horse.JWT, Horse.Upload, System.Classes,
FMX.Graphics;

procedure RegistrarRotas;
procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse);
procedure InserirEditarProduto(Req: THorseRequest; Res: THorseResponse);
//procedure ListarFoto(Req: THorseRequest; Res: THorseResponse);
//procedure EditarFoto(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('/produtos/sincronizacao', ListarProdutos);

  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Post('/produtos/sincronizacao', InserirEditarProduto);
//
//  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
//  .Get('/produtos/foto/:cod_produto', ListarFoto);
//
//  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
//  .Put('/produtos/foto/:cod_produto', EditarFoto);
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

      vJsonRet := DmGlobal.fInserirEditarProduto(vbody.GetValue<integer>('cod_produto_local',0),
                                                 vbody.GetValue<integer>('gru_codigo',0),
                                                 vbody.GetValue<integer>('fab_codigo',0),
                                                 vbody.GetValue<string>('uni_sigla',''),
                                                 vbody.GetValue<string>('prod_codigo_barra',''),
                                                 vbody.GetValue<string>('prod_referencia',''),
                                                 vbody.GetValue<string>('prod_descricao',''),
                                                 vbody.GetValue<double>('prod_valorcusto',0),
                                                 vbody.GetValue<double>('prod_lucro',0),
                                                 vbody.GetValue<double>('prod_valorvenda',0),
                                                 vbody.GetValue<string>('prod_situacao',''),
                                                 vbody.GetValue<double>('prod_valorcompra',0),
                                                 vbody.GetValue<string>('uni_siglacompra',''),
                                                 vbody.GetValue<string>('prod_ncm',''),
                                                 vbody.GetValue<double>('prod_pesoliquido',0),
                                                 vbody.GetValue<double>('prod_pesobruto',0),
                                                 vbody.GetValue<string>('prod_dtultimaos',''),
                                                 vbody.GetValue<integer>('ptipo_codigo',0),
                                                 vbody.GetValue<string>('prod_dtultimaalteracao',''),
                                                 vbody.GetValue<string>('prod_infadicionais',''),
                                                 vbody.GetValue<string>('prod_obs',''),
                                                 vbody.GetValue<string>('prod_cest',''),
                                                 vbody.GetValue<integer>('cod_produto_oficial',0)
                                                 );

      vJsonRet.AddPair('cod_produto_local', TJSONNumber.Create(vBody.GetValue<integer>('cod_produto_local',0)));

      {"cod_produto_local": 250, "cod_produto_oficial": 4500}
      Res.Send<TJsonObject>(vJSonRet).Status(200);

    except on e: Exception do
      Res.Send(e.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

//procedure ListarFoto(Req: THorseRequest; Res: THorseResponse);
//var
//  DmGlobal: TDMGlobal;
//  vDtUltSincronizacao: String;
//  vCodProduto : Integer;
//  vFoto : TStream;
//begin
//  try
//    try
//      DmGlobal := TDMGlobal.Create(Nil);
//
//      try
//        vCodProduto := Req.Params.Items['cod_produto'].ToInteger;
//      except
//        vCodProduto := 0;
//      end;
//
//      Res.Send<TStream>(DmGlobal.fListarFoto(vCodProduto)).Status(200);
//
//    except on e: Exception do
//      Res.Send(e.Message).Status(500);
//    end;
//  finally
//    FreeAndNil(DmGlobal);
//  end;
//end;
//
//procedure EditarFoto(Req: THorseRequest; Res: THorseResponse);
//var
//  vUploadConfig : TUploadConfig;
//  vCodProduto   : Integer;
//  vFoto         : TBitmap;
//  DMGlobal      : TDMGlobal;
//begin
//  try
//    vCodProduto := Req.Params.Items['cod_produto'].ToInteger;
//  except
//    vCodProduto := 0;
//  end;
//
//  vUploadConfig               := TUploadConfig.Create(ExtractFilePath(ParamStr(0)) + 'Fotos');
//  vUploadConfig.ForceDir      := True;
//  vUploadConfig.OverrideFiles := True;
//
//  vUploadConfig.UploadFileCallBack :=
//  procedure(Sender: TObject; AFile: TUploadFileInfo)
//  begin
//    try
//      DmGlobal := TDMGlobal.Create(nil);
//      vFoto    := TBitmap.CreateFromFile(AFile.fullpath);
//
//      DmGlobal.fEditarFoto(vCodProduto, vFoto);
//
//      FreeAndNil(vFoto);
//    finally
//      FreeAndNil(DmGlobal);
//
//    end;
//
//  end;
//
//  Res.Send<TUploadConfig>(vUploadConfig);
//end;

end.
