unit Controllers.Produto;

interface

uses Horse, Horse.Jhonson, Horse.CORS, System.SysUtils, DM.Global,
System.JSON, Controllers.Auth, Horse.JWT, Horse.Upload, System.Classes,
FMX.Graphics;

procedure RegistrarRotas;
//procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse);
//procedure InserirEditarProduto(Req: THorseRequest; Res: THorseResponse);
//procedure ListarFoto(Req: THorseRequest; Res: THorseResponse);
//procedure EditarFoto(Req: THorseRequest; Res: THorseResponse);

implementation

procedure RegistrarRotas;
begin
//  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
//  .Get('/produtos/sincronizacao', ListarProdutos);

//  THorse.AddCallback(HorseJWT(Controllers.Auth.cSECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
//  .Get('/produtos/foto/:cod_produto', ListarFoto);
end;


//procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse);
//var
//  DmGlobal             : TDMGlobal;
//  vDtUltSincronizacao  : String;
//  vPagina              : Integer;
//begin
//  try
//    try
//      DmGlobal := TDMGlobal.Create(Nil);
//
//      try
//        vDtUltSincronizacao := Req.Query['dt_ult_sincronizacao'];
//      except
//        vDtUltSincronizacao := '';
//      end;
//
//      try
//        vPagina := Req.Query['pagina'].ToInteger;
//      except
//        vPagina := 1;
//      end;
//
//      Res.Send<TJsonArray>(DmGlobal.fListarProdutos(vDtUltSincronizacao, vPagina)).Status(200);
//
//    except on e: Exception do
//      Res.Send(e.Message).Status(500);
//    end;
//  finally
//    FreeAndNil(DmGlobal);
//  end;
//end;


end.
