#NoEnv

; CoordMode, Mouse, Screen
; SetMouseDelay, 2
SetWorkingDir %A_ScriptDir%
#Include, %A_ScriptDir%\functions.ahk
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

; This got moved to the "mySettingsAndVariables.ini" file.
; global sleepyTime:=1000


F3:: ; ^+s:: ; (That's ctrl + Shift + s key)
	BlockInput, MouseMove
		TabSleep(4)
	BlockInput, MouseMoveOff
ExitApp
Return

; ##########################################################
; SIMPLE FUNCTION ALLOWING YOU TO SET THE SLEEP INTERVAL
; AFTER EACH TAB ENTRY INSTEAD OF TYPING IT OUT EACH TIME
; ##########################################################



