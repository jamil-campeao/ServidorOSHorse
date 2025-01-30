program GerencialOS;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnPrincipal in 'Servidor\UnPrincipal.pas' {frmPrincipal},
  Controllers.Usuario in 'Controller\Controllers.Usuario.pas',
  DM.Global in 'DataModule\DM.Global.pas' {DMGlobal: TDataModule},
  uMD5 in 'UnitsTerceiros\uMD5.pas',
  Controllers.Auth in 'Controller\Controllers.Auth.pas',
  Controllers.Notificacao in 'Controller\Controllers.Notificacao.pas',
  Controllers.Cliente in 'Controller\Controllers.Cliente.pas',
  Controllers.Produto in 'Controller\Controllers.Produto.pas',
  Controllers.OS in 'Controller\Controllers.OS.pas',
  Controllers.Cidade in 'Controller\Controllers.Cidade.pas',
  Controllers.Servico in 'Controller\Controllers.Servico.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
