program GerencialOS;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnPrincipal in 'Servidor\UnPrincipal.pas' {frmPrincipal},
  Controllers.Usuario in 'Controller\Controllers.Usuario.pas',
  DM.Global in 'DataModule\DM.Global.pas' {DMGlobal: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TDMGlobal, DMGlobal);
  Application.Run;
end.
