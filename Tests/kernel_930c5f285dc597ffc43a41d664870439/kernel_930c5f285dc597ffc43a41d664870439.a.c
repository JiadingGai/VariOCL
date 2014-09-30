#include <stdio.h> 
#define N 8
int main(int argc, char *argv[])
{
  int A[N] = {1, 2, 3, 4, 5, 6, 7, 8};
  int tmp_sum[N] = {0,0,0,0,0,0,0,0};

  int n = 8;
  int sum = 0;

  compute_sum(A, n, tmp_sum, &sum);

  for (int i = 0; i < 8; ++i)
    printf("tmp_sum = %d\n", tmp_sum[i]);

  printf("sum = %d\n", sum);

  return 0;
}
