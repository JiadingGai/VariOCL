#include "../ocl_runtime.h"

void __kernel local_memtest(__global int* in, __global int* out) {
    __local int lbuf[30];
    int idx = get_local_id(0);
    int lsz = get_local_size(0);
    if (idx < lsz) {
        lbuf[idx] = in[idx];
    }

    barrier(CLK_LOCAL_MEM_FENCE);

    out[idx] = lbuf[(idx+1)%lsz];
}
