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

:: �� ���᪥ ��� �������� ����� Koge, 㤠��� �� � ���� APPDATA\Koge
:: �᫨ � ����� � �ਯ⮬ ���� ��⠭��騪 SetupKoge.exe, ��⠭��������.
:: ����᪠�� �� �����������

:: ����� 2.2.5
set version[0]={e2e9db0b-0bac-4498-ac96-dab9e7bbb43d}
:: ����� 2.2.6
set version[1]={7f0aa41d-fe4f-417e-9cec-e94e8588a189}
:: ����� 2.2.7
set version[2]={58f6cca6-9d74-4aba-857d-2e61d2d06444}
:: ����� 2.2.8
set version[3]={eaad089e-b385-4a7c-8143-dd31f3aca23d}
:: ����� 3.2.1
set version[4]={164c8200-dcf9-4be1-ad0f-b4e1f1bd88d5}
:: ����� 2.4.1
set version[5]={b516ae86-bc4d-41f1-9212-3bdd23c6b1ca}
:: ����� 2.5.2
set version[6]={edcfee75-5b6c-4e26-b4c1-8d830b8adcfa}
:: ����� 2.6.1
set version[7]={15788722-d009-4062-bd41-0b482ab6ddfa}
:: ����� 2.7.1
set version[8]={6d727c04-2734-4234-aeed-62d4c6c420e6}
:: �����誠
set version[9]=dummy

ver |>NUL find /v "5." && if "%~1"=="" (
  Echo CreateObject^("Shell.Application"^).ShellExecute WScript.Arguments^(0^),"1","","runas",1 >"%~dp0Elevating.vbs"
  cscript.exe //nologo "%~dp0Elevating.vbs" "%~f0"& goto :eof
)

openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 (
	goto not_admin
) else (
	goto go_next
)

:not_admin
	Color 60
	echo ��� �ਯ� ������ ���� ����饭 �� ����� �����������!
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
    if defined version[%i%]  (
		set key=%uninstall_key%%%version[%i%]%%
		for /F "Tokens=2*" %%I In ('Reg Query "HKLM\%key%" /V "DisplayVersion" 2^>nul') Do Set "InstalledVersion=%%J"
		for /F "Tokens=2*" %%I In ('Reg Query "HKLM\%key%" /V "BundleCachePath" 2^>nul') Do Set "UninstallString=%%J"
		for /F "Tokens=2*" %%I In ('Reg Query "HKLM\%key%" /V "DisplayName" 2^>nul') Do Set "DisplayName=%%J"		
		if defined UninstallString goto :uninstall_job
		set /A i=%i%+1
		goto :enum_versions
    ) else (
		goto :clear_data
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
		del "%~dp0Elevating.vbs"
	) else (
		Color 60
		del "%~dp0Elevating.vbs"
	)
	
:end
pause
	