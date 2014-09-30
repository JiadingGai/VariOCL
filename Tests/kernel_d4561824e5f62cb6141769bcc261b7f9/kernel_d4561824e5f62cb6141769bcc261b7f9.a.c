#include <stdio.h> 
#define N 8
int main(int argc, char *argv[])
{
  int A[N] = {1, 2, 3, 4, 5, 6, 7, 8};
  int n = 8;
  int sum = 0;

  compute_sum_with_localmem(A, n, &sum);

  printf("sum = %d\n", sum);

  return 0;
}
