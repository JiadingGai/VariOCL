#include "../ocl_runtime.h"

inline void dummyFn(int *a, int *b)
{
  a = get_local_size(0);
  b = get_local_size(1);
}

__kernel void b(__local int *A, __local int *B, __local int *C, int n) {

    int i = 0;
    int j = 0;
    int k = 0;

    //int xDim = get_local_size(0);
    //int yDim = get_local_size(1);
    int xDim = 0;
    int yDim = 0;
    dummyFn(&xDim, &yDim);
    
    if (xDim > 0) {
      i = get_local_id(0);
      j = get_local_id(1);
      k = get_local_id(2);
    }

    barrier(0);

    int idx = k * xDim * yDim + j * xDim + i;
    if (idx < n) {
      A[idx] = i;
      B[idx] = j;
      C[idx] = k;
    }
    return;
}

__kernel void c(__local int *A, __local int *B, __local int *C, int n) {

    int i = 0;
    int j = 0;
    int k = 0;

    int xDim = get_local_size(0);
    int yDim = get_local_size(1);
    
    if (xDim > 0) {
      i = get_local_id(0);
      j = get_local_id(1);
      k = get_local_id(2);
    }

    barrier(0);

    int idx = k * xDim * yDim + j * xDim + i;
    if (idx < n) {
      A[idx] = i;
      B[idx] = j;
      C[idx] = k;
    }
    return;
}
