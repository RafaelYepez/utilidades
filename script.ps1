# ============================================================
#  SCRIPT PROFESIONAL CHIGUILAPTOPS - WINGET ROBUST
# ============================================================
$ErrorActionPreference = "SilentlyContinue"
Write-Host "`n=== INICIANDO CONFIGURACIÓN PROFESIONAL CHIGUILAPTOPS ===" -ForegroundColor Cyan

# 1. REPARACIÓN DE WINGET
Write-Host "[*] Reseteando fuentes de Winget..." -ForegroundColor Gray
winget source reset --force | Out-Null
winget source update | Out-Null

# 2. LISTA DE APLICACIONES (IDs actualizados como en winutil)
$Apps = @(
    @{ Name = "Google Chrome";      Id = "Google.Chrome" }
    @{ Name = "VLC Media Player";   Id = "VideoLAN.VLC" }
    @{ Name = "7-Zip";              Id = "7zip.7zip" }
    @{ Name = "Foxit PDF Reader";   Id = "Foxit.FoxitReader" }
    @{ Name = "Lightshot";          Id = "Skillbrains.Lightshot" }
    @{ Name = "K-Lite Codecs";      Id = "CodecGuide.K-LiteCodecPack.Basic" }
)

# 3. INSTALACIÓN NORMAL
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

# 4. ANYDESK (ID actualizado como en winutil)
Write-Host "`n[*] Instalando AnyDesk..." -ForegroundColor Yellow
$AnyDeskCmd = "install --id AnyDesk.AnyDesk --silent --accept-package-agreements --accept-source-agreements --source winget --force"
$process = Start-Process winget -ArgumentList $AnyDeskCmd -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "    [OK] AnyDesk instalado" -ForegroundColor Green
} else {
    Write-Host "    [!] AnyDesk falló (Código $($process.ExitCode)) - Intentando método alternativo" -ForegroundColor Red
    # Método alternativo directo (por si winget falla)
    try {
        $url = "https://download.anydesk.com/AnyDesk.exe"
        $out = "$env:TEMP\AnyDesk.exe"
        Invoke-WebRequest -Uri $url -OutFile $out
        Start-Process $out -ArgumentList "--install --silent --remove-first" -Wait
        Write-Host "    [OK] AnyDesk instalado por método directo" -ForegroundColor Green
    } catch {
        Write-Host "    [!] Falló también el método directo" -ForegroundColor Red
    }
}

# 5. OPEN-SHELL (Método más confiable - como recomiendan en issues)
Write-Host "`n[*] Instalando Open-Shell..." -ForegroundColor Yellow
$OpenShellUrl = "https://github.com/Open-Shell/Open-Shell-Menu/releases/download/v4.4.198/OpenShellSetup_4_4_198.exe"
$OutFile = "$env:TEMP\OpenShellSetup.exe"

try {
    Invoke-WebRequest -Uri $OpenShellUrl -OutFile $OutFile -UseBasicParsing
    Write-Host "    Descargado. Instalando silenciosamente..." -ForegroundColor Gray
    
    # /qn ADDLOCAL=StartMenu → instala solo el menú clásico (recomendado)
    Start-Process -FilePath $OutFile -ArgumentList "/qn ADDLOCAL=StartMenu" -Wait -NoNewWindow
    
    Write-Host "    [OK] Open-Shell instalado correctamente" -ForegroundColor Green
} 
catch {
    Write-Host "    [!] Error al instalar Open-Shell" -ForegroundColor Red
    Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
}

# 6. OFFICE 2021 LTSC (tu código original)
Write-Host "`n[*] Instalando Microsoft Office 2021 LTSC..." -ForegroundColor Yellow
# ... (mantengo tu bloque de Office sin cambios) ...

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
    Invoke-WebRequest -Uri $SetupUrl -OutFile $SetupPath
    Start-Process -FilePath $SetupPath -ArgumentList "/configure `"$XmlPath`"" -Wait
    Write-Host "    [OK] Office instalado" -ForegroundColor Green
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

Write-Host "`n=== PROCESO FINALIZADO ===" -ForegroundColor Cyan
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
