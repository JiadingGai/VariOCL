
#if defined (DOUBLE_SUPPORT)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
#define RES_TYPE double8
#define CONVERT_RES_TYPE convert_double8
#else
#define RES_TYPE float8
#define CONVERT_RES_TYPE convert_float8
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
#if defined (FUNC_TYPE_0)
#define FUNC(a,b) b += a;
#endif
#if defined (FUNC_TYPE_1)
#define FUNC(a,b) b = b + (a >= 0 ? a : -a);
#endif
#if defined (FUNC_TYPE_2)
#define FUNC(a,b) b = b + a * a;
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
__kernel void arithm_op_sum (int cols,int invalid_cols,int offset,int elemnum,int groupnum,
__global VEC_TYPE *src, __global RES_TYPE *dst)
{
unsigned int lid = get_local_id(0);
unsigned int gid = get_group_id(0);
unsigned int  id = get_global_id(0);
unsigned int idx = offset + id + (id / cols) * invalid_cols;
__local RES_TYPE localmem_sum[128];
RES_TYPE sum = 0,temp;
if(id < elemnum)
{
temp = CONVERT_RES_TYPE(src[idx]);
if(id % cols == 0 )
{
repeat_s(temp);
}
if(id % cols == cols - 1)
{
repeat_e(temp);
}
FUNC(temp,sum);
}
else
{
sum = 0;
}
for(id=id + (groupnum << 8); id < elemnum;id = id + (groupnum << 8))
{
idx = offset + id + (id / cols) * invalid_cols;
temp = CONVERT_RES_TYPE(src[idx]);
if(id % cols == 0 )
{
repeat_s(temp);
}
if(id % cols == cols - 1)
{
repeat_e(temp);
}
FUNC(temp,sum);
}
if(lid > 127)
{
localmem_sum[lid - 128] = sum;
}
barrier(CLK_LOCAL_MEM_FENCE);
if(lid < 128)
{
localmem_sum[lid] = sum + localmem_sum[lid];
}
barrier(CLK_LOCAL_MEM_FENCE);
for(int lsize = 64; lsize > 0; lsize >>= 1)
{
if(lid < lsize)
{
int lid2 = lsize + lid;
localmem_sum[lid] = localmem_sum[lid] + localmem_sum[lid2];
}
barrier(CLK_LOCAL_MEM_FENCE);
}
if( lid == 0)
{
dst[gid] = localmem_sum[0];
}
}

