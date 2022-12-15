@echo off
setlocal enabledelayedexpansion

set file=info.ini
set appId=
set appKey=
set keyPath=
set storePassword=
set keyPassword=
set v1=
set v2=
set v3=
set v4=
set isDelSign=true
set strFtNoSign=
set isDelZipSign=true
set strFtDelZipNoSign=
set isClose=true
set isDelayClose=true
set delayClose=20
call:readIni %file% APPID sid appId
call:readIni %file% APPID skey appKey
call:readIni %file% KEY storePassword storePassword
call:readIni %file% KEY keyPassword keyPassword
call:readIni %file% KEY_INI v1SigningEnabled v1
call:readIni %file% KEY_INI v2SigningEnabled v2
call:readIni %file% KEY_INI v3SigningEnabled v3
call:readIni %file% KEY_INI v4SigningEnabled v4
call:readIni %file% OTHER_INI isDelNoSignApk isDelSign
call:readIni %file% OTHER_INI strFtNoSign strFtNoSign
call:readIni %file% OTHER_INI isDelZipNoSignApk isDelZipSign
call:readIni %file% OTHER_INI strFtDelZipNoSign strFtDelZipNoSign
call:readIni %file% OTHER_INI isCloseCmd isClose
call:readIni %file% OTHER_INI isDelayCloseCmd isDelayClose
call:readIni %file% OTHER_INI delayCloseCmd delayClose

for /r put\ %%i in (*.apk) do (

	set jksPath=0
	for /r jks\ %%j in (*.jks) do (
		echo %%~ni | findstr %%~nj > nul && (
			set jksPath=%%j
		)
	)
	if !jksPath!==0 (
		@echo.
		echo --------------------------------------------
		echo [%%~ni.apk]  未找到匹配签名文件 
		echo --------------------------------------------
		@echo.
	) else (
		@echo.
		echo --------------------------------------------
		echo [%%~ni.apk]  将使用  [!jksPath!]  进行签名
		echo --------------------------------------------
		@echo.
		@echo.
		@echo.
		java -Dfile.encoding=utf-8 -jar lib\ms-shield.jar -sid %appId% -skey %appKey% -uploadPath %%i -downloadPath out\
		lib\zipalign -p -v 4 out\%%~ni_legu.apk out\%%~ni_legu_zip.apk
		if %isDelSign% equ true (
			for %%p in (%strFtNoSign%) do (
				echo %%~ni | findstr %%p > nul || (
				    del out\%%~ni_legu.apk
				)
			)
		)
		java -Dfile.encoding=utf-8 -jar lib\apksigner.jar sign --ks !jksPath! --ks-pass pass:%storePassword% --key-pass pass:%keyPassword% --v1-signing-enabled %v1% --v2-signing-enabled %v2% --v3-signing-enabled %v3% --v4-signing-enabled %v4% --out out\%%~ni_legu_sign.apk --verbose out\%%~ni_legu_zip.apk
		if %isDelZipSign% equ true (
			for %%r in (%strFtDelZipNoSign%) do (
				echo %%~ni | findstr %%r > nul || (
				    del out\%%~ni_legu_zip.apk
				)
			)
		)
	)
)
if %isClose% equ true (
	if %isDelayClose% equ true (
		timeout /t %delayClose%
	)
)
if %isClose% equ true (
	exit
)


:readIni
@setlocal enableextensions enabledelayedexpansion
@echo off
set file=%~1
set area=[%~2]
set key=%~3
set currarea=
for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    if "x!ln:~0,1!"=="x[" (
        set currarea=!ln!
    ) else (
        for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
            set currkey=%%b
            set currval=%%c
            if "x!area!"=="x!currarea!" (
                if "x!key!"=="x!currkey!" (
                    set var=!currval!
                )
            )
        )
    )
)
(endlocal
    set "%~4=%var%"
)
goto:eof
