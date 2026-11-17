@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
title Atualizar GitHub - Painel Sao Nicolau
echo ==================================================
echo   Atualizar GitHub - Painel Sao Nicolau
echo ==================================================
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo [ERRO] O Git nao foi encontrado neste computador.
  echo Instale em https://git-scm.com/download/win e rode este arquivo de novo.
  goto :fim
)

if not exist ".git" (
  echo [ERRO] Esta pasta nao esta ligada ao GitHub ^(nao existe a pasta .git^).
  goto :fim
)

if exist "%~dp0sincronizar_versoes.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sincronizar_versoes.ps1"
  if errorlevel 1 echo [AVISO] A sincronizacao das versoes falhou - o envio continua, mas confira as pastas tools e Paineis.
)
echo Arquivos alterados desde o ultimo envio:
echo.
git status --short
echo.

git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo Nada para enviar: o GitHub ja esta igual a esta pasta.
  goto :fim
)

echo Enviando em 5 segundos... ^(Ctrl+C para cancelar^)
timeout /t 5 >nul

set "AGORA=%date% %time:~0,5%"
git commit -q -m "Atualizacao do painel - %AGORA%"
if errorlevel 1 (
  echo [ERRO] Nao foi possivel registrar a alteracao ^(commit^).
  echo Se o Git pediu nome e e-mail, configure uma vez com:
  echo   git config --global user.name "Seu Nome"
  echo   git config --global user.email "seu@email.com"
  goto :fim
)

echo Baixando novidades do GitHub antes de enviar...
git pull --rebase origin main
if errorlevel 1 (
  git rebase --abort >nul 2>&1
  echo [ERRO] O GitHub tem alteracoes que conflitam com esta pasta.
  echo Nada foi enviado. Chame o Claude para resolver.
  goto :fim
)

echo Enviando para o GitHub...
git push origin main
if errorlevel 1 (
  echo [ERRO] O envio falhou. Se abrir uma janela de login do GitHub, entre com sua conta e rode de novo.
  goto :fim
)

echo.
echo ==================================================
echo   PRONTO! Enviado para o GitHub.
echo   O site atualiza em 1 a 2 minutos:
echo   https://thiagog-silva.github.io/Painel-Centro-Medico/
echo   ^(use Ctrl+F5 para ver a versao nova^)
echo ==================================================

:fim
echo.
pause
endlocal
