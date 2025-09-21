# ==== CONFIGURACIÓN DE PROYECTO ====
$srcFolder     = "src"        # Código fuente
$binFolder     = "bin"        # Ejecutables de compilación
$releaseFolder = "releases"   # Versiones liberadas
$repoURL       = "https://github.com/sdorian07/Proyectos-por-Version.git"
$branch        = "main"       # Rama principal

# ==== MENSAJE DE COMMIT ====
param(
    [string]$commitMsg = "Compilación automática - Nueva versión"
)

Write-Host "=== INICIANDO PROCESO ==="

#  Verificar o inicializar repositorio Git
if (!(Test-Path ".git")) {
    Write-Host " Repositorio Git no encontrado. Inicializando..."
    git init
    git branch -M $branch
    git remote add origin $repoURL
} else {
    Write-Host "Repositorio Git detectado."
}

# Crear carpetas necesarias
foreach ($folder in @($binFolder, $releaseFolder)) {
    if (!(Test-Path $folder)) {
        Write-Host "Creando carpeta: $folder"
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

# Buscar archivos .cpp en src
$cppFiles = Get-ChildItem -Path $srcFolder -Filter *.cpp
if ($cppFiles.Count -eq 0) {
    Write-Host " No se encontraron archivos .cpp en $srcFolder"
    exit
}

#  Nombre de la versión (ejecutable con fecha y hora)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$exeName   = "program_$timestamp.exe"
$exePath   = Join-Path $binFolder $exeName

Write-Host " Compilando proyecto -> $exeName"

#  Compilación con GCC
g++ $($cppFiles.FullName) -o $exePath

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilación exitosa: $exePath"

    # Guardar versión en releases
    $releaseExe = Join-Path $releaseFolder $exeName
    Copy-Item $exePath $releaseExe -Force
    Write-Host "Versión guardada en releases: $releaseExe"

    # (Opcional) Ejecutar el programa compilado
    Write-Host " Ejecutando programa..."
    & $exePath

    # Subir cambios a GitHub
    Write-Host "Preparando archivos para Git..."
    git add .
    git commit -m "$commitMsg"
    git push -u origin $branch

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Cambios enviados a GitHub correctamente"
    } else {
        Write-Host "No se pudo hacer push, revisa tu conexión o permisos."
    }
} else {
    Write-Host "Error en la compilación. No se hizo commit ni push."
}

Write-Host "=== PROCESO FINALIZADO ==="
