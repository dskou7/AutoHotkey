#Requires AutoHotkey v2.0

#SingleInstance Force
/**
 * Advanced Window Snap for AutoHotkey v2.0
 * Snaps the Active Window to one of nine different window positions. Adapted from Andrew Moore's V1 script.
 * 
 * @author Donny Skousen <donny.skousen@gmail.com>
 *
 * @author Andrew Moore <andrew+github@awmoore.com>
 * @link https://gist.github.com/AWMooreCO/1ef708055a11862ca9dc
 * @version 2.0
 */

/*
TODO: fix gaps between windows
*/

/**
 * SnapActiveWindow resizes and moves (snaps) the active window to a given position.
 * @param {string} winPlaceVertical   The vertical placement of the active window.
 *                                    Expecting "bottom" or "middle", otherwise assumes
 *                                    "top" placement.
 * @param {string} winPlaceHorizontal The horizontal placement of the active window.
 *                                    Expecting "left" or "right", otherwise assumes
 *                                    window should span the "full" width of the monitor.
 * @param {string} winSizeHeight      The height of the active window in relation to
 *                                    the active monitor's height. Expecting "half" size,
 *                                    otherwise will resize window to a "third".
 */
SnapActiveWindow(winPlaceVertical, winPlaceHorizontal, winSizeHeight) {

    ; "A" is a magic variable for the Active Window
    activeWin := WinGetID("A")
    activeMon := GetMonitorIndexFromWindow(activeWin)
    MonitorGetWorkArea(activeMon, &Left, &Top, &Right, &Bottom)

    if (winSizeHeight == "half") {
        height := (Bottom - Top)/2
    } else {
        height := (Bottom - Top)/3
    }

    if (winPlaceHorizontal == "left") {
        posX  := Left
        width := (Right - Left)/2
    } else if (winPlaceHorizontal == "right") {
        posX  := Left + (Right - Left)/2
        width := (Right - Left)/2
    } else {
        posX  := Left
        width := Right - Left
    }

    if (winPlaceVertical == "bottom") {
        posY := Bottom - height
    } else if (winPlaceVertical == "middle") {
        posY := Top + height
    } else {
        posY := Top
    }

    WinMove(posX, posY, width, height, "A")
}

/**
 * GetMonitorIndexFromWindow retrieves the monitor index of the monitor most occupied by a given window.
 * @param {Uint} windowHandle
 * 
 * Adapted from shinywong's code found on the AutoHotkey forums.
 * @author shinywong
 * @link http://www.autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/?p=440355
 */
GetMonitorIndexFromWindow(windowHandle) {
    ; Starts with 1.
    monitorIndex := 1

    ; Create a buffer to put the monitor information into.
    monitorInfo := Buffer(104)
    NumPut("uint", 104, monitorInfo)

    ; This DLL call retrieves a handle to the display monitor that has the largest area of intersection with the bounding rectangle of a specified window.
    monitorHandle := DllCall("MonitorFromWindow", "ptr", windowHandle, "uint", 0x2)
    ; With that we fill the monitorInfo buffer with the monitor information.
    DllCall("GetMonitorInfo", "ptr", monitorHandle, "ptr", monitorInfo)

    ; should probably have some check here for if these dll calls fail, but I'm not sure how they would fail.

    ; Now we extract the monitor info, which is stored in the buffer MONITORINFO struct which holds two RECT structs. 
    ; Those two structs are the monitor area and monitor work area. 
    monitorLeft   := NumGet(monitorInfo,  4, "Int")
    monitorTop    := NumGet(monitorInfo,  8, "Int")
    monitorRight  := NumGet(monitorInfo, 12, "Int")
    monitorBottom := NumGet(monitorInfo, 16, "Int")
    workLeft      := NumGet(monitorInfo, 20, "Int")
    workTop       := NumGet(monitorInfo, 24, "Int")
    workRight     := NumGet(monitorInfo, 28, "Int")
    workBottom    := NumGet(monitorInfo, 32, "Int")
    isPrimary     := NumGet(monitorInfo, 36, "Int") & 1

    MonitorCount := MonitorGetCount()

    ; Find our matching monitor.
    Loop MonitorCount {
        MonitorGetWorkArea(A_Index, &Left, &Top, &Right, &Bottom)

        ; Compare location to determine the monitor index.
        if ((workLeft = Left) and (workTop = Top)
            and (workRight = Right) and (workBottom = Bottom)) {
            monitorIndex := A_Index
            break
        }
    }

    return monitorIndex
}

; Here are the actual hotkey bindings.

; WIN + ALT + Directional Arrow Hotkeys
#!Up::SnapActiveWindow("top","full","half")
#!Down::SnapActiveWindow("bottom","full","half")

; CTRL + WIN + ALT + Directional Arrow Hotkeys
^#!Up::SnapActiveWindow("top","full","third")
^#!Down::SnapActiveWindow("bottom","full","third")

; WIN + ALT + Numberpad Hotkeys (Landscape)
#!Numpad7::SnapActiveWindow("top","left","half")
#!Numpad8::SnapActiveWindow("top","full","half")
#!Numpad9::SnapActiveWindow("top","right","half")
#!Numpad1::SnapActiveWindow("bottom","left","half")
#!Numpad2::SnapActiveWindow("bottom","full","half")
#!Numpad3::SnapActiveWindow("bottom","right","half")

; CTRL + WIN + ALT + Numberpad Hotkeys (Portrait)
^#!Numpad8::SnapActiveWindow("top","full","third")
^#!Numpad5::SnapActiveWindow("middle","full","third")
^#!Numpad2::SnapActiveWindow("bottom","full","third")
