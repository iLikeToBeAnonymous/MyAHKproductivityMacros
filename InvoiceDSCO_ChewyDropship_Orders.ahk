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
SetKeyDelay 1 ; has no effect on SendMode Input
SetMouseDelay 1
SetBatchLines 1 ; has no effect on SendMode Input
BlockInput, Send ; keeps user error from modifying input during a send event (doesn't really get a chance to act when SendMode is "Input")

; variables
barcodeURLp1 := "https://go.cin7.com/cloud/docs/barcode.ashx?code="
barcodeURLp2 := "&h=50&s=1&f=0&bf="
myWaitTime := 1000 ; time in milliseconds
global sleepyTime:=1000 ; WHY DA FUQ ISN'T THIS WORKING???

autoTrimYesNo := true ; 0 ; false ; It's more convenient to have it on by default.
autoTrimMessage := "Click to toggle AutoTrim Whitespace"


; ###################################################### Menus are created in the reverse of what would seem like a logical order.
; #########  CREATE THE GUI TO HOLD THE MENUS  ######### First, define individual menu contents
; ###################################################### Then, define menu headings. Lastly, define the menu bar to hold them.

; ####### FIRST, DEFINE THE CONTENTS OF THE MENUS ######
; Menu, tabItGoesUnder, Add, contentsOfMenuOption, functionCall
; Use "functionCallTest()" as a placeholder function when testing adding new menus.
Menu, ImaMenu_SubMenuA, Add, Replace Pipes with Tabs, regexRplcPipes
Menu, ImaMenu_SubMenuA, Add, Remove Leading Tabs, remLdngTabs
Menu, ImaMenu, Add, Swap New-Line Chars with Tabs, swapNwLnsWTabs
Menu, ImaMenu_SubMenuA, Add, Swap Multi-Spaces with Tabs, swapMultiSpaceWithTabs
Menu, ImaMenu, Add, Replace Tabs with Commas, swapTabsWithCommas
Menu, ImaMenu, Add, Replace Commas with Tabs, swapCommasWithTabs
Menu, ImaMenu_SubMenuA, Add, Fix Inches and Feet Abbreviations, fixInchesAndFeet
Menu, ImaMenu_SubMenuA, Add, Newline Chars for Cold Storage, sanitizeNewLines

Menu, autoTrimWhiteSpace, Add, %autoTrimMessage%, autoTrimToggle ; Doesn't do anything. This needs to be a bool.

; ######### SECOND, DEFINE THE TABS THEMSELVES #########
Menu, MyMenuBar, Add, I'm a menu!, :ImaMenu
	; Below are part of the sub-menu "Extras"
	Menu, ImaMenu, Add, Extras, :ImaMenu_SubMenuA
Menu, MyMenuBar, Add, Trim, trimWhiteSpace ; This is a standalone menu item (right on the bar), and clicking it triggers the function.
Menu, MyMenuBar, Add, Settings, :autoTrimWhiteSpace


; YOU NEED TO MAKE COLD STORAGE CLICKABLE/EDITABLE AS AN OPTION
; ####### THIRD, CREATE THE GUI TO HOLD THE MENUS ######
Gui, Menu, MyMenuBar ; Instanciates and names the Gui
	Gui, Margin, 20,20
	Gui, Font, q5 S12,  ; https://www.autohotkey.com/docs/commands/Gui.htm#PosSize
	; "r5" means 5 rows.
	; "vtext1" is a "v-label" much like a "g-label". The "v" has a meaning, and the "text1" is the way the specific text box gets marked for update on the guiUpdate.
	Gui, Add, Text,Border r1 w300 vautoTrimStatusDisplay,AutoTrim Whitespace is on
	Gui, Add, Text,Border r2 w300 vtext1,%extraClipboard%  ; Use "Edit" instead of "Text" to turn it into an input field
	; "wp" option means it inherits its size from the previous Gui control
	Gui, Add, Text,Border r2 wp vtext4,

	scaledX:=0.7*A_ScreenWidth
	scaledY:=0.05*A_ScreenHeight
	Gui, Show, x%scaledX% y%scaledY% AutoSize
	Gui, +AlwaysOnTop +Resize

	myBGcolor := "0099ff"
	Gui, Color, %myBGcolor% ; Progress, 1: M1 CW334477 CTaqua x10 y137 h50 w300 fs12 zh0,,,HUD,

	Gosub, updateGui




; ##############################################
;             END GUI SETUP SECTION
; ##############################################

; #########################################################################
; ##########   DEFINE THE PARAMETERS FOR THE PROGRESS BAR WINDOW ##########
; #########################################################################
; "b1" in the options below means borderless.
; "b2" would have a regular border
; "M" means moveable (M1 is resizeable and M2 has min/max/close buttons), but it has to have a title StatusBar
; "fs" denotes "subtext" font size (put "0" to use sysdefault)
;    Progress, 1: M1 CW334477 CTaqua x10 y137 h50 w300 fs12 zh0,,,HUD, ; Reactivate this line to see old HUD
; SetTimer, UpdateHUD, 170
; WinActivate Program Manager
Return

UpdateOSD: ; I have NO idea what this is here for...
	MouseGetPos, MouseX, MouseY
	GuiControl,, MyText, X%MouseX%, Y%MouseY%
return
; ######################################
; ########## MACROS BY HOTKEY ##########
; ######################################

^+c:: ; Ctrl + Shift + c
	Gosub, CopyToColdStorage
Return

autoTrimToggle:
	if (autoTrimYesNo)
	{
		autoTrimYesNo := false
		GuiControl,,autoTrimStatusDisplay,AutoTrim Whitespace is off
		ToolTip, Auto Trim is now off
		SetTimer, RemoveToolTip, -2000
		; MsgBox,,, Auto Trim is On
	}
	else if (autoTrimYesNo = false)
	{
		autoTrimYesNo := true
		GuiControl,,autoTrimStatusDisplay,AutoTrim Whitespace is on
		ToolTip, Auto Trim is now on
		SetTimer, RemoveToolTip, -2000
		; MsgBox,,, Auto Trim is Off
	}
Return

F5:: ; OPENS THE INPUT BOX TO STORE SOMETHING TO COLD STORAGE
InputBox, extraClipboard, , Please enter contents for extra clipboard`n(ESC to exit)
; MsgBox,4,,Clear clipboard?
	; IfMsgBox, Yes
		; clipboard := "✔✔✔ New Cold Storage Cycle ✔✔✔" ; The check marks appear as invalid chars because I didn't save this as UTF8-BOM
		clipboard := "New Cold Storage Cycle"
		; xtrClip := extraClipboard ; I don't know what this does anymore...
		; EnvAdd, xtrClip, 24
		; clipboard = %extraClipboard%

Return



; #########################################################################################
; ############################ SEND CONTENTS OF EXTRA CLIPBOARD ###########################
; #########################################################################################
^+Space:: ; (That's ctrl + Shift + Space)
	BlockInput, MouseMove
	extraClipboard := RegExReplace(extraClipboard, "\r\n?|\n\r?", "`n")

	if (autoTrimYesNo)
	{
		Gosub trimWhiteSpace
		SendRaw, %extraClipboard% ; You MUST use "SendRaw" in this instance instead of "Send" because otherwise special characters (like #) can't be sent
	;	SendInput, %extraClipboard% ; This is the old version before "SendRaw" was used. It's here in case you need to revert methods.
	;	Send, {Enter} ; Just if you want to hit "Enter" afterwards like a barcode scanner does.
	;	SendRaw, {Enter}
	;	SendInput, {Tab}
	}
	else if (autoTrimYesNo = false)
	{
		SendRaw, %extraClipboard%
	}

	BlockInput, MouseMoveOff

	gosub, stuckKeyCheck

Return

F3:: ; ^+s:: ; (That's ctrl + Shift + s key)
	BlockInput, MouseMove
	extraClipboard := RegExReplace(extraClipboard, "\r\n?|\n\r?", "`n")

	; Fill in the "Invoice ID" field
	Gosub trimWhiteSpace
	SendRaw, %extraClipboard%-%clipboard%
	; SendRaw, -
	; SendRaw, %clipboard%
	DllCall("Sleep","UInt", 30)
	
	; Fill in "Terms Type" to "Discount not applicable"
	TabSleep(9) ; Replace with an in-line loop?
	DllCall("Sleep","UInt", 30)
	downArrow(3) ;
	DllCall("Sleep","UInt", 75)

	; Fill in the "Basis Date"
	Send, {Tab}
	DllCall("Sleep","UInt", 30)
	myVarCurrentDateTime := A_Now
	EnvAdd, myVarCurrentDateTime, -6, hours
	EnvAdd, myVarCurrentDateTime, 1, Days ; sets date to tomorrow for submitting ARNs
	myBasisDate :=
	FormatTime, myBasisDate, %myVarCurrentDateTime%, yyyy-MM-dd
	Send, %myBasisDate%

	; Set "Discount Percent" to 0
	DllCall("Sleep","UInt", 100)
	TabSleep(2) ; Although you're only moving to the next line, you must tab twice: first to "close" the date entry, then the second to ACTUALLY move to the next line.
	Send, 0
	DllCall("Sleep","UInt", 30)
	TabSleep(4)
	; SendRaw, {Tab 4} ; TabSleep(4)
	DllCall("Sleep","UInt", 30)
	SendRaw, 30
	DllCall("Sleep","UInt", 30)
	TabSleep(1)
	BlockInput, MouseMoveOff

	gosub, stuckKeyCheck

Return

; ##########################################################
; SIMPLE FUNCTION ALLOWING YOU TO SET THE SLEEP INTERVAL
; AFTER EACH TAB ENTRY INSTEAD OF TYPING IT OUT EACH TIME
; ##########################################################
downArrow(myCtr)
{
	Loop %myCtr%
	{
		Send, {Down DOWN}
		DllCall("Sleep","UInt",50)
		Send, {Down UP}
		DllCall("Sleep","UInt",50)
	}
} ;
Return ;

mySleep:
	DllCall("Sleep","UInt", 30)
Return

TabSleep(myCtr)
{
	Loop %myCtr%
	{
		Send, {Tab}
		DllCall("Sleep","UInt",50) ; Sleep, %sleepyTime%
	}
} ;
Return ;


; #########################################################################################
; Generates an alpha-numeric barcode from the contents of the extra clipboard
; Currently uses Cin7's barcode image generator. Need to replace
; #########################################################################################
^+x:: ; (Ctrl + Shift + x)
	gosub, stuckKeyCheck
	SendRaw, %barcodeURLp1%
	SendRaw, %extraClipboard%
	SendRaw, %barcodeURLp2%
	Send, {Enter}

	gosub, stuckKeyCheck

Return


; #########################################################################################
; CIN7 CARTONIZATION MINI-SCRIPT FROM CONTENTS OF EXTRA CLIPBOARD
; #########################################################################################
^+d:: ; (That's ctrl + Shift + d)(REQUIRES THAT YOU CLICK IN THE CORRECT CELL)

	; Send, {LButton} ; Sends a left-click at the cursor's present position ; disable to manually send the left click (less efficient, but more accurate)

	; SplashTextOn,,,Line item being assigned to carton %extraClipboard%
	ToolTip Line item being assigned to carton %extraClipboard%

	; Sleep, 400 ;
	; Send, {Tab 4}
	Loop, 4
	{
		Send, {Tab}
		Sleep 30
	}
	Sleep, 100

	; Send, %xtrClip% ; I don't know why this was used instead of "extraClipboard"
	Send, %extraClipboard%

	Tooltip ; Turn off the tip

	Sleep, 300
	Send, +{Tab 2}
	Sleep, 100
	Send, {Enter}

	gosub, stuckKeyCheck

Return

; #########################################################################################
; SHIP AND ETA DATES
; #########################################################################################

F2::

	myVarCurrentDateTime := A_Now
	EnvAdd, myVarCurrentDateTime, -6, hours ; for those after-midnight entries... Note, "EnvSub" doesn't work in this context.
	oneWkLater := myVarCurrentDateTime ;
	EnvAdd, oneWkLater, 7, days

	myDispatchDt := ;
	myArrivalDt := ;


	FormatTime, myDispatchDt, %myVarCurrentDateTime%, M/d/yyyy
	FormatTime, myArrivalDt, %oneWkLater%, M/d/yyyy

	; Send, {LButton}
	; Sleep, 30
	Send, ^a
	Sleep, 50
	; Send, {Backspace}

	Send, %myDispatchDt%
	Sleep, 100
	; Send, {Backspace}
	; Sleep, 50
	TabSleep(2)
	Send, %myArrivalDt%
	TabSleep(8)
	Send, ^a ;
	Sleep, 50
	Send, {BackSpace}

	; \R is the AHK RegEx code for any new line char.
	cleanedClip := RegExReplace(clipboard, "\R{1,}", "`r")

	; below line also works, but is less versatile.
	; cleanedClip := StrReplace(StrReplace(Clipboard,"`r`n","`n"),"`n`r","`n")

	Send, %cleanedClip% ; Is only useful if you've saved the tracking info to the clipboard...

	gosub, stuckKeyCheck

Return

RAlt::RButton ; enables the right alt key to send a right-click (since my right mouse button is cantankerous)


::tdt::
	SendInput %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%
Return

; #########################################################################################
; #########################################################################################


; ##############################################################################
; ################ DEBUG TOOLS AND THINGS THAT NEED TO BE PERSISTENT ###########
; ##############################################################################

#Persistent ; YOU SHOULD PROBABLY READ MORE ABOUT WHAT THIS DOES

/*
ToggleProgressBar:
if SplashTextFlag = 0 ; respond to the current flag value
{

}
else
{

}
Return
*/

stuckKeyCheck:
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
	        ToolTip,Shift force-released,,,
	        SetTimer, RemoveToolTip, -5000
	        ; KeyHistory
	    }
	}
Return

OnClipboardChange:
	; Progress,1:,%extraClipboard%`n%clipboard%
	Gosub, updateGui
Return

+esc::
	Reload
Return





; +esc:: ; Shift + esc
;	Send, {Esc}
; Return
; test text: 1l0Oo

; ########## LOCK COMPUTER ##########
Break::
	; Send #l
	DllCall("LockWorkStation")
Return


CopyToColdStorage: ; copy selected to cold storage
	KeyWait Ctrl
	KeyWait c ; by chaining both of these, the rest of the script waits for both "Ctrl" and "c" to be released before attempting to execute
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
	if (autoTrimYesNo)
	{
		extraClipboard := Trim(clipboard)
	}
	else
	{
		extraClipboard := clipboard
	}
	; clipboard := "✔✔✔ New Cold Storage Cycle ✔✔✔" ; The check marks aren't displaying correctly after recent AHK update
	clipboard := "New Cold Storage Cycle"
	ClipWait, 3, 1
	if ErrorLevel
	{
	    MsgBox, The attempt to copy text onto the clipboard failed.
	    ; Reload
	    Gosub EndScript
	    return
	}
	; xtrClip := extraClipboard ; No idea what this code is here for...
Return

RemoveToolTip:
	ToolTip
return


updateGui: ; Some kind of scoping issue is preventing this from working correctly if done as a function.
	; Gui, Submit, NoHide
	GuiControl,,text1,%extraClipboard%
	GuiControl,,text4,%clipboard%
Return


EndScript:
	MsgBox, Script walked through %loopCount% rows. `n %remainingRows% rows remaining.`n Last SKU was %orderedSKU%`nSee "Clipboard" field in HUD after closing this.
	Clipboard = %orderedSKU%

	Reload
Return

GuiClose:
	ExitApp

functionCallTest()
{
	MsgBox, 1484096, SARCASM, You're beyond help,
}

regexRplcPipes:
	; \R is the AHK RegEx code for any new line char.
	extraClipboard := RegExReplace(extraClipboard, "\|{1,}", "	")

	; below line also works, but is less versatile.
	; cleanedClip := StrReplace(StrReplace(Clipboard,"`r`n","`n"),"`n`r","`n")

	; attempting to "send" right away makes the script start typing (or attempting to) on the active window, which is the Gui (which obviously does nothing)
	; Send, %cleanedClip% ; Is only useful if you've saved the tracking info to the clipboard...


	gosub, updateGui
Return ;

remLdngTabs:
	; \R is the AHK RegEx code for any new line char.
	; extraClipboard := RegExReplace(extraClipboard, "m)^\t", "") ; The "m)" in the regular expression means "multi-line"
	extraClipboard := RegExReplace(extraClipboard, "^\t", "") ; To remove the initial tab on first line
	; Below row removes the initial tab on each following line:
	extraClipboard := RegExReplace(extraClipboard, "m)\R\t", "`n") ; The "m)" in the regular expression means "multi-line"

	extraClipboard := RegExReplace(extraClipboard, "m)\R\s", "`n") ; Removes initial space at beginning of first line

	gosub, stuckKeyCheck
	gosub, updateGui
Return ;

swapNwLnsWTabs:
	; \R is the AHK RegEx code for any new line char.
	extraClipboard := RegExReplace(extraClipboard, "\R", "`t") 

	; More generalized and versatile version.
	; extraClipboard := RegExReplace(extraClipboard, "\R\s", "`n") 
	; extraClipboard := RegExReplace(extraClipboard, "\n{2,}", "`n")
	; extraClipboard := RegExReplace(extraClipboard, "\n", "`t") 
	; extraClipboard := RegExReplace(extraClipboard, "\t{2,}", "`t")

	gosub, updateGui
Return ;

swapMultiSpaceWithTabs:
;	extraClipboard := RegExReplace(extraClipboard, "\s{2,}", "	")
;	extraClipboard := StrReplace(extraClipboard, A_Space A_Space, A_Space, Count)

	; extraClipboard := RegExReplace(extraClipboard, "\s\R", "`n") ; This is because unlike "normal" regex, "\s" matches new-line chars as well as simple spaces.
	; extraClipboard := RegExReplace(extraClipboard, "\R\s", "`n")
	; extraClipboard := RegExReplace(extraClipboard, "\n{2,}", "`n") 
	; extraClipboard := RegExReplace(extraClipboard, "\s{2,}", A_Space)

	extraClipboard := StrReplace(extraClipboard, A_Space,"`t")
	extraClipboard := RegExReplace(extraClipboard, "\t{2,}", "`t")

	gosub, updateGui
Return ;

swapTabsWithCommas:
	extraClipboard := RegExReplace(extraClipboard, "\t", ",")

	gosub, updateGui
Return ;

swapCommasWithTabs:
	extraClipboard := RegExReplace(extraClipboard, "\,", "`t")

	gosub, updateGui
Return

sanitizeNewLines:
	extraClipboard := RegExReplace(extraClipboard, "\R", "`n")
	extraClipboard := RegExReplace(extraClipboard, "\n{2,}", "`n")
	extraClipboard := RegExReplace(extraClipboard, "\n{2,}", "`n")

	gosub, updateGui
Return ;

trimWhiteSpace:
	extraClipboard := RegExReplace(extraClipboard, "\s", "")
Return ;

fixInchesAndFeet:
	extraClipboard := RegExReplace(extraClipboard, "m)Inch|inch|in|Inches|inches|INCHES", "IN")
	extraClipboard := RegExReplace(extraClipboard, "m)INch|INches", "IN")

	extraClipboard := RegExReplace(extraClipboard, "m)Ft|Feet|ft", "FT")

	extraClipboard := RegExReplace(extraClipboard, "m)X|x", Chr(215))

	gosub, updateGui
Return

CopySelected:
	Send, {Ctrl DOWN}
	DllCall("Sleep","UInt",10) ; Sleep, 10
	Send, {c DOWN}
	DllCall("Sleep","UInt",10) ; Sleep, 10
	Send, {c UP}
	DllCall("Sleep","UInt",10) ; Sleep, 10
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