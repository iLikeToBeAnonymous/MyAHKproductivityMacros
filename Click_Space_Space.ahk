#NoEnv

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

numOfClicks:=1
; Replace the below InputBox with a Gui using an "UpDown" control (https://www.autohotkey.com/docs/commands/GuiControls.htm#UpDown)
InputBox, numOfClicks, , Type in number of clicks.`nDEFAULT SHOULD BE 1`nIf you need to re-enter this`, you must reload the script.,,,,,,,,1
InputBox, numOfSpaces, , Type in number of times `"space`" should be hit.`nDEFAULT SHOULD BE 1`nIf you need to re-enter this`, you must reload the script.,,,,,,,,1
InputBox, waitSpace, , Time in milliseconds to wait after `"space`" is hit before next action.`nDEFAULT SHOULD BE 3000 for deleting mappings`nIf you need to re-enter this`, you must reload the script.,,,,,,,,1000
If ErrorLevel
	numOfClicks=1
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
	Send, {LButton down}
	Sleep, 5
	Send, {LButton up}
	Sleep, 20
	Sleep, 1000

	spaceSendSleep(numOfSpaces,waitSpace)


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
	Sleep, 10
	Send, {c DOWN}
	Sleep, 10
	Send, {c UP}
	Sleep, 10
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
	Sleep, 10
	Send, {f DOWN}
	Sleep, 10
	Send, {f UP}
	Sleep, 10
	Send, {Ctrl UP}
	Sleep, 10

	Send, {Ctrl DOWN}
	Sleep, 10
	Send, {v DOWN}
	Sleep, 10
	Send, {v UP}
	Sleep, 10
	Send, {Ctrl UP}
	Sleep, 10
Return ;

myAltTab:
	SLEEP, 10
	Send, {Alt DOWN}
	Sleep, 5
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
		Sleep, 5
		Send, {LButton up}
		Sleep, 10
	}
Return


MultiClick(clickCount)
{
	Loop %clickCount%
	{
		Send, {LButton down}
		Sleep, 5
		Send, {LButton up}
		Sleep, 20
	}
}



; ##########################################################
; SIMPLE FUNCTION ALLOWING YOU TO SET THE SLEEP INTERVAL
; AFTER EACH TAB ENTRY INSTEAD OF TYPING IT OUT EACH TIME
; ##########################################################
TabSendSleep:
	Send, {Tab}
	; Sleep, 100
	; Sleep, 50
	Sleep, 10
Return

spaceSendSleep(spacebarCount,waitTime)
{
	Loop %spacebarCount%
	{
		Send, {Space down}
		Sleep, 5
		Send, {Space up}
		Sleep, %waitTime%
	}
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
