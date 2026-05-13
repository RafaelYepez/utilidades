# ============================================================
#  SCRIPT PROFESIONAL CHIGUILAPTOPS - WINGET ROBUST
# ============================================================
$ErrorActionPreference = "SilentlyContinue"
Write-Host "`n=== INICIANDO CONFIGURACIÓN PROFESIONAL CHIGUILAPTOPS ===" -ForegroundColor Cyan

# 1. REPARACIÓN DE WINGET
Write-Host "[*] Reseteando fuentes de Winget..." -ForegroundColor Gray
winget source reset --force | Out-Null
winget source update | Out-Null

# 2. LISTA DE APLICACIONES (sin AnyDesk ni Open-Shell)
$Apps = @(
    @{ Name = "Google Chrome";      Id = "Google.Chrome" }
    @{ Name = "VLC Media Player";   Id = "VideoLAN.VLC" }
    @{ Name = "7-Zip";              Id = "7zip.7zip" }
    @{ Name = "Foxit PDF Reader";   Id = "Foxit.FoxitReader" }
    @{ Name = "Lightshot";          Id = "Skillbrains.Lightshot" }
    @{ Name = "K-Lite Codecs";      Id = "CodecGuide.K-LiteCodecPack.Basic" }
)

# 3. INSTALACIÓN NORMAL CON WINGET
foreach ($App in $Apps) {
    Write-Host "`n[*] Instalando $($App.Name)..." -ForegroundColor Yellow
    $cmd = "install --id $($App.Id) --silent --accept-package-agreements --accept-source-agreements --source winget --force"
    
    $process = Start-Process winget -ArgumentList $cmd -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "    [OK] $($App.Name) instalado" -ForegroundColor Green
    } else {
        Write-Host "    [!] $($App.Name) falló (Código $($process.ExitCode))" -ForegroundColor Red
    }
}

# 4. ANYDESK - Instalación Directa (evita winget)
Write-Host "`n[*] Instalando AnyDesk (método directo)..." -ForegroundColor Yellow
try {
    $AnyDeskUrl = "https://download.anydesk.com/AnyDesk.exe"
    $AnyDeskPath = "$env:TEMP\AnyDesk.exe"
    
    Invoke-WebRequest -Uri $AnyDeskUrl -OutFile $AnyDeskPath -UseBasicParsing
    Write-Host "    Descargado. Instalando en silencio..." -ForegroundColor Gray
    
    Start-Process -FilePath $AnyDeskPath -ArgumentList "--install --silent --remove-first" -Wait -NoNewWindow
    Write-Host "    [OK] AnyDesk instalado correctamente" -ForegroundColor Green
} 
catch {
    Write-Host "    [!] Error instalando AnyDesk: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. OPEN-SHELL - Instalación Directa (versión estable)
Write-Host "`n[*] Instalando Open-Shell (método directo)..." -ForegroundColor Yellow
try {
    $OpenShellUrl = "https://github.com/Open-Shell/Open-Shell-Menu/releases/download/v4.4.198/OpenShellSetup_4_4_198.exe"
    $OpenShellPath = "$env:TEMP\OpenShellSetup.exe"
    
    Invoke-WebRequest -Uri $OpenShellUrl -OutFile $OpenShellPath -UseBasicParsing
    Write-Host "    Descargado. Instalando en silencio..." -ForegroundColor Gray
    
    Start-Process -FilePath $OpenShellPath -ArgumentList "/qn ADDLOCAL=StartMenu" -Wait -NoNewWindow
    Write-Host "    [OK] Open-Shell instalado correctamente" -ForegroundColor Green
} 
catch {
    Write-Host "    [!] Error instalando Open-Shell: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. OFFICE 2021 LTSC (tu código original)
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
  <RemoveMSI />
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
    Write-Host "    [OK] Office procesado" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error en Office" -ForegroundColor Red
}

# 7. ACTIVACIÓN MAS
Write-Host "`n[*] Activando Windows y Office..." -ForegroundColor Yellow
try {
    & ([scriptblock]::Create((irm https://get.activated.win))) /HWID
    & ([scriptblock]::Create((irm https://get.activated.win))) /Ohook
    Write-Host "    [OK] Activación completada" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error en activación" -ForegroundColor Red
}

Write-Host "`n=== PROCESO FINALIZADO - CHIGUILAPTOPS LISTA ===" -ForegroundColor Cyan
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
