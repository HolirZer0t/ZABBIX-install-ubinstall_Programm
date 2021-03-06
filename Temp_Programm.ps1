$f1 = "C:\zabbix\temp\programs-list-new.txt" 
$isf1 = Test-Path $f1 
if($isf1 -ne "True") {New-Item -Path $f1 -ItemType File | Out-Null}
$f2 = "C:\zabbix\temp\programs-list-old.txt"
$isf2 = Test-Path $f2 
if($isf2 -ne "True") {New-Item -Path $f2 -ItemType File | Out-Null}
$f3 = "C:\zabbix\temp\programs-list.txt"
$isf3 = Test-Path $f3 
if($isf3 -ne "True") {New-Item -Path $f3 -ItemType File | Out-Null}

    #Проверка разрядности OS
$OS = Get-WmiObject -Class Win32_OperatingSystem
$0 = $OS.OSArchitecture
$1 = "64-bit"

    #Получение списка
if ($0 -eq $1) {Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName | Format-Table -AutoSize > $f1}
else {Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName | Format-Table -AutoSize > $f1}

#______________________Фильтрация от определенных программ С:\programs-list-new.txt______________________
(get-content $f1) -notmatch "Microsoft Visual C" | out-file $f1
(get-content $f1) -notmatch "Update for Microsoft" | out-file $f1
(get-content $f1) -notmatch "Service Pack 1 for Microsoft" | out-file $f1
(get-content $f1) -notmatch "FusionInventory" | out-file $f1
(get-content $f1) -notmatch "                                                                             " | out-file $f1
#______________________(------------------------------------------------------)______________________

    #Сравнение С:\programs-list-new.txt c С:\programs-list-old.txt и запись результата в С:\programs-list.txt 
    #Если разницы нет то записать в файл С:\programs-list.txt 0x0
$strReference = Get-Content $f2 
$strDifference = Get-Content $f1
Compare-Object -referenceObject $strReference -differenceObject $strDifference | Out-File $f3 -Force

    #Замена на понятные значения
$str = Get-Content $f3
$str -replace "=>","/INSTALL" -replace "<=","/UNINSTALL" -replace "   "," " | Set-Content $f3
(get-content $f3) -notmatch "InputObject" | out-file $f3
(get-content $f3) -notmatch "-----------" | out-file $f3
(get-content $f3) -notmatch "Update for" | out-file $f3
    #Переименование старого файла С:\programs-list-new.txt в С:\programs-list-old.txt
Move-Item $f1 $f2 -force