
#if defined (DOUBLE_SUPPORT)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
#endif
__kernel void magnitudeSqr_C1_D5 (__global float *src1,int src1_step,int src1_offset,
__global float *src2, int src2_step,int src2_offset,
__global float *dst,  int dst_step,int dst_offset,
int rows,  int cols,int dst_step1)
{
int x = get_global_id(0);
int y = get_global_id(1);
if (x < cols && y < rows)
{
x = x << 2;
#define dst_align ((dst_offset >> 2) & 3)
int src1_index = mad24(y, src1_step, (x << 2) + src1_offset - (dst_align << 2));
int src2_index = mad24(y, src2_step, (x << 2) + src2_offset - (dst_align << 2));
int dst_start  = mad24(y, dst_step, dst_offset);
int dst_end    = mad24(y, dst_step, dst_offset + dst_step1);
int dst_index  = mad24(y, dst_step, dst_offset + (x << 2) -(dst_align << 2));
int src1_index_fix = src1_index < 0 ? 0 : src1_index;
int src2_index_fix = src2_index < 0 ? 0 : src2_index;
float4 src1_data = vload4(0, (__global float  *)((__global char *)src1 + src1_index_fix));
float4 src2_data = vload4(0, (__global float *)((__global char *)src2 + src2_index_fix));
if(src1_index < 0)
{
float4 tmp;
tmp.xyzw = (src1_index == -2) ? src1_data.zwxy:src1_data.yzwx;
src1_data.xyzw = (src1_index == -1) ? src1_data.wxyz:tmp.xyzw;
}
if(src2_index < 0)
{
float4 tmp;
tmp.xyzw = (src2_index == -2) ? src2_data.zwxy:src2_data.yzwx;
src2_data.xyzw = (src2_index == -1) ? src2_data.wxyz:tmp.xyzw;
}
float4 dst_data = *((__global float4 *)((__global char *)dst + dst_index));
float4   tmp_data  ;
tmp_data.x = src1_data.x * src1_data.x + src2_data.x * src2_data.x;
tmp_data.y = src1_data.y * src1_data.y + src2_data.y * src2_data.y;
tmp_data.z = src1_data.z * src1_data.z + src2_data.z * src2_data.z;
tmp_data.w = src1_data.w * src1_data.w + src2_data.w * src2_data.w;
dst_data.x = ((dst_index + 0 >= dst_start) && (dst_index + 0 < dst_end)) ? tmp_data.x : dst_data.x;
dst_data.y = ((dst_index + 4 >= dst_start) && (dst_index + 4 < dst_end)) ? tmp_data.y : dst_data.y;
dst_data.z = ((dst_index + 8 >= dst_start) && (dst_index + 8 < dst_end)) ? tmp_data.z : dst_data.z;
dst_data.w = ((dst_index + 12 >= dst_start) && (dst_index + 12 < dst_end)) ? tmp_data.w : dst_data.w;
*((__global float4 *)((__global char *)dst + dst_index)) = dst_data;
}
}
#if defined (DOUBLE_SUPPORT)
__kernel void magnitudeSqr_C2_D5 (__global float *src1,int src1_step,int src1_offset,
__global float *dst,  int dst_step,int dst_offset,
int rows,  int cols,int dst_step1)
{
int x = get_global_id(0);
int y = get_global_id(1);
if (x < cols && y < rows)
{
x = x << 2;
#define dst_align ((dst_offset >> 2) & 3)
int src1_index = mad24(y, src1_step, (x << 3) + src1_offset - (dst_align << 3));
int dst_start  = mad24(y, dst_step, dst_offset);
int dst_end    = mad24(y, dst_step, dst_offset + dst_step1);
int dst_index  = mad24(y, dst_step, dst_offset + (x << 2) -(dst_align << 2));
int src1_index_fix = src1_index < 0 ? 0 : src1_index;
float8 src1_data = vload8(0, (__global float  *)((__global char *)src1 + src1_index_fix));
if(src1_index==-6)
src1_data.s01234567 = src1_data.s67012345;
if(src1_index==-4)
src1_data.s01234567 = src1_data.s45670123;
if(src1_index== -2)
src1_data.s01234567 = src1_data.s23456701;
float4 dst_data = *((__global float4 *)((__global char *)dst + dst_index));
float4   tmp_data  ;
tmp_data.x = src1_data.s0 * src1_data.s0 + src1_data.s1 * src1_data.s1;
tmp_data.y = src1_data.s2 * src1_data.s2 + src1_data.s3 * src1_data.s3;
tmp_data.z = src1_data.s4 * src1_data.s4 + src1_data.s5 * src1_data.s5;
tmp_data.w = src1_data.s6 * src1_data.s6 + src1_data.s7 * src1_data.s7;
dst_data.x = ((dst_index + 0 >= dst_start) && (dst_index + 0 < dst_end)) ? tmp_data.x : dst_data.x;
dst_data.y = ((dst_index + 4 >= dst_start) && (dst_index + 4 < dst_end)) ? tmp_data.y : dst_data.y;
dst_data.z = ((dst_index + 8 >= dst_start) && (dst_index + 8 < dst_end)) ? tmp_data.z : dst_data.z;
dst_data.w = ((dst_index + 12 >= dst_start) && (dst_index + 12 < dst_end)) ? tmp_data.w : dst_data.w;
*((__global float4 *)((__global char *)dst + dst_index)) = dst_data;
}
}
#endif

