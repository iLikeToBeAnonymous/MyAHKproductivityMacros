#NoEnv
; #KeyHistory 0 ; Disables the program from recording history for debugging.
; ListLines Off ; Disables the program from recording the most recently activated lines.


; CoordMode, Mouse, Screen
; SetMouseDelay, 2
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
; SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce

SetControlDelay 1 ; has no effect on SendMode Input
SetWinDelay 1
SetKeyDelay 10 ; has no effect on SendMode Input
SetMouseDelay 1
SetBatchLines 1 ; has no effect on SendMode Input
BlockInput, Send ; keeps user error from modifying input during a send event (doesn't really get a chance to act when SendMode is "Input")

numOfClicks:=3
; Replace the below InputBox with a Gui using an "UpDown" control (https://www.autohotkey.com/docs/commands/GuiControls.htm#UpDown)
InputBox, numOfClicks, , Type in number of clicks.`nDEFAULT SHOULD BE 3`nIf you need to re-enter this`, you must reload the script.,,,,,,,,3
If ErrorLevel
	numOfClicks=3
; Shift + Escape == Emergency stop (reloads the app)
+Escape:: ;
	Reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
	IfMsgBox, Yes, Edit
Return



F3::
	BlockInput, MouseMove
	Sleep, 10
	; MouseMove, 2145, 493
	; Send, {LButton down}{LButton up}{LButton down}{LButton up}{LButton down}{LButton up}
	; Gosub, TripleClick
	MultiClick(numOfClicks)
	DllCall("Sleep","UInt",20)
	Gosub, CopySelected

  ; Below code only now works if the target window for "find" is Chrome
	WinActivateBottom, - Google Chrome
	DllCall("Sleep","UInt",200)

	; Select the address bar so you're always starting at the same spot on the page.
	Send, ^l ; Chrome command to select the address StatusBar
	DllCall("Sleep","UInt",50)

	; DllCall("Sleep","UInt",1000)
	TabSendSleep(14)
	DllCall("Sleep","UInt",400)
	CtrlV()
	DllCall("Sleep","UInt", 400)
	Send, {Enter}
	DllCall("Sleep","UInt", 5000)
	
	; Select the address bar so you're always starting at the same spot on the page.
	Send, ^l ; Chrome command to select the address StatusBar
	DllCall("Sleep","UInt",50)

	TabSendSleep(18)
	DllCall("Sleep","UInt", 300)
	Send, {Enter}
	DllCall("Sleep","UInt", 1000)
	Send, {Enter}


	
	BlockInput, MouseMoveOff
Return

; #########################################################################################################################
; #########################################################################################################################
; #########################################################################################################################
; FUNCTIONS LIST
; #########################################################################################################################
; #########################################################################################################################
; #########################################################################################################################

stuckKeyCheck: ; fix stuck ctrl keys
	If GetKeyState("Ctrl")           ; If the OS believes the key to be in (logical state),
	{
	    If !GetKeyState("Ctrl","P")  ; but  the user isn't physically holding it down (physical state)
	    {
	        Send {Blind}{Ctrl Up}
	        ; MsgBox,,, Ctrl force-released
	        ToolTip,Ctrl force-released,,,
	        SetTimer, RemoveToolTip, -5000
	        ; KeyHistory
	    }
	}
	If GetKeyState("Shift")           ; If the OS believes the key to be in (logical state),
	{
	    If !GetKeyState("Shift","P")  ; but  the user isn't physically holding it down (physical state)
	    {
	        Send {Blind}{Shift Up}
	        ; MsgBox,,, Shift force-released
	        ToolTip, "Shift force-released",,,
	        SetTimer, RemoveToolTip, -5000
	        ; KeyHistory
	    }
	}
Return

RemoveToolTip:
	ToolTip
Return


; ##########################################################################################
; FUNCTION TO HELP MINIMIZE THE CHANCE OF SENDING KEYS FASTER THAN THE CLIPBOARD WILL WORK
; IT SEEMS DRAWN OUT, BUT SIMPLER METHODS WEREN'T AS RELIABLE
; ##########################################################################################
CopySelected:
	Send, {Ctrl DOWN}
	DllCall("Sleep","UInt",10)
	Send, {c DOWN}
	DllCall("Sleep","UInt",10)
	Send, {c UP}
	DllCall("Sleep","UInt",10)
	Send, {Ctrl UP}
	ClipWait, 3, 1
	if ErrorLevel
	{
	    MsgBox, The attempt to copy text onto the clipboard failed.
	    ; Reload
	    Gosub EndScript
	    return
	}
	Gosub, stuckKeyCheck
Return

FindClip:
	Send, {Ctrl DOWN}
	DllCall("Sleep","UInt",10)
	Send, {f DOWN}
	DllCall("Sleep","UInt",10)
	Send, {f UP}
	DllCall("Sleep","UInt",10)
	Send, {Ctrl UP}
	DllCall("Sleep","UInt",10)

	Send, {Ctrl DOWN}
	DllCall("Sleep","UInt",10)
	Send, {v DOWN}
	DllCall("Sleep","UInt",10)
	Send, {v UP}
	DllCall("Sleep","UInt",10)
	Send, {Ctrl UP}
	DllCall("Sleep","UInt",10)
Return ;

myAltTab:
	DllCall("Sleep","UInt",10)
	Send, {Alt DOWN}
	DllCall("Sleep","UInt",5)
	Send, {Tab DOWN}
	Sleep, 200
	Send, {Tab UP}
	Sleep, 10
	Send, {Alt UP}
	Sleep, 10
Return

TripleClick:
	Loop, 3
	{
		Send, {LButton down}
		DllCall("Sleep","UInt",5)
		Send, {LButton up}
		DllCall("Sleep","UInt",10)
	}
Return


MultiClick(clickCount)
{
	Loop %clickCount%
	{
		Send, {LButton down}
		DllCall("Sleep","UInt",5)
		Send, {LButton up}
		DllCall("Sleep","UInt", 20)
	}
}



; ##########################################################
; SIMPLE FUNCTION ALLOWING YOU TO SET THE SLEEP INTERVAL
; AFTER EACH TAB ENTRY INSTEAD OF TYPING IT OUT EACH TIME
; ##########################################################
TabSendSleep(tabCount)
{	Loop, %tabCount%
	{
		Send, {Tab}
		DllCall("Sleep","UInt",10)
	} ;
}

CtrlV()
{
	Send, {Ctrl DOWN}
	DllCall("Sleep","UInt",10)
	Send, {v DOWN}
	DllCall("Sleep","UInt",10)
	Send, {v UP}
	DllCall("Sleep","UInt",10)
	Send, {Ctrl UP}
	DllCall("Sleep","UInt",10)
Return ;
}

; #######################################################################################
; SHOWS HUD IN TOP RIGHT CORNER OF SCREEN SO YOU CAN SEE WHAT'S LOADED IN THE VARIABLES
; #######################################################################################
OnClipboardChange:
		; SplashTextFlag := 1
		; SplashTextOn,300,45,HUD, %extraClipboard%`n%clipboard%
		; SplashTextOn,300,77,HUD,"Clipboard: "%clipboard%`n"Current SKU: "%orderedSKU%`n"QTY: "%qtyOrdered%`n"Remaining: "%remainingRows%
		SplashTextOn,300,77,HUD,"Clipboard: "%clipboard%
		WinMove, HUD,, 1475, 100
		; WinSet, Region, 50-0 W400 H133 R40-40, HUD
return

; #######################################################################################
; JUST THE END-SCRIPT PROCEDURE
; #######################################################################################
EndScript:
	MsgBox, Script walked through %loopCount% rows. `n %remainingRows% rows remaining.`n Last SKU was %orderedSKU%`nSee "Clipboard" field in HUD after closing this.
	Clipboard = %orderedSKU%
	Gosub, stuckKeyCheck
	Reload
Return

GuiClose:
ExitApp
