unit Controllers.Auth;

interface

uses Horse, Horse.JWT, Jose.Core.JWT, Jose.Types.JSON, Jose.Core.Builder,
System.JSON, System.SysUtils;

const
  cSecret = 'FAROLOS@2024';

type TMyClaims = class(TJWTClaims)
  private
    function GetCodUsuario: Integer;
    procedure setCodUsuario(const Value: Integer);
  public
    property COD_USUARIO : Integer read GetCodUsuario write setCodUsuario;
end;

function fCriarToken(pCodUsuario: Integer): String;
function fGetUsuarioRequest(pReq: THorseRequest): Integer;

implementation

function fCriarToken(pCodUsuario: Integer): String;
var
  vJWT    : TJWT;
  vClaims : TMyClaims;
begin
  try
    vJWT    := TJWT.Create;
    vClaims := TMyClaims(vJWT.Claims);

    try
      vClaims.COD_USUARIO := pCodUsuario;
      Result              := TJose.SHA256CompactToken(cSecret, vJWT);
    except
      Result := '';
    end;
  finally
    FreeAndNil(vJWT);
  end;

end;

function fGetUsuarioRequest(pReq: THorseRequest): Integer;
var
  vClaims : TMyClaims;
begin
  vClaims := pReq.Session<TMyClaims>;
  Result  := vClaims.COD_USUARIO;
end;

function TMyClaims.GetCodUsuario: Integer;
begin
  Result := FJSON.GetValue<integer>('id',0);
end;

procedure TMyClaims.setCodUsuario(const Value: Integer);
begin
  TJSONUtils.SetJSONValueFrom<integer>('id', Value, FJSON);
end;

end.
