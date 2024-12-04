program GerencialOS;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnPrincipal in 'Servidor\UnPrincipal.pas' {frmPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
