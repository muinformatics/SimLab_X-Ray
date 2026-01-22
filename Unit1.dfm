object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Simlab x-ray acquisition'
  ClientHeight = 743
  ClientWidth = 1065
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ImgHolder: TImage
    Left = 281
    Top = 281
    Width = 784
    Height = 462
    Align = alClient
    Anchors = []
    Enabled = False
    Proportional = True
    Stretch = True
    Visible = False
    ExplicitLeft = 287
    ExplicitTop = 409
    ExplicitHeight = 424
  end
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1065
    Height = 281
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label3: TLabel
      Left = 544
      Top = 252
      Width = 451
      Height = 23
      Caption = 'Note - X-ray image appears after saving file to server.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 136
      Top = 16
      Width = 244
      Height = 25
      Caption = 'Selected Student: None'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Image1: TImage
      Left = 544
      Top = 51
      Width = 192
      Height = 142
      Proportional = True
      Stretch = True
    end
    object Label1: TLabel
      Left = 136
      Top = 47
      Width = 3
      Height = 13
    end
    object Label4: TLabel
      Left = 544
      Top = 219
      Width = 6
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object BtnScanWithDialog: TButton
      Left = 1
      Top = 87
      Width = 129
      Height = 25
      Caption = 'Scan With Dialog'
      TabOrder = 0
      Visible = False
      OnClick = BtnScanWithDialogClick
    end
    object BtnScanWithoutDialog: TButton
      Left = 136
      Top = 68
      Width = 345
      Height = 90
      Caption = 'Scan'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = BtnScanWithoutDialogClick
    end
    object BtnReloadSources: TButton
      Left = 0
      Top = 118
      Width = 113
      Height = 25
      Caption = 'Reload Sources'
      TabOrder = 2
      Visible = False
      OnClick = BtnReloadSourcesClick
    end
    object Button1: TButton
      Left = 136
      Top = 164
      Width = 345
      Height = 81
      Caption = 'Save This x-Ray'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = Button1Click
    end
    object ComboBox1: TComboBox
      Left = 8
      Top = 224
      Width = 457
      Height = 21
      DropDownCount = 25
      TabOrder = 3
      Text = 'Select Student'
      Visible = False
      OnChange = ComboBox1Change
    end
    object Button3: TButton
      Left = 760
      Top = 51
      Width = 257
      Height = 142
      Caption = 'Close Student Session'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = Button3Click
    end
    object Panel1: TPanel
      Left = 8
      Top = 13
      Width = 1017
      Height = 262
      Caption = 'Swipe your barcode to start the session'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      object Edit1: TEdit
        Left = 248
        Top = 168
        Width = 385
        Height = 43
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -29
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnKeyPress = Edit1KeyPress
      end
      object Button4: TButton
        Left = 776
        Top = 0
        Width = 121
        Height = 32
        Caption = 'Test FTP'
        TabOrder = 1
        Visible = False
        OnClick = Button4Click
      end
    end
  end
  object LBSources: TListBox
    Left = 0
    Top = 281
    Width = 281
    Height = 462
    Align = alLeft
    ItemHeight = 13
    TabOrder = 1
  end
  object Button2: TButton
    Left = 943
    Top = 4
    Width = 122
    Height = 41
    Caption = 'Mock xray'
    TabOrder = 2
    Visible = False
    OnClick = Button2Click
  end
  object IdFTP1: TIdFTP
    Host = '134.48.29.132'
    Passive = True
    ConnectTimeout = 0
    ExternalIP = '134.48.29.132'
    Password = 'phone2012'
    Username = 'xray'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 16
    Top = 192
  end
end
