( WeForth Windows interface
LoadLibrary load a DLL into program space.
GetProcessAddress return function address by name.

doWINAPI move parameters from datastack to return stack
         then call the windows API, after API return,
         TOS is replaced by eax.
         
doCALLBACK move parameters from return stack to private datastack,
          then call forth word, after forth return , 
          doCALLBACK move TOS to eax and return control to windows. 
          please note that ebp is adjusted by windows in callback function, 
          don't expect DEPTH and other data stack word to work properly.

WINAPI: define a interface to windows API,
        it take the number of parameter and import library of the function,
        a word has exactly same name with API will be created.

CALLBACK: define a constant which will return a valid entry point
          for windows to call. )
  


: WINAPI:  ( #para dll -funcname- )
  BL WORD DUP >R DUP $,n      \ #para dll counted_funcstr 
  COUNT DROP                  \ #para dll zfuncstr
  GetProcAddress ?DUP IF      \ #para  procaddr
     ['] doWINAPI call,       \ the api wrapper
      , ,                     \ procaddr ,  #para
     RET, OVERT               \ compile RET and add to voc
     R> DROP
  ELSE                        \ #para
     DROP
     ."  Import Error:"
     R> THROW
  THEN
; 

: CALLBACK:  ( #para cfa -cbfuncname- )
  CREATE  
    ['] doCALLBACK call,      \ callback wrapper
    , ,                       \ cfa #para
  DOES> R>                    \ return entry-point at runtime
;
  
: &WINAPI    ( -name- addr )
  ' CELL+ 1+ @
;

: *CALLBACK  ( addr -- cfa )
  CELL+ 1+ @
;
