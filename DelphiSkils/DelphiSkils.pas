unit DelphiSkils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms,  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  JvExComCtrls, JvComCtrls, Vcl.Clipbrd,
  {Units} Utilitarios, Data.DB, Data.Win.ADODB;

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
    IdentarAtivo, VerificarCamposDaTabelaAtivo: Boolean;
    procedure PassarSQLParaDelphi(ChamadaPeloTeclado: Boolean = False);
    procedure PassarDelphiParaSQL(ChamadaPeloTeclado: Boolean = False);
    procedure InvocarRegion;
    procedure Identar;
    procedure VerificarCamposDaTabela;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
const
  FimLinhaStr: String = #13+#10;
implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
var
  TimerTeclasPressionadas: TTimeOut;
begin
  PassarSQLParaDelphiAtivo     := False;
  InvocarRegionAtivo           := False;  VerificarCamposDaTabelaAtivo := False;  {$Region 'Invocar Timer De Teclas Digitadas'}    TimerTeclasPressionadas    :=    SetInterval(
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
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD4) or TeclaEstaPressionada(52))
          then VerificarCamposDaTabela;
        if (TeclaEstaPressionada(VK_LSHIFT)   or TeclaEstaPressionada(VK_RSHIFT)) and TeclaEstaPressionada(VK_ESCAPE)
          then Application.Terminate;
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and TeclaEstaPressionada(VK_ESCAPE) then begin
          Self.WindowState := wsNormal;
          ShowWindow(Application.Handle, SW_SHOW);
          Application.BringToFront;
        end;
      End,
    10);
  {$EndRegion}end;

procedure TFormMain.VerificarCamposDaTabela;
var
  Texto: string;
begin
  {$Region 'Verificar se já está ativo'}
    if VerificarCamposDaTabelaAtivo
      then Exit;
    VerificarCamposDaTabelaAtivo := True;
  {$EndRegion}

  {$Region 'Control + C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}


  SetTimeOut(
    Procedure
    var Alias:      TADOConnection;
        Consultant: TADOQuery;
        Canvas : TCanvas;
        vHDC : HDC;
        pt: TPoint;
        X: Integer;
    TamanhoMaxString: integer;
    begin
      TRY
        Texto       := Clipboard.AsText;

        {$Region 'Criar objeto de conexão com o banco'}
          Alias := TAdoConnection.Create(Application);
          Alias.Attributes     := [];
          //Com xaCommitRetaining após commitar ele abre uma nova transação,
          //Com xaAbortRetaining  após abordar ele abre uma nova transação, custo muito alto.
          Alias.CommandTimeout := 1;
          //Se o comando demorar mais de 1 segundos ele aborta
          Alias.Connected      := False;
          //A conexão deve vir inicialmente fechada
          Alias.ConnectionTimeout := 15;
          //Se demorar mais de 15 segundos para abrir a conexão ele aborta
          Alias.CursorLocation := clUseServer;
          //Toda informação ao ser alterada sem commitar vai ficar no servidor.
          Alias.DefaultDatabase := '';
          Alias.IsolationLevel := ilReadUncommitted;
          //Quero saber os campos que ainda não foram commitados também
          Alias.KeepConnection := True;
          Alias.LoginPrompt    := False;
          Alias.Mode           := cmRead;
          //Somente leitura
          Alias.Name           := 'VerificarCamposDaTabelaConnection';
          Alias.Provider       := 'SQLNCLI11.1';
          Alias.Tag            := 1;
          //Para indicar que é usado em VerificarCamposDaTabela
        {$EndRegion}

        ConfigurarConexao(Alias);

        Consultant := TAdoQuery.Create(Application);
        with consultant do begin
          Close;
          Connection := Alias;
          SQL.Text   := 'declare @pesquisaCampo varchar(100)'+FimLinhaStr+
                        'declare @pesquisaTabela varchar(100)'+FimLinhaStr+
                        'set @pesquisaCampo  = ''%'''+FimLinhaStr+
                        'set @pesquisaTabela = '''+Texto+''''+FimLinhaStr+
                        '--set @pesquisaTabela = '''''+FimLinhaStr+
                        ''+FimLinhaStr+
                        'Select'+FimLinhaStr+
                        'object_name(object_id) as Tabela,'+FimLinhaStr+
                        'sc.name as Campo,'+FimLinhaStr+
                        'st.name as Tipo,'+FimLinhaStr+
                        'sc.max_length as tamanho,'+FimLinhaStr+
                        'case sc.is_identity when 0 then ''NÃO'' else ''SIM'' end as IDENTIDADE'+FimLinhaStr+
                        'From'+FimLinhaStr+
                        'sys.columns sc'+FimLinhaStr+
                        'Inner Join'+FimLinhaStr+
                        'sys.types st On st.system_type_id = sc.system_type_id and st.user_type_id = sc.user_type_id'+FimLinhaStr+
                        'where sc.name like @pesquisaCampo and ( (object_name(object_id) = @pesquisaTabela) or (object_name(object_id) like (@pesquisaTabela+''_'')))'+FimLinhaStr+
                        'order by 1, 2';
          Open;

          vHDC := GetDC(0);
          Canvas := TCanvas.Create;
          Canvas.Handle      := vHDC;
          Canvas.Pen.Color   := ClRed;
          Canvas.Brush.Color := ClRed;
          GetCursorPos(pt);
          First;
          TamanhoMaxString := Length(FieldByName('Tabela').AsString);
          while not eof do begin
            if Length(FieldByName('Campo').AsString) > TamanhoMaxString
              then TamanhoMaxString := Length(FieldByName('Campo').AsString);
            Next;
          end;
          First;
          X := 1;
          Canvas.Rectangle(Pt.x,Pt.y,Pt.x + ((TamanhoMaxString + 13) * 5), Pt.y + 10 + (52*RecordCount));
          Canvas.TextOut(Pt.x,Pt.y, 'TABELA:     ' + FieldByName('Tabela').AsString);
          while not eof do begin
            Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'CAMPO:      ' + FieldByName('Campo').AsString);
            Inc(X);
            Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TIPO:       ' + FieldByName('Tipo').AsString);
            Inc(X);
            Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TAMANHO:    ' + FieldByName('tamanho').AsString);
            Inc(X);
            Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'IDENTIDADE: ' + FieldByName('IDENTIDADE').AsString);
            INC(X);
            Next;
          end;
          Free;
        end;

        Alias.Free;
      FINALLY
        {$Region 'Setar TimeOut para reabilitar uso da funcionalidade'}
          SetTimeOut(
            Procedure
            begin
              VerificarCamposDaTabelaAtivo := False;
            End,
          1000);
        {$EndRegion}
      END;
    End,
  100);
end;

procedure TFormMain.Identar;
begin
  {$Region 'Verificar se já está ativo'}
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
    EncontrouEspaço: Boolean;
    NroEspacos: Integer;
      begin
        Texto       := Clipboard.AsText;
        TextoFinal  := '';
        {$Region 'Igualar altura dos ":="'}
          {$Region 'Remover espaços desnecessários'}
            TextoFinal := '';
            NroEspacos := 0;
            for char_ in Texto do begin
                if (char_ = ' ')
                  then begin
                    EncontrouEspaço            := True;
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
                    EncontrouEspaço                   := False;
                    NroEspacos := 0;
                    TextoFinal := TextoFinal + ' :=';
                  end
                  else
                if EncontrouEspaço
                  then begin
                    for I := 1 to NroEspacos
                      do TextoFinal := TextoFinal + ' ';
                    TextoFinal      := TextoFinal + Char_;
                    NroEspacos      := 0;
                    EncontrouEspaço := False;
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
                      TextoParcialDepoisDoDuploPonto  := Copy(TextoParcial, POS(':=', TextoParcial)+2, Length(TextoParcial));                    TextoParcial                    := TextoParcialAteODuploPonto;
                      for I := 1 to (QtdeMaxDeCaracteresAteODoisPontosIgual - length(TextoParcialAteODuploPonto) - 2)                      do TextoParcial                 := TextoParcial + ' ';                    TextoParcial                     := TextoParcial + ':=';                    TextoParcial                     := TextoParcial + TextoParcialDepoisDoDuploPonto;                  end
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
      Texto       := identamento + '{$Region ''Procedimentos''}'+FimLinhaStr
                                 +    Texto+FimLinhaStr+
                     identamento + '{$EndRegion}';

      EncontrouTexto         := False;      for char_ in Texto do begin
        if (char_ <> ' ') and not (EncontrouTexto)
          then begin
            TextoFinal       := TextoFinal + '  ' + char_;            EncontrouTexto   := True;          end
          else
        if char_ = #10
          then begin
            TextoFinal     := TextoFinal + char_;            EncontrouTexto := False;          end          else TextoFinal  := TextoFinal + char_;      end;
      ClipBoard.AsText     := TextoFinal;
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
      Texto_            := '''';      for char_ in Texto do begin
        if char_ = ''''
          then Texto_   := Texto_ + ''''''          else
        if char_ = #13
          then Texto_   := Texto_ + '''+FimLinhaStr+' + #13          else
        if char_ = #10
          then Texto_   := Texto_ + #10 + ''''          else Texto_   := Texto_ + char_;      end;
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
      Texto              := Clipboard.AsText;      TextoFinal         := '';
      consecutivo        := True;      for char_ in Texto do begin
        if (char_ = '''') and (not Consecutivo)
          then begin
            TextoFinal   := TextoFinal + '''';            consecutivo  := True;          end
          else
        if (char_ = '''') and (Consecutivo)
          then begin
            consecutivo  := False;          end
          else
        if char_ = #10
          then begin
            consecutivo  := True;          end
          else
        if char_ = #13
          then begin
            TextoFinal   := Copy(TRIM(TextoFinal),1,Length(TRIM(TextoFinal))-14) +FimLinhaStr;            consecutivo  := false;          end
          else begin
            TextoFinal   := TextoFinal + char_;            consecutivo  := False;          end
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
