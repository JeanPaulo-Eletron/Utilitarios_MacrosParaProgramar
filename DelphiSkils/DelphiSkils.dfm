object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Utilit'#225'rios'
  ClientHeight = 236
  ClientWidth = 536
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 550
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object JvPageControl1: TJvPageControl
    Left = 0
    Top = 0
    Width = 536
    Height = 236
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 176
    object TabSheet1: TTabSheet
      Caption = 'Atalhos do teclado'
      ExplicitHeight = 148
      object Label1: TLabel
        Left = 0
        Top = 0
        Width = 528
        Height = 208
        Align = alClient
        Caption = 
          'Sobre o bloco de texto Selecionado'#13#10'Control + 0 = Tr'#225's programa ' +
          'para frente'#13#10'Control + 1 = Adiciona "+FimLinhaStr+" e duplica as' +
          'pas simples. '#13#10'Control + 2 = Desfaz o que o Control + 0 fez.'#13#10'Co' +
          'ntrol + 3 = Seta uma region gen'#233'rica sobre.'#13#10'Control + 4 = Igual' +
          'a o distanciamento entre os iguais.'#13#10'Control + 5 = Lista todos o' +
          's campos da tabela ou tabelas do campo, '#13#10'ignora plural.'
        Font.Charset = ANSI_CHARSET
        Font.Color = clMaroon
        Font.Height = -16
        Font.Name = 'Tempus Sans ITC'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 512
        ExplicitHeight = 160
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Mouse E Teclado Autom'#225'tizado'
      ImageIndex = 1
      TabVisible = False
    end
  end
end
