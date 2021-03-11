# pidp11-211bsd-man-pages

            /$$$$$$    /$$     /$$   /$$$$$$$   /$$$$$$  /$$$$$$$ 
           /$$__  $$ /$$$$   /$$$$  | $$__  $$ /$$__  $$| $$__  $$
          |__/  \ $$|_  $$  |_  $$  | $$  \ $$| $$  \__/| $$  \ $$
            /$$$$$$/  | $$    | $$  | $$$$$$$ |  $$$$$$ | $$  | $$
           /$$____/   | $$    | $$  | $$__  $$ \____  $$| $$  | $$
          | $$        | $$    | $$  | $$  \ $$ /$$  \ $$| $$  | $$
          | $$$$$$$$ /$$$$$$ /$$$$$$| $$$$$$$/|  $$$$$$/| $$$$$$$/
          |________/|______/|______/|_______/  \______/ |_______/

          ********************************************************
          ************** The 211BSD man page project *************
          ********************************************************

I've been working to collect the formatted text from the man pages under 211BSD on my PiDP11.

Version 3 of the files bring an index with page numbers along with some reformatting of some of the content which didn't format well when I captured it.

Goals were too:
  * Keep the text as close to the original as possible.
  * Format the output so it would print properly.
  * Remove/replace some of the formatting characters that are not compatable with a modern printer.
	* Enforce page boundries such that page headers and footers are positioned correctly on the 
	  printed page.
  * Clean up tables and source code as the nroff output didn't do a clean job on these.
  * Deal with lines that wrap around so the output is clean.
  * Provide these files to the PiDP11 and 211BSD communities.
  
Process:
  For the .t files these were converted to text using nroff under 211BSD,  nroff -ms *.t > file.txt
  The .txt files were then FTPed to my primary computer.
  Edit the .txt files in Notepad++ too:
    * Remove any special characters such as [BS] used to double print characters (bold printing).
	  * Remove other special charaters.
  Import the resulting .txt files into MSWord too:
    * Add proper page alignment spacing
	  * Editing to remove the commands to create tables which didn't work then to recreate the tables. 
	  * Deal with lines that wrapped. 
	  * Move page notes to the bottom of the page.
    * Clean up anything else that didn't format properly.
    * Save the results as both .doc and .pdf files.

I hope you enjoy these.

   Please checkout my YouTube channel. There are over 300 videos on vintage computing, vintage electronics
   and other stuff that caught my attention.
   
   The ShadowTronBlog - https://www.youtube.com/c/shadowtronblog
   
   Living in the shadow of the electron.
   
-Neil
