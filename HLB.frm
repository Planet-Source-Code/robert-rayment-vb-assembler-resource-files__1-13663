VERSION 5.00
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   Caption         =   "Form1"
   ClientHeight    =   2055
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   3210
   Icon            =   "HLB.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   137
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   214
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox Text1 
      Alignment       =   1  'Right Justify
      Height          =   315
      Index           =   2
      Left            =   60
      MaxLength       =   32
      TabIndex        =   2
      Text            =   "Text1"
      Top             =   1260
      Width           =   3030
   End
   Begin VB.TextBox Text1 
      Alignment       =   1  'Right Justify
      Height          =   315
      Index           =   1
      Left            =   60
      MaxLength       =   10
      TabIndex        =   1
      Text            =   "Text1"
      Top             =   720
      Width           =   1035
   End
   Begin VB.TextBox Text1 
      Alignment       =   1  'Right Justify
      Height          =   315
      Index           =   0
      Left            =   60
      MaxLength       =   8
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   180
      Width           =   915
   End
   Begin VB.Label Label3 
      Caption         =   "Max 4294967295"
      Height          =   255
      Left            =   1320
      TabIndex        =   7
      Top             =   720
      Width           =   1635
   End
   Begin VB.Label Label2 
      Caption         =   "Max FFFFFFFF"
      Height          =   255
      Left            =   1320
      TabIndex        =   6
      Top             =   180
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Hex"
      Height          =   255
      Index           =   2
      Left            =   180
      TabIndex        =   5
      Top             =   0
      Width           =   435
   End
   Begin VB.Label Label1 
      Caption         =   "Binary"
      Height          =   255
      Index           =   1
      Left            =   180
      TabIndex        =   4
      Top             =   1080
      Width           =   555
   End
   Begin VB.Label Label1 
      Caption         =   "Long"
      Height          =   255
      Index           =   0
      Left            =   180
      TabIndex        =   3
      Top             =   540
      Width           =   675
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'HLB by Robert Rayment

'MAKE SURE TO READ INFO ON CREATING BINARY RES FILES
'AND INFO IN FORM.LOAD ABOUT COMMENTING IN AND OUT
'LOADING ASSEMBLER BIN FILES FROM DISK OR THE RESOURCE.

'SEE ALSO NOTES.TXT FILE FOR FURTHER EXPLANATIONS.

'Assembler & Resource file

'Hex, Long integer & Binary Converter

'--------------------------------
'How to create resource .res file
'--------------------------------

'Click Add-Ins / Add In Manager
'Select (Double click) Resource Editor /Click OK
'Click Tools & then Resource Editor
'Click Add Custom Resource (Tool Tip Text)
'From file menu select binary file, in this case HBL.bin
'Note the number along side the resultant list, 101 in this case
'Close resource editor
'The folder will now contain a .res file

'With this prog the resource file is done and it can be compiled
'to an EXE for you to test its independence!  The EXE is NOT
'included in the zip file.

'goto '***  in Form.Load to see how to test and to extract the binary
'           assembler data

'--------------------------------
'--------------------------------

'


Option Base 1

DefLng A-Z  'All variables Long unless otherwise specified
            'NB VB Net wont allow this anymore

'For calling machine code
Private Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" _
(ByVal lpMCode As Long, _
ByVal InpLong As Long, ByVal lpHex As Long, _
ByVal lpBin As Long, ByVal OpType As Long) As Long

'lpMCode    pointer to machine code
'InpLong    long integer number input
'lpHex      pointer to HexBytes(1)  input & output
'lpBin      pointer to BinBytes(1)  input & output
'OpType     long number 1,2 or 4 for respec. Hex, Dec & Bin input
'result     long decimal output (from reg EAX)

Dim lpMCode
Dim InpDec
Dim lpHex
Dim lpBin

Dim resdbl As Double

Dim InCode() As Byte 'To hold mcode
Dim HexBytes() As Byte
Dim binbytes() As Byte
Dim T0SW As Boolean, T1SW As Boolean, T2SW As Boolean
Dim zero As Boolean

Private Sub Form_Load()
Show
Refresh

resdbl = MsgBox("Have you read information in HBL.frm" & vbCrLf & _
"If so you can comment out the messagebox in Form.Load", _
vbYesNo + vbQuestion)
If resdbl = vbNo Then End


'Size & get pointers to byte arrays
ReDim HexBytes(8)
ReDim binbytes(32)
lpHex = VarPtr(HexBytes(1))
lpBin = VarPtr(binbytes(1))

'Get application path
PathSpec$ = App.Path
If Right$(PathSpec$, 1) <> "\" Then PathSpec$ = PathSpec$ & "\"

'***
'----------------------------------------------
'The following 2 lines of VB code are for testing
'assembler bin files

'Load in machine code from bin file

'InFile$ = PathSpec$ & "HBL.bin"
'Loadmcode (InFile$)

'NB when the machine code is working properly
'and the code saved in a res file (as in this prog)
'and the code for extracting the bin data from
'the resource is done,
'comment out the 2 lines of code above.  This
'must be done for the EXE file to be independent
'of the associated bin file.
'----------------------------------------------

'----------------------------------------------
'When assembler is working properly this is the
'code for extracting the bin file from resource
'This needs to be commented out during testing.
Dim resbytes() As Byte
resbytes = LoadResData(101, "CUSTOM")
Open "~RRTemp.tmp" For Binary As #1
Put #1, , resbytes
Close #1
InFile$ = "~RRTemp.tmp"
Loadmcode (InFile$)
Kill "~RRTemp.tmp"
'----------------------------------------------

'Get pointer to machine code
lpMCode = VarPtr(InCode(1))

End Sub

Private Sub Text1_Change(Index As Integer)
'0 Hex, 1 Dec, 2 Bin
Select Case Index
Case 0   'Hex
   If T0SW = False Then Exit Sub
   Hex2Long2Bin
Case 1   'Long integer
   If T1SW = False Then Exit Sub
   Long2Bin2Hex
Case 2   'Bin
   If T2SW = False Then Exit Sub
   Bin2Hex2Long
End Select
End Sub

Private Sub Text1_KeyPress(Index As Integer, KeyAscii As Integer)
Select Case Index
Case 0   'Hex
   'Capitalize lower case letters
   If (KeyAscii >= 97 And KeyAscii <= 102) Then KeyAscii = KeyAscii - 32
   'Take numbers 0-9 letters A-F & Backspace & Del
   If (KeyAscii >= 48 And KeyAscii <= 57) Or _
   (KeyAscii >= 65 And KeyAscii <= 70) Or _
   KeyAscii = 8 Or KeyAscii = 46 Then
   Else: KeyAscii = 0
   End If
   T0SW = True
   T1SW = False
   T2SW = False
Case 1   'Long
   'Take numbers 0-9 & Backspace
   If (KeyAscii >= 48 And KeyAscii <= 57) Or KeyAscii = 8 Then
   Else: KeyAscii = 0
   End If
   T0SW = False
   T1SW = True
   T2SW = False
Case 2   'Bin
   'Take numbers 0-1 & Backspace
   If (KeyAscii >= 48 And KeyAscii <= 49) Or KeyAscii = 8 Then
   Else: KeyAscii = 0
   End If
   T0SW = False
   T1SW = False
   T2SW = True
End Select
End Sub

Private Sub Hex2Long2Bin()

a$ = Text1(0).Text

'Check if any input
If a$ = "" Then
   Text1(1).Text = a$
   Text1(2).Text = a$
   Exit Sub
End If
'"0" to HexBytes()
For i = 1 To 8
   HexBytes(i) = 48
Next i

'Fill HexBytes()
For i = 1 To Len(a$)
   HexBytes(i) = Asc(Mid$(a$, Len(a$) - i + 1, 1))
Next i

'Execute machine code
res = CallWindowProc(lpMCode, InpLong, lpHex, lpBin, 1&)

'Long result
resdbl = CLng(res)
'Check if conversion -ve to +ve value needed
If resdbl < 0 Then resdbl = resdbl + 2# * 2147483648#

Text1(1).Text = Trim$(Str$(resdbl))

'Binary result
a$ = ""
zero = True
For i = 32 To 1 Step -1
   If binbytes(i) = 48 And zero = True Then
   Else
      zero = False
      a$ = a$ + Chr$(binbytes(i))
   End If
Next i

Text1(2).Text = a$

End Sub

Private Sub Long2Bin2Hex()

a$ = Text1(1).Text

'Check if any input
If a$ = "" Then
   Text1(0).Text = a$
   Text1(2).Text = a$
   Exit Sub
End If

'Check for Long overflow
resdbl = Val(Text1(1).Text)
If resdbl > 4294967295# Then
   Text1(1).Text = "Too big"
   Exit Sub
End If
If resdbl > 2147483647 Then
   resdbl = resdbl - 2# * 2147483648#
End If

InpLong = CLng(resdbl)

'Put "0" in byte arrays
For i = 1 To 8
   HexBytes(i) = 48
Next i
For i = 1 To 32
   binbytes(i) = 48
Next i

'Execute machine code
res = CallWindowProc(lpMCode, InpLong, lpHex, lpBin, 2&)

'Hex result
a$ = ""
zero = True
For i = 8 To 1 Step -1
   If HexBytes(i) = 48 And zero = True Then
   Else
      zero = False
      a$ = a$ + Chr$(HexBytes(i))
   End If
Next i

Text1(0).Text = a$

'Binary result
a$ = ""
zero = True
For i = 32 To 1 Step -1
   If binbytes(i) = 48 And zero = True Then
   Else
      zero = False
      a$ = a$ + Chr$(binbytes(i))
   End If
Next i

Text1(2).Text = a$

End Sub

Private Sub Bin2Hex2Long()

a$ = Text1(2).Text

'Check if any input
If a$ = "" Then
   Text1(0).Text = a$
   Text1(1).Text = a$
   Exit Sub
End If

'Put "0" in byte arrays
For i = 1 To 8
   HexBytes(i) = 48
Next i
For i = 1 To 32
   binbytes(i) = 48
Next i

'Fill BinBytes()
For i = 1 To Len(a$)
   binbytes(i) = Asc(Mid$(a$, Len(a$) - i + 1, 1))
Next i

'Execute machine code
res = CallWindowProc(lpMCode, InpLong, lpHex, lpBin, 4&)

'Long result
resdbl = CLng(res)
'Check if conversion -ve to +ve value needed
If resdbl < 0 Then resdbl = resdbl + 2# * 2147483648#

Text1(1).Text = Trim$(Str$(resdbl))

'Hex result
a$ = ""
zero = True
For i = 8 To 1 Step -1
   If HexBytes(i) = 48 And zero = True Then
   Else
      zero = False
      a$ = a$ + Chr$(HexBytes(i))
   End If
Next i

Text1(0).Text = a$

End Sub

Private Sub Form_Resize()
Height = 2200
Width = 3330
Top = 2000
Left = 2000
Caption = "RR HLB Converter"
For i = 0 To 2
   Text1(i).Text = ""
Next i

CurrentY = Text1(2).Top + Text1(2).Height - 2
For i = 0 To 8
   CurrentX = Text1(2).Left + 5 + i * 4 * TextWidth("0")
   Print "|";
Next i
End Sub
Private Sub Loadmcode(InFile$)
Open InFile$ For Binary As #1
MCSize& = LOF(1)
If MCSize& = 0 Then
   MsgBox (InFile$ & " missing")
   End
End If
ReDim InCode(MCSize&)
Get #1, , InCode
Close #1
End Sub

