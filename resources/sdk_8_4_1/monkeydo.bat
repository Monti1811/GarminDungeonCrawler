@echo off

REM allow runtime variable assignment to non-existing environment variables (i.e. constants)
setlocal enabledelayedexpansion

REM Check to make sure the required arguments are provided
IF "%~1"=="/?" GOTO usage   REM Handle Windows standard help command
IF "%~2"=="" GOTO usage     REM Handle not enough arguments. We require the executable and device ID to be passed.

IF "%~3" NEQ "" (
    REM Make sure additional files flag, run native pairing flow flag or test flag is correct
    IF "%~3"=="/n" (
       GOTO parse_args
    )
    IF "%~3"=="/a" (
       GOTO parse_args
    )
    IF "%~3"=="/t" (
        GOTO parse_args
    ) ELSE (
        GOTO usage
    )
)

:parse_args
REM Parse the command line arguments
SET prg_path=%1
SHIFT /1
SET device_id=%1
SHIFT /1
REM Check to see if runNativePairing flag is provided
SET runNativePairing_flag=%1
REM Check to see if additional files are provided to be sent over to the simulator
SET additional_file_flag=%1
REM Check to see if test flag is provided
SET test_flag=%1
SHIFT /1
SET additional_files=
SET test_names=
IF "%runNativePairing_flag%" == "/n" (
    SET runNativePairing_flag=-n
    SET additional_file_flag=
    SET test_flag=

    GOTO :excution
) ELSE (
   SET runNativePairing_flag=
)

IF "%additional_file_flag%" == "/a" (
    SET additional_file_flag=-a

   :get_additional_files
   IF "%~1" NEQ "/t" IF "%~1" NEQ "" (
      SET additional_files=%additional_files% %~1;%~2
      SHIFT /1
      SHIFT /1
      GOTO :get_additional_files
    )
    GOTO :check_test_flag
) ELSE (
   SET additional_file_flag=
)

:check_test_flag
IF "%test_flag%" == "/a" (
    SET test_flag=%1
    SHIFT /1
)


IF "%test_flag%" == "/t" (
    SET test_flag=-t
)

:get_test_names
IF "%~1" NEQ "" (
    SET test_names=%test_names% "%~1"
    SHIFT /1
    GOTO :get_test_names
)

:excution
REM Get the constant arguments from the command line
SET home=%~dp0

REM Execute the call to shell
java -classpath "%home%monkeybrains.jar" com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux -f %prg_path% -d %device_id% -s "%home%shell.exe" %runNativePairing_flag% %additional_file_flag% %additional_files% %test_flag% %test_names%
GOTO :eof  rem Skip past the usage block

rem Print the help/usage information for this script
:usage
@echo Pushes and runs a Connect IQ executable on the Connect IQ simulator. The simulator must be running for this command to succeed.
@echo.
@echo Usage: %0 executable device_id ^[/n] ^[/a additional_file^] ^[/t ^| /t test_name^]
@echo     executable - A Connect IQ executable to run.
@echo     device_id  - The device to simulate.
@echo     n          - When provided, the app will be run in Native Pairing mode
@echo     additional_file - ehen providing the additionalFile flag you must specify one or more additional files to send to the simulator in the form of "<source>;<dest>".
@echo     test_name  - When providing the test flag you may specify a one or more test names.
endlocal
exit /B 1
