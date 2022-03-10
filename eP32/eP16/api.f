
( import commonly used window api )

LoadLibrary kernel32.dll CONSTANT kernel32
LoadLibrary   user32.dll CONSTANT user32
LoadLibrary    gdi32.dll CONSTANT gdi32

0 kernel32 WINAPI: GetLastError

(hinst) @ CONSTANT HINST
 (hwnd) @ CONSTANT HWND
$C user32   WINAPI: CreateWindowExA
$4 user32   WINAPI: MessageBoxA
 1 user32   WINAPI: UpdateWindow
 1 user32   WINAPI: ShowWindow
 4 user32   WINAPI: SendMessageA
 4 user32   WINAPI: DefWindowProcA
 1 user32   WINAPI: RegisterClassExA
 2 user32   WINAPI: LoadIconA
 2 user32   WINAPI: LoadCursorA
 3 user32   WINAPI: GetClassInfoExA
( lpfnWndProc hwnd uMsg wparam lparam -- res )
 5 user32   WINAPI: CallWindowProcA
 1 user32   WINAPI: DestroyWindow
 7 kernel32 WINAPI: CreateFileA
 1 kernel32 WINAPI: CloseHandle
 5 kernel32 WINAPI: WriteFile
 5 kernel32 WINAPI: ReadFile
 0 kernel32 WINAPI: GetTickCount