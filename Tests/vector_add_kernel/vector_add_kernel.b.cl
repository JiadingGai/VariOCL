#include "../ocl_runtime.h"

__constant int xDim = 1;
__constant int yDim = 2;
__constant int zDim = 4;
__constant int xid = 0;
__constant int yid = 0;
__constant int zid = 0;

__kernel void vector_add(int *A, int *B, int *C, int n) {

    int i = get_local_id(0);
    int j = get_local_id(1);
    int k = get_local_id(2);

    int idx = k * xDim * yDim + j * xDim + i;

    if (idx < n)
      C[idx] = A[idx] + B[idx];


   barrier(1);

   if (idx > n) {
       return;
   } else if (idx < n) {
       C[idx] = A[idx] + B[idx];
   } else {
       return;
   }

    return;
}

