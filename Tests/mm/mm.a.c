#include <stdio.h>

#define N 4
#define NN 16

int main(int argc, char *argv[])
{
   int wA = N;
   int wB = N;

   int aMatrix[NN] = {1, 4, 3, 2, 2, 5, 6, 7, 3, 6, 8, 3, 1, 5, 3, 8};
   int bMatrix[NN] = {7, 8, 9, 4, 7, 1, 3, 2, 6, 3, 7, 1, 7, 3, 5, 2};
   int product[NN] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
   int golden [NN] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

   matrixMul(product, aMatrix, bMatrix, wA, wB);

   int IsPassed = 1;
   for (int row = 0; row < N; row++) {
     for (int col = 0; col < N; col++) {
       // Multiply the row of A by the column of B to get the row, column of product.
       for (int inner = 0; inner < N; inner++) {
         golden[row * N + col] += aMatrix[row * N + inner] * bMatrix[inner * N + col];
       }

       printf("%d(%d) ", product[row * N + col], golden[row * N + col]);
       if (product[row * N + col] != golden[row * N + col]) {
         IsPassed = 0;
       }
     }
     printf("\n");
   }

   if (!IsPassed) {
     printf("Matrix Multiplication FAILED!\n");
   } else {
     printf("Matrix Multiplication PASSED!\n");
   }

   return 0;
}
