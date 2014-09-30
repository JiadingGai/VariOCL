#include "f7f7_runtime.h"

__kernel void test_fn(__local uint *sSharedStorage, __global uint *src, __global uint *offsets, __global uint *alignmentOffsets, __global uint *results )
{
   int tid = get_global_id( 0 );
   int lid = get_local_id( 0 );

   if (lid == 0) {
     for ( int i = 0; i < (256 * 8); i++ )
       sSharedStorage[ i ] = src[ i ];
   }

   barrier( CLK_LOCAL_MEM_FENCE );

   uint tmp[8];
   vload8 (offsets[ tid ], 
           ( (__local uint *) sSharedStorage ) + alignmentOffsets[ tid ],
           tmp);

   for (int i = 0; i < 8; ++i) {
     results[tid * 8 + i] = tmp[i];
   }
}
