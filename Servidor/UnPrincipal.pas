unit UnPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TfrmPrincipal = class(TForm)
    memo: TMemo;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses Horse, Horse.Jhonson, Horse.CORS, HORSE.OctetStream, HORSE.Upload,
Controllers.Usuario;

{$R *.fmx}

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  THorse.Use(Jhonson());
  THorse.Use(CORS);
  THorse.Use(OctetStream);
  THorse.Use(Upload);

  {Registrar Rotas}
  Controllers.Usuario.fRegistrarRotas;


  THorse.Listen(9000);
  memo.Lines.Add('Servidor Executando na porta: ' + THorse.Port.ToString);
end;

end.
