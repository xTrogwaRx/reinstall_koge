$env:SystemDirectory = [Environment]::SystemDirectory
$dir_koge = $env:APPDATA + '\Koge'

function GetGUID() {
	$apps = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "��� � ������������ �����*"}
	if ($apps -ne $null) {
		foreach ($app in $apps) {
			return $app.IdentifyingNumber
		}
	} else {
		return $null
	}
    return $null
}

function GetKOGEGUID($GUID) {
	$depend_key = "\SOFTWARE\Classes\Installer\Dependencies\" + $GUID + "\Dependents"		
	$dependes = Get-childitem -path HKLM:$depend_key | select PSchildname
	foreach ($depend in $dependes) {
		return $depend.PSchildname
	}
    return $null
}

function UninstallKOGE($GUID) {
    $key = "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$GUID"
	if (Test-Path -Path registry::"HKLM\$key") {
		$uninstall = Get-ItemProperty -Path HKLM:$key
		if ($uninstall -ne $null) {
			$exe_path = $uninstall.'BundleCachePath'
			$version = $uninstall.'DisplayVersion'
			$displayname = $uninstall.'DisplayName'
			Write-Output "������� $displayname $version. ������..."
			Start-Process "$exe_path" -ArgumentList "/uninstall /quiet /norestart" -Wait
			Write-Output "�������� ���������"
		}
	}    
}

Write-Output "����� ������������� ������� KOGE"

$GUID = GetGUID

if ($GUID -ne $null) {

    $KogeGUID = GetKOGEGUID($GUID)

    if ($KogeGUID -ne $null) {
		# Write-Output $KogeGUID 
        UninstallKOGE($KogeGUID)
    } else {
        Write-Output "��������� ����������� �����������"
    }
} else {
    Write-Output "��������� �� �����������"
}

Write-Output "������� %APPDATA%\Koge"

if (Test-Path -Path $dir_koge){
	Remove-Item -Recurse -Force $dir_koge
	Write-Output "������� ���������"
} else {
	Write-Output "����� �����������"
}

if (Test-Path -Path $PSScriptRoot\SetupKoge.exe){
	Write-Output "������ ���������� SetupKoge.exe. ������������..."
	Start-Process $PSScriptRoot\SetupKoge.exe -ArgumentList "/S" -Wait
	Write-Output "��������� ���������!"
} else {
	Write-Output "����������� ���� ���������!"
}

Write-Host "������ ������� ���������. ��� ������ ������� ����� �������..."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | out-null