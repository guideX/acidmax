VERSION 5.00
Begin VB.Form frmMain 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   Caption         =   "control panel"
   ClientHeight    =   7065
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   11145
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   MouseIcon       =   "frmMain.frx":000C
   Picture         =   "frmMain.frx":015E
   ScaleHeight     =   471
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   743
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   Begin VB.Timer tmrShowMain 
      Enabled         =   0   'False
      Interval        =   1
      Left            =   600
      Top             =   360
   End
   Begin VB.Image imgTemp 
      Height          =   495
      Left            =   1080
      Top             =   360
      Visible         =   0   'False
      Width           =   495
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private lCurrentItem As Integer
Private lCurrentItemIndex As Integer
Private lCurrentLeftNavItem As Integer
Private Const WM_SETTEXT = &HC
Private Const WM_CHAR = &H102
Private Const WM_GETTEXTLENGTH = &HE
Private Const WM_GETTEXT = &HD
Private Declare Function SendMessageLong& Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long)
Private Declare Function SendMessageByString Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As String) As Long
Private Declare Function FindWindowEx Lib "user32" Alias "FindWindowExA" (ByVal hWnd1 As Long, ByVal hWnd2 As Long, ByVal lpsz1 As String, ByVal lpsz2 As String) As Long
Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Private Declare Sub ReleaseCapture Lib "user32" ()
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Integer, ByVal lParam As Long) As Long
Private Declare Function SetParent Lib "user32.dll" (ByVal hWndChild As Long, ByVal hWndNewParent As Long) As Long
Private Type gListViewItem
    lTitle As String
    lToolTip As String
    lCommand As String
    lImage As String
    lImageIndex As Integer
End Type
Private lListViewItems(100) As gListViewItem
Private Type RECT
    Left As Long
    Top As Long
    Right As Long
    Bottom As Long
End Type
Private Declare Function GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT) As Long
Private lVarRect As RECT, lVarLong As Long
Private lTitleBarHeight As Long

Sub GetWindowSize(ByVal hwnd As Long, Width As Long, Height As Long)
Dim rc As RECT
GetWindowRect hwnd, rc
Width = rc.Right - rc.Left
Height = rc.Bottom - rc.Top
End Sub

Public Function DoesFileExist(lFileName As String) As Boolean
Dim msg As String
msg = dir(lFileName)
If msg <> "" Then
    DoesFileExist = True
Else
    DoesFileExist = False
End If
End Function

Public Function ReadFile(lFile As String) As String
On Local Error Resume Next
Dim n As Integer, msg As String
n = FreeFile
If DoesFileExist(lFile) = True Then
    Open lFile For Input As #n
        msg = StrConv(InputB(LOF(n), n), vbUnicode)
        If Len(msg) <> 0 Then
            ReadFile = Left(msg, Len(msg) - 2)
        End If
    Close #n
End If
End Function

Public Function GetFileTitle(lFileName As String) As String
On Local Error Resume Next
Dim msg() As String
If Len(lFileName) <> 0 Then
    msg = Split(lFileName, "\", -1, vbTextCompare)
    GetFileTitle = msg(UBound(msg))
End If
End Function

Public Sub FormDrag(lForm As Form)
On Local Error GoTo ErrHandler
ReleaseCapture
Call SendMessage(lForm.hwnd, &HA1, 2, 0&)
Exit Sub
ErrHandler:
    Err.Clear
End Sub

Private Sub Form_Load()
On Local Error Resume Next
Dim msg As String
lTitleBarHeight = ReturnWindowTitleBarHeight(ReturnParentWindow)
msg = App.Path & "\du.ini"
SetWindowToChild Me.hwnd
tmrShowMain.Enabled = True
msg = App.Path & "\du.ini"
Me.Width = ReadINI(msg, "settings", "width", Me.Width)
Me.Height = ReadINI(msg, "settings", "height", Me.Height)
If Err.Number <> 0 Then Err.Clear
End Sub

Private Sub Form_Resize()
On Local Error GoTo ErrHandler
Exit Sub
ErrHandler:
    Err.Clear
End Sub

Private Sub Form_Unload(Cancel As Integer)
On Local Error GoTo ErrHandler
Dim msg As String
msg = App.Path & "\du.ini"
WriteINI msg, "settings", "width", ReturnMainFormWidth()
WriteINI msg, "settings", "height", ReturnMainFormHeight()
WriteINI msg, "settings", "top", ReturnMainFormTop()
WriteINI msg, "settings", "left", ReturnMainFormLeft()
Exit Sub
ErrHandler:
    Err.Clear
End Sub

Sub mIRCStatusSend(lData As String)
On Local Error Resume Next
Dim lmIRC As Long, lMdiClient As Long, lmIRCStatus As Long, lEditBox As Long
lmIRC = FindWindow("mIRC", vbNullString)
lMdiClient = FindWindowEx(lmIRC, 0&, "MdiClient", vbNullString)
lmIRCStatus = FindWindowEx(lMdiClient, 0&, "mIRC_Status", vbNullString)
lEditBox = FindWindowEx(lmIRCStatus, 0&, "RichEdit20A", vbNullString)
Call SendMessageByString(lEditBox, WM_SETTEXT, 0&, lData)
If lEditBox = 0 Then Exit Sub
Do
    DoEvents
    lmIRC = FindWindow("mIRC", vbNullString)
    lMdiClient = FindWindowEx(lmIRC, 0&, "MdiClient", vbNullString)
    lmIRCStatus = FindWindowEx(lMdiClient, 0&, "mIRC_Status", vbNullString)
    lEditBox = FindWindowEx(lmIRCStatus, 0&, "RichEdit20A", vbNullString)
    Call SendMessageLong(lEditBox, WM_CHAR, 13, 0&)
Loop Until lEditBox <> 0
End Sub
