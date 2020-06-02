begin comment algol-m program to compute permutations of 
              sets of numbers;
integer n;
integer function factorial(n);
    integer n;
       FACTORIAL:=IF N=0 THEN 1 ELSE N*FACTORIAL(N-1);
write("Input the number of numbers in the set");
read(n);
while n<>9999 do
   begin integer array set[1:n];

   procedure writeout;
    begin integer i; write(" ");
      for i:=1 step 1 until n do
        writeon(set[i]);
    end;

   procedure exchange(i,j);
    integer i,j;
   integer temp;
    begin temp:=set[i]; set[i]:=set[j];
     set[j]:=temp;
    end;

     procedure permute(k);
         integer k,i;
        begin
       if k=n then writeout else
        BEGIN
         for i:=k step 1 until n do
           begin exchange(i,k); permute(k+1);
             exchange(k,i);
            end;
         end;
        end;

     PROCEDURE READER;
       begin
        integer i;
        for i:=1 step 1 until n do
          begin
            write("Input number",i);
            read(set[i]);
          end;
        writeout;
       end;

   WRITE(" "); WRITE("THERE ARE",FACTORIAL(N)," ");
   WRITEON("PERMUTATIONS OF THE FOLLOWING SET OF NUMBERS");
   READER; WRITE(" "); WRITE(" ");
   permute(1); write(" "); read(n);
  end;
 write("end of run");
 end
eof
