( windows UI
  2002.4.02   high level WindowProc ok
)  
5 CONSTANT #MESSAGEHANDLER
3 user32 WINAPI: SetWindowLongA
7 user32 WINAPI: SetWindowPos
2 user32 WINAPI: GetWindowLongA
$-15 CONSTANT GWL_USERDATA

: MESSAGEHANDLER: ( cfa -name- )
  4 SWAP CALLBACK: 
;

VARIABLE hWnd VARIABLE uMsg VARIABLE wParam VARIABLE lParam

\ create variable for window parameters

: !WNDMSGHANDLER ( hWnd uMsg pos cfa -- )  \ set a new message handler at pos
;

: @WNDMSGHANDLER  ( hWnd uMsg -- cfa )     \ find message handler by uMsg
  uMsg ! hWnd !
  #MESSAGEHANDLER
  FOR AFT
    hWnd @ R@ 2* CELLS GetWindowLongA uMsg @ = 
    IF                                  \ found a handler 
      hWnd @ R@ 2* CELLS CELL+ GetWindowLongA
      EXIT
    THEN
  THEN NEXT
  hWnd @ GWL_USERDATA GetWindowLongA       \ default handler stored in GWL_USERDATA
;

: INSTALLHANDLER ( hWnd newhandler -- ) \ install handler mechinism to a window
  OVER SWAP $-4 SWAP        ( hWnd hWnd -4 newhandler )
  SetWindowLongA            ( hWnd OldProc )
  GWL_USERDATA SWAP SetWindowLongA   \ Set oldwinproc to User data
  DROP
;


: GETMSGPARA  ( hWnd uMsg wParam lParam -- ) 
  lParam ! wParam ! uMsg ! hWnd !
;

1 CONSTANT BUTTONID 
: (wndproc) ( hwnd uMsg wparam lparam -- res )
  GETMSGPARA

  uMsg @ $111 =   \ WM_COMMAND
  IF
    lParam @ 0 = 
    IF                               \ Menu 

    ELSE
        wParam @ DUP BUTTONID = 
        IF
           $10 RSHIFT 0 =            \ BN_CLICKED 
           IF
              HWND Z" hello " Z" click" 1 MessageBoxA DROP
           THEN
        THEN
    THEN
  ELSE 
    hWnd @ uMsg @ wParam @ lParam @ DefWindowProcA  
  THEN

;  

' (wndproc) MESSAGEHANDLER: &wndproc

: FORMCLASSNAME Z" WFForm1" ;

&WINAPI DefWindowProcA CONSTANT &DefWindowProcA
0 $7F00 LoadIconA CONSTANT icon
0 $7F00 LoadCursorA CONSTANT cursor
CREATE FORMCLASS 
       $30 ,                        \ cbSizex
       $3 ,                         \ style = CS_HREDRAW + CS_VREDRAW
       &DefWindowProcA ,
       0 ,                          \ cbClsExtra
       #MESSAGEHANDLER 8 * ,        \ cbWndExtra  win98 maximum = 40 extra byte
       HINST ,                      \ hInstance
       icon ,
       cursor ,
       $6 ,                         \ hbrBackground COLOR_WINDOW+1
       0 ,                          \ lpszMenuName
       FORMCLASSNAME ,
       0 ,

FORMCLASSNAME FORMCLASS $28 + !
&wndproc FORMCLASS $8 + !

FORMCLASS RegisterClassExA DROP

: N
  0 
  Z" WFForm1" 
  Z" App1" 
  $10C80000          
  10 10 150 150
  0
  0
  HINST
  0
  CreateWindowExA DUP ." hwnd=" . CR
;


: NEWBUTTON ( hwnd  caption id -- hbutton )
  >R >R hWnd !
  0
  Z" button"
  R>               \ caption
  $50000001 
  1 1 30 30
  hWnd @           \ parent
  R>               \ button id
  HINST
  0
  CreateWindowExA 
;

VARIABLE win1
VARIABLE button1

: CALLORIHANDLER ( hWnd uMsg wParam lParam -- res )
  GETMSGPARA
  hWnd @ uMsg @ wParam @ lParam @
  hWnd @ GWL_USERDATA GetWindowLongA  \ addr
  4 SWAP 
  CALLWIN
;

: childhandler ( hWnd uMsg wParam lParam -- res )
  GETMSGPARA
  uMsg @ $84 = IF      \ WM_NCHITTEST
    $1 wParam !           \ HTCAPTION
    ." hit"
  THEN
  hWnd @ uMsg @ wParam @ lParam CALLORIHANDLER
;

' childhandler MESSAGEHANDLER: &CHILDHANDLER
: test N win1 ! 
       win1 @  Z" Click Me"  BUTTONID NEWBUTTON button1 !
       button1 @ &CHILDHANDLER INSTALLHANDLER
 ;
