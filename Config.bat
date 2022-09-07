@echo off
title Config WorkStation
call 
goto :eof

set D=https://github.com/ViniciusRed/Windows-Optimizer/releases/download/temp/autocleartemp.bat
set D2=https://www.7-zip.org/a/7z2201-x64.msi
set D3=https://www.opera.com/pt-br/computer/thanks?ni=eapgx&os=windows
set D4=https://www.iobit.com/downloadcenter.php?product=pt-driver-booster-free-new
set D5=https://github.com/git-for-windows/git/releases/download/v2.37.3.windows.1/Git-2.37.3-64-bit.exe
set D6=https://code.visualstudio.com/sha/download?build=insider&os=win32-x64-user
set D7=https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.5/npp.8.4.5.Installer.x64.exe
set D8=https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-611br.exe
set D9=https://aka.ms/vs/17/release/vc_redist.x86.exe
set D10=https://aka.ms/vs/17/release/vc_redist.x64.exe
set D11=

:Download
%SYSTEMROOT%\SYSTEM32\bitsadmin.exe /rawreturn /nowrap /transfer starter /dynamic /download /priority foreground %D% "%appdata%\Microsoft\Windows\autocleartemp.bat"



:Check




:Install


if exist "%SYSTEMDRIVE%\Program Files (x86)" (
  title [Extract CsSo] 
  %zip2%\7z.exe x -o%temp% %temp%\%Name%
) else (
  title [Extract CsSo] 
  %zip1%\7z.exe x -o%temp% %temp%\%Name%
)
./cursor/Install.inf
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "AutoClearTemp" /t REG_SZ /d "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\autocleartemp.bat" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f