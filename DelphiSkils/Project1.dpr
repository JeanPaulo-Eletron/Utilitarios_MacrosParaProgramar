program Project1;

uses
  Vcl.Forms,
  DelphiSkils in 'DelphiSkils.pas' {FormMain},
  Utilitarios in 'Utilitarios.pas',
  HelpersPadrao in 'HelpersPadrao.pas';

{$R *.res}

begin
  Application.Initialize;
  InitializeThreadConectionMode;
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
