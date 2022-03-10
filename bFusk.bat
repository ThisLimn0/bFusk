@ECHO OFF & SETLOCAL EnableDelayedExpansion


:::::::::::::::::::::::::::::::::::::
SET "CL_AutoDiscovery=enabled"   ::: AutoDiscovery is enabled by default.
:::::::::::::::::::::::::::::::::::::

WGET --spider -q http://www.google.com/ >NUL 2>NUL
IF NOT "%ErrorLevel%"=="0" (
	::: # WGETNotPresentException
	ECHO. [/^^!\] WGET does not seem to be either installed or in the same folder as script.
	ECHO.       If both of the above is untrue, you might want to check your internet connection.
	ECHO.       Press [Any Key] to exit.
	PAUSE >NUL
	EXIT 
)
ECHO.Please provide an URL to fusker. Example: http://abc.def.gh/img/[1-400].jpg
SET /P "FuskURL=> "
SET "LinkCount=0"
FOR /F "usebackq tokens=1-3 delims=[+]" %%A in ('!FuskURL!') DO (
	SET "FuskerURLSplitA=%%A"
	SET "FuskerRange=%%B"
	SET "FuskerURLSplitB=%%C"
	IF DEFINED FuskerRange (
		FOR /F "usebackq tokens=1,2 delims=-" %%A in ('!FuskerRange!') DO (
			SET "FuskerMIN=%%A"
			SET "FuskerMAX=%%B"
			FOR /L %%A IN (!FuskerMIN!,1,!FuskerMAX!) DO (
				SET /A LinkCount+=1
			)
		)
	) ELSE (
		::: # NoFuskerRangeException
		ECHO. [/^^!\] Your input ^(!FuskURL!^) is errorneous.
		ECHO.       The range to fusker could not be determined.
		ECHO.       Press [Any Key] to exit.
		PAUSE >NUL
		EXIT 
	)
)
ECHO.[DBG] U:!FuskURL!;RNGE:!FuskerRange!;MIN:!FuskerMIN!;MAX:!FuskerMAX!
ECHO.[AutoDiscovery=%CL_AutoDiscovery%]
ECHO.
SET "CountA=0"
SET "Errors="
ECHO.Scanning... follow the progress in the WindowTitle.
FOR /L %%A in (%FuskerMIN%,1,%FuskerMAX%) DO (
	SET /A CountA+=1
	TITLE bFusk - Scanning... [%%A/!FuskerMAX!] !Errors! !ErrorCount!
	SET "TempBuiltURL=!FuskerURLSplitA!%%A!FuskerURLSplitB!"
	WGET --spider -q -U "Mozilla/4.0" !TempBuiltURL!
	IF NOT "!ErrorLevel!"=="0" (
		SET /A Errors+=1
		ECHO.Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!] 
		IF DEFINED Errors (
			SET "ErrorCount=Error"
			IF "!Errors!" GTR "0" (
				SET "ErrorCount=Error"
				SET "P=was"
			) ELSE IF "!Errors!" GTR "1" (
				SET "ErrorCount=Errors"
				SET "P=were"
			)
		) ELSE (
			SET "ErrorCount="
		)
	)
)
IF NOT DEFINED ErrorCount (
	SET "AdditionalMessage= %CountA%/%LinkCount% links are available."
) ELSE (
	SET "AdditionalMessage= There %P% %Errors% %ErrorCount% while scanning."
)
ECHO.--^> [SC] Scanning finished.!AdditionalMessage!
ECHO.
IF /I NOT "%CL_AutoDiscovery%"=="enabled" GOTO :EscapeLoop
ECHO.AutoDiscovery... this might take a while.
SET "CountA=0"
SET "Errors="
SET "FuskerMAXNew=%FuskerMAX%"
FOR /L %%A in (%FuskerMAX%,1,99999) DO (
	TITLE bFusk - AutoDiscovery: New Range... [!FuskerMIN!-!FuskerMAXNew!] !Errors! !ErrorCount!
	SET "TempBuiltURL=!FuskerURLSplitA!%%A!FuskerURLSplitB!"
	WGET --spider -q -U "Mozilla/4.0" !TempBuiltURL!
	IF NOT "!ErrorLevel!"=="0" (
		IF NOT !FuskerMIN! LEQ 1 (
			SET "CountA=0"
			SET "Errors="
			SET "FuskerMINNew=%FuskerMIN%"
			ECHO.[DBG] Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!]
			ECHO.Please wait...
			CALL :ReverseDiscovery
			GOTO :EscapeLoop
		) ELSE (
			SET /A Errors+=1
			ECHO.Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!]
			ECHO.--^>[AD] AutoDiscovery finished. !CountC! additional images discovered.
			TITLE bFusk - AutoDiscovery: New Range... [!FuskerMIN!-!FuskerMAXNew!] !Errors! !ErrorCount!
			ECHO.
			GOTO :EscapeLoop
		)
	)
	IF DEFINED Errors (
		SET "ErrorCount=Error"
		IF "!Errors!" GTR "0" (
			SET "ErrorCount=Error"
			SET "P=was"
		) ELSE IF "!Errors!" GTR "1" (
			SET "ErrorCount=Errors"
			SET "P=were"
		)
	) ELSE (
		SET "ErrorCount="
	)
	SET /A FuskerMAXNew+=1
)
:EscapeLoop
ECHO.-----
SET /P "DownloadPath=Please put the Path to download to below: "
IF NOT DEFINED DownloadPath (
	::: # NoDownloadPathException
	ECHO. [/^^!\] Your input ^(!FuskURL!^) is errorneous.
	ECHO.       The output directory is not specified.
	ECHO.       Press [Any Key] to exit.
	PAUSE >NUL
	EXIT
) 
IF "!DownloadPath!"=="!FuskURL!" (
	::: # EditedAtRuntimeException
	ECHO. [/^^!\] Your input ^(!FuskURL!^) is errorneous.
	ECHO.       Press [Any Key] to exit.
	PAUSE >NUL
	EXIT
)
SET "CountA=0"
SET "Errors="
FOR /L %%A in (%FuskerMINNew%,1,%FuskerMAXNew%) DO (
	SET /A CountA+=1
	TITLE bFusk - Download... [%%A/!FuskerMAXNew!] !Errors! !ErrorCount!
	SET "TempBuiltURL=!FuskerURLSplitA!%%A!FuskerURLSplitB!"
	WGET -q --show-progress -U "Mozilla/4.0" --directory-prefix="!DownloadPath!" !TempBuiltURL! 
	IF NOT "!ErrorLevel!"=="0" (
		ECHO.Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!]
	)
)
ECHO.-----
ECHO.
ECHO.The download process is finished. Press [Any Key] to exit.
PAUSE >NUL
EXIT

:ReverseDiscovery
SET "Errors="
FOR /L %%A in (%FuskerMIN%,-1,0) DO (
	TITLE bFusk - AutoDiscovery: New range...[%%A-!FuskerMAXNew!] !Errors! !ErrorCount!
	SET "TempBuiltURL=!FuskerURLSplitA!%%A!FuskerURLSplitB!"
	SET "FuskerMINNew=%%A"
	WGET --spider -q -U "Mozilla/4.0" !TempBuiltURL!
	IF NOT "!ErrorLevel!"=="0" (
		SET /A "FuskerMAXNew=!FuskerMAXNew!-1"
		SET /A "FuskerMINNew=!FuskerMINNew!+1"
		FOR /L %%A IN (!FuskerMINNew!,1,!FuskerMAXNew!) DO (
			SET /A CountC+=1
		)
		SET /A "CountC=!CountC!-!LinkCount!"
		ECHO.[DBG] U:!FuskerURLSplitA![!FuskerMINNew!-!FuskerMAXNew!]!FuskerURLSplitB!;C:!CountC!;MIN:!FuskerMINNew!;MAX:!FuskerMAXNew!
		TITLE bFusk - AutoDiscovery: New Range... [!FuskerMINNew!-!FuskerMAXNew!]
		ECHO.[DBG] Error at !TempBuiltURL! [WGET/Err:!ErrorLevel!]
		ECHO.--^>[AD] AutoDiscovery finished. !CountC! additional images discovered.
		ECHO.Link with new range:
		ECHO.!FuskerURLSplitA![!FuskerMINNew!-!FuskerMAXNew!]!FuskerURLSplitB!|CLIP
		ECHO.	!FuskerURLSplitA![!FuskerMINNew!-!FuskerMAXNew!]!FuskerURLSplitB!
		ECHO.
		EXIT /B
	
	)
	IF DEFINED Errors (
		SET "ErrorCount=Error"
		IF "!Errors!" GTR "0" (
			SET "ErrorCount=Error"
			SET "P=was"
		) ELSE IF "!Errors!" GTR "1" (
			SET "ErrorCount=Errors"
			SET "P=were"
		)
	) ELSE (
		SET "ErrorCount="
	)
)
EXIT /B