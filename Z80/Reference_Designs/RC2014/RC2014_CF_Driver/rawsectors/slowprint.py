import sys
from time import sleep

for line in sys.stdin:

    for ch in line:
        sys.stdout.write( ch );
        sys.stdout.flush();
        #sleep(0.01);

    sys.stdout.write('\r\n');
    sys.stdout.flush();
    sleep(0.05);


sleep(0.3);
sys.stdout.write("DOKE &h8224, &h9000\r\n");
sys.stdout.flush();
sleep(0.1);
sys.stdout.write("PRINT USR(0)\r\n")
sys.stdout.flush();