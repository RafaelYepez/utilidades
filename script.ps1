$ErrorActionPreference = "SilentlyContinue"
Write-Host "`n=== INICIANDO CONFIGURACIÓN GENERAL ===" -ForegroundColor Cyan

$Apps = @(
    @{ Name = "Google Chrome";      Id = "Google.Chrome" }
    @{ Name = "VLC Media Player";   Id = "VideoLAN.VLC" }
    @{ Name = "7-Zip";              Id = "7zip.7zip" }
    @{ Name = "AnyDesk";            Id = "AnyDeskSoftwareGmbH.AnyDesk" }
    @{ Name = "Foxit PDF Reader";   Id = "Foxit.FoxitReader" }
    @{ Name = "Lightshot";          Id = "Skillbrains.Lightshot" }
    @{ Name = "Open Shell";         Id = "Open-Shell.Open-Shell-Menu" }
    @{ Name = "K-Lite Codecs";      Id = "CodecGuide.K-LiteCodecPack.Basic" }
)

Write-Host "[*] Reparando base de datos de Winget..." -ForegroundColor Gray
winget source reset --force | Out-Null
winget source update | Out-Null

foreach ($App in $Apps) {
    Write-Host "`n[*] Instalando $($App.Name)..." -ForegroundColor Yellow
    
    $args = "install --id $($App.Id) --silent --accept-package-agreements --accept-source-agreements --source winget --force"
    
    $process = Start-Process winget -ArgumentList $args -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "    [OK] Instalado correctamente." -ForegroundColor Green
    } else {
        Write-Host "    [!] Error $($process.ExitCode). Reintentando sin fuente específica..." -ForegroundColor Magenta
        winget install --id $($App.Id) --silent --accept-package-agreements --accept-source-agreements
    }
}

Write-Host "`n[*] Instalando Microsoft Office 2021 LTSC..." -ForegroundColor Yellow
$OfficePath = "$env:TEMP\OfficeSetup"
if (!(Test-Path $OfficePath)) { New-Item -ItemType Directory -Path $OfficePath | Out-Null }

$XmlContent = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="PerpetualVL2021">
    <Product ID="ProPlus2021Volume" PIDKEY="HFPBN-RYGG8-HQWCW-26CH6-PDPVF">
      <Language ID="es-es" />
      <ExcludeApp ID="Access" /><ExcludeApp ID="Groove" /><ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" /><ExcludeApp ID="OneNote" /><ExcludeApp ID="Outlook" />
      <ExcludeApp ID="Publisher" /><ExcludeApp ID="Teams" />
    </Product>
  </Add>
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
"@

$XmlPath = "$OfficePath\config_ltsc.xml"
$XmlContent | Out-File -FilePath $XmlPath -Encoding utf8
$SetupUrl = "https://github.com/RafaelYepez/utilidades/raw/refs/heads/main/setup.exe"
$SetupPath = "$OfficePath\setup.exe"

try {
    Invoke-WebRequest -Uri $SetupUrl -OutFile $SetupPath -ErrorAction Stop
    Start-Process -FilePath $SetupPath -ArgumentList "/configure `"$XmlPath`"" -Wait
    Write-Host "    [OK] Office 2021 configurado." -ForegroundColor Green
} catch {
    Write-Host "    [!] Falló la descarga de Office." -ForegroundColor Red
}

Write-Host "`n[*] Activando Windows y Office (Modo Silencioso)..." -ForegroundColor Yellow
try {
    & ([scriptblock]::Create((irm https://get.activated.win))) /HWID
    & ([scriptblock]::Create((irm https://get.activated.win))) /Ohook
    Write-Host "[OK] Sistema activado." -ForegroundColor Green
} catch {
    Write-Host "[!] Error en activación remota." -ForegroundColor Red
}

Write-Host "`n=== CHIGUILAPTOPS: PROCESO COMPLETADO ===" -ForegroundColor Cyan
Write-Host "Presione cualquier tecla para cerrar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
