
#if defined (DOUBLE_SUPPORT)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
#endif
#if defined (DEPTH_0)
#define VEC_TYPE uchar8
#define TYPE uchar
#define CONVERT_TYPE convert_uchar8
#define MIN_VAL 0
#define MAX_VAL 255
#endif
#if defined (DEPTH_1)
#define VEC_TYPE char8
#define TYPE char
#define CONVERT_TYPE convert_char8
#define MIN_VAL -128
#define MAX_VAL 127
#endif
#if defined (DEPTH_2)
#define VEC_TYPE ushort8
#define TYPE ushort
#define CONVERT_TYPE convert_ushort8
#define MIN_VAL 0
#define MAX_VAL 65535
#endif
#if defined (DEPTH_3)
#define VEC_TYPE short8
#define TYPE short
#define CONVERT_TYPE convert_short8
#define MIN_VAL -32768
#define MAX_VAL 32767
#endif
#if defined (DEPTH_4)
#define VEC_TYPE int8
#define TYPE int
#define CONVERT_TYPE convert_int8
#define MIN_VAL INT_MIN
#define MAX_VAL INT_MAX
#endif
#if defined (DEPTH_5)
#define VEC_TYPE float8
#define TYPE float
#define CONVERT_TYPE convert_float8
#define MIN_VAL (-FLT_MAX)
#define MAX_VAL FLT_MAX
#endif
#if defined (DEPTH_6)
#define VEC_TYPE double8
#define TYPE double
#define CONVERT_TYPE convert_double8
#define MIN_VAL (-DBL_MAX)
#define MAX_VAL DBL_MAX
#endif
#if defined (REPEAT_E0)
#define repeat_me(a) a = a;
#endif
#if defined (REPEAT_E1)
#define repeat_me(a) a.s7 = 0;
#endif
#if defined (REPEAT_E2)
#define repeat_me(a) a.s7 = 0;a.s6 = 0;
#endif
#if defined (REPEAT_E3)
#define repeat_me(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;
#endif
#if defined (REPEAT_E4)
#define repeat_me(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;
#endif
#if defined (REPEAT_E5)
#define repeat_me(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;a.s3 = 0;
#endif
#if defined (REPEAT_E6)
#define repeat_me(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;a.s3 = 0;a.s2 = 0;
#endif
#if defined (REPEAT_E7)
#define repeat_me(a) a.s7 = 0;a.s6 = 0;a.s5 = 0;a.s4 = 0;a.s3 = 0;a.s2 = 0;a.s1 = 0;
#endif
#pragma OPENCL EXTENSION cl_khr_global_int32_base_atomics:enable
#pragma OPENCL EXTENSION cl_khr_global_int32_extended_atomics:enable
__kernel void arithm_op_minMax_mask (int cols,int invalid_cols,int offset,int elemnum,int groupnum, __global TYPE *src,
int minvalid_cols,int moffset, __global uchar *mask,__global VEC_TYPE *dst)
{
unsigned int lid = get_local_id(0);
unsigned int gid = get_group_id(0);
unsigned int  id = get_global_id(0);
unsigned int idx = id + (id / cols) * invalid_cols;
unsigned int midx = id + (id / cols) * minvalid_cols;
__local VEC_TYPE localmem_max[128],localmem_min[128];
VEC_TYPE minval,maxval,temp,m_temp;
if(id < elemnum)
{
temp = vload8(idx, &src[offset]);
m_temp = CONVERT_TYPE(vload8(midx,&mask[moffset]));
if(id % cols == cols - 1)
{
repeat_me(m_temp);
}
minval = m_temp != (VEC_TYPE)0 ? temp : (VEC_TYPE)MAX_VAL;
maxval = m_temp != (VEC_TYPE)0 ? temp : (VEC_TYPE)MIN_VAL;
}
else
{
minval = MAX_VAL;
maxval = MIN_VAL;
}
for(id=id + (groupnum << 8); id < elemnum;id = id + (groupnum << 8))
{
idx = id + (id / cols) * invalid_cols;
midx = id + (id / cols) * minvalid_cols;
temp = vload8(idx, &src[offset]);
m_temp = CONVERT_TYPE(vload8(midx,&mask[moffset]));
if(id % cols == cols - 1)
{
repeat_me(m_temp);
}
minval = min(minval,m_temp != (VEC_TYPE)0 ? temp : minval);
maxval = max(maxval,m_temp != (VEC_TYPE)0 ? temp : maxval);
}
if(lid > 127)
{
localmem_min[lid - 128] = minval;
localmem_max[lid - 128] = maxval;
}
barrier(CLK_LOCAL_MEM_FENCE);
if(lid < 128)
{
localmem_min[lid] = min(minval,localmem_min[lid]);
localmem_max[lid] = max(maxval,localmem_max[lid]);
}
barrier(CLK_LOCAL_MEM_FENCE);
for(int lsize = 64; lsize > 0; lsize >>= 1)
{
if(lid < lsize)
{
int lid2 = lsize + lid;
localmem_min[lid] = min(localmem_min[lid] , localmem_min[lid2]);
localmem_max[lid] = max(localmem_max[lid] , localmem_max[lid2]);
}
barrier(CLK_LOCAL_MEM_FENCE);
}
if( lid == 0)
{
dst[gid] = localmem_min[0];
dst[gid + groupnum] = localmem_max[0];
}
}

