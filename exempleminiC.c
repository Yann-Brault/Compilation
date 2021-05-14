extern int printd(int x);

int main()
{
   int i, j;
   for (i = 0; i < 10; i = i + 1)
   {
      if (i == 5)
         break;
   }
   printd(i);
   return (i + 3);
}
