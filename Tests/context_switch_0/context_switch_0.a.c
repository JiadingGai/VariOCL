#include <stdio.h>

#define N 8

int main(int argc, char *argv[])
{
  int A[N] = {-1,-1,-1,-1,-1,-1,-1,-1};
  int B[N] = {-1,-1,-1,-1,-1,-1,-1,-1};
  int C[N] = {-1,-1,-1,-1,-1,-1,-1,-1};
  int n = 7;

  b(A, B, C, n);
  for (int i = 0; i < N; i++)
    printf("\n(%d,%d,%d)\n", A[i], B[i], C[i]);
  printf("\n");
  return 0;
}
