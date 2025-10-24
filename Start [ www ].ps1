#requires -Version 5.0
$ErrorActionPreference = 'Stop'

# =========================================================
# 1. Definições de Caminho
# =========================================================
$RAIY = "------"
$RAIX = "www"
$SETNG_PHP = "/Settings/arguments_php.txt"
$SETNG_CHR = "/Settings/arguments_chrome.txt"
$PHP_EXE = "$RAIY\PHP\php.exe"
$CHR_EXE = "$RAIY\Chromium\Chrome.exe"
$PHP_PROCESS_NAME = "php.exe"
$CHR_FLD = "$RAIY\Chromium"

# =========================================================
# Verifica se Chrome.dll existe, senão executa join_DLL.php
# =========================================================
if (-not (Test-Path "$CHR_FLD\Chrome.dll")) {
    Write-Host "Juntando DLLs..." -ForegroundColor Yellow
    & "$PHP_EXE" "$PSScriptRoot\$CHR_FLD\join_DLL.php"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao executar join_DLL.php"
        exit 1
    }
}

# =========================================================
# LEITURA DE ARQUIVOS DE CONFIGURAÇÃO E VERIFICAÇÕES
# =========================================================

# 2. Verifica se PHP.exe existe
if (-not (Test-Path $PHP_EXE)) {
    Write-Error "ERRO: PHP executável não encontrado em $PHP_EXE"
    exit 1
}

# 3. Lê argumentos do PHP
$PHP_ARGS_PATH = "$RAIY$SETNG_PHP"
if (-not (Test-Path $PHP_ARGS_PATH)) {
    Write-Error "ERRO: Arquivo $SETNG_PHP não encontrado."
    exit 1
}

$ARGS_PHP = Get-Content -Path $PHP_ARGS_PATH -Raw -ErrorAction SilentlyContinue
$ARGS_PHP = $ARGS_PHP.Trim()
if ([string]::IsNullOrWhiteSpace($ARGS_PHP)) {
    Write-Warning "AVISO: Nenhuma configuração encontrada em $SETNG_PHP. Usando padrão."
    $ARGS_PHP = ""
}

# 4. Lê argumentos do Chrome
$CHR_ARGS_PATH = "$RAIY$SETNG_CHR"
if (-not (Test-Path $CHR_ARGS_PATH)) {
    Write-Error "ERRO: Arquivo $SETNG_CHR não encontrado."
    exit 1
}

$ARGS_CHROME = Get-Content -Path $CHR_ARGS_PATH -Raw -ErrorAction SilentlyContinue
$ARGS_CHROME = $ARGS_CHROME.Trim()
if ([string]::IsNullOrWhiteSpace($ARGS_CHROME)) {
    Write-Warning "AVISO: Nenhuma configuração encontrada em $SETNG_CHR"
    $ARGS_CHROME = ""
}

# 5. Verifica se index.php existe
if (-not (Test-Path "$RAIX/index.php")) {
    Write-Error "ERRO: Arquivo www/index.php não encontrado."
    exit 1
}

# =========================================================
# INICIALIZAÇÃO DO SERVIDOR PHP
# =========================================================
Write-Host "Iniciando servidor PHP..." -ForegroundColor Green

# Inicia o PHP em segundo plano
$PhpProcess = Start-Process -FilePath $PHP_EXE -ArgumentList $ARGS_PHP -PassThru -NoNewWindow

# Aguarda até que o processo esteja realmente ativo
$PhpPid = $null
do {
    Start-Sleep -Milliseconds 500
    $PhpProcess.Refresh()
    if ($PhpProcess.HasExited) {
        Write-Error "ERRO: Processo PHP terminou inesperadamente."
        exit 1
    }
    $PhpPid = $PhpProcess.Id
} while (-not $PhpPid)

Write-Host "PHP Server iniciado com PID: $PhpPid" -ForegroundColor Green

# =========================================================
# INICIALIZAÇÃO DO NAVEGADOR
# =========================================================
Write-Host "Abrindo o navegador. O servidor será encerrado quando você fechar o Chrome." -ForegroundColor Cyan

# Inicia o Chrome e aguarda fechar
$ChromeProcess = Start-Process -FilePath $CHR_EXE -ArgumentList $ARGS_CHROME -PassThru

# Aguarda o Chrome fechar
try {
    $ChromeProcess.WaitForExit()
} catch {
    # Em caso de erro (ex: processo já morto), continua
}

# =========================================================
# ENCERRAMENTO DO SERVIDOR PHP
# =========================================================
Write-Host "Encerrando servidor PHP (PID: $PhpPid)..." -ForegroundColor Yellow

try {
    Stop-Process -Id $PhpPid -Force -ErrorAction Stop
    Write-Host "Servidor encerrado com sucesso." -ForegroundColor Green
} catch {
    Write-Warning "Não foi possível encerrar o processo PHP (PID: $PhpPid). Pode já estar fechado."
}

exit 0