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

call:readIni %file% APPID_INI sid appId
call:readIni %file% APPID_INI skey appKey
call:readIni %file% KEY_INI storePassword storePassword
call:readIni %file% KEY_INI keyPassword keyPassword
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


for /r lib\temp\ %%b in (*.bat) do (
	del %%b
)

set /a a = 1
for /r put\ %%i in (*.apk) do (

	set jksPath=0
	set jksName=0
	for /r jks\ %%j in (*.jks) do (
		echo %%~ni | findstr %%~nj > nul && (
			set jksPath=%%j
			set jksName=%%~nj
		)
	)
	if !jksPath! == 0 (
		@echo.
		echo --------------------------------------------
		echo [%%~ni.apk]  未找到匹配签名文件
		echo --------------------------------------------
		@echo.
	) else (
		@echo.
		echo --------------------------------------------
		echo [%%~ni.apk]  将使用  [!jksPath!]  进行签名  [lib\temp\temp!a!.bat]
		echo --------------------------------------------
		@echo.
		echo @echo off > lib\temp\temp!a!.bat
		echo echo ---------------------- 配置参考 ---------------------- >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo echo 当前加固的APK为:             %%~ni.apk >> lib\temp\temp!a!.bat
		echo echo 当前签名文件为:              !jksName!.jks >> lib\temp\temp!a!.bat
		echo echo 当前签名文件storePassword为: %storePassword% >> lib\temp\temp!a!.bat
		echo echo 当前签名文件keyPassword为:   %keyPassword% >> lib\temp\temp!a!.bat
		echo echo 当前签名类型为:              [v1 = %v1%], [v2 = %v2%], [v3 = %v3%], [v4 = %v4%] >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo echo ------------------------------------------------------ >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo echo ---------------------- 开始加固 ---------------------- >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo setlocal enabledelayedexpansion >> lib\temp\temp!a!.bat
		echo java -Dfile.encoding=utf-8 -jar lib\ms-shield.jar -sid %appId% -skey %appKey% -uploadPath %%i -downloadPath out\ >> lib\temp\temp!a!.bat
		echo lib\zipalign -p -v 4 out\%%~ni_legu.apk out\%%~ni_legu_zip.apk >> lib\temp\temp!a!.bat
		if %isDelSign% equ true (
			for %%p in (%strFtNoSign%) do (
				echo %%~ni | findstr %%p > nul || (
				    echo del out\%%~ni_legu.apk >> lib\temp\temp!a!.bat
				)
			)
		)
		echo java -Dfile.encoding=utf-8 -jar lib\apksigner.jar sign --ks !jksPath! --ks-pass pass:%storePassword% --key-pass pass:%keyPassword% --v1-signing-enabled %v1% --v2-signing-enabled %v2% --v3-signing-enabled %v3% --v4-signing-enabled %v4% --out out\%%~ni_legu_sign.apk --verbose out\%%~ni_legu_zip.apk >> lib\temp\temp!a!.bat
		if %isDelZipSign% equ true (
		    for %%r in (%strFtDelZipNoSign%) do (
				echo %%~ni | findstr %%r > nul || (
				    echo del out\%%~ni_legu_zip.apk >> lib\temp\temp!a!.bat
				)
			)
		)
		echo @echo. >> lib\temp\temp!a!.bat
		echo echo ------------------------------------------------------ >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo echo ---------------------- 执行完成 ---------------------- >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo echo 加固后的文件路径: ~out\%%~ni_legu_sign.apk >> lib\temp\temp!a!.bat
		echo @echo. >> lib\temp\temp!a!.bat
		echo echo ------------------------------------------------------ >> lib\temp\temp!a!.bat
		if %isClose% equ true (
			if %isDelayClose% equ true (
				echo timeout /t %delayClose% >> lib\temp\temp!a!.bat
			)
		)
		if %isClose% equ true (
			echo exit >> lib\temp\temp!a!.bat
		)
		start lib\temp\temp!a!.bat
		set /a a += 1
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
