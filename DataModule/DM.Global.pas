unit DM.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait, System.IniFiles, FireDAC.Phys.IBBase, FireDac.DApt,
  System.JSON, DataSet.Serialize;

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
                          ' USU_NOME                       '+
                          ' FROM USUARIO                   '+
                          ' WHERE USU_CODIGO = :USU_CODIGO '+
                          ' AND USU_SENHA =   :SENHA       ';

    vSQLQuery.ParamByName('USU_CODIGO').AsInteger := pCodUsuario;
    vSQLQuery.ParamByName('SENHA').AsString       := pSenha;

    vSQLQuery.Open;

    Result := vSQLQuery.ToJSONObject;
  finally
    FreeAndNil(vSQLQuery);
  end;

end;

end.
