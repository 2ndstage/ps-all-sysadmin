Option Explicit 
Dim from_sv, to_sv, PrinterPath, PrinterName, DefaultPrinterName, DefaultPrinter 
Dim DefaultPrinterServer, SetDefault, key 
Dim spoint, Loop_Counter, scomma 
Dim WshNet, WshShell 
Dim WS_Printers 
DefaultPrinterName = "" 
spoint = 0 
scomma = 0 
SetDefault = 0 
set WshShell = CreateObject("WScript.shell") 
 
from_sv = "\\old" 'This should be the name of the old server. 
to_sv = "\\new" 'This should be the name of your new server. 
 
 
'Just incase their are no printers and therefor no defauld printer set 
' this will prevent the script form erroring out. 
On Error Resume Next 
key = "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows\Device" 
DefaultPrinter = LCase(WshShell.RegRead (key)) 
 
 
If Err.Number <> 0 Then 
    DefaultPrinterName = "" 
else 
'If the registry read was successful then parse out the printer name so we can  
' compare it with each printer later and reset the correct default printer 
' if one of them matches this one read from the registry. 
spoint = instr(3,DefaultPrinter,"\")+1 
 
  
 
DefaultPrinterServer = left(DefaultPrinter,spoint-2) 
 
    if lcase(DefaultPrinterServer) = from_sv then 
        DefaultPrinterName = mid(DefaultPrinter,spoint,len(DefaultPrinter)-spoint+1) 
        scomma = instr(DefaultPrinterName,",") 
        DefaultPrinterName = left(DefaultPrinterName,scomma -1) 
    end if 
end if 
 
Set WshNet = CreateObject("WScript.Network") 
Set WS_Printers = WshNet.EnumPrinterConnections 
 
'You have to step by 2 because only the even numbers will be the print queue's 
' server and share name. The odd numbers are the printer names. 
For Loop_Counter = 0 To WS_Printers.Count - 1 Step 2 
    'Remember the + 1 is to get the full path ie.. \\your_server\your_printer. 
    PrinterPath = lcase(WS_Printers(Loop_Counter + 1)) 
 
    'We only want to work with the network printers that are mapped to the original 
    ' server, so we check for "\\Your_server". 
    if lcase(LEFT(PrinterPath,len(from_sv))) = from_sv then 
        'Now we need to parse the PrinterPath to get rhe Printer Name. 
        spoint = instr(3,PrinterPath,"\")+1 
        PrinterName = mid(PrinterPath,spoint,len(PrinterPath)-spoint+1) 
        'Now remove the old printer connection. 
        WshNet.RemovePrinterConnection from_sv+"\"+PrinterName 
        'and then create the new connection. 
        'Do not create c6100 
        if lcase(PrinterName) <> "c6100" then 
            WshNet.AddWindowsPrinterConnection to_sv+"\"+PrinterName 
            'If this printer matches the default printer that we got from the registry then 
            ' set it to be the default printer. 
            if DefaultPrinterName = PrinterName then 
                WshNet.SetDefaultPrinter to_sv+"\"+PrinterName 
            end if 
        end if 
    end if 
Next 
Set WS_Printers = Nothing 
Set WshNet = Nothing 
Set WshShell = Nothing 
 
' wscript.echo "Printers Migrated" 

