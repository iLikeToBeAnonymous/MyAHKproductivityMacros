#NoEnv

; CoordMode, Mouse, Screen
; SetMouseDelay, 2
SetWorkingDir %A_ScriptDir%
#Include, %A_ScriptDir%\mySettingsAndVariables.ini
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
BlockInput, Send

; sleepyTime:=1000

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

TabSleep(myCtr)
{
	Loop %myCtr%
	{
		; global sleepyTime
		Send, {Tab}
		DllCall("Sleep","UInt",sleepyTime) ; the var "sleepyTime" must be WITHOUT percent signs framing it.
	}
Return ;
} ;