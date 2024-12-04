program GerencialOS;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnPrincipal in 'Servidor\UnPrincipal.pas' {frmPrincipal},
  Controllers.Usuario in 'Controller\Controllers.Usuario.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
