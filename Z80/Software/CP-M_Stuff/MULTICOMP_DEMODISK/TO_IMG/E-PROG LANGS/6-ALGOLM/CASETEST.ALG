begin
  comment This is a test program to test the functioning of the 
          Algol-m case statement;
  while 1=1 do
      begin
        integer num,input,index;
        write("input test value");
        
        read(input);
        case input of
          begin
           begin
             write("0",input);
           end;
           begin
            %this is case 1%
            write("1",input);
           end;
           begin
           write("2",input);
             for index:=1 step 1 until input do
                begin
                write(index);
              end;
             end;
           write("3"," ",input);
          end;
       end;
end
eof

