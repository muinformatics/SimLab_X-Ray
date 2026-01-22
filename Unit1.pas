unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, DelphiTwain, DelphiTwain_Vcl, Vcl.StdCtrls,
  Vcl.ExtCtrls, StrUtils, Vcl.Imaging.Jpeg, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTP, IdFTPCommon, WinAPI.ShellApi ;

type
  TForm1 = class(TForm)
    PnlTop: TPanel;
    LBSources: TListBox;
    ImgHolder: TImage;
    BtnScanWithDialog: TButton;
    BtnScanWithoutDialog: TButton;
    BtnReloadSources: TButton;
    ComboBox1: TComboBox;
    Image1: TImage;
    Button1: TButton;
    IdFTP1: TIdFTP;
    Button2: TButton;
    Label1: TLabel;
    Panel1: TPanel;
    Edit1: TEdit;
    Button3: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button4: TButton;
    procedure BtnReloadSourcesClick(Sender: TObject);
    procedure BtnScanWithDialogClick(Sender: TObject);
    procedure BtnScanWithoutDialogClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WriteLog(fname:string);
    procedure SaveAsJpg(fname:string);
    procedure FetchData;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure Button4Click(Sender: TObject);

  private
    Twain: TDelphiTwain;

    procedure ReloadSources;
    procedure TwainTwainAcquire(Sender: TObject; const Index: Integer;
      Image: TBitmap; var Cancel: Boolean);
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
  end;

type
  Tusers = Record
     lname : string[20];
     fname : string[20];
     email : string[50];
     sid : string[15];
     scode : string[8];
     group : string[2];
     year : string[20];
     gender : string[20];
     sequence : string[20];
     rounds : string[20];
     blank1 : string[20];
     blank2 : string[20];
     fullname : string[20];
  End;

type
    TSimlab = Record
      card : string[15];
      producer : string[10];
      student : string[50];
  End;


var
  thisstudent : integer;
  thisproducer : string;
  thisuser, thisrole, Ffolder : string;
  UserRecord : array of Tusers;
  SimlabRecord : array of Tsimlab;
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.BtnReloadSourcesClick(Sender: TObject);
begin
  if Twain.SourceManagerLoaded then
    ReloadSources;
end;

procedure TForm1.BtnScanWithDialogClick(Sender: TObject);
begin
  Twain.SelectedSourceIndex := LBSources.ItemIndex;

  if Assigned(Twain.SelectedSource) then begin
    //Load source, select transference method and enable (display interface)}
    Twain.SelectedSource.Loaded := True;
    Twain.SelectedSource.ShowUI := True;//display interface
    Twain.SelectedSource.Enabled := True;
  end;
end;

procedure TForm1.BtnScanWithoutDialogClick(Sender: TObject);
begin
  Label1.Caption:='';
  Twain.SelectedSourceIndex := LBSources.ItemIndex;

  if Assigned(Twain.SelectedSource) then begin
    //Load source, select transference method and enable (display interface)}
    Twain.SelectedSource.Loaded := True;
    Twain.SelectedSource.ShowUI := False;
    Twain.SelectedSource.Enabled := True;
    Button1.Enabled := True;
    ImgHolder.Visible:=False;
    label4.Caption:='Image successfully scanned.';
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  fname : string;
  formattedDateTime : string;
  myDate : TDateTime;
  param1 : string;

begin
  if(ImgHolder.Picture.Graphic <> Nil) and (thisproducer <> 'none') then
  begin
    myDate := Now;
    DateTimeToString(formattedDateTime, 'yyyy-mm-dd-hh-nn-zzz', myDate);
    fname := LeftStr(thisproducer,5)+'-'+formattedDateTime+'.jpg';
    writelog('Upload: '+fname);

    param1 := '"C:\Users\svc-dentappsnd-sftp\.ssh" "'+fname+'"';
    ShellExecute(0, 'open', PChar('upload_image.bat'), PChar(param1), '', SW_SHOWNORMAL);

    button1.Enabled:=false;
    ImgHolder.Visible:=True;
    label1.Caption:='File '+fname+ ' uploaded.';
    label4.Caption:='';
    Button1.Enabled := False;

  end
  else
    begin
      showmessage('File not saved - Must select student and have a scanned image.');
    end
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  folder : string;
begin
  folder := GetCurrentDir;
  ImgHolder.Picture.LoadFromFile(folder + '\xray.jpg');
  Button1.Enabled := True;
  ImgHolder.Visible:=False;
  label4.Caption:='Image successfully scanned.';
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    edit1.Text := '';
    panel1.Visible := TRUE;
    label2.Caption:='Selected Student: None';
    thisproducer := 'none';
    ImgHolder.Visible:=False;
    label1.Caption:='';
    label4.Caption:='';
    edit1.SetFocus;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  param1 : string;
begin
    param1 := '"C:\Users\svc-dentappsnd-sftp\.ssh" "S9999.jpg"';
    ShellExecute(0, 'open', PChar('upload_image.bat'), PChar(param1), '', SW_SHOWNORMAL);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  fname : string;
begin

  if (ComboBox1.Text = 'Close Student Session') then
  begin
    panel1.Visible := TRUE;
  end
  else
  begin
    panel1.Visible := FALSE;
  end;



  //fname := '\\vs-dentfs1\delphi$\simlabxrays\images\' + LeftStr(ComboBox1.Text,5) + '.jpg';
  fname := '\\marqnet.mu.edu\depts\Dental\Groups\Delphi\simlabxrays\images\' + LeftStr(ComboBox1.Text,5) + '.jpg';


  if (FileExists(fname)) then
  begin
    BtnScanWithoutDialog.Enabled:=True;
    //showmessage(fname);
    Image1.Picture.LoadFromFile(fname);
    BtnScanWithoutDialog.SetFocus;
  end
  else
  begin
    BtnScanWithoutDialog.Enabled:=False;
    Image1.Picture:=Nil;
    //Button1.Enabled := False;
  end;
end;

procedure TForm1.DoCreate;
begin
  inherited;

  Twain := TDelphiTwain.Create;
  Twain.OnTwainAcquire := TwainTwainAcquire;

  if Twain.LoadLibrary then
  begin
    //Load source manager
    Twain.SourceManagerLoaded := TRUE;

    ReloadSources;
  end else begin
    ShowMessage('Twain is not installed.');
  end;
end;

procedure TForm1.DoDestroy;
begin
  Twain.Free;//Don't forget to free Twain!

  inherited;
end;


procedure TForm1.Edit1Exit(Sender: TObject);
var
  x : integer;
  cardfound : integer;
begin
    cardfound := 0;
    for x := 0 to length(SimlabRecord)-1 do
    begin
      if ( pos(SimlabRecord[x].card,Edit1.Text) > 0 ) then
      begin
        label2.Caption:='Selected Student: '+SimlabRecord[x].student;
        thisproducer := SimlabRecord[x].producer;
        panel1.Visible := FALSE;
        cardfound := 1;
      end
    end;
    if cardfound = 0 then
      begin
        edit1.Text := '';
        showmessage('Sorry - that card read failed - please try again...');
        edit1.SetFocus;
      end;

end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
      SelectNext(Sender as tWinControl, True, True );
      if Sender = Edit1 then
        Edit1Exit(Sender);
      Key := #0;
  end;

end;

procedure TForm1.ReloadSources;
var
  I: Integer;
begin
  LBSources.Items.Clear;
  for I := 0 to Twain.SourceCount-1 do
    LBSources.Items.Add(Twain.Source[I].ProductName);

  if LBSources.Items.Count > 0 then
    LBSources.ItemIndex := 0;
end;

procedure TForm1.TwainTwainAcquire(Sender: TObject; const Index: Integer;
  Image: TBitmap; var Cancel: Boolean);
var
  Jpg: TJPEGImage;
  parameter : string;
begin
  deletefile('xray.jpg');
  deletefile('xray.bmp');
  Jpg := TJPEGImage.Create;
  try
    //Bmp.LoadFromFile(Image);
    Jpg.Assign(Image);
    Jpg.SaveToFile('xray.jpg');
    Image.SaveToFile('xray.bmp');
  finally
    Jpg.Free;
  end;

  //parameter := ' -rotate 90 xray.jpg xray.jpg';
  //ShellExecute(Handle, 'open', 'jpegtran.exe', PChar(parameter), nil, SW_SHOW );
  //SaveAsJpg('xray.jpg');

  //showmessage('wait');
  //Image.SaveToFile('xray.jpg');

  ImgHolder.Picture.Assign(Image);
  //ImgHolder.Picture.LoadFromFile('xray.jpg');
  Cancel := True;//Only want one image
end;

procedure TForm1.SaveAsJpg(fname:string);
var
 SEInfo: TShellExecuteInfo;
 ExitCode: DWORD;
 ExecuteFile, ParamString, StartInString: string;
begin
 ExecuteFile:='jpegtran.exe';

 FillChar(SEInfo, SizeOf(SEInfo), 0) ;
 SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
 with SEInfo do begin
 fMask := SEE_MASK_NOCLOSEPROCESS;
 Wnd := Application.Handle;
 lpFile := PChar(ExecuteFile) ;
 lpParameters := PChar(' -rotate 90 xray.jpg xray.jpg') ;
{
ParamString can contain the
application parameters.
}
// lpParameters := PChar(ParamString) ;
{
StartInString specifies the
name of the working directory.
If ommited, the current directory is used.
}
// lpDirectory := PChar(StartInString) ;
 nShow := SW_SHOWNORMAL;
 end;
 if ShellExecuteEx(@SEInfo) then
 begin repeat
   Application.ProcessMessages;
   GetExitCodeProcess(SEInfo.hProcess, ExitCode) ;
 until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
   //ShowMessage('Scan unsuccessful - terminated') ;
 end
 else ShowMessage('Error starting scan!') ;
end;



procedure TForm1.WriteLog(fname:string);
var
  myFile : TextFile;
  text   : string;
  i      : Integer;

begin
  // Try to open the Test.txt file for writing to

  AssignFile(myFile, 'log.txt');
  Append(myFile);

  // Write a couple of well known words to this file
  write(myFile, fname);
  WriteLn(myFile);

  // Close the file
  CloseFile(myFile);
end;

procedure TForm1.FetchData;
var
  y, recno, StatusFound : integer;
  Schedfile: Textfile;
  Schedline, Ffolder : string;
  SchedTstring : TStringList;
  ComboTstring : TStringList;
begin
  recno := 0;
  SchedTstring := TstringList.Create;
  ComboTstring := TstringList.Create;

  //Ffolder:='\\vs-dentfs1\delphi$\simlabxrays\';
  Ffolder:='\\marqnet.mu.edu\depts\Dental\Groups\Delphi\simlabxrays\';


  Assignfile(SchedFile, Ffolder + 'simlablist.csv');
  reset(Schedfile);
  while not eof(SchedFile) do
  begin
    ReadLn(SchedFile, Schedline);
    SchedTstring.Delimiter := ',';
    SchedTstring.DelimitedText := Schedline;

      if ( (length(SchedTstring[0]) > 0) and (length(SchedTstring[1]) > 0) and (length(SchedTstring[2]) > 0))  then
      begin
        inc(recno);
        if length(SimlabRecord)< recno then SetLength(SimlabRecord,recno);
        with SimlabRecord[recno-1] do
        begin
          card := SchedTstring[0];
          producer := SchedTstring[1] ;
          student := SchedTstring[2] ;
          //course := ADOQuery1.Fields[4].AsString;
        end;

      end;
  end;

  CloseFile(Schedfile);

//  showmessage(SimlabRecord[5].card);


//  Ffolder:='\\vs-dentfs1\delphi$\simlabxrays\';
//  Assignfile(SchedFile, Ffolder + 'student.csv');
//  ComboTstring.Add('Close Student Session');
//  reset(Schedfile);
//  while not eof(SchedFile) do
//  begin
//    ReadLn(SchedFile, Schedline);
//    SchedTstring.Delimiter := ',';
//    SchedTstring.DelimitedText := Schedline;
//    ComboTstring.Add(Schedline);
//      if ( (length(SchedTstring[0]) > 0))  then
//      begin
//        //ComboTstring.Add(SchedTstring[5]+' - '+SchedTstring[13]);
//      end;
//  end;
//  CloseFile(Schedfile);
//  ComboTstring.Add('S9999 - Test Student');
//  ComboBox1.Items.AddStrings(ComboTstring);



end;


procedure TForm1.FormActivate(Sender: TObject);
begin
  edit1.SetFocus;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  thisproducer := 'none';
  FetchData;
end;


end.
