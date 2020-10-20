unit DelphiSkils;
interface

{$Region 'uses'}
  uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms,  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, JvExComCtrls, JvComCtrls, 
    Vcl.Clipbrd, Utilitarios, Data.DB, Data.Win.ADODB, ActiveX, Vcl.Grids, Vcl.DBGrids;
{$EndRegion}                                                           

type
  TFormMain = class(TForm)
    JvPageControl1: TJvPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    TSConfigConect: TTabSheet;
    EditServidor: TEdit;
    EditUsuario: TEdit;
    EditSenha: TEdit;
    EditDataBase: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JvPageControl1Change(Sender: TObject);
    procedure EditConfiguraConexaoExit(Sender: TObject);

  {$Region 'private'}
    private
      PassarSQLParaDelphiAtivo: Boolean;
      InvocarRegionAtivo: Boolean;
      IgualarDistanciamentoEntreOsIguaisAtivo, VerificarCamposDaTabelaAtivo: Boolean;
      IdentarAtivo: Boolean;
      DBGrid: TDBGrid;
      procedure PassarSQLParaDelphi(ChamadaPeloTeclado: Boolean = False);
      procedure PassarDelphiParaSQL(ChamadaPeloTeclado: Boolean = False);
      procedure InvocarRegion;
      procedure IgualarDistanciamentoEntreOsIguais;
      procedure VerificarCamposDaTabela;
      procedure Identar;
    procedure VerificarProcedimentos;
  {$EndRegion}
  public
  end;

var
  FormMain: TFormMain;
const
  FimLinhaStr: String = #13+#10;
implementation

{$R *.dfm}

procedure TFormMain.EditConfiguraConexaoExit(Sender: TObject);
var
  CaminhoENomeArquivo, ExePath: String;
  NovoArq: TStringList;
begin
  ExePath    := ExtractFilePath(Application.ExeName);
  CaminhoENomeArquivo := ExePath + 'Config.ini';

  NovoArq := TStringList.Create;
  NovoArq.Add('Servidor        : '+EditServidor.Text);
  NovoArq.Add('Usu�rio         : '+EditUsuario.Text);                                   
  NovoArq.Add('Senha           : '+EditSenha.Text);
  NovoArq.Add('LicencaDataBase : '+EditDataBase.Text);
  NovoArq.Add('O Sistema s� ir� considerar as 4 primeiras linhas e somente o que estiver ap�s o ":",');
  NovoArq.Add('ele n�o ira considerar espa�os adicionais a direita e esquerda.');
 
  NovoArq.SaveToFile(CaminhoENomeArquivo);

  NovoArq.Free;
end;

procedure TFormMain.FormCreate(Sender: TObject);
{$Region 'var ...'}
  var
    TimerTeclasPressionadas: TTimeOut;
{$EndRegion}
begin
  JvPageControl1.ActivePageIndex := 0;
  PassarSQLParaDelphiAtivo     := False;
  InvocarRegionAtivo           := False;
  VerificarCamposDaTabelaAtivo := False;

  {$Region 'Invocar Timer De Teclas Digitadas'}
    TimerTeclasPressionadas    :=
    SetInterval(
      Procedure
      begin
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD0) or TeclaEstaPressionada(48)) then begin
          Self.WindowState := wsNormal;
          ShowWindow(Application.Handle, SW_SHOW);
          Application.BringToFront;
        end;
        if  (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD1) or TeclaEstaPressionada(49))
          then PassarSQLParaDelphi(TRUE);
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD2) or TeclaEstaPressionada(50))
          then PassarDelphiParaSQL(TRUE);
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD3) or TeclaEstaPressionada(51))
          then InvocarRegion;
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD4) or TeclaEstaPressionada(52))
          then IgualarDistanciamentoEntreOsIguais;
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD5) or TeclaEstaPressionada(53))
          then VerificarCamposDaTabela;
        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD6) or TeclaEstaPressionada(54))
          then VerificarProcedimentos;
//        if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD7) or TeclaEstaPressionada(55))
//          then Identar;
        if (TeclaEstaPressionada(VK_LSHIFT)   or TeclaEstaPressionada(VK_RSHIFT)) and TeclaEstaPressionada(VK_ESCAPE)
          then Application.Terminate;
      End,
    10);
  {$EndRegion}
end;

procedure TFormMain.Identar;
var
  TextoFinal: string;
  NroEspacos: Integer;
  char_: char;
  EncontrouEspa�o: Boolean;
  Texto: string;
  EncontrouDuploPonto: Boolean;
  I: Integer;
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

  {$Region 'Identando'}
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
            if EncontrouDuploPonto
              then TextoFinal := TextoFinal + ':';
            for I := 1 to NroEspacos
              do TextoFinal   := TextoFinal + ' ';
            TextoFinal        := TextoFinal + Char_;
            NroEspacos        := 0;
            EncontrouEspa�o   := False;
          end
          else begin
            EncontrouDuploPonto := False;
            TextoFinal          := TextoFinal + Char_;
          end;
    end;
    Texto := TextoFinal;
  {$EndRegion}
end;

procedure TFormMain.IgualarDistanciamentoEntreOsIguais;
begin
  {$Region 'Verificar se j� est� ativo'}
    if IgualarDistanciamentoEntreOsIguaisAtivo
      then Exit;
    IgualarDistanciamentoEntreOsIguaisAtivo := True;
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
          QtdeMaxDeCaracteresAteODoisPontosIgual, CharCountDaLinha:  integer;
          Char_:  Char;
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
                    if EncontrouDuploPonto
                      then TextoFinal := TextoFinal + ':';
                    for I := 1 to NroEspacos
                      do TextoFinal   := TextoFinal + ' ';
                    TextoFinal        := TextoFinal + Char_;
                    NroEspacos        := 0;
                    EncontrouEspaço   := False;
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
                    TextoParcial                    := TextoParcialAteODuploPonto;
                      for I := 1 to (QtdeMaxDeCaracteresAteODoisPontosIgual - length(TextoParcialAteODuploPonto) - 2)
                      do TextoParcial                 := TextoParcial + ' ';
                    TextoParcial                     := TextoParcial + ':=';
                    TextoParcial                     := TextoParcial + TextoParcialDepoisDoDuploPonto;
                  end
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
        IgualarDistanciamentoEntreOsIguaisAtivo := False;
      End,
    1000);
  {$EndRegion}
end;

procedure TFormMain.InvocarRegion;
{$Region 'var ...'}
  var Texto, TextoFinal, identamento : String;
      EncontrouTexto: Boolean;
{$EndRegion}
begin
  {$Region 'Verifica se essa funcionalidade já está ativa, ela não pode ser chamada várias vezes seguida'}
    if InvocarRegionAtivo
      then Exit;
    InvocarRegionAtivo := True;
  {$EndRegion}

  {$Region 'Control C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Coloca a region'}
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
  
        EncontrouTexto         := False;
      for char_ in Texto do begin
          if (char_ <> ' ') and not (EncontrouTexto)
            then begin
              TextoFinal       := TextoFinal + '  ' + char_;
            EncontrouTexto   := True;
          end
            else
          if char_ = #10
            then begin
              TextoFinal     := TextoFinal + char_;
            EncontrouTexto := False;
          end
          else TextoFinal  := TextoFinal + char_;
      end;
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
  {$EndRegion}

  {$Region 'Reabilita o uso da funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        InvocarRegionAtivo := False;
      End,
    1000);
  {$EndRegion}
end;

procedure TFormMain.JvPageControl1Change(Sender: TObject);
var
  ExePath, Txt, CaminhoENomeArquivo: String;
  arquivo: TStringList;
begin
  if JvPageControl1.ActivePageIndex = 1 then begin
    ExePath    := ExtractFilePath(Application.ExeName);
    arquivo := TStringList.Create;
    CaminhoENomeArquivo := ExePath + 'Config.ini';
    arquivo.LoadFromFile(CaminhoENomeArquivo);
    Txt := arquivo.Strings[0];
    EditServidor.Text := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt) ));
    Txt := arquivo.Strings[1];
    EditUsuario.Text  := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    Txt := arquivo.Strings[2];
    EditSenha.Text    := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    Txt := arquivo.Strings[3];
    EditDataBase.Text := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    arquivo.Free;
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, getWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  ShowWindow(Application.Handle, SW_SHOW);
end;

procedure TFormMain.PassarSQLParaDelphi(ChamadaPeloTeclado: Boolean = False);
{$Region 'var ...'}
  var
    Linha, Linha_, Texto, Texto_: String;
    char_: char;
{$EndRegion}
begin
  {$Region 'Verifica se funcionalidade já não foi chamada para evitar reuso'}
    if PassarSQLParaDelphiAtivo
      then Exit;
    PassarSQLParaDelphiAtivo := True;
  {$EndRegion}

  {$Region 'Control C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Passa o SQL para Delphi'}
    SetTimeOut(
      Procedure
      var char_: char;
      begin
        Texto             := ClipBoard.AsText;
        Texto_            := '''';
      for char_ in Texto do begin
          if char_ = ''''
            then Texto_   := Texto_ + ''''''
          else
          if char_ = #13
            then Texto_   := Texto_ + '''+FimLinhaStr+' + #13
          else
          if char_ = #10
            then Texto_   := Texto_ + #10 + ''''
          else Texto_   := Texto_ + char_;
      end;
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
  {$EndRegion}

  {$Region 'Reabilita funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        PassarSQLParaDelphiAtivo := False;
      End,
    1000);
  {$EndRegion}
end;

procedure TFormMain.PassarDelphiParaSQL(ChamadaPeloTeclado: Boolean = False);
{$Region 'var ...'}
  var
    Linha, Linha_, Texto, TextoFinal: String;
    char_: char;
    consecutivo: Boolean;
    Strings: TStrings;
{$EndRegion}
begin
  {$Region 'Verificar se funcionalidade ja não foi chamada'}
    if PassarSQLParaDelphiAtivo
      then Exit;
    PassarSQLParaDelphiAtivo   := True;
  {$EndRegion}

  {$Region 'Control C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Passa o delphi para SQL'}
    SetTimeOut(
      Procedure
      var char_: char;
          Linha_: String;
      begin
        Texto              := Clipboard.AsText;
      TextoFinal         := '';

        consecutivo        := True;
      for char_ in Texto do begin
          if (char_ = '''') and (not Consecutivo)
            then begin
              TextoFinal   := TextoFinal + '''';
            consecutivo  := True;
          end
            else
          if (char_ = '''') and (Consecutivo)
            then begin
              consecutivo  := False;
          end
            else
          if char_ = #10
            then begin
              consecutivo  := True;
          end
            else
          if char_ = #13
            then begin
              TextoFinal   := Copy(TRIM(TextoFinal),1,Length(TRIM(TextoFinal))-14) +FimLinhaStr;
            consecutivo  := false;
          end
            else begin
              TextoFinal   := TextoFinal + char_;
            consecutivo  := False;
          end
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
  {$EndRegion}

  {$Region 'Seta timer para reabilitar uso da funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        PassarSQLParaDelphiAtivo := False;
      End,
    2000);
  {$EndRegion}

end;

procedure TFormMain.VerificarProcedimentos;
var
  Thread: TThread;
  Texto: String;
  Alias:      TADOConnection;
  Consultant: TADOQuery;
  Form: TForm;
  DS: TDataSource;
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
  Begin
    Texto       := Clipboard.AsText;
    Thread := TThread.CreateAnonymousThread(
    Procedure
    Begin
      TRY
        {$Region 'Criar objeto de conexão com o banco e configura a conexão'}
          Thread.Synchronize(Thread,
          Procedure
          Begin
            Form := Tform.Create(Self);
            Form.Width  := 500;
            Form.Height := 250;
            Form.Show;
            Form.BorderStyle := bsSizeable;
          End);
          coInitialize(nil);
          Alias := TAdoConnection.Create(Form);
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
          Alias.Name           := 'VerificarProcedimentosConnection';
          Alias.Provider       := 'SQLNCLI11.1';
          Alias.Tag            := 1;
          //Para indicar que é usado em VerificarCamposDaTabela

          ConfigurarConexao(Alias);
          Alias.Connected        := True;
        {$EndRegion}

        {$Region 'Realiza consulta e escreve dados na tela'}
          Consultant := TAdoQuery.Create(Application);
          with consultant do begin
            Close;
            Connection := Alias;
            SQL.Text := 'SELECT '+FimLinhaStr+
                        'case type when ''P'' then ''Stored procedure'' '+FimLinhaStr+
                        'when ''FN'' then ''Function'' '+FimLinhaStr+
                        'when ''TF'' then ''Function'' '+FimLinhaStr+
                        'when ''TR'' then ''Trigger'' '+FimLinhaStr+
                        'when ''V'' then ''View'' '+FimLinhaStr+
                        'else ''Outros Objetos'' '+FimLinhaStr+
                        'end as Procedimento,'+FimLinhaStr+
                        'B.name Nome_Do_Procedimento, A.Text Conteudo '+FimLinhaStr+
                        'FROM syscomments A (nolock)'+FimLinhaStr+
                        'JOIN sysobjects B (nolock) on A.Id = B.Id'+FimLinhaStr+
                        'WHERE A.Text like ''%'+Texto+'%''';
            DS := TDataSource.Create(Form);
            DS.DataSet := Consultant;           amigos
            Thread.Synchronize(Thread,
            Procedure
            Begin
              DBGrid  := TDBGrid.Create(Form);
              with DBGrid do begin
                Parent := Form;
                Align := alClient;
                Name := 'Grid';
                DataSource := DS;
                Visible := True;
                Left    := 0;
                Top     := 0;
                DBGrid.Columns.Insert(0);
                DBGrid.Columns[0].FieldName:='Procedimento';
                DBGrid.Columns[0].Title.Caption:='Procedimento';
                DBGrid.Columns[0].Title.Alignment := taCenter;
                DBGrid.Columns[0].Title.Font.Style := [fsBold];
                DBGrid.Columns[0].Width:=155;
                DBGrid.Columns.Insert(1);
                DBGrid.Columns[1].FieldName:='Nome_Do_Procedimento';
                DBGrid.Columns[1].Title.Caption:='Nome';
                DBGrid.Columns[1].Title.Alignment := taCenter;
                DBGrid.Columns[1].Title.Font.Style := [fsBold];
                DBGrid.Columns[1].Width:=200;
                DBGrid.Columns.Insert(2);
                DBGrid.Columns[2].FieldName:='Conteudo';
                DBGrid.Columns[2].Title.Caption:='Conteudo';
                DBGrid.Columns[2].Title.Alignment := taCenter;
                DBGrid.Columns[2].Title.Font.Style := [fsBold];
                DBGrid.Columns[2].Width:=65;
              end;
              Open;
              Application.BringToFront;
            End);
          end;
        {$EndRegion}
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
    End);
    Thread.Start;
  end,
  100);
end;

procedure TFormMain.VerificarCamposDaTabela;
{$Region 'var ...'}
  var
    Texto: string;
{$EndRegion}
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

  {$Region 'Realiza consulta para trazer dados da tabela ou campo informado'}
    SetTimeOut(
      Procedure
      {$Region 'Var ...'}
        var Alias:      TADOConnection;
            Consultant: TADOQuery;
            Canvas : TCanvas;
            vHDC : HDC;
            pt: TPoint;
            X: Integer;
            TamanhoMaxString: integer;
            SELECT: String;
            TABELAOUCAMPOOUPROCEDIMENTOS: String;
            Thread: TThread;
      {$EndRegion}
      begin
        {$Region 'Cria Thread para realizar a consulta para caso ela for muito grande não fique aparente ao usuário(não usei os eventos da AdoQuery pois daria mais trabalho de vincular.'}
          Thread := TThread.CreateAnonymousThread(
          procedure
          {$Region '...'}
            label FimWith;
          {$EndRegion}
          begin
            TRY
              Texto       := Clipboard.AsText;

              {$Region 'Criar objeto de conexão com o banco e configura a conexão'}
                CoInitialize(nil);
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

                ConfigurarConexao(Alias);
                Alias.Connected        := True;
              {$EndRegion}

              {$Region 'Realiza consulta e escreve dados na tela'}
                Consultant := TAdoQuery.Create(Application);
                with consultant do begin
                  Close;
                  Connection := Alias;
                  TABELAOUCAMPOOUPROCEDIMENTOS := 'TABELA';
                  {$Region 'Montar SELECT'}
                    SELECT        := 'Select'+FimLinhaStr+
                                     'object_name(object_id) as Tabela,'+FimLinhaStr+
                                     'sc.name as Campo,'+FimLinhaStr+
                                     'st.name as Tipo,'+FimLinhaStr+
                                     'sc.max_length as tamanho,'+FimLinhaStr+
                                     'case sc.is_nullable when 0 then ''NÃO'' else ''SIM'' end as PermiteNulo'+FimLinhaStr+
                                     'From'+FimLinhaStr+
                                     'sys.columns sc'+FimLinhaStr+
                                     'Inner Join'+FimLinhaStr+
                                     'sys.types st On st.system_type_id = sc.system_type_id and st.user_type_id = sc.user_type_id'+FimLinhaStr+
                                     'where sc.name like @pesquisaCampo and ( (object_name(object_id) = @pesquisaTabela) or (object_name(object_id) like (@pesquisaTabela+''_'')))'+FimLinhaStr+
                                     'order by sc.is_nullable, sc.name';
                  {$EndRegion}

                  {$Region 'Colocar SELECT NA QUERY'}
                    SQL.Text      := 'declare @pesquisaCampo varchar(100)'+FimLinhaStr+
                                     'declare @pesquisaTabela varchar(100)'+FimLinhaStr+
                                     'set @pesquisaCampo  = ''%'''+FimLinhaStr+
                                     'set @pesquisaTabela = '''+Texto+''''+FimLinhaStr+
                                     ''+FimLinhaStr+
                                     SELECT;
                  {$EndRegion}

                  Open;
                  {$Region 'Se n�o retornar nada, tentar fazer o mesmo considerando ele como campo ao inv�s de tabela'}
                    if IsEmpty then begin
                      TABELAOUCAMPOOUPROCEDIMENTOS := 'CAMPO';
                      SQL.Text      := 'declare @pesquisaCampo varchar(100)'+FimLinhaStr+
                                       'declare @pesquisaTabela varchar(100)'+FimLinhaStr+
                                       'set @pesquisaTabela = ''%'''+FimLinhaStr+
                                       'set @pesquisaCampo  = '''+Texto+''''+FimLinhaStr+
                                       ''+FimLinhaStr+
                                       SELECT;
                      Open;
                      {$Region 'Se vazio ir ao fim do with'}
                        if IsEmpty then begin
                          goto FimWith;
                          //Aten��o use goto com responsabilidade, ele aumenta a complexidade do c�digo muito f�cilmente,
                          //use o m�nimo poss�vel e de prefer�ncia simulando um break (indo para baixo);
                        end;
                      {$EndRegion}
                    end;
                  {$EndRegion}


                  {$Region 'Configura canvas'}
                    vHDC := GetDC(0);
                    Canvas := TCanvas.Create;
                    Canvas.Handle      := vHDC;
                    Canvas.Pen.Color   := ClRed;
                    Canvas.Brush.Color := ClRed;
                    GetCursorPos(pt);
                  {$EndRegion}
                  {$Region 'Ir ao primeiro registro retornado pela consulta'}
                    First;
                  {$EndRegion}

                  {$Region 'Localiza tamanho máximo das strings retornadas, para que com isso seja possivel definir o tamanho do retangulo'}
                    TamanhoMaxString := Length(FieldByName('Tabela').AsString);
                    while not eof do begin
                      if Length(FieldByName('Campo').AsString) > TamanhoMaxString
                        then TamanhoMaxString := Length(FieldByName('Campo').AsString);
                      Next;
                    end;
                  {$EndRegion}

                  {$Region 'Ir ao primeiro registro retornado pela consulta'}
                    First;
                  {$EndRegion}

                  {$Region 'Desenha o retangulo na tela'}
                    X := 1;
                    Canvas.Rectangle(Pt.x,Pt.y,Pt.x + ((TamanhoMaxString + 15) * 5), Pt.y + 10 + (52*RecordCount));
                  {$EndRegion}

                  {$Region 'Escreve dados das tabelas/campos na tela'}
                    {$Region 'Escreve dados sobre a Tabela ou Campo base da consulta'}
                      if TABELAOUCAMPOOUPROCEDIMENTOS = 'TABELA'
                        then Canvas.TextOut(Pt.x,Pt.y,              'TABELA:        ' + FieldByName('Tabela').AsString)
                        else Canvas.TextOut(Pt.x,Pt.y,              'CAMPO:         ' + FieldByName('Campo').AsString);
                    {$EndRegion}
                    while not eof do begin
                      {$Region 'Escreve os dados'}
                        if TABELAOUCAMPOOUPROCEDIMENTOS = 'TABELA'
                          then Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'CAMPO:         ' + FieldByName('Campo').AsString)
                          else Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TABELA:        ' + FieldByName('Tabela').AsString);
                        Inc(X);
                        Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TIPO:         ' + FieldByName('Tipo').AsString);
                        Inc(X);
                        Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TAMANHO:      ' + FieldByName('tamanho').AsString);
                        Inc(X);
                        Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'PERMITE NULO: ' + FieldByName('PermiteNulo').AsString);
                        INC(X);
                      {$EndRegion}

                      {$Region 'Vai ao próximo registro'}
                        Next;
                      {$EndRegion}
                    end;
                  {$EndRegion}

                  FimWith:
                  {$Region 'Libera objeto Query da memória'}
                    Free;
                  {$EndRegion}
                end;
              {$EndRegion}

              {$Region 'Libera objeto de conexão da memória'}
                Alias.Free;
              {$EndRegion}
            FINALLY
              Thread.Synchronize(Thread,
              procedure begin
                {$Region 'Setar TimeOut para reabilitar uso da funcionalidade'}
                  SetTimeOut(
                    Procedure
                    begin
                      VerificarCamposDaTabelaAtivo := False;
                    End,
                  1000);
                {$EndRegion}
              end);
            END;

          end
          );
          Thread.Start;
        {$EndRegion}
      End,
    100);
  {$EndRegion}
end;

end.
