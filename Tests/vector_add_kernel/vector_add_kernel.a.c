#include <stdio.h>

#define N 8

int main(int argc, char *argv[])
{
   int A[N] = {1,2,3,4,5,6,7,8};
   int B[N] = {8,7,6,5,4,3,2,1};
   int C[N] = {0,0,0,0,0,0,0,0};
   int n = 5;

    vector_add(A, B, C, n);
    for (int i = 0; i < N; i++)
        printf("%d ",C[i]);
    printf("\n");
    return 0;
}
