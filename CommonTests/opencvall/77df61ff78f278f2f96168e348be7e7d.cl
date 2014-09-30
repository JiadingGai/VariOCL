
#if defined (DOUBLE_SUPPORT)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
#endif
#if defined (DEPTH_0)
#define VEC_TYPE uchar8
#endif
#if defined (DEPTH_1)
#define VEC_TYPE char8
#endif
#if defined (DEPTH_2)
#define VEC_TYPE ushort8
#endif
#if defined (DEPTH_3)
#define VEC_TYPE short8
#endif
#if defined (DEPTH_4)
#define VEC_TYPE int8
#endif
#if defined (DEPTH_5)
#define VEC_TYPE float8
#endif
#if defined (DEPTH_6)
#define VEC_TYPE double8
#endif
#if defined (REPEAT_S0)
#define repeat_s(a) a = a;
#endif
#if defined (REPEAT_S1)
#define repeat_s(a) a.s0 = 0;
#endif
#if defined (REPEAT_S2)
#define repeat_s(a) a.s0 = 0;a.s1 = 0;
#endif
#if defined (REPEAT_S3)
#define repeat_s(a) a.s0 = 0;a.s1 = 0;a.s2 = 0;
#endif
#if defined (REPEAT_S4)
#define repeat_s(a) a.s0 = 0;a.s1 = 0;a.s2 = 0;a.s3 = 0;
#endif
#if defined (REPEAT_S5)
#define repeat_s(a) a.s0 = 0;a.s1 = 0;a.s2 = 0;a.s3 = 0;a.s4 = 0;
#endif
#if defined (REPEAT_S6)
#define repeat_s(a) a.s0 = 0;a.s1 = 0;a.s2 = 0;a.s3 = 0;a.s4 = 0;a.s5 = 0;
#endif
#if defined (REPEAT_S7)
#define repeat_s(a) a.s0 = 0;a.s1 = 0;a.s2 = 0;a.s3 = 0;a.s4 = 0;a.s5 = 0;a.s6 = 0;
#endif
#if defined (REPEAT_E0)
#define repeat_e(a) a = a;
#endif
#if defined (REPEAT_E1)
#define repeat_e(a) a.s7 = 0;
#endif
#if defined (REPEAT_E2)
#define repeat_e(a) a.s7 = 0;a.s6 = 0;
#endif
#if defined (REPEAT_E3)
#define repeat_e(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;
#endif
#if defined (REPEAT_E4)
#define repeat_e(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;
#endif
#if defined (REPEAT_E5)
#define repeat_e(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;a.s3 = 0;
#endif
#if defined (REPEAT_E6)
#define repeat_e(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;a.s3 = 0;a.s2 = 0;
#endif
#if defined (REPEAT_E7)
#define repeat_e(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;a.s3 = 0;a.s2 = 0;a.s1 = 0;
#endif
#pragma OPENCL EXTENSION cl_khr_global_int32_base_atomics:enable
#pragma OPENCL EXTENSION cl_khr_global_int32_extended_atomics:enable
__kernel void arithm_op_nonzero (int cols,int invalid_cols,int offset,int elemnum,int groupnum,
__global VEC_TYPE *src, __global int8 *dst)
{
unsigned int lid = get_local_id(0);
unsigned int gid = get_group_id(0);
unsigned int  id = get_global_id(0);
unsigned int idx = offset + id + (id / cols) * invalid_cols;
__local int8 localmem_nonzero[128];
int8 nonzero;
VEC_TYPE zero=0,one=1,temp;
if(id < elemnum)
{
temp = src[idx];
if(id % cols == 0 )
{
repeat_s(temp);
}
if(id % cols == cols - 1)
{
repeat_e(temp);
}
nonzero = convert_int8(temp == zero ? zero:one);
}
else
{
nonzero = 0;
}
for(id=id + (groupnum << 8); id < elemnum;id = id + (groupnum << 8))
{
idx = offset + id + (id / cols) * invalid_cols;
temp = src[idx];
if(id % cols == 0 )
{
repeat_s(temp);
}
if(id % cols == cols - 1)
{
repeat_e(temp);
}
nonzero = nonzero + convert_int8(temp == zero ? zero:one);
}
if(lid > 127)
{
localmem_nonzero[lid - 128] = nonzero;
}
barrier(CLK_LOCAL_MEM_FENCE);
if(lid < 128)
{
localmem_nonzero[lid] = nonzero + localmem_nonzero[lid];
}
barrier(CLK_LOCAL_MEM_FENCE);
for(int lsize = 64; lsize > 0; lsize >>= 1)
{
if(lid < lsize)
{
int lid2 = lsize + lid;
localmem_nonzero[lid] = localmem_nonzero[lid] + localmem_nonzero[lid2];
}
barrier(CLK_LOCAL_MEM_FENCE);
}
if( lid == 0)
{
dst[gid] = localmem_nonzero[0];
}
}

