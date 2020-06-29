/*******************************************************************/
/*                                                                 */
/*                    General Purpose Move Routine                 */
/*                                                                 */
/*******************************************************************/

move(from,to,count)
char *from, *to;
unsigned int count;
{
  qmemcpy(to, from, count);
}
