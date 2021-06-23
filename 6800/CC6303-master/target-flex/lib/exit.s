;
;	We don't implement atexit and friends yet.
;
		.export _exit
		.export __exit
		.code
_exit;
__exit:
		jmp $AD03

