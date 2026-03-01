const HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."

dim intRow
intRow = 0

Dim objFSO, objFile  
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("Output.txt", True)
	objFile.WriteLine "Sno" & vbtab & "Hostname" & vbTab & "KeyPath" & vbTAB & "KeyName"

Dim Fso, InputFile 
Set Fso = CreateObject("Scripting.FileSystemObject")
Set InputFile = fso.OpenTextFile("MachineList.Txt")

'loop start this will read Machinelist.txt file
'**********************************************
dim st
st="failed"

Do While Not (InputFile.atEndOfStream)
	strComputer = InputFile.ReadLine	'save computer name
	strComputer = Trim(strComputer)		'remove space if any
	Err.Clear
	On Error Resume Next
	if (strComputer = "") then
		intRow  = intRow +1	
	else
	
		Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\"&_ 
			strComputer & "\root\default:StdRegProv")

		strKeyPath = "SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\"
		strValueName = ""
		strValue = "AppVShNotify.exe,AppVStreamingUX.exe,EMET_Agent.exe"

		'strKeyPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"
		oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys

		For Each subkey In arrSubKeys
msgbox "ok"
		    msgbox subkey ' Just for debugging
		Next


		intRow  = intRow +1	
'			If (x = 0) And (Err.Number = 0) Then 
'				st="Success"
'			else
'				st="Fail"
'			end if
		
	end if 

		objFile.WriteLine intRow & vbtab & strComputer & vbTab & st
		st="failed"
intRow  = intRow +1

loop

			
msgbox "Done. Open Output.txt"