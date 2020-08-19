@LIBC
*mkdir obj
asm68 -lQ src\abs.s -o obj\abs.o
*del obj\*.o
com%s %c -Q src\_memset.c src\_memset.s
asm68 %a -lQ src\_memset.s -o obj\_memset.o
*del src\_memset.s
com%s %c -Q src\_tolower.c src\_tolower.s
asm68 %a -lQ src\_tolower.s -o obj\_tolower.o
*del src\_tolower.s
com%s %c -Q src\_toupper.c src\_toupper.s
asm68 %a -lQ src\_toupper.s -o obj\_toupper.o
*del src\_toupper.s
com%s %c -Q src\abort.c src\abort.s
asm68 %a -lQ src\abort.s -o obj\abort.o
*del src\abort.s
com%s %c -Q src\atoi.c src\atoi.s
asm68 %a -lQ src\atoi.s -o obj\atoi.o
*del src\atoi.s
com%s %c -Q src\atol.c src\atol.s
asm68 %a -lQ src\atol.s -o obj\atol.o
*del src\atol.s
com%s %c -Q src\bsearch.c src\bsearch.s
asm68 %a -lQ src\bsearch.s -o obj\bsearch.o
*del src\bsearch.s
com%s %c -Q src\clearerr.c src\clearerr.s
asm68 %a -lQ src\clearerr.s -o obj\clearerr.o
*del src\clearerr.s
com%s %c -Q src\ctypetab.c src\ctypetab.s
asm68 %a -lQ src\ctypetab.s -o obj\ctypetab.o
*del src\ctypetab.s
com%s %c -Q src\env.c src\env.s
asm68 %a -lQ src\env.s -o obj\env.o
*del src\env.s
com%s %c -Q src\errno.c src\errno.s
asm68 %a -lQ src\errno.s -o obj\errno.o
*del src\errno.s
com%s %c -Q src\exit.c src\exit.s
asm68 %a -lQ src\exit.s -o obj\exit.o
*del src\exit.s
com%s %c -Q src\fclose.c src\fclose.s
asm68 %a -lQ src\fclose.s -o obj\fclose.o
*del src\fclose.s
com%s %c -Q src\feof.c src\feof.s
asm68 %a -lQ src\feof.s -o obj\feof.o
*del src\feof.s
com%s %c -Q src\ferror.c src\ferror.s
asm68 %a -lQ src\ferror.s -o obj\ferror.o
*del src\ferror.s
com%s %c -Q src\fflush.c src\fflush.s
asm68 %a -lQ src\fflush.s -o obj\fflush.o
*del src\fflush.s
com%s %c -Q src\fgetc.c src\fgetc.s
asm68 %a -lQ src\fgetc.s -o obj\fgetc.o
*del src\fgetc.s
com%s %c -Q src\fgetpos.c src\fgetpos.s
asm68 %a -lQ src\fgetpos.s -o obj\fgetpos.o
*del src\fgetpos.s
com%s %c -Q src\fgets.c src\fgets.s
asm68 %a -lQ src\fgets.s -o obj\fgets.o
*del src\fgets.s
com%s %c -Q src\fileno.c src\fileno.s
asm68 %a -lQ src\fileno.s -o obj\fileno.o
*del src\fileno.s
com%s %c -Q src\fillbuf.c src\fillbuf.s
asm68 %a -lQ src\fillbuf.s -o obj\fillbuf.o
*del src\fillbuf.s
com%s %c -Q src\fltstdmy.c src\fltstdmy.s
asm68 %a -lQ src\fltstdmy.s -o obj\fltstdmy.o
*del src\fltstdmy.s
com%s %c -Q src\flushbuf.c src\flushbuf.s
asm68 %a -lQ src\flushbuf.s -o obj\flushbuf.o
*del src\flushbuf.s
com%s %c -Q src\fopen.c src\fopen.s
asm68 %a -lQ src\fopen.s -o obj\fopen.o
*del src\fopen.s
com%s %c -Q src\fputc.c src\fputc.s
asm68 %a -lQ src\fputc.s -o obj\fputc.o
*del src\fputc.s
com%s %c -Q src\fputs.c src\fputs.s
asm68 %a -lQ src\fputs.s -o obj\fputs.o
*del src\fputs.s
com%s %c -Q src\eputs.c src\eputs.s
asm68 %a -lQ src\eputs.s -o obj\eputs.o
*del src\eputs.s
com%s %c -Q src\fread.c src\fread.s
asm68 %a -lQ src\fread.s -o obj\fread.o
*del src\fread.s
com%s %c -Q src\freopen.c src\freopen.s
asm68 %a -lQ src\freopen.s -o obj\freopen.o
*del src\freopen.s
com%s %c -Q src\fseek.c src\fseek.s
asm68 %a -lQ src\fseek.s -o obj\fseek.o
*del src\fseek.s
com%s %c -Q src\fsetpos.c src\fsetpos.s
asm68 %a -lQ src\fsetpos.s -o obj\fsetpos.o
*del src\fsetpos.s
com%s %c -Q src\fwrite.c src\fwrite.s
asm68 %a -lQ src\fwrite.s -o obj\fwrite.o
*del src\fwrite.s
com%s %c -Q src\getchar.c src\getchar.s
asm68 %a -lQ src\getchar.s -o obj\getchar.o
*del src\getchar.s
com%s %c -Q src\getenv.c src\getenv.s
asm68 %a -lQ src\getenv.s -o obj\getenv.o
*del src\getenv.s
com%s %c -Q src\gets.c src\gets.s
asm68 %a -lQ src\gets.s -o obj\gets.o
*del src\gets.s
com%s %c -Q src\ioctl.c src\ioctl.s
asm68 %a -lQ src\ioctl.s -o obj\ioctl.o
*del src\ioctl.s
com%s %c -Q src\isalnum.c src\isalnum.s
asm68 %a -lQ src\isalnum.s -o obj\isalnum.o
*del src\isalnum.s
com%s %c -Q src\isalpha.c src\isalpha.s
asm68 %a -lQ src\isalpha.s -o obj\isalpha.o
*del src\isalpha.s
com%s %c -Q src\isascii.c src\isascii.s
asm68 %a -lQ src\isascii.s -o obj\isascii.o
*del src\isascii.s
com%s %c -Q src\iscntrl.c src\iscntrl.s
asm68 %a -lQ src\iscntrl.s -o obj\iscntrl.o
*del src\iscntrl.s
com%s %c -Q src\iscsym.c src\iscsym.s
asm68 %a -lQ src\iscsym.s -o obj\iscsym.o
*del src\iscsym.s
com%s %c -Q src\iscsymf.c src\iscsymf.s
asm68 %a -lQ src\iscsymf.s -o obj\iscsymf.o
*del src\iscsymf.s
com%s %c -Q src\isdigit.c src\isdigit.s
asm68 %a -lQ src\isdigit.s -o obj\isdigit.o
*del src\isdigit.s
com%s %c -Q src\isgraph.c src\isgraph.s
asm68 %a -lQ src\isgraph.s -o obj\isgraph.o
*del src\isgraph.s
com%s %c -Q src\islower.c src\islower.s
asm68 %a -lQ src\islower.s -o obj\islower.o
*del src\islower.s
com%s %c -Q src\isodigit.c src\isodigit.s
asm68 %a -lQ src\isodigit.s -o obj\isodigit.o
*del src\isodigit.s
com%s %c -Q src\isprint.c src\isprint.s
asm68 %a -lQ src\isprint.s -o obj\isprint.o
*del src\isprint.s
com%s %c -Q src\ispunct.c src\ispunct.s
asm68 %a -lQ src\ispunct.s -o obj\ispunct.o
*del src\ispunct.s
com%s %c -Q src\isspace.c src\isspace.s
asm68 %a -lQ src\isspace.s -o obj\isspace.o
*del src\isspace.s
com%s %c -Q src\isupper.c src\isupper.s
asm68 %a -lQ src\isupper.s -o obj\isupper.o
*del src\isupper.s
com%s %c -Q src\isxdigit.c src\isxdigit.s
asm68 %a -lQ src\isxdigit.s -o obj\isxdigit.o
*del src\isxdigit.s
com%s %c -Q src\main.c src\main.s
asm68 %a -lQ src\main.s -o obj\main.o
*del src\main.s
com%s %c -Q src\main_arg.c src\main_arg.s
asm68 %a -lQ src\main_arg.s -o obj\main_arg.o
*del src\main_arg.s
com%s %c -Q src\malloc.c src\malloc.s
asm68 %a -lQ src\malloc.s -o obj\malloc.o
*del src\malloc.s
com%s %c -Q src\memchr.c src\memchr.s
asm68 %a -lQ src\memchr.s -o obj\memchr.o
*del src\memchr.s
com%s %c -Q src\memcmp.c src\memcmp.s
asm68 %a -lQ src\memcmp.s -o obj\memcmp.o
*del src\memcmp.s
com%s %c -Q src\memcpy.c src\memcpy.s
asm68 %a -lQ src\memcpy.s -o obj\memcpy.o
*del src\memcpy.s
com%s %c -Q src\memmove.c src\memmove.s
asm68 %a -lQ src\memmove.s -o obj\memmove.o
*del src\memmove.s
com%s %c -Q src\memset.c src\memset.s
asm68 %a -lQ src\memset.s -o obj\memset.o
*del src\memset.s
com%s %c -Q src\perror.c src\perror.s
asm68 %a -lQ src\perror.s -o obj\perror.o
*del src\perror.s
com%s %c -Q src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printf.o
*del src\printf.s
com%s %c -Q src\putchar.c src\putchar.s
asm68 %a -lQ src\putchar.s -o obj\putchar.o
*del src\putchar.s
com%s %c -Q src\puts.c src\puts.s
asm68 %a -lQ src\puts.s -o obj\puts.o
*del src\puts.s
com%s %c -Q src\qsort.c src\qsort.s
asm68 %a -lQ src\qsort.s -o obj\qsort.o
*del src\qsort.s
com%s %c -Q -Xw2 src\rand.c src\rand.s
asm68 %a -lQ src\rand.s -o obj\rand.o
*del src\rand.s
com%s %c -Q src\sbrk.c src\sbrk.s
asm68 %a -lQ src\sbrk.s -o obj\sbrk.o
*del src\sbrk.s
com%s %c -Q src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanf.o
*del src\scanf.s
com%s %c -Q src\setbuf.c src\setbuf.s
asm68 %a -lQ src\setbuf.s -o obj\setbuf.o
*del src\setbuf.s
com%s %c -Q src\setvbuf.c src\setvbuf.s
asm68 %a -lQ src\setvbuf.s -o obj\setvbuf.o
*del src\setvbuf.s
com%s %c -Q -Of1 src\signal.c src\signal.s
asm68 %a -lQ src\signal.s -o obj\signal.o
*del src\signal.s
com%s %c -Q src\stdio.c src\stdio.s
asm68 %a -lQ src\stdio.s -o obj\stdio.o
*del src\stdio.s
com%s %c -Q src\strcat.c src\strcat.s
asm68 %a -lQ src\strcat.s -o obj\strcat.o
*del src\strcat.s
com%s %c -Q src\strchr.c src\strchr.s
asm68 %a -lQ src\strchr.s -o obj\strchr.o
*del src\strchr.s
com%s %c -Q src\strcmp.c src\strcmp.s
asm68 %a -lQ src\strcmp.s -o obj\strcmp.o
*del src\strcmp.s
com%s %c -Q src\strcpy.c src\strcpy.s
asm68 %a -lQ src\strcpy.s -o obj\strcpy.o
*del src\strcpy.s
com%s %c -Q src\strcspn.c src\strcspn.s
asm68 %a -lQ src\strcspn.s -o obj\strcspn.o
*del src\strcspn.s
com%s %c -Q src\strerror.c src\strerror.s
asm68 %a -lQ src\strerror.s -o obj\strerror.o
*del src\strerror.s
com%s %c -Q src\strlen.c src\strlen.s
asm68 %a -lQ src\strlen.s -o obj\strlen.o
*del src\strlen.s
com%s %c -Q src\strncat.c src\strncat.s
asm68 %a -lQ src\strncat.s -o obj\strncat.o
*del src\strncat.s
com%s %c -Q src\strncmp.c src\strncmp.s
asm68 %a -lQ src\strncmp.s -o obj\strncmp.o
*del src\strncmp.s
com%s %c -Q src\strncpy.c src\strncpy.s
asm68 %a -lQ src\strncpy.s -o obj\strncpy.o
*del src\strncpy.s
com%s %c -Q src\strpbrk.c src\strpbrk.s
asm68 %a -lQ src\strpbrk.s -o obj\strpbrk.o
*del src\strpbrk.s
com%s %c -Q src\strrchr.c src\strrchr.s
asm68 %a -lQ src\strrchr.s -o obj\strrchr.o
*del src\strrchr.s
com%s %c -Q src\strspn.c src\strspn.s
asm68 %a -lQ src\strspn.s -o obj\strspn.o
*del src\strspn.s
com%s %c -Q src\strstr.c src\strstr.s
asm68 %a -lQ src\strstr.s -o obj\strstr.o
*del src\strstr.s
com%s %c -Q src\strtok.c src\strtok.s
asm68 %a -lQ src\strtok.s -o obj\strtok.o
*del src\strtok.s
com%s %c -Q src\strtol.c src\strtol.s
asm68 %a -lQ src\strtol.s -o obj\strtol.o
*del src\strtol.s
com%s %c -Q src\strtoul.c src\strtoul.s
asm68 %a -lQ src\strtoul.s -o obj\strtoul.o
*del src\strtoul.s
com%s %c -Q src\system.c src\system.s
asm68 %a -lQ src\system.s -o obj\system.o
*del src\system.s
com%s %c -Q src\tmpfile.c src\tmpfile.s
asm68 %a -lQ src\tmpfile.s -o obj\tmpfile.o
*del src\tmpfile.s
com%s %c -Q src\toascii.c src\toascii.s
asm68 %a -lQ src\toascii.s -o obj\toascii.o
*del src\toascii.s
com%s %c -Q src\tolower.c src\tolower.s
asm68 %a -lQ src\tolower.s -o obj\tolower.o
*del src\tolower.s
com%s %c -Q src\toupper.c src\toupper.s
asm68 %a -lQ src\toupper.s -o obj\toupper.o
*del src\toupper.s
com%s %c -Q src\ungetc.c src\ungetc.s
asm68 %a -lQ src\ungetc.s -o obj\ungetc.o
*del src\ungetc.s
com%s %c -Q -Of1 src\xcptn.c src\xcptn.s
asm68 %a -lQ src\xcptn.s -o obj\xcptn.o
*del src\xcptn.s
com%s %c -Q -Of1 -DM68010 src\xcptn.c src\xcptn10.s
asm68 %a -lQ src\xcptn10.s -o obj\xcptn10.o
*del src\xcptn10.s
com%s %c -Q -DM68306 src\int306.c src\int306.s
asm68 %a -lQ src\int306.s -o obj\int306.o
*del src\int306.s
com%s %c -Q -DM68306 src\uart306.c src\uart306.s
asm68 %a -lQ src\uart306.s -o obj\uart306.o
*del src\uart306.s
asm68 %a -lQ -dM68306 src\int306a.s -o obj\int306a.o
asm68 %a -lQ src\uart306a.s -o obj\uart306a.o
asm68 %a -lQ src\timer306.s -o obj\timer306.o
asm68 %a -lQ src\abs.s -o obj\abs.o
asm68 %a -lQ src\div.s -o obj\div.o
asm68 %a -lQ src\div16.s -o obj\div16.o
asm68 %a -lQ src\div32.s -o obj\div32.o
asm68 %a -lQ src\ftrapdmy.s -o obj\ftrapdmy.o
asm68 %a -lQ src\labs.s -o obj\labs.o
asm68 %a -lQ src\ldiv.s -o obj\ldiv.o
asm68 %a -lQ src\ldtraps.s -o obj\ldtraps.o
asm68 %a -lQ src\seterrno.s -o obj\seterrno.o
asm68 %a -lQ -dSKIP_ILL_INST src\ldtraps.s -o obj\ldtrapsx.o
asm68 %a -lQ src\load_tbl.s -o obj\load_tbl.o
asm68 %a -lQ src\mod16.s -o obj\mod16.o
asm68 %a -lQ src\mod32.s -o obj\mod32.o
asm68 %a -lQ src\setjmp.s -o obj\setjmp.o
asm68 %a -lQ src\stk_chk.s -o obj\stk_chk.o
asm68 %a -lQ src\traps.s -o obj\traps.o
asm68 %a -lQ src\xcptndmy.s -o obj\xcptndmy.o
*lib68 -C %l obj\*.o mklibcfg.doc
*del obj\*.o
*rmdir obj

@LIBM
*mkdir obj
asm68 -lQ src\abs.s -o obj\abs.o
*del obj\*.o
com%s %c -Q -M -DFLOAT src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printf.o
*del src\printf.s
com%s %c -Q -DFLOAT src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanf.o
*del src\scanf.s
asm68 %a -lQ src\h_ldtrap.s -o obj\h_ldtrap.o
asm68 %a -lQ src\h_traps.s -o obj\h_traps.o
asm68 %a -lQ src\h_xcptn.s -o obj\h_xcptn.o
asm68 %a -lQ src\h_initcr.s -o obj\h_initcr.o
asm68 %a -lQ src\h_frexp.s -o obj\h_frexp.o
asm68 %a -lQ src\h_ldexp.s -o obj\h_ldexp.o
*copy fp_obj.all obj
*cd obj
lib68 -x fp_obj.all
*cd ..
lib68 -C %l -i obj\lm%p
*del obj\*.o
*del obj\fp_obj.all
*del obj\*.68
*del obj\*.020
*del obj\*.332
*del obj\*.040
*rmdir obj

@LIBMS
*mkdir obj
asm68 -lQ src\abs.s -o obj\abs.o
*del obj\*.o
com%s %c -Q -M2 -DFLOAT -DDP_FLOAT src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printf.o
*del src\printf.s
com%s %c -Q -DFLOAT -DDP_FLOAT src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanf.o
*del src\scanf.s
asm68 %a -lQ src\mx_xcptn.s -o obj\mx_xcptn.o
asm68 %a -lQ src\dp_frexp.s -o obj\dp_frexp.o
asm68 %a -lQ src\dp_ldexp.s -o obj\dp_ldexp.o
*copy fp_obj.all obj
*cd obj
lib68 -x fp_obj.all
*cd ..
lib68 -C %l -i obj\lms%p
*del obj\*.o
*del obj\fp_obj.all
*del obj\*.68
*del obj\*.020
*del obj\*.332
*del obj\*.040
*rmdir obj

@LIBMSF
*mkdir obj
asm68 -lQ src\abs.s -o obj\abs.o
*del obj\*.o
com%s %c -Q -M3 -DFLOAT -DFP_FLOAT src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printf.o
*del src\printf.s
com%s %c -Q -DFLOAT -DFP_FLOAT src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanf.o
*del src\scanf.s
asm68 %a -lQ src\mx_xcptn.s -o obj\mx_xcptn.o
asm68 %a -lQ src\fp_frexp.s -o obj\fp_frexp.o
asm68 %a -lQ src\fp_ldexp.s -o obj\fp_ldexp.o
*copy fp_obj.all obj
*cd obj
lib68 -x fp_obj.all
*cd ..
lib68 -C %l -i obj\lmsf%p
*del obj\*.o
*del obj\fp_obj.all
*del obj\*.68
*del obj\*.020
*del obj\*.332
*del obj\*.040
*rmdir obj

@LIBMSFF
*mkdir obj
asm68 -lQ src\abs.s -o obj\abs.o
*del obj\*.o
com%s %c -Q -M4 -DFLOAT -DFF_FLOAT src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printf.o
*del src\printf.s
com%s %c -Q -DFLOAT -DFF_FLOAT src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanf.o
*del src\scanf.s
asm68 %a -lQ src\mx_xcptn.s -o obj\mx_xcptn.o
asm68 %a -lQ src\ff_frexp.s -o obj\ff_frexp.o
asm68 %a -lQ src\ff_ldexp.s -o obj\ff_ldexp.o
*copy fp_obj.all obj
*cd obj
lib68 -x fp_obj.all
*cd ..
lib68 -C %l -i obj\lmsff%p
*del obj\*.o
*del obj\fp_obj.all
*del obj\*.68
*del obj\*.020
*del obj\*.332
*del obj\*.040
*rmdir obj

@LIBMSMX
*mkdir obj
*mkdir obj\mx
asm68 -lQ src\abs.s -o obj\abs.o
*copy obj\abs.o obj\mx
*del obj\*.o
*del obj\mx\*.o
com%s %c -Q -M2 -DLIBMSMX -DFLOAT -DDP_FLOAT src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printf.o
*del src\printf.s
com%s %c -Q -DLIBMSMX -DFLOAT -DDP_FLOAT src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanf.o
*del src\scanf.s
com%s %c -Q -M3 -DLIBMSMX -DFLOAT -DFP_FLOAT src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printff.o
*del src\printf.s
com%s %c -Q -DLIBMSMX -DFLOAT -DFP_FLOAT src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanff.o
*del src\scanf.s
com%s %c -Q -M4 -DLIBMSMX -DFLOAT -DFF_FLOAT src\printf.c src\printf.s
asm68 %a -lQ src\printf.s -o obj\printfff.o
*del src\printf.s
com%s %c -Q -DLIBMSMX -DFLOAT -DFF_FLOAT src\scanf.c src\scanf.s
asm68 %a -lQ src\scanf.s -o obj\scanfff.o
*del src\scanf.s
asm68 %a -lQ -dLIBMSMX src\mx_xcptn.s -o obj\mx_xcptn.o
asm68 %a -lQ src\dp_frexp.s -o obj\dp_frexp.o
asm68 %a -lQ src\dp_ldexp.s -o obj\dp_ldexp.o
asm68 %a -lQ -dLIBMSMX src\fp_frexp.s -o obj\mx\fp_frexp.o
asm68 %a -lQ -dLIBMSMX src\fp_ldexp.s -o obj\mx\fp_ldexp.o
asm68 %a -lQ -dLIBMSMX src\ff_frexp.s -o obj\mx\ff_frexp.o
asm68 %a -lQ -dLIBMSMX src\ff_ldexp.s -o obj\mx\ff_ldexp.o
*copy fp_obj.all obj
*copy fpmx_obj.all obj\mx
*cd obj
lib68 -x fp_obj.all
*cd mx
lib68 -x fpmx_obj.all
*cd ..\..
lib68 -C %l -i obj\lmsmx%p
*del obj\*.o
*del obj\fp_obj.all
*del obj\*.68
*del obj\*.020
*del obj\*.332
*del obj\*.040
*del obj\mx\*.o
*del obj\mx\fpmx_obj.all
*rmdir obj\mx
*rmdir obj




