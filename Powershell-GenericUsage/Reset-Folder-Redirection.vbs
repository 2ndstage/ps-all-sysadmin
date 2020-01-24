Option Explicit

Dim WshShell, WshFSO, WshFile, Username, Profile, ServerName

Set WshFSO = CreateObject("Scripting.FileSystemObject")

Set WshShell = WScript.CreateObject("WScript.Shell")

Profile = WshShell.ExpandEnvironmentStrings("%userprofile%")

Username = WshShell.ExpandEnvironmentStrings("%username%")

'Update Server Name Variable

ServerName = "\\newServerName"

'Check if this has run before

If NOT (WshFSO.FileExists(Profile & "\mydocfix.log")) Then

'Create Registry Key

WshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Personal", ServerName & "\users$\" & Username

WshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\My Pictures", ServerName & "\users$\" & Username

Set WshFile = WshFSO.CreateTextFile(Profile & "\mydocfix.log", 2)

WshFile.Write "Fixed My Doc's Mapping on " & Date & " at " & Time

WshFile.close

'wscript.echo "You will be logged off for the changes to be applied."

wscript.echo "You need to log off for changes to be applied. Press OK to log off now."

'Log user off to apply changes

WshShell.run "Shutdown.exe -l -f"

End If

wscript.quit