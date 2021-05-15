extern int printd(int x);

int main()
{
  int i;
  i = 0;
  while (i < 10)
  {
    printd(i);
    i = i + 2;
  }
  for (i = -10; i <= 10; i = i + 1)
    printd(i);
  i = 0;
  while (i >= -20)
  {
    printd(i);
    i = i - 1;
  }
  return 0;
}
