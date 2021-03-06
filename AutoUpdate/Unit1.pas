unit Unit1;

interface

uses
	Winapi.Messages,
	System.Variants,
	System.Classes,
	Vcl.Graphics,
	Vcl.Controls,
	Vcl.Forms,
	Vcl.Dialogs,
	Vcl.StdCtrls,
	Winapi.Windows;

type
	TForm1 = class(TForm)
		Button_Update : TButton;
		Label1 : TLabel;
		Button_TemDir : TButton;
		Edit_WindowsTemp : TEdit;
		Edit_Origem : TEdit;
		procedure Button_TemDirClick(Sender : TObject);
		private
			function GetWindowsTemp : string;
			function criarDiretorio(diretorioTemp : String) : Boolean;
			function GetTmpFileName(ext : String) : String;
			function ExtractName(const Filename : String) : String;
			function GetTmpDir : String;
			procedure KillProcess(hWindowHandle : HWnd; nome : String);
		public
			{ Public declarations }
	end;

var
	Form1 : TForm1;

implementation

uses
	Winapi.ShellAPI,
	System.SysUtils;

{$R *.dfm}

{ TForm1 }

procedure TForm1.Button_TemDirClick(Sender : TObject);
var
	lista   : TStrings;
	nomeBAT : String;
	nomeDOS : String;
begin
	Edit_WindowsTemp.Text := GetWindowsTemp;

	criarDiretorio(Edit_WindowsTemp.Text);
	if FileExists(Application.ExeName) then
	begin
		CopyFile(Pchar(Edit_Origem.Text), Pchar(Edit_WindowsTemp.Text + 'Update.exe'), True);

		if (FileExists(Edit_WindowsTemp.Text + 'Update.exe')) then
		begin
			CopyFile(Pchar(Edit_WindowsTemp.Text + 'Update.exe'),
				Pchar(ChangeFileExt(Application.ExeName, '.tmp')), True);

			nomeDOS := Application.ExeName;
			lista   := TStringList.Create;
			try
				lista.Clear;
				nomeBAT := GetTmpFileName('.bat');
				lista.Add(':Label1');
				lista.Add('@echo off');
				lista.Add('del ' + nomeDOS);
				lista.Add('if Exist ' + nomeDOS + ' goto Label1');
				lista.Add('Move ' + ExtractFilePath(Application.ExeName) + ExtractName(nomeDOS) + '.tmp' + ' ' + nomeDOS);
				lista.Add('TIMEOUT 5');
				lista.Add('Call ' + nomeDOS);
				lista.Add('del ' + nomeBAT);
				lista.SaveToFile(nomeBAT);
				Application.ProcessMessages;
				ChDir(GetTmpDir);
				KillProcess(Application.Handle, nomeBAT);
				Application.Terminate;
				Abort;
			finally

				FreeAndNil(lista);

			end;
		end;

	end;

end;

function TForm1.criarDiretorio(diretorioTemp : String) : Boolean;
var
	SHFileOpStruct : tSHFileOpStruct;
	DirBuf         : array [0 .. 255] of Char;
begin
	Result := False;
	if DirectoryExists(diretorioTemp) then
	begin
		try
			Fillchar(SHFileOpStruct, Sizeof(SHFileOpStruct), 0);
			Fillchar(DirBuf, Sizeof(DirBuf), 0);
			StrPCopy(DirBuf, diretorioTemp);
			with SHFileOpStruct do
			begin
				Wnd    := 0;
				pFrom  := @DirBuf;
				wFunc  := FO_DELETE;
				fFlags := FOF_ALLOWUNDO;
				fFlags := fFlags or FOF_NOCONFIRMATION;
				fFlags := fFlags or FOF_SILENT;
			end;
			Application.ProcessMessages;
			Result := (SHFileOperation(SHFileOpStruct) = 0);
			System.SysUtils.CreateDir(diretorioTemp);
			Application.ProcessMessages;
		except
			Result := False;
		end;
	end else
	begin
		System.SysUtils.CreateDir(diretorioTemp);
		Application.ProcessMessages;
		Result := True;
	end;
end;

function TForm1.ExtractName(const Filename : String) : String;
var
	aExt : String;
	aPos : Integer;
begin
	Application.ProcessMessages;

	aExt   := ExtractFileExt(Filename);
	Result := ExtractFileName(Filename);

	if aExt <> '' then
	begin
		aPos := Pos(aExt, Result);
		if aPos > 0 then
		begin
			Delete(Result, aPos, Length(aExt));
		end;
	end;

	Application.ProcessMessages;
end;

function TForm1.GetTmpDir : String;
var
	pc : Pchar;
begin
	Application.ProcessMessages;
	pc := StrAlloc(Max_path + 1);
	GetTempPath(Max_path, pc);
	Result := string(pc);
	StrDispose(pc);
end;

function TForm1.GetTmpFileName(ext : String) : String;
var
	pc : Pchar;
begin
	Application.ProcessMessages;
	pc := StrAlloc(Max_path + 1);
	GetTempFileName(Pchar(GetTmpDir), 'EZC', 0, pc);
	Result := string(pc);
	Result := ChangeFileExt(Result, ext);
	StrDispose(pc);
end;

function TForm1.GetWindowsTemp : string;
var
	Buffer : array [0 .. Max_path] of Char;
begin
	Fillchar(Buffer, Max_path + 1, 0);
	GetTempPath(Max_path, Buffer);
	Result := string(Buffer);
	if Result[Length(Result)] <> '\' then
		Result := Result + '\';
	Result   := Result + 'UpdateLive\';
end;

procedure TForm1.KillProcess(hWindowHandle : HWnd; nome : String);
var
	hprocessID    : Integer;
	processHandle : THandle;
	DWResult      : DWORD;
	dir           : String;
	EXE           : String;
begin
	SendMessageTimeout(hWindowHandle, WM_CLOSE, 0, 0, SMTO_ABORTIFHUNG Or SMTO_NORMAL, 5000, DWResult);

	if isWindow(hWindowHandle) Then
	begin
		GetWindowThreadProcessID(hWindowHandle, @hprocessID);
		if hprocessID <> 0 Then
		begin
			processHandle := OpenProcess(PROCESS_TERMINATE Or PROCESS_QUERY_INFORMATION, False, hprocessID);
			if processHandle <> 0 Then
			begin
				dir := ExtractFilePath(nome);
				EXE := ExtractFileName(nome);
				ShellExecute(0, nil, pWideChar(EXE), nil, pWideChar(dir), SW_HIDE);
				TerminateProcess(processHandle, 0);
				CloseHandle(processHandle);
			end;
		end;
	end;
end;

end.
