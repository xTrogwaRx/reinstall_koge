@echo off
Color 1B
echo.  
echo                         ~              O                               
echo       .           `           .                 .     ~    .        .  
echo               .       .                O                          .    
echo        ~                    .              .                           
echo           .                            o             .        .        
echo     .              .                                                 . 
echo            �                           �                               
echo     ���������    ��    ��     �������� �       888    i888 88888888888 
echo    ���    ���   ���    ���   ���    ���        888   i8888     888     
echo    ���    ���   ���    ���   ���    ���   ~    888  i88888     888     
echo    ���    ���  ������������� ���    ��� .      888 i88Y888     888     
echo    ���    ��� �������������  ���    ���        888d88Y 888     888     
echo    ���    ���   ���    ���   ���    ���        88888Y  888     888     
echo    ���    ���   ���    ���   ���    ���   .    8888Y   888     888  ~  
echo   ������������  ���    ��     ��������         888Y    888     888     
echo   ��        ��                                                         
echo. 


:elevate_privileges
	echo ����襭�� �ਢ������...
	ver |>NUL find /v "5." && if "%~1"=="" (
	  Echo CreateObject^("Shell.Application"^).ShellExecute WScript.Arguments^(0^),"1","","runas",1 >"%~dp0elevating.vbs"
	  cscript.exe //nologo "%~dp0elevating.vbs" "%~f0"& goto :eof
	)

:get_GUID
	echo ����祭�� GUID...
	powershell -Command "Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like '��� � �������୮� �ଥ*'}" > temp
	for /F "tokens=1,3 delims= " %%i in (temp) do set %%i=%%j

:check_privileges
	echo �஢�ઠ �ਢ������...
	openfiles > NUL 2>&1
	if NOT %ERRORLEVEL% EQU 0 (
		goto not_admin
	) else (
		goto go_next
	)

:not_admin
	Color 60
	echo ��� �ਯ� ������ ���� ����饭 �� ����� �����������!
	pause
	goto end

:go_next
	reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
	if %OS%==64BIT (
		set uninstall_key=SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
	) else (
		set uninstall_key=SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\
	)

	set /A i=0
:enum_versions
    if defined IdentifyingNumber  (
		for /F "Tokens=7* delims=\" %%I In ('Reg Query HKLM\SOFTWARE\Classes\Installer\Dependencies\%IdentifyingNumber%\Dependents /s') Do Set "UnistalNumber=%%J"
	
		set key=%uninstall_key%%UnistalNumber%

		for /F "Tokens=2*" %%I In ('Reg Query "HKLM\%key%" /V "DisplayVersion" 2^>nul') Do Set "InstalledVersion=%%J"
		for /F "Tokens=2*" %%I In ('Reg Query "HKLM\%key%" /V "BundleCachePath" 2^>nul') Do Set "UninstallString=%%J"
		for /F "Tokens=2*" %%I In ('Reg Query "HKLM\%key%" /V "DisplayName" 2^>nul') Do Set "DisplayName=%%J"
		
		if defined UninstallString goto uninstall_job
		set /A i=%i%+1
		goto enum_versions
    ) else (
		goto clear_data
	)	
	
:uninstall_job
	echo ������� %DisplayName% v.%InstalledVersion%. ������...
	start /wait "" "%UninstallString%" /uninstall /quiet
	
:clear_data
	if exist %APPDATA%\Koge	(
		echo ������ APPDATA\Koge
		@RD /S /Q "%APPDATA%\Koge"
	) else (
		echo ����� APPDATA\Koge �� �������
	)

:install_new
	if exist "%~dp0SetupKoge.exe" (
		echo ������ ��⠭��騪 SetupKoge.exe. ��⠭�������...
		start /wait "" "%~dp0SetupKoge.exe" /S
		Color 27
		
		goto start_promt
	) else (
		echo ��⠭��騪 SetupKoge.exe �� ������. �� ����室����� ������� ��⠭��騪 ������.
		pause
		goto end
	)


:start_promt
	setlocal
	set res=null
	:promt
	SET /P AREYOUSURE=�������� "��� � �������୮� �ଥ" ��᫥ �����襭�� �ਯ�? (Y/N)?

	if /I "%AREYOUSURE%" == "N" set res=false
	if /I "%AREYOUSURE%" == "�" set res=false
	if /I "%AREYOUSURE%" == "Y" set res=true
	if /I "%AREYOUSURE%" == "�" set res=true

	if "%res%"=="false" ( 
		GOTO end_promt
	)
	if not "%res%"=="true"  (
		GOTO promt
	)

	start explorer.exe "C:\Users\Public\Desktop\��� � �������୮� �ଥ.lnk"

	:end_promt
	endlocal
	
	
:end
del "%~dp0elevating.vbs"
del "temp"