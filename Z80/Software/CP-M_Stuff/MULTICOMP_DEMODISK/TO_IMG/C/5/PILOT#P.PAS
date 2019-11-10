			PROGRAM PILOT_P;

{
PROGRAM NAME:		PILOT/P

SUMMARY:
	See the file PILOT/P.DOC for further information.  The file
	PILOT/P.REF is the Quick Reference Guide.

MODIFICATION RECORD:
  02/26/84 --   Version 2.5 (rep)
		-Modified the procedure match() to use a linked list for the
		 argument string parsing.
		-Modified the labels table to use a linked list thereby
		 removing the restriction of 20 labels.
  02/03/84 --   Version 2.4 (rep)
		-Added new control instructions:
			L:		link to another program.
			W:x		wait a specified time in seconds.
		-Modified the delimiter to the "!" mark for the Match
		 statement.
			M:Yes!No!yes!no
  02/01/84 --   Version 2.3 (rep)
		-Still having problems with procedure T() so, I wrote my own.
  01/22/84 --   Version 2.2 (rep)
		-Restored LABELS to original PILOT syntax:
			*START
			.....
			JN:*START
		-Subroutines (procedures) begin with the symbol '%:'
		 and end with the proper PILOT symbol 'E:'.
		-Rewrote the procedure match() for the correct
		 PILOT syntax.
  01/11/84 --   Version 2.1 (rep)
		-Restored variables to original PILOT syntax:
			#n == integer variable.
			$n == string variable.
		-Restored Y,N syntax to original PILOT syntax:
			TY: text
			AY: #x
			CN: #x:=#x+1
  01/06/84  --  Version 2.0 by Raymond E. Penley (rep)
		-Converted to Pascal/Z.
		-Moved the Pascal declarations to the file PILOT/P.HDR.
		 This allows easy modifications with any text editor.
		-Rewrote the program so it would work without reading
		 past end of file and bombing out.
		-Rewrote the procedures scan(); translate(); and T();
		-All string utilities from the Pascal/Z Users Group
		 Library ASL.REL.
  06/??/80  --   Version 1.0 by David Mundie
				104B OAKHURST CIR
				CHARLOTTESVILLE, VA. 22903
		 As published in the July 1980 issue of BYTE.

PROGRAMMERS NOTES:
To reconstruct PILOT/P.PAS after any additions/changes. Rename the program
to PILOT.PAS (Pascal/Z doesn't understand the /), then execute the batch
file COMPILE.SUB.

	A>DO COMPILE PILOT B ASL/S ILIB/S

Place the program PILOT.PAS ON DRIVE 'B' and these files on drive 'A':
DO.COM, COMPILE.SUB, PRIMS.PZ, ASL.REL, ILIB.REL, LIB.REL, PASCAL.COM, PAS254,
MAIN.SRC, LINK.COM, ASMBL.COM
}
{-------------- Pascal/Z compiler options -----------------}
{$C-}{..........control-c checking OFF			   }
{$R-}{..........range checking OFF			   }
{$S-}{..........stack overflow error checking OFF	   }
{$F-}{..........floating point error checking OFF	   }
{$M-}{..........integer mult & divd error checking OFF	   }
{----------------------------------------------------------}

TYPE 
  strng	    = STRING 80;	{ the length of a "default" string }
  byte	    = 0..255;		{ single byte integer		 }
  string0   = STRING 0;		{ special string for Pascal/Z	 }
  string255 = STRING 255;	{ maximum length for a string	 }

  lblptr    = ^labelrec;
  labelrec  = RECORD		{ The data structure of the label list }
     name   : strng;		{ THE LABEL'S NAME }
     posn   : integer;		{ POSITION OF LABEL IN TREE }
     left,			{ We use a binary tree for faster access }
     right  : lblptr
  end;

  mode =(init,			{ initial stage of production	}
	 term,			{ terminator			}
	 prgm,			{ program mode			}
	 proc,			{ procedure mode		}
	 unk);			{ null mode; no activity	}

  sym =(progsym,
	remsym,			{REMARK		}
	typsym,			{TYPE		}
	mtchsym,		{MATCH		}
	jmpsym,			{JUMP		}
	exitsym,
	procsym,		{PROCEDURE	}
	termsym,
	computesym,		{COMPUTE	}
	usesym,			{USE		}
	boolsym,
	asksym,			{ACCEPT		}
	labelsym,
	linksym,		{LINK		}
	waitsym,		{WAIT		}
	null );

VAR
	badsyntax : boolean;		{ flag any bad systax in prgm }
	buffer	  : strng;		{ data line from input file }

	cpos	  : integer;		{ current label's position }
	tree	  : lblptr;		{ the labels tree     }

	state	  : mode;		{ the current state   }
	PrevState : mode;		{ the previous state  }

	symbol	  : sym;		{ the current symbol  }
	PrevSym   : sym;		{ the previous symbol }

	temp	  : strng;		{ temp usage string }
	used_outbuf: boolean;		{ flag if using outbuf }

	fout,				{ Output file }
	fin	  : TEXT;		{ Input file  }

{$iPRIMS.PZ }{Utilities from Pascal/Z Users Group Utility Library disk}


PROCEDURE error( message: strng );
VAR	ch: char;
BEGIN
  WRITELN( buffer );
  WRITELN( 'ERROR: ',message );
  WRITE( 'Type anything to continue' );
  keyin(ch);
  WRITELN;
  badsyntax := true;
END{error};


{ strip -- strips blanks and tabs from buffer at position 'i' }

PROCEDURE strip( i: byte );
BEGIN
  WHILE (buffer[i]=' ') or (buffer[i]=chr(9)) DO delete(buffer,i,1);
END{strip};


PROCEDURE place( VAR tree: lblptr; var key: strng );
BEGIN
  IF tree = NIL THEN BEGIN
    NEW(tree);
    cpos := cpos+1;
    WITH tree^ DO BEGIN
	name	 := key;
	posn	 := cpos;
	left	 := NIL;
	right	 := NIL
    END{WITH}
  END
  ELSE
    WITH tree^ DO
	IF key < name THEN
	  place( left,key )
	ELSE IF key > name THEN
	  place( right,key )
	ELSE
	  error('DUPLICATE LABEL')
END{place};


FUNCTION FIND( VAR tree: lblptr; VAR key: strng ): lblptr;
BEGIN
   if tree=nil then
     find := nil
   else
     WITH tree^ DO
	if key < name then
	  find := find( left,key )
	else if key > name then
	  find := find( right,key )
	else
	  find := tree
END{FIND};


FUNCTION lookup( VAR buffer: strng ): INTEGER;
{ tries to find the label contained in buffer in the labels tree. if not
  found then the label is inserted into the tree. returns the position of
  this label in the tree. }
VAR	node: lblptr;
BEGIN
  ucase( buffer );
  node := find( tree,buffer );
  if node=nil then begin
    place( tree,buffer );
    node := find( tree,buffer );
  end;
  lookup := node^.posn;
END{lookup};


PROCEDURE T( VAR buffer: strng );
{ THIS VERSION WRITTEN BY Raymond E. Penley, Feb 01, 1984 }
{ LAST EDITED: MAR 4, 1984 rep }
{
    THIS INPUT			   PRODUCES THIS OUTPUT
 T:This is a test		writeln('This is a test');
 T:				writeln;
 T:@$a@				writeln($a);
 T:@chr(7)@@chr(27)@		writeln(chr(7),chr(27));

 T:@temp@ is not correct	writeln(temp,' is not correct');
 T: your score is @#s@		writeln(' your score is ',#s);
 T:Your score is @#s:3@ points	writeln('Your score is ',#s:3,' points');
}
LABEL	9;
CONST	delim = '@';
	apos = '''';
TYPE	link = ^object;
	object = record		{ the data structure of the parse list }
		  TXT : STRNG;	
		  TYP : BOOLEAN;
		  next: link 
		end;
VAR	empty,			{ flag for empty queue }
	switch	: BOOLEAN;	{ toggle switch for string vs variable }
	c	: CHAR;
	argv	: link;		{ one component of the queue }
	front,			{ front of the queue }
	rear	: link;		{ rear component of queue }
	I	: INTEGER;
	width	: INTEGER;


	{ getc - returns one character from the input buffer }
	PROCEDURE getc( var c: char );
	BEGIN
	  IF I<vlength(buffer) THEN begin
	    I:=I+1;
	    c:=buffer[I];
	    { QUALIFY CHARACTER READ IN }
	    IF c=delim THEN SWITCH:=NOT SWITCH;
	    end
	  ELSE c:=delim;
	END{getc};

	{ retrieve - removes the first component from the queue and sets
	  the pointer 'first' pointing to it. Special action is taken when
	  the last component of the queue is removed and the queue becomes
	  empty. }

	PROCEDURE retrieve( var first,front,rear: link );
	BEGIN
	  first := front;
	  if front<>NIL then begin
	    front := front^.next;
	    if front=NIL then rear := NIL;
	  end;
	END{retrieve};

	{ enqueue - places a new component at the rear of the queue. 'Arrival'
	  is a pointer to the new component provided by the caller of the
	  program. Special action is taken when the queue becomes empty. }

	PROCEDURE enqueue( arrival: link; var front,rear: link );
	BEGIN
	  if front=NIL
	     then front := arrival
	     else rear^.next := arrival;
	  rear := arrival;
	END{enqueue};

BEGIN{PROCEDURE T}
  WRITE( fout,'WRITE' );
  IF vlength(buffer)=0 THEN BEGIN
     WRITELN( fout,'LN;' );
     GOTO 9;
  END;
  IF buffer[vlength(buffer)]=';'
     THEN delete( buffer,vlength(buffer),1 )
     ELSE write ( fout,'LN' );
  IF vlength(buffer)=0 THEN BEGIN
     WRITELN( fout,';' );
     GOTO 9;
  END;

  front := NIL;		{ initialize queue pointers }
  rear := NIL;

  I := 0;
  SWITCH := FALSE;
  WHILE I<vlength(buffer) do begin
	new(argv);			{ create a new component }
	argv^.next := NIL;		{ initialize link }
	setlength(argv^.txt,0);		{ txt := '';      }
	getc(c);
	IF c=delim THEN getc(c);
	WHILE c<>delim do begin
	   append(argv^.txt,c);
	   IF c=apos THEN append(argv^.txt,apos);
	   argv^.typ := SWITCH;
	   getc(c);
	END;
	enqueue( argv,front,rear );
  END;

{ Rebuild the output string from all the arguments }
  setlength( temp,0 );	{ temp := ''; }
  empty := false;
  while not empty do begin
	retrieve( argv,front,rear );
	if argv<>nil then begin
	      CASE argv^.typ OF
		TRUE:  append(temp,argv^.txt);
		FALSE: BEGIN
			 append(temp,apos);
			 append(temp,argv^.txt);
			 append(temp,apos);
		       END
	      END{CASE};
	end;
	empty := (front=nil) and (rear=nil);
	if not empty then append(temp,',');
  end;

  if {we} used_outbuf then width := 51 else width := 68;
  if vlength(temp) > width
     then writeln( fout,'(' )
     else write( fout,'(' );
  writeln( fout,temp,');' );
9:
END{T};


PROCEDURE Execute( symbol: sym );
{LAST EDITED: 02/26/84 Ray Penley}
VAR	i:INTEGER;
BEGIN
  CASE symbol of
   labelsym,jmpsym,asksym,linksym,waitsym:
        strip{buffer}(1); { purge any blanks/tabs }
  end{case};
  CASE symbol of
    progsym: { Begin main program symbol. internal program symbol }
	WRITELN( fout,'BEGIN initialize;' );

    remsym: { Remark symbol }
	{	R: This is a remark		}
	WRITELN( fout,'{',buffer,'}' );

    typsym: { Type symbol }
	{	T: text string				   }
	{	TY: text @$a@ text	-- type a variable }
	T( buffer );

    mtchsym: { Match symbol }
        {	M:@$a@		<<< string variable	}
	{	M:a!e!i!o!u	<<< text string		}
	IF buffer[1]='@' THEN BEGIN { match a variable }
	  copy( temp,buffer,2,2 );{ extract 2 characters from variable }
	  WRITELN( fout,'match(', temp, ',''!'',ans,flag);' );
	  END
	ELSE BEGIN{ match a text string }
	  IF vlength(buffer)>55
	    then writeln( fout,'match(' )
	    else write  ( fout,'match(' );
	  WRITELN( fout,'''', buffer, ''',''!'',ans,flag);' ); 
	END;

    jmpsym,labelsym: { Jump, label symbols } 
	{	*START		<LABEL		}
	{	J:*START	<JUMP		}	
	BEGIN
	  IF buffer[1]<>'*' THEN
	    error('Improperly formed label')
	  ELSE BEGIN
	    i := lookup( buffer );	
	    CASE symbol of
	      jmpsym  : WRITELN( fout,'GOTO ',i:1,';' );
	      labelsym: WRITELN( fout,i:1,':' )
	    END{case};
	    END;
	END;

    exitsym: { Exit from Program/Procedure. internal program symbol }
	WRITELN( fout,'GOTO 0;' );

    procsym: { Commence a Procedure/Function }
	{	%: getchoice(var #c:integer)		<<< procedure starts }
	{	R: accepts a number and checks its value	}
	{	C: REPEAT writeln				}
	{	T: What is your choice(1 to 10)?;		}
	{	A: #c						}
	{	X: #c in [1..10]				}
	{	TN: @#c:4@@chr(7)@ is out of range		}
	{	C: UNTIL flag					}
	{	E:					<<< procedure ends }
	BEGIN
	  WRITELN( fout,'PROCEDURE ',buffer,';' );
	  WRITE  ( fout,'LABEL 0,1,2,3,4,5,6,7,8,9,10,11,' );
	  WRITELN( fout,'12,13,14,15,16,17,18,19,20;' );
	  WRITELN( fout,'BEGIN' );
	END;

    termsym: { Procedure terminator }
	WRITELN( fout, '0:END;' );

    usesym,     { USE/CALL a subroutine. 		}
    computesym: { Compute.				}
	{ Terminates statement with a ';'		}
	{	C:#x:=#x+1				}	
	{	C:FOR #i:=1 to 100 DO writeln(#i:5)	}
	{	U: TEST(a,b,c)				} 	
	WRITELN( fout,buffer,';' );

    linksym:	{ Link/chain symbol			}
	{ LINKS/CHAINS TO ANOTHER PROGRAM.		}
	{	L:LESSON1				}
	BEGIN
	  IF vlength(buffer)>8 then
	    error('INVALID PROGRAM NAME FOR LINK.')
	  ELSE BEGIN
	    { output -> FTXTIN('FILE.COM');CHAIN;   }	
	    append(buffer,'.COM');
	    WRITELN( fout,'FTXTIN(''',buffer,''');CHAIN;' );
	  END;
	END;

    waitsym: { Wait sumbol				}
	{ PAUSES THE SPECIFIED AMOUNT OF TIME OR UNTIL	}
	{ A KEY IS PRESSED ON THE KEYBOARD.		}
	{	W:5 ! W:#x				}
	WRITELN( fout, 'WAIT(',buffer,',ch);' );


    boolsym: { ANY legal Pascal boolean expression }
	{	X: i < length(ans)		}
	{	X: ans='HOUSE'			}
	{	C:$s := 'SUNDAY MONDAY TUESDAY' }
	{	X: index($s,'DAY')<>0		}
	WRITELN( fout,'flag:=',buffer,';' );

    asksym: { Ask symbol }					{01/11/84 rep}
	{	A:$s				}
  	{	A:#x				}
	CASE vlength(buffer) OF
	 2: begin
	    if (buffer[1] IN ['#','$']) and
		(buffer[2] IN ['A'..'Z','a'..'z']) THEN
		  WRITELN( fout,'READLN(',buffer[1],buffer[2],');' )
	    else
		CASE buffer[1] of
		  '#': error('Integer variable expected');
		  '$': error('String variable expected');
		 else: error('Improperly formed ask statement');
		end{case};
	    end;
	 else: WRITELN( fout,'READLN(ans);' );
	END{CASE vlength(buffer) OF};
  END{CASE symbol OF};
END{Execute};


PROCEDURE Translate;
{LAST EDITED: 02/26/84 Ray Penley }
LABEL	1;
VAR	outbuf	  : strng;		{ line output buffer  }


PROCEDURE Parse( VAR buffer: strng; VAR symbol: sym );
{LAST EDITED: 02/03/84 Ray Penley}
VAR	ch: char;

	{ tosym -- returns enumerated type sym }
	function tosym( ch: char ): sym;
	begin
	  case toupper(ch) of
	   'R': tosym := remsym;
	   'T': tosym := typsym;
	   'M': tosym := mtchsym;
	   'J': tosym := jmpsym;
	   'E': tosym := exitsym;
	   '%': tosym := procsym;
	   'C': tosym := computesym;
	   'U': tosym := usesym;
	   'X': tosym := boolsym;
	   'A': tosym := asksym;
	   'L': tosym := linksym;
	   'W': tosym := waitsym;
	   '*': tosym := labelsym;
	   else: tosym := null;
	  end{case};
	end{tosym};

BEGIN{Parse}
{    Parse a typical PILOT instruction that looks like:

	    <name><conditional><:><object>
}
  setlength(outbuf,0);	{ outbuf := ''; }
  strip{buffer}(1);	{ strip leading blanks and tabs }

  {if the first character position is a ':' then force the TYPE symbol}
  if buffer[1]=':' then insert( 'T',buffer,1 );

  { extract the operation code from the input line }
  symbol := tosym(buffer[1]);
  if NOT ((symbol=null) or (symbol=labelsym)) then delete( buffer,1,1 );
  strip{buffer}(1);

	{ Scan for conditional in input line: }
	{   TY: text | AY: #x |  CN: #x:=#x+1 }
  ch := toupper(buffer[1]);
  IF ch IN ['Y','N'] THEN BEGIN
     case ch of
	'Y': append(outbuf,'if flag then ');
        'N': append(outbuf,'if not flag then ');
     end{case};
     delete(buffer,1,1);	{ strip conditional from input line }
     strip{buffer}(1);		{ and clean up spaces/tabs }
  END{IF ch IN};

  { input buffer should now contain only the object or a label }
  if symbol<>labelsym then
     delete( buffer,1,index(buffer,':') );
END{Parse};


BEGIN {translate}
  tree       := NIL;	{ empty tree }
  cpos       := 0;	{ label's position in tree }
  badsyntax  := false;
  WRITELN( fout,'PROGRAM ',buffer,';' );
  WRITELN( fout,'{$iPILOT/P.HDR }' );
  WRITELN( 'Translating: ', buffer );

  PrevSym := termsym;	{ set up sym as end of procedure }
  PrevState := init;	{ set up state as initialize }
  State := init;
  WHILE NOT EOF(fin) DO BEGIN
    readln( fin,buffer );
    if vlength(buffer)=0 then goto 1;
    Parse( buffer,symbol );
    IF symbol<>null then BEGIN
	{Determine our new state.}
	Case PrevState of

	  init: { initial commencement of translation }
		if symbol=procsym then { entering a procedure }
		   state := proc
		else if symbol<>remsym then begin
		   state := prgm;{ not a remark, so begin program}
		   Execute(progsym);
		   end;

	  proc: { translating a procedure }
		if symbol=exitsym then begin
		   state := term;
		   symbol := termsym;{ terminate procedure }
		   end;

	  term: { end symbol when translating a procedure }
		if symbol=procsym then { we can have procedures }
		   state := proc       { following procedures   }
		else begin
		   state := prgm;
		   Execute(progsym);
		   end;

	  prgm: { now translating the program proper }
		if symbol=procsym then
		   error('Can''t do procedure now.');

	end{Case PrevState of};

	used_outbuf := (vlength(outbuf)>0);
	if used_outbuf then write(fout,outbuf);
	Execute( symbol );
	PrevState := state; { remember our present state }
	PrevSym := symbol;  { for next go around. }
	end
    else begin{ symbol is not valid }
	error('Illegal Command' );
	Execute(remsym);
	end;
1:END{while};

  {state := EndProgram;}
  WRITELN( fout,'0:END.' );
  IF badsyntax THEN
    WRITELN( 'Errors in PILOT program, Pascal program is invalid!' );
END{translate};


PROCEDURE ConnectFiles;
{ Written by Raymond E. Penley }
CONST	INPUT = 0;	{ required for Pascal/Z compiler }
VAR	ix, jx: 0..255;
	name,
	fileid: strng;
BEGIN
  IF eoln(INPUT) THEN
    WRITE('Translate what file? ');
  READLN( fileid );

  {OPEN file 'NAME.PLT' for READ assign fin}
  name := fileid; append(name,'.PLT');
  RESET( name,fin );
  IF eof(fin) THEN BEGIN
     WRITE(CHR(7),'PROGRAM TERMINATED, FILE ', name ); HALT( ' NOT FOUND.');
     END;
  writeln('READING FROM ',name);

  {OPEN file 'NAME.PAS' for WRITE assign fout}
  name := fileid; append(name,'.PAS');
  REWRITE( name,fout );
  writeln('WRITING TO   ',name);
  { attempt to copy just the file's name without drive unit or extension }
  jx := index(fileid,':'); { see if drive unit specified }
  ix := index(fileid,'.'); { see if file name extension specified }
  IF ( ix=0 )
    THEN { no extension, so }
      ix := vlength(fileid)
    ELSE
      ix := ix-1;
  IF ( jx>0 )
    THEN { a drive unit specified }
      jx := jx+1
    ELSE
      jx := 1;
  copy( name,fileid,jx,(ix-jx)+1 );
  name[1] := toupper(name[1]);
  buffer := name;{ transfer parsed file name to main program }
END{ConnectFiles};


BEGIN{ Main Program PILOT/P }
  writeln('PILOT/P version 2.5, 02/26/84');
  ConnectFiles;
  Translate;
END. {PILOT/P}
