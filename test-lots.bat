@echo off
chcp 1251 >nul
setlocal

REM ============================================================
REM  PigRating - заливка ТЕСТОВЫХ лотов в pointauc (для проверки расширения)
REM
REM  ВАЖНО: храни этот файл в кодировке Windows-1251 (ANSI / Кириллица).
REM         Если пересохранить в UTF-8 - кириллица сломается.
REM
REM  КАК ПОЛЬЗОВАТЬСЯ:
REM   1) Вставь свой токен в строку TOKEN ниже
REM      (pointauc.com -> Настройки -> Personal Token).
REM   2) В блоке "СПИСОК ЛОТОВ" перечисли строки вида:
REM         call :add "Название лота"  "ник_инвестора"  баллы
REM      Тест-кейсы:
REM       - один и тот же ЛОТ с разными никами   = несколько вкладчиков (групповой лот)
REM       - один и тот же НИК в разных лотах      = ник в нескольких лотах
REM       - ник, которого нигде нет              = в расширении "выбрать лот / нет лота"
REM   3) Сохрани файл и запусти двойным кликом.
REM
REM  Превью без отправки: убери REM в строке "set DRYRUN=1".
REM  Имена лотов - латиницей. Ники = ники из таблицы (twitch-логины).
REM ============================================================

set "TOKEN=ВСТАВЬ_СЮДА_ТОКЕН"
REM set "DRYRUN=1"

REM =================== СПИСОК ЛОТОВ ===========================
call :add "Half-Life 2"    "2BeFirefly"    800
call :add "INSIDE"         "maxxsxsx"      200
call :add "Mass Effect 2"  "ffirinor"      600
call :add "Mass Effect 2"  "vova_ova1"     200
call :add "Diablo 3"       "oridontworry"  300
call :add "Outlast"        "oridontworry"  150
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
> "%TEMP%\pa_bid.json" echo {"bids":[{"cost":%PTS%,"message":"%LOT%","investorId":"%INV%","username":"%INV%","insertStrategy":"force","isDonation":false}]}
if defined DRYRUN (
  echo [dry] %LOT% / %INV% / %PTS%
  type "%TEMP%\pa_bid.json"
  echo.
  goto :eof
)
if "%TOKEN%"=="ВСТАВЬ_СЮДА_ТОКЕН" (
  echo [!] Сначала впиши свой токен в строку TOKEN вверху файла.
  goto :eof
)
curl -s -o nul -w "  [%%{http_code}] %LOT% / %INV% : %PTS%\n" -X POST -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" --data-binary "@%TEMP%\pa_bid.json" "https://pointauc.com/api/oshino/bids"
goto :eof
