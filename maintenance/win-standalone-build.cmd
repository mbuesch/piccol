@echo off
setlocal ENABLEDELAYEDEXPANSION

set project=piccol

set PATH=%PATH%;C:\WINDOWS;C:\WINDOWS\SYSTEM32
for /D %%f in ( "%USERPROFILE%\AppData\Local\Programs\Python\Python*" ) do set PATH=!PATH!;%%f;%%f\Scripts
set PATH=%PATH%;%ProgramFiles%\7-Zip


cd ..
if ERRORLEVEL 1 goto error_basedir


call :detect_version
set distdir=%project%-win64-standalone-%version%
set sfxfile=%project%-win64-%version%.package.exe
set bindirname=%project%-bin
set bindir=%distdir%\%bindirname%
set licensedirname=licenses
set licensedir=%distdir%\%licensedirname%


echo Building standalone Windows executable for %project% v%version%...
echo.

call :prepare_env
call :build_cxfreeze
call :copy_files
call :gen_startup_wrapper
call :make_archive

echo ---
echo finished
pause
exit /B 0


:detect_version
	py -c "import re; print(re.match(r'.*^\s*PICCOL_VERSION\s*=\s*\"([\w\d\.\-_]+)\"\s*$.*', open('piccol').read(), re.DOTALL | re.MULTILINE).group(1))" > version.txt
	if ERRORLEVEL 1 goto error_version
	set /p version= < version.txt
	del version.txt
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


:build_cxfreeze
	echo === Creating the cx_Freeze distribution
	py setup.py build build_exe --build-exe=%bindir%
	if ERRORLEVEL 1 goto error_exe
	exit /B 0


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
	exit /B 0


:gen_startup_wrapper
	echo === Generating startup wrapper
	set wrapper=%distdir%\%project%.cmd
	echo @set PATH=%bindirname%;%bindirname%\lib;%%PATH%% > %wrapper%
	echo @start %bindirname%\%project%.exe %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9 >> %wrapper%
	if ERRORLEVEL 1 goto error_wrapper
	exit /B 0


:make_archive
	echo === Creating the distribution archive
	7z a -mx=9 -sfx7z.sfx %sfxfile% %distdir%
	if ERRORLEVEL 1 goto error_7z
	exit /B 0


:error_basedir
echo FAILED to CD to base directory
goto error

:error_version
echo FAILED to detect version
goto error

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
