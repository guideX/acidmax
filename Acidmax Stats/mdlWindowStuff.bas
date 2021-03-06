Attribute VB_Name = "mdlWindowStuff"
Option Explicit
Private Const GWL_STYLE = -16
Private Const WS_CHILD = &H40000000
Private Const WS_POPUP = &H80000000
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Private Declare Function SetWindowText Lib "user32" Alias "SetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String) As Long
Private Declare Function SetWindowPos Lib "user32" (ByVal hwnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long
Private Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Private Declare Function EnumChildWindows Lib "user32" (ByVal hWndParent As Long, ByVal lpEnumFunc As Long, ByVal lParam As Long) As Long
Private Declare Function EnumWindows Lib "user32" (ByVal lpEnumFunc As Long, ByVal lParam As Any) As Long
Private Declare Function SetParent Lib "user32.dll" (ByVal hWndChild As Long, ByVal hWndNewParent As Long) As Long
Private Declare Function GetWindowTextLength Lib "user32" Alias "GetWindowTextLengthA" (ByVal hwnd As Long) As Long
Private Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String, ByVal cch As Long) As Long
Private Declare Function GetClassName Lib "user32" Alias "GetClassNameA" (ByVal hwnd As Long, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long
Private Declare Function SetFocus Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function MakeModal& Lib "dsmodal" (ByVal AppHwnd&, ByVal hwndDest&, Optional ByVal Beep& = 0)
Private Declare Function SwitchToThisWindow Lib "user32" (ByVal hwnd As Long, ByVal hWindowState As Long) As Long
Private Declare Function SetForegroundWindow Lib "user32" (ByVal hwnd As Long) As Long
Private Const WM_SETTEXT = &HC
Private Const WM_GETTEXTLENGTH = &HE
Private Const WM_GETTEXT = &HD
Private lLong As Long
Private lParentText As String
Private lParenthWnd As String
Private lChildText As String
Private lChildHnwd As String
Private Declare Function SendMessageByString Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As String) As Long
Private Declare Function FindWindowEx Lib "user32" Alias "FindWindowExA" (ByVal hWnd1 As Long, ByVal hWnd2 As Long, ByVal lpsz1 As String, ByVal lpsz2 As String) As Long
Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Private Const WM_CHAR = &H102
Private Declare Function SendMessageLong& Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long)
Private Type RECT
    Left As Long
    Top As Long
    Right As Long
    Bottom As Long
End Type
Private Declare Function PtInRect Lib "user32" (lpRect As RECT, ByVal lLeft As Long, ByVal lTop As Long) As Long
'Private Declare Function SetParent Lib "user32.dll" (ByVal hWndChild As Long, ByVal hWndNewParent As Long) As Long
Private Declare Function GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As Any) As Long
Private Const HWND_NOTOPMOST = -2
Private Const HWND_TOPMOST = -1
Private Const SWP_NOACTIVATE = &H10
Private Const SWP_SHOWWINDOW = &H40

Public Sub AlwaysOnTop(myfrm As Form, SetOnTop As Boolean)
On Local Error Resume Next
Dim lFlag As Integer
If SetOnTop Then
    lFlag = HWND_TOPMOST
Else
    lFlag = HWND_NOTOPMOST
End If
SetWindowPos myfrm.hwnd, lFlag, myfrm.Left / Screen.TwipsPerPixelX, myfrm.Top / Screen.TwipsPerPixelY, myfrm.Width / Screen.TwipsPerPixelX, myfrm.Height / Screen.TwipsPerPixelY, SWP_NOACTIVATE Or SWP_SHOWWINDOW
End Sub

Public Function GetCheckboxValue(lCheckbox As CheckBox) As Boolean
On Local Error Resume Next
If lCheckbox.value = 1 Then
    GetCheckboxValue = True
Else
    GetCheckboxValue = False
End If
End Function

Sub mIRCStatusSend(lData As String)
On Local Error Resume Next
Dim lmIRC As Long, lMdiClient As Long, lmIRCStatus As Long, lEditBox As Long
lmIRC = FindWindow("mIRC", vbNullString)
lMdiClient = FindWindowEx(lmIRC, 0&, "MdiClient", vbNullString)
lmIRCStatus = FindWindowEx(lMdiClient, 0&, "mIRC_Status", vbNullString)
lEditBox = FindWindowEx(lmIRCStatus, 0&, "Edit", vbNullString)
Call SendMessageByString(lEditBox, WM_SETTEXT, 0&, lData)
If lEditBox = 0 Then Exit Sub
Do
    DoEvents
    lmIRC = FindWindow("mIRC", vbNullString)
    lMdiClient = FindWindowEx(lmIRC, 0&, "MdiClient", vbNullString)
    lmIRCStatus = FindWindowEx(lMdiClient, 0&, "mIRC_Status", vbNullString)
    lEditBox = FindWindowEx(lmIRCStatus, 0&, "Edit", vbNullString)
    Call SendMessageLong(lEditBox, WM_CHAR, 13, 0&)
Loop Until lEditBox <> 0
End Sub

Public Sub Pause(interval)
'''On Local Error Resume Next
Dim Current
Current = Timer
Do While Timer - Current < Val(interval)
    DoEvents
Loop
End Sub

Public Sub SetChildWindowText(lText As String)
On Local Error Resume Next
SetWindowText CLng(Trim(lChildHnwd)), lText
End Sub

Public Sub PutIn(lForm As Form)
'''On Local Error Resume Next
Dim r As RECT
With r
    .Left = .Left - 4
    .Top = .Top - 4
    .Right = .Right + 4
    .Bottom = .Bottom + 4
End With
PtInRect r, lForm.Left, lForm.Top
End Sub

Public Sub SetWindowToChild(lWindowHwnd As Long)
On Local Error GoTo ErrHandler
'Dim lStyle As Long
'lStyle = WS_CHILD Or WS_POPUP
SetWindowLong lWindowHwnd, GWL_STYLE, WS_CHILD
SetParent CLng(Trim(lWindowHwnd)), lParenthWnd
SetWindowText CLng(Trim(lParenthWnd)), "Advanced System Stats v" & App.Major & "." & App.Revision
Exit Sub
ErrHandler:
    MsgBox Err.Description
    Err.Clear
End Sub

Public Sub SetParentHwnd(lhWnd As Long)
On Local Error Resume Next
'MsgBox "Parent Hwnd Set To " & lhWnd
lParenthWnd = Str(lhWnd)
End Sub

Public Sub SetChildHWND(lhWnd As Long)
On Local Error Resume Next
lChildHnwd = Str(lhWnd)
End Sub

Public Sub ClearWindowStuff()
On Local Error GoTo ErrHandler
lLong = 0
lParenthWnd = ""
lParentText = ""
lChildHnwd = ""
lChildText = ""
ErrHandler:
    Err.Clear
End Sub

Public Function SetWindowFocus(lhWnd As Long)
On Local Error GoTo ErrHandler
'SetForegroundWindow lhWnd
SetFocus lhWnd
'SwitchToThisWindow lhWnd, 1
Exit Function
ErrHandler:
    Err.Clear
End Function

Public Function ShowNonModalForm(lForm As Form) As Boolean
On Local Error GoTo ErrHandler
ShowWindow lForm.hwnd, 1
Exit Function
ErrHandler:
    Err.Clear
End Function

Public Function GetParentVersion() As String
On Local Error GoTo ErrHandler
Dim c As Long, l As Long, msg As String
l = GetWindowTextLength(lParenthWnd)
msg = Space$(l + 1)
l = GetWindowText(lParenthWnd, msg, l + 1)
msg = Left$(msg, Len(msg) - 1)
GetParentVersion = Right(msg, Len(msg) - 25)
Exit Function
ErrHandler:
    Err.Clear
End Function

Public Function ReturnChildWindowHwnd() As Long
On Local Error GoTo ErrHandler
ReturnChildWindowHwnd = lChildHnwd
Exit Function
ErrHandler:
    Err.Clear
End Function

Public Function ReturnParentWindowHwnd() As Long
On Local Error GoTo ErrHandler
ReturnParentWindowHwnd = lParenthWnd
Exit Function
ErrHandler:
    Err.Clear
End Function

Public Function SetParentWindowFunction(lSetAsParent As Boolean, lParentCaption As String, lChildCaption As String, lForm As Form) As Boolean
On Local Error Resume Next
Dim l As Long, o As Long
If Len(lParentCaption) <> 0 Then
    If lSetAsParent = True Then
        lParentText = lParentCaption
        l = EnumWindows(AddressOf CheckWindows, lForm)
        lChildText = lChildCaption
        o = EnumChildWindows(lParenthWnd, AddressOf CheckChildWindow, l)
        SetParent lForm.hwnd, lChildHnwd
        SetWindowPosition CLng(lChildHnwd), 0, 0, ReturnMainFormWidth / Screen.TwipsPerPixelX, ReturnMainFormHeight / Screen.TwipsPerPixelY + 27
    ElseIf lSetAsParent = False Then
        SetParent lChildHnwd, 0
    End If
End If
End Function

Public Function SetWindowPosition(lhWnd As Long, lLeft As Long, lTop As Long, lWidth As Long, lHeight As Long) As Boolean
On Local Error GoTo ErrHandler
SetWindowPos lhWnd, 0, lLeft, lTop, lWidth, lHeight, 0
Exit Function
ErrHandler:
    Err.Clear
End Function

Public Function IsParentChildOpen() As Boolean
On Local Error GoTo ErrHandler
lChildHnwd = 0
lLong = EnumChildWindows(lParenthWnd, AddressOf CheckChildWindow, 0)
If lChildHnwd = 0 Then
    IsParentChildOpen = False
Else
    IsParentChildOpen = True
End If
Exit Function
ErrHandler:
    Err.Clear
End Function

Public Function ReturnParentHwnd() As Long
On Local Error GoTo ErrHandler
ReturnParentHwnd = lParenthWnd
Exit Function
ErrHandler:
    MsgBox Err.Description
    Err.Clear
End Function

Private Function CheckWindows(ByVal lhWnd As Long, ByVal lForm As Form) As Long
On Local Error Resume Next
Dim msg As String * 512, lRet As Long, lLen As Long, lClass As String * 50
lLen = GetWindowTextLength(lhWnd)
lRet = GetWindowText(lhWnd, msg, lLen + 1)
GetClassName lhWnd, lClass, 50
If lLen <> 0 Then
    msg = Trim(msg)
    If InStr(1, LCase(msg), lParentText, vbTextCompare) Then lParenthWnd = lhWnd
End If
CheckWindows = 1
End Function

Private Function CheckChildWindow(ByVal lhWnd As Long) As Long
On Local Error Resume Next
Dim lRet As Long, msg As String * 50
lRet = GetClassName(lhWnd, msg, 50)
If Trim(LCase(lChildText)) = Trim(LCase(GetText(lhWnd))) Then lChildHnwd = lhWnd
CheckChildWindow = 1
If Err.Number <> 0 Then Err.Clear
End Function

Private Function GetText(lhWnd As Long) As String
On Local Error Resume Next
Dim lLen As Long, lText As String
lLen = SendMessage(lhWnd, WM_GETTEXTLENGTH, 0, 0)
If lLen = 0 Then
    GetText = "Nothing"
    Exit Function
End If
lLen = lLen + 1
lText = Space(lLen)
lLen = SendMessage(lhWnd, WM_GETTEXT, lLen, ByVal lText)
GetText = Left(lText, lLen)
If Err.Number <> 0 Then
    Err.Clear
End If
End Function

