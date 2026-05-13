# ============================================================
#  SCRIPT PROFESIONAL CHIGUILAPTOPS - WINGET ROBUST
#  Lógica: Gestión de paquetes dinámica + Activación MAS
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
Write-Host "`n=== INICIANDO CONFIGURACIÓN PROFESIONAL CHIGUILAPTOPS ===" -ForegroundColor Cyan

# 1. REPARACIÓN PROFUNDA DE WINGET (Para evitar error -1978335189)
# Esto elimina la dependencia de la Microsoft Store y resetea las fuentes.
Write-Host "[*] Limpiando y reseteando fuentes de Winget..." -ForegroundColor Gray
winget source reset --force | Out-Null
winget source update | Out-Null

# 2. LISTA DE IDs UNIVERSALES (Basado en el JSON de Titus)
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

# 3. INSTALACIÓN DE APLICACIONES CON FILTRO DE FUENTE
foreach ($App in $Apps) {
    Write-Host "`n[*] Instalando $($App.Name)..." -ForegroundColor Yellow
    
    # --source winget es CRITICO: evita que busque en la MS Store y use el repo de la comunidad.
    # --force: ignora advertencias de versiones.
    $args = "install --id $($App.Id) --silent --accept-package-agreements --accept-source-agreements --source winget --force"
    
    $process = Start-Process winget -ArgumentList $args -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "    [OK] Instalado correctamente." -ForegroundColor Green
    } else {
        Write-Host "    [!] Winget falló (Código $($process.ExitCode))." -ForegroundColor Red
    }
}

# 4. INSTALACIÓN DE MICROSOFT OFFICE 2021 LTSC
Write-Host "`n[*] Instalando Microsoft Office 2021 LTSC..." -ForegroundColor Yellow
$OfficePath = "$env:TEMP\OfficeSetup"
if (!(Test-Path $OfficePath)) { New-Item -ItemType Directory -Path $OfficePath | Out-Null }

# Creamos el XML con tus parámetros específicos
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

# Descargamos el setup.exe de tu repositorio
$SetupUrl = "https://github.com/RafaelYepez/utilidades/raw/refs/heads/main/setup.exe"
$SetupPath = "$OfficePath\setup.exe"

try {
    Invoke-WebRequest -Uri $SetupUrl -OutFile $SetupPath -ErrorAction Stop
    Write-Host "    Iniciando Setup de Office..." -ForegroundColor Gray
    Start-Process -FilePath $SetupPath -ArgumentList "/configure `"$XmlPath`"" -Wait
    Write-Host "    [OK] Proceso de Office finalizado." -ForegroundColor Green
} catch {
    Write-Host "    [!] Error al descargar o ejecutar Office Setup." -ForegroundColor Red
}

# 5. ACTIVACIÓN AUTOMÁTICA (MAS - MODO DESATENDIDO)
Write-Host "`n[*] Activando Windows y Office (Modo Silencioso)..." -ForegroundColor Yellow
try {
    # Usamos la URL corta oficial de MAS que acepta parámetros /HWID y /Ohook
    Write-Host "    -> Activando Windows 10/11..." -ForegroundColor Gray
    & ([scriptblock]::Create((irm https://get.activated.win))) /HWID

    Write-Host "    -> Activando Microsoft Office..." -ForegroundColor Gray
    & ([scriptblock]::Create((irm https://get.activated.win))) /Ohook
    
    Write-Host "[OK] Activación completada." -ForegroundColor Green
} catch {
    Write-Host "[!] Error de conexión con los servidores de activación." -ForegroundColor Red
}

Write-Host "`n=== PROCESO FINALIZADO - CHIGUILAPTOPS LISTA ===" -ForegroundColor Cyan
Write-Host "Presione cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
