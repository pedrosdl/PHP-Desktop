@echo off
setlocal enabledelayedexpansion

REM 1. Definições de Caminho
set "RAIZ=------"
set "RAIX=www"
set "SETNG_PHP=/Settings/arguments_php.txt"
set "SETNG_CHR=/Settings/arguments_chrome.txt"
set "PHP_EXE=%RAIZ%\PHP\php.exe"
set "CHR_EXE=%RAIZ%\Chromium\Chrome.exe"
set "PHP_PROCESS_NAME=php.exe"
set "CHR_FLD=%RAIZ%\Chromium"

if not exist "%CHR_FLD%\Chrome.dll" (
	start "Juntar DLL" /WAIT "%PHP_EXE%" "%cd%\%CHR_FLD%\join_DLL.php"
)
REM =========================================================
REM LEITURA DE ARQUIVOS DE CONFIGURAÇÃO E VERIFICAÇÕES
REM =========================================================

REM 3. Verifica e lê argumentos de php_arguments.txt
if not exist "%RAIZ%%SETNG_PHP%" (
    echo ERRO: Arquivo %SETNG_PHP% nao encontrado.
    exit /b 1
)
set "ARGS_PHP="
for /f "usebackq tokens=* delims=" %%a in ("%RAIZ%%SETNG_PHP%") do (
    set "ARGS_PHP=%%a"
)
if not defined ARGS_PHP (
    echo AVISO: Nenhuma configuracao encontrada em %SETNG_PHP% Usando padrao.
)

REM 2. Verifica se o PHP existe
if not exist "%PHP_EXE%" (
    echo ERRO: PHP executavel nao encontrado em %PHP_EXE%.
    exit /b 1
)

REM 3. Verifica e lê argumentos de chrome_arguments.txt
if not exist "%RAIZ%%SETNG_CHR%" (
    echo ERRO: Arquivo %SETNG_CHR% nao encontrado.
    exit /b 1
)
set "ARGS_CHROME="
for /f "usebackq tokens=* delims=" %%a in ("%RAIZ%%SETNG_CHR%") do (
    set "ARGS_CHROME=%%a"
)
if not defined ARGS_CHROME (
    echo AVISO: Nenhuma configuracao encontrada em %SETNG_CHR%
)

REM 5. Verifica se o arquivo index.html existe
if not exist "%RAIX%/index.php" (
    echo ERRO: Arquivo www/index.html nao encontrado.
    exit /b 1
)

REM =========================================================
REM INICIALIZAÇÃO DO SERVIDOR E OBTENÇÃO DO PID
REM =========================================================

REM 6. Inicia o servidor PHP em segundo plano (/B)
echo Iniciando servidor PHP...
start "PHP Server" /B "%PHP_EXE%" %ARGS_PHP%

REM Tenta obter o PID do servidor PHP em um loop até que seja encontrado.
set "PHP_PID="
:GetPIDLoop
    echo Tentando obter o PID do %PHP_PROCESS_NAME%...
    timeout /T 1 /NOBREAK >nul
    
    REM Filtra e extrai o PID de forma limpa usando WMIC e CSV
    for /f "tokens=2 delims=," %%a in (
        'wmic process where "Name='%PHP_PROCESS_NAME%'" get ProcessID /format:csv ^| findstr /V "ProcessID"'
    ) do (
        REM A variável PHP_PID será definida para o PID
        set "PHP_PID=%%a"
    )

    REM Se o PID não for definido (ainda não iniciado), repete.
    if not defined PHP_PID (
        echo ... PID nao encontrado. Aguardando.
        goto GetPIDLoop
    )
    
echo PHP Server iniciado com PID: !PHP_PID!

REM =========================================================
REM INICIALIZAÇÃO DO NAVEGADOR E ENCERRAMENTO
REM =========================================================

REM Inicia o navegador e AGUARDA (/WAIT) o usuário fechar a janela.
echo Abrindo o navegador. O servidor sera encerrado quando voce fechar a janela do Chrome.
start "Chrome App" /WAIT "%CHR_EXE%" %ARGS_CHROME%
REM O script so continua a partir daqui apos o usuario fechar o navegador.
taskkill /PID %PHP_PID% /F
echo Servidor encerrado com sucesso.
endlocal
exit