#include <stdio.h>

#define N 8

int main(int argc, char *argv[])
{
  int sum_per_wi[N] = {0, 0, 0, 0, 0, 0, 0, 0};
  int sum_wg = 0;
  int Sum_Final = 0;

  bar_fence(&sum_wg, sum_per_wi, &Sum_Final);

  for (int i = 0; i < N; i++)
    printf("\n(%d,%d,%d)\n", sum_wg, sum_per_wi[i], Sum_Final);
  printf("\n");
  return 0;
}
