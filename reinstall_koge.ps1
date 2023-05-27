$env:SystemDirectory = [Environment]::SystemDirectory
$dir_koge = $env:APPDATA + '\Koge'

function GetGUID() {
	$apps = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "ОГЭ в компьютерной форме*"}
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
			Write-Output "Найдена $displayname $version. Удаляю..."
			Start-Process "$exe_path" -ArgumentList "/uninstall /quiet /norestart" -Wait
			Write-Output "Удаление завершено"
		}
	}    
}

Write-Output "Поиск установленной Станции KOGE"

$GUID = GetGUID

if ($GUID -ne $null) {

    $KogeGUID = GetKOGEGUID($GUID)

    if ($KogeGUID -ne $null) {
		# Write-Output $KogeGUID 
        UninstallKOGE($KogeGUID)
    } else {
        Write-Output "Программа установлена неправильно"
    }
} else {
    Write-Output "Программа не установлена"
}

Write-Output "Очистка %APPDATA%\Koge"

if (Test-Path -Path $dir_koge){
	Remove-Item -Recurse -Force $dir_koge
	Write-Output "Очистка завершена"
} else {
	Write-Output "Папка отсутствует"
}

if (Test-Path -Path $PSScriptRoot\SetupKoge.exe){
	Write-Output "Найден установщик SetupKoge.exe. Устанавливаю..."
	Start-Process $PSScriptRoot\SetupKoge.exe -ArgumentList "/S" -Wait
	Write-Output "Установка завершена!"
} else {
	Write-Output "Отсутствует файл установки!"
}

Write-Host "Работа скрипта завершена. Для выхода нажмите любую клавишу..."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | out-null