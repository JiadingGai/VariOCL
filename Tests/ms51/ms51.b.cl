#include "../ocl_runtime.h"

__kernel void ms51(__local int *A, __local int *B, int n) {

    int tid = 0;
    int lsz = get_local_size(0);
    
    if (lsz > 1) {
      tid = get_local_id(0);
      if (tid % 2) {
        A[tid] = tid;
      }
      barrier(0);
    } else {
      A[tid] = -1;
    }

    barrier(0);

    if (tid == 0) {
      for (int i = 0; i < lsz; ++i)
        B[i] = A[i];
    }

    return;
}
