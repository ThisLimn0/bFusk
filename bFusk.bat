@ECHO OFF & SETLOCAL EnableDelayedExpansion

::: # Test to see if WGET is installed.
WGET --spider -q http://www.google.com/ >NUL 2>NUL
IF NOT "%ErrorLevel%"=="0" (
	ECHO. [/^^!\] WGET does not seem to be either installed or in the same folder as script.
	ECHO.       If both of the above is untrue, you might want to check your internet connection.
	ECHO.       Press [Any Key] to exit.
	PAUSE >NUL
	EXIT 
)
ECHO. Please provide an URL to fusker. Example: http://abc.def.gh/img/[1-400].jpg
SET /P "FuskURL=> "

FOR /F "usebackq tokens=1-3 delims=[+]" %%A in ('!FuskURL!') DO (
	SET "FuskerURLSplitA=%%A"
	SET "FuskerRange=%%B"
	SET "FuskerURLSplitB=%%C"
	IF DEFINED FuskerRange (
		FOR /F "usebackq tokens=1,2 delims=-" %%A in ('!FuskerRange!') DO (
			SET "FuskerMIN=%%A"
			SET "FuskerMAX=%%B"
		)
	) ELSE (
		ECHO. [/^^!\] Your input ^(!FuskURL!^) is errorneous.
		ECHO.       The range to fusker could not be determined.
		ECHO.       Press [Any Key] to exit.
		PAUSE >NUL
		EXIT 
	)
)
ECHO.
ECHO.DEBUG:U:!FuskURL!;RNGE:!FuskerRange!;MIN:!FuskerMIN!;MAX:!FuskerMAX!
ECHO.[AdvancedDiscovery=enabled]
ECHO.
SET "CountA=0"
SET "CountB="
ECHO.Scanning... follow the progress in the Window-Title.
FOR /L %%A in (%FuskerMIN%,1,%FuskerMAX%) DO (
	SET /A CountA+=1
	TITLE bFusk - Scanning... [%%A/!FuskerMAX!] !CountB! !ErrorCount!
	SET "TempBuiltURL=!FuskerURLSplitA!%%A!FuskerURLSplitB!"
	WGET --spider -q -U "Mozilla/4.0" !TempBuiltURL!
	IF NOT "!ErrorLevel!"=="0" (
		SET /A CountB+=1
		ECHO.Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!] 
		IF DEFINED CountB (
			SET "ErrorCount=Error"
			IF "!CountB!" GTR "1" (
				SET "ErrorCount=Errors"
			) ELSE (
				SET "ErrorCount="
			)
		)
	)
)
ECHO.	[$] Scanning finished.!AdditionalMessage!
ECHO.
ECHO.AdvancedDiscovery... this might take a while.
SET "CountA=0"
SET "CountB="
SET "FuskerMAXNew=%FuskerMAX%"
FOR /L %%A in (%FuskerMAX%,1,99999) DO (
	TITLE bFusk - AdvancedDiscovery... [1/!FuskerMAXNew!] !CountB! !ErrorCount!
	SET "TempBuiltURL=!FuskerURLSplitA!%%A!FuskerURLSplitB!"
	WGET --spider -q -U "Mozilla/4.0" !TempBuiltURL!
	IF NOT "!ErrorLevel!"=="0" (
		SET /A CountB+=1
		ECHO.Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!] This seems to be the last working image.
		ECHO.
		ECHO.	[$] Scanning finished.!AdditionalMessage!
		GOTO :EscapeLoop
		IF DEFINED CountB (
			SET "ErrorCount=Error"
			IF "!CountB!" GTR "1" (
				SET "ErrorCount=Errors"
			)
		) ELSE (
			SET "ErrorCount="
		)
	)
	SET /A FuskerMAXNew+=1
)
:EscapeLoop
SET /P "DownloadPath=Please put the Path to download to below: "
IF NOT DEFINED DownloadPath (
	ECHO. [/^^!\] Your input ^(!FuskURL!^) is errorneous.
	ECHO.       The output directory is not specified.
	ECHO.       Press [Any Key] to exit.
	PAUSE >NUL
	EXIT
)	
SET "CountA=0"
SET "CountB="
FOR /L %%A in (%FuskerMIN%,1,%FuskerMAXNew%) DO (
	SET /A CountA+=1
	TITLE bFusk - Download... [%%A/!FuskerMAXNew!] !CountB! !ErrorCount!
	SET "TempBuiltURL=!FuskerURLSplitA!%%A!FuskerURLSplitB!"
	WGET -q --show-progress -U "Mozilla/4.0" --directory-prefix="!DownloadPath!" !TempBuiltURL! 
	IF NOT "!ErrorLevel!"=="0" (
		SET /A CountB+=1
		ECHO.Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!]
		IF DEFINED CountB (
			SET "ErrorCount=Error"
			IF "!CountB!" GTR "1" (
				SET "ErrorCount=Errors"
			) ELSE (
				SET "ErrorCount="
			)
		)
	)
)
PAUSE >NUL