@echo off

setlocal ENABLEDELAYEDEXPANSION

set PATH=%PATH%;C:\WINDOWS;C:\WINDOWS\SYSTEM32
for /D %%f in ( "C:\PYTHON*" ) do set PATH=!PATH!;%%f
for /D %%f in ( "%USERPROFILE%\AppData\Local\Programs\Python\Python*" ) do set PATH=!PATH!;%%f;%%f\Scripts
set PATH=%PATH%;%ProgramFiles%\7-Zip


set version=0.1


set project=piccol
set distdir=%project%-win64-standalone-%version%
set sfxfile=%project%-win64-%version%.package.exe
set bindirname=%project%-bin
set bindir=%distdir%\%bindirname%
set licensedirname=licenses
set licensedir=%distdir%\%licensedirname%


echo Building standalone Windows executable for %project% v%version%...
echo.

echo Please select GUI framework:
echo   1)  Build with PyQt5 (default)
echo   2)  Build with PySide4
set /p framework=Selection: 
if "%framework%" == "" goto framework_pyqt5
if "%framework%" == "1" goto framework_pyqt5
if "%framework%" == "2" goto framework_pyside4
echo "Error: Invalid selection"
goto error

:framework_pyqt5
echo Using PyQt5
set excludes=PySide
goto select_freezer

:framework_pyside4
echo Using PySide4
set excludes=PyQt5
goto select_freezer


:select_freezer
echo.
echo Please select freezer:
echo   1)  Build 'cx_Freeze' based distribution (default)
echo   2)  Build 'py2exe' based distribution
set /p buildtype=Selection: 
if "%buildtype%" == "" goto build_cxfreeze
if "%buildtype%" == "1" goto build_cxfreeze
if "%buildtype%" == "2" goto build_py2exe
echo "Error: Invalid selection"
goto error


:build_cxfreeze
set buildtype=1
echo === Creating the cx_Freeze distribution
call :prepare_env
py setup.py build_exe ^
	--build-exe=%bindir% ^
	--excludes=%excludes% ^
	--silent
if ERRORLEVEL 1 goto error_exe
goto copy_files


:build_py2exe
set buildtype=2
echo === Creating the py2exe distribution
call :prepare_env
py setup.py py2exe ^
	--dist-dir=%bindir% ^
	--bundle-files=3 ^
	--ignores=win32api,win32con,readline ^
	--excludes=%excludes% ^
	--quiet
if ERRORLEVEL 1 goto error_exe
goto copy_files


:copy_files
echo === Copying additional files
mkdir %licensedir%
if ERRORLEVEL 1 goto error_copy
copy README.* %distdir%\
if ERRORLEVEL 1 goto error_copy
copy foreign-licenses\*.txt %licensedir%\
if ERRORLEVEL 1 goto error_copy
copy COPYING %licensedir%\%project%-LICENSE.txt
if ERRORLEVEL 1 goto error_copy


echo === Generating startup wrapper
set wrapper=%distdir%\%project%.cmd
echo @set PATH=%bindirname%;%%PATH%%> %wrapper%
echo @start %project%-bin\%project%.exe %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9>> %wrapper%
if ERRORLEVEL 1 goto error_wrapper


echo === Creating the distribution archive
7z a -mx=9 -sfx7z.sfx %sfxfile% %distdir%
if ERRORLEVEL 1 goto error_7z


echo ---
echo finished
pause
exit /B 0


:prepare_env
echo === Preparing distribution environment
rd /S /Q build 2>NUL
rd /S /Q %distdir% 2>NUL
del %sfxfile% 2>NUL
timeout /T 2 /NOBREAK >NUL
mkdir %distdir%
if ERRORLEVEL 1 goto error_prep
mkdir %bindir%
if ERRORLEVEL 1 goto error_prep
exit /B 0


:error_prep
echo FAILED to prepare environment
goto error

:error_exe
echo FAILED to build exe
goto error

:error_copy
echo FAILED to copy files
goto error

:error_wrapper
echo FAILED to create wrapper
goto error

:error_7z
echo FAILED to create archive
goto error

:error
pause
exit 1