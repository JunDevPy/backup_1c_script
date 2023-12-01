@echo off
chcp 866
SET date_tmp=%DATE:~0,2%_%DATE:~3,2%_%DATE:~6,4%
SET time_tmp=%TIME:~0,2%_%TIME:~3,2%
SET configuration_file=%CD%\config.ini
cls
call :read_settings %CD%\config.ini || exit /b 1
exit /b 0
:read_settings
set SETTINGSFILE=%1
if not exist %SETTINGSFILE% (
    echo FAIL: "Файл настроек не существует проверьте наличие данного файла"
    echo FAIL: "По пути --->>>  %configuration_file% <<<---"
    timeout -t 5 /nobreak
    exit /b 1
)
for /f "eol=# delims== tokens=1,2" %%i in (%SETTINGSFILE%) do (
    set %%i=%%j
    rem echo %%j
    rem  timeout -t 1 /nobreak
)
set folder_base=%folder%
set user_1c=%user_1c%
set pwd_1c=%password_admin_1c%
set base_name=%base_name%
set folder_backup=%folder_with_backups%
SET path_1c=%full_path_to_1c%
timeout -t 5 /nobreak
net stop Apache2.4
timeout -t 5 /nobreak
taskkill /F /IM 1cv8c.exe
timeout -t 5 /nobreak
echo DONE: "Выгоняем терминальных пользователей"
CHANGE LOGON /DISABLE
timeout -t 5 /nobreak
echo DONE: "Начинаем выполнять бэкап файловой базы 1с %base_name%"
start "%path_1c%" CONFIG /F "%folder_base%" /N %user_1c% /P %pwd_1c% /DumpIB %folder_backup%\%date_tmp%_%time_tmp%_%base_name%.dt
REM echo "%path_1c%" CONFIG /F "%folder_base%" /N %user_1c% /P %pwd_1c% /DumpIB %folder_backup%\%date_tmp%_%time_tmp%_%base_name%.dt
timeout -t 5 /nobreak
:wait
TASKLIST | find "1cv8c.exe" >nul
if %errorlevel%==0 goto wait
timeout /t 5 /nobreak
echo DONE: "Разрешаем терминальным пользователям вход"
CHANGE LOGON /ENABLE
net stop Apache2.4
timeout /t 5 /nobreak
echo DONE: "Открываем папку с бэкапами и проверяем создался ли файл бэкапа"
explorer.exe %folder_backup% & exit /b 0
