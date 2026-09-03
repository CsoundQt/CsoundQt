; CsoundQt 7  I N N O   S E T U P   S C R I P T
;
; Builds a Windows installer for CsoundQt 7 from a staging directory that
; already contains the deployed application (CsoundQt.exe + Qt runtime +
; the Csound runtime it was built against). Meant to be driven from CI.
;
; Required environment variables:
;   CSOUNDQT_VERSION        e.g. "7.0.2"
;   CSOUNDQT_APPNAME        executable file name, e.g. "CsoundQt-d-cs7.exe"
;   CSOUNDQT_STAGING_DIR    directory whose content is installed to {app}
;
; Optional environment variables:
;   CSOUNDQT_BUILDNUM       appended to the output file name (e.g. GITHUB_RUN_NUMBER)

[setup]
#define AppName "CsoundQt"
#define AppVersion GetEnv("CSOUNDQT_VERSION")
#define AppExeName GetEnv("CSOUNDQT_APPNAME")
#define StagingDir GetEnv("CSOUNDQT_STAGING_DIR")
#define BuildNum GetEnv("CSOUNDQT_BUILDNUM")
#define AppPublisher "CsoundQt"
#define AppURL "https://csoundqt.github.io/"
#if BuildNum != ""
#define BuildSuffix "-" + BuildNum
#else
#define BuildSuffix ""
#endif

AppVerName={#AppName} {#AppVersion}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AppId={{7ECAB2AF-9E01-4F44-B27C-5E4A6A1C6C7C}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=yes
DisableDirPage=no
LicenseFile="..\..\lgpl-2.1.txt"
SetupIconFile="..\..\images\csoundqt.ico"
OutputBaseFilename={#AppName}-{#AppVersion}-windows_x86_64{#BuildSuffix}
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#StagingDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: modifypath; Description: "Add CsoundQt directory to your PATH environment variable"

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName:"Path"; ValueData:"{app};{olddata}"; Flags: preservestringtype uninsdeletevalue; Tasks: modifypath

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
