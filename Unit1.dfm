object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 426
  ClientWidth = 789
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 23
  object Label1: TLabel
    Left = 144
    Top = 60
    Width = 138
    Height = 23
    Caption = 'Vers'#227'o: 1.0.0.1B'
  end
  object Button_Update: TButton
    Left = 568
    Top = 24
    Width = 153
    Height = 97
    Caption = 'Update'
    TabOrder = 0
  end
  object Button_TemDir: TButton
    Left = 568
    Top = 152
    Width = 153
    Height = 97
    Caption = 'Criar Diret'#243'rio Tempor'#225'rio'
    TabOrder = 1
    WordWrap = True
    OnClick = Button_TemDirClick
  end
  object Edit_WindowsTemp: TEdit
    Left = 8
    Top = 255
    Width = 713
    Height = 31
    TabOrder = 2
  end
  object Edit_Origem: TEdit
    Left = 8
    Top = 303
    Width = 713
    Height = 31
    TabOrder = 3
    Text = 'C:\Users\andre\Desktop\AutoUpdate\Win32\Update.exe'
  end
end
