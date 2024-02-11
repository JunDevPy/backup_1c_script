@echo off
chcp 866
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
)
SET date_tmp=%DATE:~0,2%_%DATE:~3,2%_%DATE:~6,4%
SET time_tmp=%TIME:~0,2%_%TIME:~3,2%
set folder_base=%folder%
set user_1c=%user_1c%
set pwd_1c=%password_admin_1c%
set base_name=%base_name%
set folder_backup=%folder_with_backups%
SET path_1c=%full_path_to_1c%
REM set cmd_line="%path_1c%" DESIGNER /F "%folder_base%" /N %user_1c% /P %pwd_1c% /DumpIB %tmp%\%date_tmp%_%time_tmp%_%base_name%.dt
timeout -t 3 /nobreak
net stop Apache2.4
timeout -t 3 /nobreak
taskkill /F /IM 1cv8c.exe
timeout -t 3 /nobreak
REM echo DONE: "Выгоняем терминальных пользователей"
REM CHANGE LOGON /DISABLE
echo "Чистим кеш базы 1с %base_name%"
@FOR /D %%j in ("%LOCALAPPDATA%\1C\1Cv8\c29b2768-5acd-47a5-8c40-88a022eef863") do rd /s /q "%%j"
@FOR /D %%j in ("%AppData%\1C\1Cv8\c29b2768-5acd-47a5-8c40-88a022eef863") do rd /s /q "%%j"
timeout -t 3 /nobreak
echo "Начинаем выполнять бэкап файловой базы 1с %base_name%"
SET name_file_backup=%date_tmp%_%time_tmp%_%base_name%
"%path_1c%" CONFIG /F "%folder_base%" /N %user_1c% /P %pwd_1c% /DumpIB %tmp%\%name_file_backup%.dt
REM start /wait "cmd_line"
timeout -t 120 /nobreak
REM echo DONE: "Разрешаем терминальным пользователям вход"
REM CHANGE LOGON /ENABLE
xcopy "%tmp%\%name_file_backup%.dt" "%folder_backup%" /R /Y
net start Apache2.4
timeout /t 3 /nobreak
echo DONE: "Открываем папку с бэкапами и проверяем создался ли файл бэкапа"
explorer.exe %folder_backup% & exit /b 0
