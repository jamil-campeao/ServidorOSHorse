unit DM.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait, System.IniFiles, FireDAC.Phys.IBBase, FireDac.DApt,
  System.JSON, DataSet.Serialize, uMD5;

type
  TDMGlobal = class(TDataModule)
    DM: TFDConnection;
    DriverLink: TFDPhysFBDriverLink;
    procedure DMBeforeConnect(Sender: TObject);
  private
    procedure fCarregaConfigDB(pConexao: TFDConnection);
    { Private declarations }
  public
    function fLogin(pCodUsuario: Integer; pSenha: String): TJsonObject;
    function fInserirUsuario(pNomeUsuario, pLogin, pSenha: String): TJsonObject;

    { Public declarations }
  end;

var
  DMGlobal: TDMGlobal;

implementation

procedure TDMGlobal.fCarregaConfigDB(pConexao: TFDConnection);
var
    vIni : TIniFile;
    vArq: string;
begin
  try
    // Caminho do vIni...
    vArq := ExtractFilePath(ParamStr(0)) + 'dbxconnections.ini';

    // Validar arquivo vIni...
    if NOT FileExists(vArq) then
        raise Exception.Create('Arquivo dbxconnections.ini não encontrado: ' + vArq);

    // Instanciar arquivo vIni...
    vIni := TIniFile.Create(vArq);
    pConexao.DriverName := vIni.ReadString('GERENCIALOS', 'DriverID', '');

    // Buscar dados do arquivo fisico...
    with pConexao.Params do
    begin
      Clear;
      Add('DriverID=' + vIni.ReadString('GERENCIALOS', 'DriverID', ''));
      Add('Database=' + vIni.ReadString('GERENCIALOS', 'Database', ''));
      Add('User_Name=' + vIni.ReadString('GERENCIALOS', 'User_name', ''));
      Add('Password=' + vIni.ReadString('GERENCIALOS', 'Password', ''));

      if vIni.ReadString('GERENCIALOS', 'Port', '') <> '' then
          Add('Port=' + vIni.ReadString('GERENCIALOS', 'Port', ''));

      if vIni.ReadString('GERENCIALOS', 'Server', '') <> '' then
          Add('Server=' + vIni.ReadString('GERENCIALOS', 'Server', ''));

      if vIni.ReadString('GERENCIALOS', 'Protocol', '') <> '' then
          Add('Protocol=' + vIni.ReadString('GERENCIALOS', 'Protocol', ''));

      if vIni.ReadString('GERENCIALOS', 'VendorLib', '') <> '' then
          DriverLink.VendorLib := vIni.ReadString('GERENCIALOS', 'VendorLib', '');
    end;

  finally
    if Assigned(vIni) then
      vIni.DisposeOf;
  end;
end;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDMGlobal.DMBeforeConnect(Sender: TObject);
begin
  fCarregaConfigDB(DM);
end;

function TDMGlobal.fLogin(pCodUsuario: Integer; pSenha: String): TJsonObject;
var
  vSQLQuery : TFDQuery;
begin
  vSQLQuery := TFDQuery.Create(nil);
  try
    vSQLQuery.Connection := DM;
    vSQLQuery.SQL.Clear;

    vSQLQuery.SQL.Text := ' SELECT                         '+
                          ' USU_CODIGO,                    '+
                          ' USU_LOGIN                      '+
                          ' FROM USUARIO                   '+
                          ' WHERE USU_CODIGO = :USU_CODIGO '+
                          ' AND USU_SENHA =   :SENHA       ';

    vSQLQuery.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;
    vSQLQuery.ParamByName('SENHA').AsString       := fSaltPassword(pSenha);

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONObject;
  finally
    FreeAndNil(vSQLQuery);
  end;

end;

function TDMGlobal.fInserirUsuario(pNomeUsuario, pLogin, pSenha: String): TJsonObject;
var
  vSQLQueryInsert : TFDQuery;
  vSQLQuerySelect : TFDQuery;
begin
  vSQLQueryInsert := TFDQuery.Create(nil);
  vSQLQuerySelect := TFDQuery.Create(nil);
  try
    vSQLQueryInsert.Connection := DM;
    vSQLQuerySelect.Connection := DM;

    vSQLQueryInsert.SQL.Clear;
    vSQLQuerySelect.SQL.Clear;

    vSQLQuerySelect.SQL.Text := ' SELECT MAX(USU_CODIGO) AS USU_CODIGO FROM USUARIO ';
    vSQLQuerySelect.Open;

    vSQLQueryInsert.SQL.Text := ' INSERT INTO USUARIO                                           '+
                                ' (USU_CODIGO, USU_NOME, USU_LOGIN, USU_SENHA, EMP_CODIGO)      '+
                                ' VALUES                                                        '+
                                ' (:USU_CODIGO, :USU_NOME, :USU_LOGIN, :USU_SENHA, :EMP_CODIGO) '+
                                ' RETURNING USU_CODIGO                                          ';

    vSQLQueryInsert.ParamByName('USU_CODIGO').AsInteger  := vSQLQuerySelect.FieldByName('USU_CODIGO').AsInteger + 1;
    vSQLQueryInsert.ParamByName('USU_NOME').AsString     := pNomeUsuario;
    vSQLQueryInsert.ParamByName('USU_LOGIN').AsString    := pLogin;
    vSQLQueryInsert.ParamByName('USU_SENHA').AsString    := fSaltPassword(pSenha);
    vSQLQueryInsert.ParamByName('EMP_CODIGO').AsInteger  := 1; {Estou setando fixo temporariamente, para
                                                                decidir depois como irá ser feito essa parte da empresa}

    vSQLQueryInsert.Open;

    Result := vSQLQueryInsert.ToJSONObject;
  finally
    FreeAndNil(vSQLQueryInsert);
  end;

end;


end.
