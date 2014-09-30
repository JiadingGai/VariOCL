#include "../ocl_runtime.h"

__kernel void bar_fence(__global int* sum_wg ,__local int *sum_per_wi, __global int* Sum_final) {
  
  int gid = get_group_id(0); // get work group id
  int lid = get_local_id(0); // get local id in each work group
  int lsz = get_local_size(0);
  int sum = 0;
  int start = gid * 10000 + lid*100;
  for (int i=0;i<100;i++) {
    sum+=start;
    start++;
  }
  sum_per_wi[lid]=sum;

  barrier(CLK_LOCAL_MEM_FENCE); //waits for all work items in the group to be finished
  if (lid==0) { // find the sum of each work_group
    int tmp=0;
    for (int i=0;i<lsz;i++)
         tmp += sum_per_wi[i];
    sum_wg[gid] = tmp;
  }
  
  barrier(CLK_GLOBAL_MEM_FENCE); //waits until all work groups to be over now

  //find the sum of the final required output
  if (gid == 0) {
    int final=0;
    for(int i = 0;i<1;i++)
      final+=sum_wg[i];
    *Sum_final=final;
  }
}
