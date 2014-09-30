#include <stdio.h>

#define N 8

int main(int argc, char *argv[])
{
  int A[N] = {1, 2, 3, 4, 5, 6, 7, 8};
  int B[N] = {-1,-1,-1,-1,-1,-1,-1,-1};
  int n = 8;

  local_memtest(A, B);
  for (int i = 0; i < N; i++)
    printf("\n(%d,%d)\n", A[i], B[i]);
  printf("\n");
  return 0;
}
