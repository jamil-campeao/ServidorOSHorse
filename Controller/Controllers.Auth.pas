unit Controllers.Auth;

interface

uses
  Horse, Horse.JWT, JOSE.Core.JWT, Jose.Types.JSON, Jose.Core.Builder,
  System.JSON, System.SysUtils;

const
  cSECRET = 'GERENCIALOS@2024';

type
  TMyClaims = class(TJWTClaims)
    private
    function GetCodUsuario: Integer;
    procedure SetCodUsuario(const Value: Integer);
    public
      property COD_USUARIO: Integer read GetCodUsuario write SetCodUsuario;

  end;

  function fCriarToken(cod_usuario: Integer): String;
  function fGetUsuarioRequest(Req: THorseRequest): Integer;

implementation

function fCriarToken(cod_usuario: Integer): String;
var
  vJWT: TJWT;
  vClaims: TMyClaims;
begin
  try
    vJWT    := TJWT.Create;
    vClaims := TMyClaims(vJWT.Claims);

    try
      vClaims.COD_USUARIO := cod_usuario;

      Result := TJOSE.SHA256CompactToken(cSECRET, vJWT);

    except
      Result := '';

    end;
  finally
    FreeAndNil(vJWT);

  end;

end;

function fGetUsuarioRequest(Req: THorseRequest): Integer;
var
  vClaims: TMyClaims;
begin
  vClaims := Req.Session<TMyClaims>;
  Result  := vClaims.COD_USUARIO;

end;

function TMyClaims.GetCodUsuario: Integer;
begin
  Result := FJSON.GetValue<Integer>('id', 0);
end;

procedure TMyClaims.SetCodUsuario(const Value: Integer);
begin
  TJSONUtils.SetJSONValueFrom<Integer>('id',Value,FJSON);

end;

end.
