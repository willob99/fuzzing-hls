@echo off
setlocal enabledelayedexpansion

@REM set test-dir="C:\Users\willo\Documents\CS239 Project\fuzzing-hls\src\intel"
set test-dir=%~dp0
set test-dir="%test-dir:~0,-1%"
echo test-dir: %test-dir%

@REM cd C:\intelFPGA_pro\21.4\hls\examples\csmith_test
@REM cd %test-dir%
::RM resultFile.txt
touch resultFile.txt
ECHO Welcome to HLS Fuzz testing - Intel HLS!

set /p num=Please enter number of tests you would like to run: 
ECHO %num%
SET /A i =1
:loop

IF %i%==(%num%+1) GOTO END
	ECHO Starting test %i%
	RM test.cpp
	@REM CP %test-dir%\tests\%i%\test.c %test-dir%\test.cpp
	CP %test-dir%\tests\rand_prog2.c %test-dir%\test.cpp
	RM test.txt
	RM test_Mod.txt
	TOUCH test_Mod.txt
	RM test-x86-64.exe
	RM test-fpga.exe
	RM -rf test-fpga.prj *obj* *obj *prj_name*
   	CP test.cpp test.txt
	ECHO Compiling modifyMain.c
	GCC modifyMain.c -o modifyMain
	ECHO Calling modifyMain on Csmith-generated program
	@REM note that modifyMain expects csmith to be installed at C:\csmith
	@REM modifyMain 0 calls the modify() function
   	modifyMain 0 > test_Mod.cpp
	CP test_Mod.cpp test.txt
	@REM modifyMain 1 calls add_component()
	modifyMain 1 > test_Mod.cpp
	CP test_Mod.cpp test.txt
	ECHO Test %i% >> %test-dir%\resultFile.txt
	ECHO Calling build.bat
	./build.bat test-x86-64
	IF %errorlevel%==124 GOTO :INCRE
   	ECHO .
	ECHO Synthesis result: >> %test-dir%\resultFile.txt
	./test-x86-64.exe >> %test-dir%\resultFile.txt
	IF %errorlevel%==124 GOTO :INCRE
   	ECHO .
	GCC addDirective_c.c -o addDirective
	addDirective
	CP test_Mod.txt test_Mod.cpp
	./build.bat test-fpga
	IF %errorlevel%==124 GOTO :INCRE
	ECHO Cosimulation result: >> %test-dir%\resultFile.txt
	./test-fpga.exe >> %test-dir%\resultFile.txt
	IF %errorlevel%==124 GOTO :INCRE
	Taskkill /im i++.exe /f /T
	Taskkill /im test-fpga.exe /f /T
   	ECHO .  
  	ECHO Test %i% finished!
	SET /a i=%i%+1
GOTO :LOOP

:incre
SET /a i=%i%+1
GOTO :LOOP

:END
ECHO Finished!
GCC checkResult.c -o checkResult
checkResult > resultCheck.txt
@REM exit
