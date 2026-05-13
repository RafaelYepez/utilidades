# ============================================================
#  INSTALADOR PROFESIONAL - LOGICA WINUTIL (Chris Titus)
#  Adaptado para: ChiguiLaptops
# ============================================================

$Apps = @(
    @{ Name = "Google Chrome";      Id = "Google.Chrome";         Type = "winget" }
    @{ Name = "VLC Media Player";   Id = "VideoLAN.VLC";          Type = "winget" }
    @{ Name = "7-Zip";              Id = "7zip.7zip";             Type = "winget" }
    @{ Name = "AnyDesk";            Id = "AnyDeskSoftwareGmbH.AnyDesk"; Type = "winget" }
    @{ Name = "Foxit PDF Reader";   Id = "Foxit.FoxitReader";     Type = "winget" }
    @{ Name = "Lightshot";          Id = "Skillbrains.Lightshot"; Type = "winget" }
    @{ Name = "Open Shell";         Id = "Open-Shell.Open-Shell-Menu"; Type = "winget" }
    @{ Name = "K-Lite Codecs";      Id = "CodecGuide.K-LiteCodecPack.Basic"; Type = "winget" }
    @{ Name = "Visual C++ 2015-2022"; Id = "Microsoft.VCRedist.2015+.x64"; Type = "winget" }
    @{ Name = "DotNet Desktop 6";   Id = "Microsoft.DotNet.DesktopRuntime.6"; Type = "winget" }
)

Write-Host "`n=== CHIGUILAPTOPS: INICIANDO INSTALACION AUTOMATICA ===" -ForegroundColor Cyan

# Aseguramos que Winget use la fuente correcta antes de empezar (Evita errores de msstore)
Write-Host "Configurando fuentes de Winget..." -ForegroundColor Gray
winget source reset --force | Out-Null

foreach ($App in $Apps) {
    Write-Host "`n[*] Instalando $($App.Name)..." -ForegroundColor Yellow
    
    # Parámetros exactos que usa WinUtil:
    # --silent (sin ventanas), --accept-package-agreements (acepta licencias), 
    # --source winget (evita fallos de la Microsoft Store)
    $process = Start-Process winget -ArgumentList "install --id $($App.Id) --silent --accept-package-agreements --accept-source-agreements --source winget" -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "[OK] $($App.Name) instalado correctamente." -ForegroundColor Green
    } else {
        Write-Host "[!] Error al instalar $($App.Name). Código: $($process.ExitCode)" -ForegroundColor Red
    }
}

Write-Host "`n=== PROCESO FINALIZADO - LAPTOP LISTA PARA ENTREGA ===" -ForegroundColor Cyan
Pause
