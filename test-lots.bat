@echo off
chcp 1251 >nul
setlocal

REM ============================================================
REM  PigPoints - заливка ТЕСТОВЫХ лотов в pointauc (для проверки расширения)
REM
REM  ВАЖНО: храни этот файл в кодировке Windows-1251 (ANSI / Кириллица).
REM         Если пересохранить в UTF-8 - кириллица сломается.
REM
REM  КАК ПОЛЬЗОВАТЬСЯ:
REM   1) Вставь свой токен в строку TOKEN ниже
REM      (pointauc.com -> Настройки -> Personal Token).
REM      Держи вкладку аукциона ОТКРЫТОЙ при запуске (API шлёт в неё).
REM   2) В блоке "СПИСОК ЛОТОВ" перечисли строки:
REM         call :add "Название лота"  "ник"  баллы          - обычная ставка
REM         call :add "Название лота"  "ник"  баллы  don     - как донат
REM      Кейсы: один лот + разные ники = групповой лот;
REM             один ник + разные лоты  = ник в нескольких лотах;
REM             ник без лота            = в расширении "выбрать лот".
REM   3) Сохрани файл и запусти двойным кликом (201 = успех).
REM
REM  Превью без отправки: убери REM в строке "set DRYRUN=1".
REM  Имена лотов - латиницей. Ники = ники из таблицы (twitch-логины).
REM ============================================================

set "TOKEN=PASTE_TOKEN_HERE"
REM set "DRYRUN=1"

REM =================== СПИСОК ЛОТОВ ===========================
call :add "Dune"         "darkwolf"   551 don
call :add "Hades"        "lena_play"  281 don
call :add "Inside"       "nikitos"    206 don
call :add "Blade Runner" "kotik"      251 don
call :add "Outer Wilds"  "procrast"   201 don
REM =================== КОНЕЦ СПИСКА ===========================

del "%TEMP%\pa_bid.json" 2>nul
echo.
echo Готово. Открой pointauc и проверь доску.
pause
exit /b

:add
set "LOT=%~1"
set "INV=%~2"
set "PTS=%~3"
set "DON=true"
if /i "%~4"=="don" set "DON=true"
> "%TEMP%\pa_bid.json" echo {"bids":[{"cost":%PTS%,"message":"%LOT%","investorId":"%INV%","username":"%INV%","insertStrategy":"force","isDonation":%DON%}]}
if defined DRYRUN (
  echo [dry] %LOT% / %INV% / %PTS% / don=%DON%
  type "%TEMP%\pa_bid.json"
  echo.
  goto :eof
)
echo %TOKEN%| findstr /c:"-" >nul || (
  echo [!] Сначала впиши свой реальный токен в строку TOKEN вверху файла.
  goto :eof
)
curl -s -o nul -w "  [%%{http_code}] %LOT% / %INV% : %PTS% (don=%DON%)\n" -X POST -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" --data-binary "@%TEMP%\pa_bid.json" "https://pointauc.com/api/oshino/bids"
goto :eof
