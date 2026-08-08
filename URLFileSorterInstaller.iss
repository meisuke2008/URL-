#define MyAppName "URL File Sorter"
#define MyAppVersion "0.0.1"
#define MyAppPublisher "meisu"
#define MyAppExeName "app.exe"
#define NativeHostName "com.url_file_sorter"
#define ExtensionId "lifdkcdgicceckllfbibphbcnbainhjl"

[Setup]
AppId={{B218F6A1-BAA2-4B75-A2C0-1DF694A0A201}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={localappdata}\URLFileSorter
DisableProgramGroupPage=yes

PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

OutputDir=output
OutputBaseFilename=URLFileSorterSetup
Compression=lzma
SolidCompression=yes

UninstallDisplayName={#MyAppName}

[Files]
Source: "C:\Users\meisu\Desktop\開発\URL拡張\app\dist\app.exe"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
Root: HKCU; \
Subkey: "Software\Google\Chrome\NativeMessagingHosts\{#NativeHostName}"; \
ValueType: string; \
ValueName: ""; \
ValueData: "{app}\app.json"; \
Flags: uninsdeletekey

[UninstallDelete]
Type: files; Name: "{app}\app.json"
Type: dirifempty; Name: "{app}"

[Code]
function EscapeJsonPath(const Path: String): String;
begin
    Result := Path;
    StringChangeEx(Result, '\', '\\', True);
end;

procedure CreateNativeHostManifest;
var
    JsonText: String;
    AppExePath: String;
    ManifestPath: String;
begin
    AppExePath := ExpandConstant('{app}\{#MyAppExeName}');
    ManifestPath := ExpandConstant('{app}\app.json');

    JsonText :=
        '{' + #13#10 +
        '  "name": "{#NativeHostName}",' + #13#10 +
        '  "description": "URL File Sorter Native Host",' + #13#10 +
        '  "path": "' + EscapeJsonPath(AppExePath) + '",' + #13#10 +
        '  "type": "stdio",' + #13#10 +
        '  "allowed_origins": [' + #13#10 +
        '    "chrome-extension://{#ExtensionId}/"' + #13#10 +
        '  ]' + #13#10 +
        '}';

    if not SaveStringToFile(
        ManifestPath,
        JsonText,
        False
    ) then
    begin
        MsgBox(
            'app.jsonの作成に失敗しました。',
            mbError,
            MB_OK
        );
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    if CurStep = ssPostInstall then
    begin
        CreateNativeHostManifest;
    end;
end;