#include <stdio.h>

#define N 8

int main(int argc, char *argv[])
{
  int A[N] = {-1,-1,-1,-1,-1,-1,-1,-1};
  int B[N] = {-1,-1,-1,-1,-1,-1,-1,-1};
  int n = 7;

  b(A, B, n);
  for (int i = 0; i < N; i++)
    printf("\n(%d)\n", B[i]);
  printf("\n");
  return 0;
}
