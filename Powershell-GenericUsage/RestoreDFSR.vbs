'==========================================================================
'
' 
' NAME: RestoreDFSR.VBS
'
'  AUTHOR: NedPyle, EPS, Microsoft Corporation
' 
' 
'  COMMENT: Disaster Recovery script for pulling DFSR data out of 'ConflictAndDeleted' 
'	    or 'PreExisting' folders and putting it back into a usable directory tree, 
' 	    preserving paths, names, and security descriptor info.
'
'  USAGE: Replace the 3 variables in the "operator-edited" section below
'         with valid paths. The Script will copy the contents of the source folder
'         to a specified path, returning files to original names and adding back 
'         their folder structure at the time of deletion. 
' 
'         It is important to note that duplicate conflicts (i.e. multiple versions of
'	  the same file that were conflicted) will be restored with only the latest version.
'
'         Finally: this tool can only copy files that were preserved in ConflictAndDeleted
'         by quota (by default, 660MB). If the quota prevented all files from being saved
'         this script is not going to help for those that were trimmed out. The PreExisting
'	  folder does not have a quota so all data should be restorable.
'
'  VERSION HISTORY:
'
'
'	  3.01 / 10/18/10
'	  Rewritten to finally properly support all file and folder attributes
'	  Warns of missing admin-specified paths
'
'
'  KNOWN ISSUES:
'
'	  If the script halts processing with errors, there are typically two possible issues:
'
'	  1) Your paths are incorrect in the "operator-edited" section
' 	  2) Your XML file is corrupt and unreadable (We've seen this after disk failures)
'
'
' This script is provided "AS IS" with no warranties, and confers no rights.
' For more information please visit 
' http://www.microsoft.com/info/cpyright.mspx to find terms of use.
'
'==========================================================================

Dim ofile
Dim Source
Dim Dest
Dim msg
Const quote = """"
Const BS = "\"


' Startup XML
Set objXMLDoc = CreateObject("Microsoft.XMLDOM") 
objXMLDoc.async = False

' Set File Read Environment
Set objShell = WScript.CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")


'=======================================================================
' Section must be operator-edited to provide valid paths
'=======================================================================

' Change path to specify location of XML Manifest
' Example 1: "C:\Data\DfsrPrivate\ConflictAndDeletedManifest.xml"
' Example 2: "C:\Data\DfsrPrivate\preexistingManifest.xml"

objXMLDoc.load("e:\userdocs\DfsrPrivate\PreExistingManifest.xml") 

' Change path to specify location of source files

' Example 1: "C:\data\DfsrPrivate\ConflictAndDeleted"
' Example 2: "C:\data\DfsrPrivate\preexisting"

SourceFolder = ("e:\userdocs\DfsrPrivate\PreExisting")

' Change path to specify output folder

OutputFolder = ("E:\tmp\userdocs_restore")

'========================================================================

' Check if admin forgot to change the path

if SourceFolder = "C:\your_replicated_folder\DfsrPrivate\ConflictAndDeleted" then 
	wscript.echo "Please edit script for your folder and XML paths. Exiting script."
	wscript.quit
elseif OutputFolder = "c:\your_dfsr_repair_tree" then 
	wscript.echo "Please edit script for your folder and XML paths. Exiting script."
	wscript.quit
end if


set objRootNodes = objXMLDoc.documentElement.ChildNodes

For Each objRootNode In objRootNodes 
   
  Set objChildNodes = objRootNode.ChildNodes
  For Each objChildNode in objChildNodes
       
       If objChildNode.nodeName = "Path" then
	  StrFullPath = objChildNode.firstChild.nodeValue
       end if

       If objChildNode.nodeName = "Attributes" then
	  FileorFolder = objChildNode.firstChild.nodeValue
       end if

       If objChildNode.nodeName = "NewName" then
	
	  GuidName = objChildNode.firstChild.nodeValue

          If GuidName <> "" then
              
              Length = Len(StrFullPath)
              StrExtract = Mid(strFullPath, 7, Length-6)	

              Source = SourceFolder & BS & GuidName
              Dest = OutputFolder & strExtract

	      Dim f

	      On Error Resume Next

		If fso.FileExists(Source) Then
		Set f = fso.GetFile(Source)

			wscript.echo "CMD /C XCOPY " & quote & Source & quote & " " & quote & Dest & quote & " " & "/Q /H /R /X /C /Y /K"
			objShell.Run "CMD /C ECHO F | XCOPY " & quote & Source & quote & " " & quote & Dest & quote & " " & "/Q /H /R /X /C /Y /K /F",0,TRUE

		ElseIf fso.FolderExists(Source) Then

			Set f = fso.GetFolder(Source)

		wscript.echo "CMD /C XCOPY " & quote & Source & quote & " " & quote & Dest & quote & " " & "/Q /H /R /X /Y /E /I /C /K"
		objShell.Run "CMD /C ECHO D | XCOPY " & quote & Source & quote & " " & quote & Dest & quote & " " & "/Q /H /R /X /Y /E /I /C /K /F",0,TRUE
 
		Else

			WScript.Echo "ERROR: """ & Source & """ does not exist."

		End If


          end if
         
      end if
  Next

Next
