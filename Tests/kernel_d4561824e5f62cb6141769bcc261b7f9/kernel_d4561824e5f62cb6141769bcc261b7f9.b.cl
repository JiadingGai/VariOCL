#include "../ocl_runtime.h"

//__constant int xDim = 1;
//__constant int yDim = 2;
//__constant int zDim = 4;
//__constant int xid = 0;
//__constant int yid = 0;
//__constant int zid = 0;

__kernel void compute_sum_with_localmem(__global int *a, int n, __global int *sum)
{
    __local int tmp_sum[512];
    int  tid = get_local_id(0);
    int  lsize = get_local_size(0);
    int  i;

    tmp_sum[tid] = 0;
    for (i=tid; i<n; i+=lsize)
        tmp_sum[tid] += a[i];
 
    if( lsize == 1 )
    {
       if( tid == 0 )
           *sum = tmp_sum[0];
       return;
    }

    do
    {
       barrier(CLK_LOCAL_MEM_FENCE);
       if (tid < lsize/2)
       {
           int sum = tmp_sum[tid];
           if( (lsize & 1) && tid == 0 )
               sum += tmp_sum[tid + lsize - 1];
           tmp_sum[tid] = sum + tmp_sum[tid + lsize/2];
       }
       lsize = lsize/2; 
    }while( lsize );

   if( tid == 0 )
      *sum = tmp_sum[0];
}

