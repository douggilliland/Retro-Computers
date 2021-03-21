/* Check keyboard input
// --------------------
// Check if key is pressed, then
// get key, otherwise return 0
*/
xkey()
{
    if(kbhit()) {
       return getch();
    }
    return 0;
}
