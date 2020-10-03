unit DelphiSkils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms,  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  JvExComCtrls, JvComCtrls, Vcl.Clipbrd,
  {Units} Utilitarios;

type
  TFormMain = class(TForm)
    JvPageControl1: TJvPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    PassarSQLParaDelphiAtivo: Boolean;
    InvocarRegionAtivo: Boolean;
    IdentarAtivo: Boolean;
    procedure PassarSQLParaDelphi(ChamadaPeloTeclado: Boolean = False);
    procedure PassarDelphiParaSQL(ChamadaPeloTeclado: Boolean = False);
    procedure InvocarRegion;
    procedure Identar;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
var
  TimerTeclasPressionadas: TTimeOut;
begin
  PassarSQLParaDelphiAtivo  := False;
  InvocarRegionAtivo        := False;
      Procedure
      begin
        if  (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD0) or TeclaEstaPressionada(48))
          then PassarSQLParaDelphi(TRUE);
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD1) or TeclaEstaPressionada(49))
          then PassarDelphiParaSQL(TRUE);
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD2) or TeclaEstaPressionada(50))
          then InvocarRegion;
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD3) or TeclaEstaPressionada(51))
          then Identar;
        if (TeclaEstaPressionada(VK_LSHIFT)   or TeclaEstaPressionada(VK_RSHIFT)) and TeclaEstaPressionada(VK_ESCAPE)
          then Application.Terminate;
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and TeclaEstaPressionada(VK_ESCAPE) then begin
          Self.WindowState := wsNormal;
          ShowWindow(Application.Handle, SW_SHOW);
          Application.BringToFront;
        end;
      End,
    10);
  {$EndRegion}


procedure TFormMain.Identar;
begin
  {$Region 'Verificar se j� est� ativo'}
    if IdentarAtivo
      then Exit;
    IdentarAtivo := True;
  {$EndRegion}

  {$Region 'Control + C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Transformar o texto e dar control V'}
    SetTimeOut(
      Procedure
      var Texto, TextoFinal, TextoParcial: String;
          QtdeMaxDeCaracteresAteODoisPontosIgual, CharCountDaLinha : integer;
          Char_ : Char;
          I, DepoisDo13: Integer;
          EncontrouDuploPonto: Boolean;
          TextoParcialAteODuploPonto: String;
          TextoParcialDepoisDoDuploPonto: String;
          EncontrouOperadorIgualNaLinha: Boolean;
    EncontrouEspa�o: Boolean;
    NroEspacos: Integer;
      begin
        Texto       := Clipboard.AsText;
        TextoFinal  := '';
        {$Region 'Igualar altura dos ":="'}
          {$Region 'Remover espa�os desnecess�rios'}
            TextoFinal := '';
            NroEspacos := 0;
            for char_ in Texto do begin
                if (char_ = ' ')
                  then begin
                    EncontrouEspa�o            := True;
                    Inc(NroEspacos);
                  end
                  else
                if (char_ = ':') and (not EncontrouDuploPonto)
                  then begin
                    EncontrouDuploPonto            := True;
                  end
                  else
                if (char_ = '=') and (EncontrouDuploPonto)
                  then begin
                    EncontrouDuploPonto               := False;
                    EncontrouEspa�o                   := False;
                    NroEspacos := 0;
                    TextoFinal := TextoFinal + ' :=';
                  end
                  else
                if EncontrouEspa�o
                  then begin
                    for I := 1 to NroEspacos
                      do TextoFinal := TextoFinal + ' ';
                    TextoFinal      := TextoFinal + Char_;
                    NroEspacos      := 0;
                    EncontrouEspa�o := False;
                  end
                  else begin
                    EncontrouDuploPonto := False;
                    TextoFinal          := TextoFinal + Char_;
                  end;
            end;
            Texto := TextoFinal;
          {$EndRegion}

          CharCountDaLinha := 1;
          QtdeMaxDeCaracteresAteODoisPontosIgual := 0;

          {$Region 'Verificar quantos char possui o operador de receber mais afastado'}
            for char_ in Texto do begin
              if (char_ = #13)
                then begin
                  CharCountDaLinha := 1;
                  EncontrouDuploPonto   := False;
                  EncontrouOperadorIgualNaLinha := False;
                end
                else
              if (char_ = ':') and (not EncontrouDuploPonto)
                then begin
                  EncontrouDuploPonto            := True;
                end
                else
              if (char_ = '=') and (EncontrouDuploPonto) and (not EncontrouOperadorIgualNaLinha)
                then begin
                  if CharCountDaLinha > QtdeMaxDeCaracteresAteODoisPontosIgual
                    then QtdeMaxDeCaracteresAteODoisPontosIgual := CharCountDaLinha;
                  CharCountDaLinha     := CharCountDaLinha + 1;
                  EncontrouDuploPonto            := False;
                  EncontrouOperadorIgualNaLinha     := True;
                end
                else CharCountDaLinha  := CharCountDaLinha + 1;
            end;
          {$EndRegion}

          {$Region 'Igualando igual'}
            EncontrouOperadorIgualNaLinha := False;
            EncontrouDuploPonto           := False;
            Texto        := Texto + #13;
            TextoParcial := Texto;
            TextoFinal   := '';
            for char_ in Texto do begin
               if (char_ = #13)
                  then begin
                    if POS(#10, TextoParcial) > 1
                      then TextoFinal             := TextoFinal + Copy(TextoParcial, 1, POS(#10, TextoParcial)) //Texto Final Recebe a linha
                      else TextoFinal             := TextoFinal + Copy(TextoParcial, 1, POS(#13, TextoParcial)); //Texto Final Recebe a linha
                    if POS(#10, TextoParcial) > 1
                      then TextoParcial           := Copy(TextoParcial, POS(#10, TextoParcial) + 1, length(TextoParcial))//Texto Parcial Remove a linha
                      else TextoParcial           := Copy(TextoParcial, POS(#13, TextoParcial) + 1, length(TextoParcial));//Texto Parcial Remove a linha
                    EncontrouDuploPonto           := False;
                    EncontrouOperadorIgualNaLinha := False;
                  end
                  else
                if (char_ = ':') and (not EncontrouDuploPonto)
                  then begin
                    EncontrouDuploPonto            := True;
                  end
                  else
                if (char_ = '=') and (EncontrouDuploPonto) and (not EncontrouOperadorIgualNaLinha)
                  then begin
                    EncontrouDuploPonto               := False;
                    EncontrouOperadorIgualNaLinha     := True;
                    if pos('for', TextoParcial) = 0 then begin
                      TextoParcialAteODuploPonto      := Copy(TextoParcial, 1, POS(':=', TextoParcial)-1);
                      TextoParcialDepoisDoDuploPonto  := Copy(TextoParcial, POS(':=', TextoParcial)+2, Length(TextoParcial));
                      for I := 1 to (QtdeMaxDeCaracteresAteODoisPontosIgual - length(TextoParcialAteODuploPonto) - 2)
                  end
                  else EncontrouDuploPonto            := False;
            end;
          {$EndRegion}

          TextoFinal     := Copy(TextoFinal,1,Length(TextoFinal)-1);
          Texto          := TextoFinal;
        {$EndRegion}

        ClipBoard.AsText := TextoFinal;

        {$Region 'Control + V'}
          SetTimeOut(
            Procedure
            begin
              PressionarControlEManter;
              PressionarTeclaV;
              SoltarControl;
            End,
          100);
        {$EndRegion}
      End,
    100);
  {$EndRegion}

  {$Region 'Setar TimeOut para reabilitar uso da funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        IdentarAtivo := False;
      End,
    1000);
  {$EndRegion}
end;

procedure TFormMain.InvocarRegion;
var Texto, TextoFinal, identamento : String;
    EncontrouTexto: Boolean;
begin
  if InvocarRegionAtivo
    then Exit;
  InvocarRegionAtivo := True;

  PressionarControlEManter;
  PressionarTeclaC;
  SoltarControl;
  SetTimeOut(
    Procedure
    var i : integer;
        Char_ : Char;
    begin
      Texto       := Clipboard.AsText;
      TextoFinal  := '';
      for i := 1 to Length(Texto)-Length(Trim(Texto))-2
        do identamento  := identamento + ' ';
      Texto       := identamento + '{$Region ''Procedimentos''}'+#13+#10
                                +    Texto+#13+#10+
                    identamento + '{$EndRegion}';

      EncontrouTexto         := False;
        if (char_ <> ' ') and not (EncontrouTexto)
          then begin
            TextoFinal       := TextoFinal + '  ' + char_;
          else
        if char_ = #10
          then begin
            TextoFinal     := TextoFinal + char_;
      ClipBoard.AsText     := TextoFinal;

        Procedure
        begin
          PressionarControlEManter;
          PressionarTeclaV;
          SoltarControl;
        End,
      100);
    End,
  100);
  SetTimeOut(
    Procedure
    begin
      InvocarRegionAtivo := False;
    End,
  1000);
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, getWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  ShowWindow(Application.Handle, SW_SHOW);
end;

procedure TFormMain.PassarSQLParaDelphi(ChamadaPeloTeclado: Boolean = False);
var
  Linha, Linha_, Texto, Texto_: String;
  char_: char;
begin
  if PassarSQLParaDelphiAtivo
    then Exit;
  PassarSQLParaDelphiAtivo := True;

  PressionarControlEManter;
  PressionarTeclaC;
  SoltarControl;
  SetTimeOut(
    Procedure
    var char_: char;
    begin
      Texto             := ClipBoard.AsText;
      Texto_            := '''';
        if char_ = ''''
          then Texto_   := Texto_ + ''''''
        if char_ = #13
          then Texto_   := Texto_ + '''+FimLinhaStr+' + #13
        if char_ = #10
          then Texto_   := Texto_ + #10 + ''''
      ClipBoard.AsText  := Texto_ + '''+FimLinhaStr+' + #13;
      SetTimeOut(
        Procedure
        begin
          PressionarControlEManter;
          PressionarTeclaV;
          SoltarControl;
        End,
      100);
    End,
  100);
  SetTimeOut(
    Procedure
    begin
      PassarSQLParaDelphiAtivo := False;
    End,
  1000);
end;

procedure TFormMain.PassarDelphiParaSQL(ChamadaPeloTeclado: Boolean = False);
var
  Linha, Linha_, Texto, TextoFinal: String;
  char_: char;
  consecutivo: Boolean;
  Strings: TStrings;
begin
  if PassarSQLParaDelphiAtivo
    then Exit;
  PassarSQLParaDelphiAtivo   := True;
  PressionarControlEManter;
  PressionarTeclaC;
  SoltarControl;
  SetTimeOut(
    Procedure
    var char_: char;
        Linha_: String;
    begin
      Texto              := Clipboard.AsText;
      consecutivo        := True;
        if (char_ = '''') and (not Consecutivo)
          then begin
            TextoFinal   := TextoFinal + '''';
          else
        if (char_ = '''') and (Consecutivo)
          then begin
            consecutivo  := False;
          else
        if char_ = #10
          then begin
            consecutivo  := True;
          else
        if char_ = #13
          then begin
            TextoFinal   := Copy(TRIM(TextoFinal),1,Length(TRIM(TextoFinal))-14) +#13+#10;
          else begin
            TextoFinal   := TextoFinal + char_;
      end;

      ClipBoard.AsText   := TextoFinal;

      SetTimeOut(
        Procedure
        begin
          PressionarControlEManter;
          PressionarTeclaV;
          SoltarControl;
        End,
      100);
    End,
  100);

  SetTimeOut(
    Procedure
    begin
      PassarSQLParaDelphiAtivo := False;
    End,
  2000);
end;

end.