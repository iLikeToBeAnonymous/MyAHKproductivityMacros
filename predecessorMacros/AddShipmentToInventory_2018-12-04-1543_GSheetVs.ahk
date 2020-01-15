

#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce

SetControlDelay 1 ; has no effect on SendMode Input
SetWinDelay 1
SetKeyDelay 10 ; has no effect on SendMode Input
SetMouseDelay 1
SetBatchLines 1 ; has no effect on SendMode Input
BlockInput, Send ; keeps user error from modifying input during a send event (doesn't really get a chance to act when SendMode is "Input")



orderedSKU := 
qtyOrdered := 0
numOfRows := 0
remainingRows := 0
fieldSelect := 0
selectedFieldName := 
tabToUpdateButton := 35
loopCount := 0 ; count of the number of times the loop has occurred
; oldInvAddress := "http://ec2-52-15-252-126.us-east-2.compute.amazonaws.com/tackadmin/management/inventory/"
oldInvAddress := 
oldInvAddressP1:= "http://ec2-52-15-252-126.us-east-2.compute.amazonaws.com/tackadmin/management/inventory/?barcode=&name=&option=sku&sku="
oldInvAddressP2:= "&category=&supplier=&submit=Show"


; Emergency exit (kills and properly closes the app)
Escape:: 
	Gosub, stuckKeyCheck
	Goto, EndScript
Return

; HARD-KILL THE APP WITHOUT RELOAD
^+Escape:: ; Ctrl + Shift + Esc
	Gosub, stuckKeyCheck
	ExitApp
Return

; Shift + Escape == Emergency stop (reloads the app)
+Escape:: ; 
	Reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
	IfMsgBox, Yes, Edit
Return



/*
	Starting position/active window is the spreadsheet with the SKU list in it. 
	Script only works its way down the column selected at the start of the script.
	The source spreadsheet and the desired "first cell" are assumed to be selected.
	The Old Inv MUST ALREADY HAVE THE USER LOGGED IN FOR THIS TO WORK!!!

	TO DO:
	1) DONE Have the script prompt the user through the setup process.
	2) DONE Replace the mouse work with Chrome shortcut keys.
	3) Enable CSV upload to the macro (such as by "fileread" or something) to save the 
	   time-consuming step of switching windows and copying from a spreadsheet.
	4) If an attempted SKU lookup fails in Old Inv, have script store line position in 
	   source spreadsheet and move on (THIS MAY POSSIBLY BE DOABLE BY WAITING UNTIL THE 
	   PAGE LOADS, THEN COMPARING THE URL OF THE LOADED PAGE TO THAT ON FILE, BUT ONLY 
	   IF THE URL REDIRECTS ON NAVIGATION FAILURE)
*/

F3::
; ################################################
; ########### USER INPUT OF ROW COUNT ############
; ################################################
InputBox, numOfRows, , Please enter the number of products you wish to update
remainingRows := numOfRows
Sleep, 100

; ################################################
; ### USER SELECTION OF WHICH FIELD TO UPDATE ####
; ################################################
FieldRadio:
	RadiosExist := WinExist()
		; 22 loops puts the "Quantity Ordered 1" field as active. 
		; 23 loops puts the "Quantity Ordered 2" field as active.
		; 24 loops puts the "Quantity on Ocean 1" field as active.
		; 25 loops puts "Add # On Ocean 1 to New Quantity" button as active
		; 26 loops puts the "Quantity on Ocean 2" field as active.
		; 27 loops puts "Add # On Ocean 2 to New Quantity" button as active
		; 35 loops puts the "Update Item" button as active.
	Gui, Add, Radio, gCheckRadio vRadioGroup1, "Quantity Ordered 1 Field"
	Gui, Add, Radio, gCheckRadio vRadioGroup2, "Quantity Ordered 2 Field"
	Gui, Add, Radio, gCheckRadio vRadioGroup3, "Quantity on Ocean 1 Field"
	Gui, Add, Radio, gCheckRadio vRadioGroup4, "Quantity on Ocean 2 Field"
	Gui, Show
	WinWait, AHK_id %RadiosExist%
	WinWaitClose, AHK_id %RadiosExist%
; To edit options above, don't forget about the "Check" function
Return

 
 
CheckRadio:
Gui, Submit ; , NoHide
if (RadioGroup1)
{
	fieldSelect := 22
	selectedFieldName := "Quantity Ordered 1 Field"
}
if (RadioGroup2)
{
	fieldSelect := 23
	selectedFieldName := "Quantity Ordered 2 Field"
}
if (RadioGroup3)
{
	fieldSelect := 24
	selectedFieldName := "Quantity on Ocean 1 Field"
}
if (RadioGroup4)
{
	fieldSelect := 26
	selectedFieldName := "Quantity on Ocean 2 Field"
}

	EnvSub, tabToUpdateButton, fieldSelect
	; MsgBox, %FieldSelect%`n%tabToUpdateButton%

; Gui, Destroy 

; Return



MsgBox, "1. BEFORE CLICKING 'OK', VERIFY THAT YOU ARE LOGGED INTO OLD INV (Click on 'Reports' and log in if not)"`n"2. CLICK ON THE FIRST CELL OF THE SPREADSHEET (which should contain a SKU)"`n"3. RETURN TO THIS WINDOW AND CLICK 'OK' FOR THE SCRIPT TO BEGIN ADJUSTING INVENTORY"`n"4. PRESS 'Esc' TO TERMINATE, OR 'Shift + Esc' TO RELOAD"`n5. MAKE SURE THAT YOUR SOURCE SPREADSHEET IS A GOOGLE SHEET TITLED 'Untitled spreadsheet'

IfWinExist, Untitled spreadsheet - Google Sheets - Google Chrome ahk_class Chrome_WidgetWin_1
	    WinActivate, Untitled spreadsheet - Google Sheets - Google Chrome ahk_class Chrome_WidgetWin_1
	    WinWaitActive, Untitled spreadsheet - Google Sheets - Google Chrome ahk_class Chrome_WidgetWin_1, , 2
		if ErrorLevel
		{
		    MsgBox, Window not found!
	    	Gosub, EndScript
		}

; ################################################
; ############## BEGIN LOOP PASS #################
; ################################################ 
Loop, %numOfRows%
{
	clipboard :=  
	orderedSKU := 
	qtyOrdered := 0

; ################################################
; ######### Copy data from spreadsheet ###########
; ################################################

; You should be back at the first column now.
; Copy the contents of the cell (you DO have the desired cell active, don't you?) 
	Sleep, 200
	; copy the SKU in the selected cell
	; Send, ^c
	Gosub, CopySelected
	; Sleep, 200

	orderedSKU := clipboard
	clipboard := 
	; Copy the qty in the adjacent cell
	Send, {Right}
	; clipboard = ;
	Sleep, 200

	; Send, ^c
	Gosub, CopySelected
	Sleep, 500
	ClipWait, 3, 0
	if ErrorLevel
	{
	    MsgBox, The attempt to copy text onto the clipboard failed.
	    ; Reload
	    Gosub EndScript
	    return
	}
	qtyOrdered := clipboard
	clipboard := 
	Sleep, 200


; ######################################################################################
; ############### Switch from the master spreadsheet to the Old Inv Window #############
; ######################################################################################
	IfWinExist, Inventory - Google Chrome ahk_class Chrome_WidgetWin_1
	    WinActivate, Inventory - Google Chrome ahk_class Chrome_WidgetWin_1
	    WinWaitActive, Inventory - Google Chrome ahk_class Chrome_WidgetWin_1, , 2
		if ErrorLevel
		{
		    MsgBox, Window not found!
	    	Gosub, EndScript
		}

	
    


	Sleep, 500

	Send, ^l ; Chrome command to select the address StatusBar
	Sleep, 50

	
	Send, %oldInvAddressP1%
	Sleep, 50
	Send, %orderedSKU%
	Sleep, 50
	Send, %oldInvAddressP2%
	Sleep, 1500
	Send, {Enter}
	Sleep, 1500
	

	; #####################################################################################
	; Tab down to select the appropriate button to enter the item edit page of the Old Inv.
	; #####################################################################################
	Loop, 8
	{
		Gosub, TabSendSleep
	}
	; Click the edit button
	Send, {Enter}
	Sleep, 200

	; #############################################################################
	; ################## EDIT THE ADMIN PAGE FOR THE PRODUCT ######################
	; #############################################################################

	Loop, %fieldSelect% ; REMEMBER! fieldSelect is just a variable for how many times the loop should execute
	{
		Gosub, TabSendSleep
		; Sleep, 300 ; used for debugging
	}
	

	Send, %qtyOrdered%
	Sleep, 500

	; Tab down to the "Update Item" button
	Loop, %tabToUpdateButton%
	{
		Gosub, TabSendSleep
	}

	Sleep, 100
	
	; MsgBox, "Is 'Update Item' Button highlighted?"
	Send, {Enter}
	EnvAdd, loopCount, 1
	EnvSub, remainingRows, 1
	clipboard := 
	Sleep, 1500
	

	; Switch back to the spreadsheet with the order items
	
	IfWinExist, Untitled spreadsheet - Google Sheets - Google Chrome ahk_class Chrome_WidgetWin_1
	    WinActivate, Untitled spreadsheet - Google Sheets - Google Chrome ahk_class Chrome_WidgetWin_1
	    WinWaitActive, Untitled spreadsheet - Google Sheets - Google Chrome ahk_class Chrome_WidgetWin_1, , 2
		if ErrorLevel
		{
		    MsgBox, Window not found!
	    	Gosub, EndScript
		}
	
	Sleep, 200

	; Select the next cell to copy a SKU when the loop starts back up
	Send, {Down}
	Sleep, 200
	Send, {Left}
	Sleep, 800
	Gosub, stuckKeyCheck

} ; this brace ends the main (numOfRows) loop


Gosub, EndScript

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

; #######################################################################################
; SHOWS HUD IN TOP RIGHT CORNER OF SCREEN SO YOU CAN SEE WHAT'S LOADED IN THE VARIABLES
; #######################################################################################
OnClipboardChange:
		; SplashTextFlag := 1
		; SplashTextOn,300,45,HUD, %extraClipboard%`n%clipboard%
		SplashTextOn,300,77,HUD,"Clipboard: "%clipboard%`n"Current SKU: "%orderedSKU%`n"QTY: "%qtyOrdered%`n"Remaining: "%remainingRows%
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