@if "%DEBUG%"=="" @echo off
@rem We use delayed expansion to dynamically set values
setlocal enableDelayedExpansion

@rem Get the location of this script without a trailing slash
for %%Q in ("%~dp0\.") do set "SOURCE=%%~fQ"

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVACMD=java.exe
%JAVACMD% -version >NUL 2>&1
if %ERRORLEVEL% equ 0 goto checkUpgrade

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

exit /b 1

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVACMD=%JAVA_HOME%\bin\java.exe

if exist "%JAVACMD%" goto checkUpgrade

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

exit /b 1

:checkUpgrade

set PENDING_UPGRADE=%SOURCE%\pending-upgrade

if exist "!PENDING_UPGRADE!" goto upgrade

:execute

if not defined TOOLKIT_PROJECT_HOME set TOOLKIT_PROJECT_HOME=.
if defined TOOLKIT_JAVA_OPTIONS set JAVA_TOOL_OPTIONS=%TOOLKIT_JAVA_OPTIONS%

@rem Use the log config in the project directory, otherwise default to the one in the jar
set LOG_CONFIG="!TOOLKIT_PROJECT_HOME!\log4j2.yaml"
if exist %LOG_CONFIG% set LOG_FLAG=-Dlog4j2.configurationFile=%LOG_CONFIG%

set RESOURCES_DIR=%TOOLKIT_PROJECT_HOME%\resources
set LIB_DIR=%TOOLKIT_PROJECT_HOME%\lib\*
set GLOBAL_LIB_DIR=%USERPROFILE%\.toolkit\lib\*
set CLASSPATH="%RESOURCES_DIR%";"%SOURCE%\*";"%LIB_DIR%";"%GLOBAL_LIB_DIR%"

"%JAVACMD%" ^
  -cp %CLASSPATH% ^
  --add-opens "java.base/java.nio=ALL-UNNAMED" ^
  !LOG_FLAG! ^
  -Dtoolkit.home="%SOURCE%" ^
  io.phdata.tool.cli.ToolkitCli %*

goto end

:upgrade

@rem If the pending directory is empty just remove it
dir /b /s /a "!PENDING_UPGRADE!" | findstr .>NUL || (
    goto remove-pending
)
echo Completing pending upgrade... 1>&2
del /q "%SOURCE%\*.jar"
move "!PENDING_UPGRADE!\*" "%SOURCE%" >NUL
:remove-pending
rmdir "!PENDING_UPGRADE!" /s /q >NUL
goto execute

:end
