unit uMD5;

interface

uses IdHashMessageDigest, Classes, SysUtils;

const
    SALT = 'j5*k.9S8W6*(/OG5#1O1Dfp5z9/3U5dls5y9s6hU49Z95FQyn7ab9r5j6k3';

function fMD5(const Value: string): string;
function fSaltPassword(pass: string): string;

implementation

function fMD5(const Value: string): string;
var
    xMD5: TIdHashMessageDigest5;
begin
    xMD5 := TIdHashMessageDigest5.Create;
    Result := Value;

    try
        Result := xMD5.HashStringAsHex(Result);
    finally
        xMD5.Free;
    end;
end;

function fSaltPassword(pass: string): string;
var
    xMD5: TIdHashMessageDigest5;
    randomStr: string;
    x : integer;
begin
    xMD5 := TIdHashMessageDigest5.Create;
    Result := '';

    try
        for x := 1 to Length(pass) do
            Result := Result + Copy(SALT, x, 1) + Copy(pass, x, 1);

        Result := LowerCase(xMD5.HashStringAsHex(Result));  // 1x
        Result := LowerCase(xMD5.HashStringAsHex(Result));  // 2x
    finally
        xMD5.Free;
    end;
end;

end.
