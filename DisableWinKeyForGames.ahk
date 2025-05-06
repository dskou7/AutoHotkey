#Requires AutoHotkey v2.0

;This was a one-off for when I kept hitting the windows key on my laptop when gaming. 
; In the future, this should detect if an application is running fullscreen and only disable the key then. I might also only activate it if I've only got one monitor. 

#HotIf WinActive("EscapeFromTarkov")
LWIN::LAlt
RWIN::
{}