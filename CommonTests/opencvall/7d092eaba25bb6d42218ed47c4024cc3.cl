
#if defined (DOUBLE_SUPPORT)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
typedef double F;
typedef double4 F4;
#define convert_F4 convert_double4;
#else
typedef float F;
typedef float4 F4;
#define convert_F4 convert_float4;
#endif
__kernel void arithm_pow_D5 (__global float *src1, int src1_step, int src1_offset,
__global float *dst,  int dst_step,  int dst_offset,
int rows, int cols, int dst_step1,
F p)
{
int x = get_global_id(0);
int y = get_global_id(1);
if(x < cols && y < rows)
{
int src1_index = mad24(y, src1_step, (x << 2) + src1_offset);
int dst_index  = mad24(y, dst_step,  (x << 2) + dst_offset);
float src1_data = *((__global float *)((__global char *)src1 + src1_index));
float tmp = src1_data > 0 ? exp(p * log(src1_data)) : (src1_data == 0 ? 0 : exp(p * log(fabs(src1_data))));
*((__global float *)((__global char *)dst + dst_index)) = tmp;
}
}
#if defined (DOUBLE_SUPPORT)
__kernel void arithm_pow_D6 (__global double *src1, int src1_step, int src1_offset,
__global double *dst,  int dst_step,  int dst_offset,
int rows, int cols, int dst_step1,
F p)
{
int x = get_global_id(0);
int y = get_global_id(1);
if(x < cols && y < rows)
{
int src1_index = mad24(y, src1_step, (x << 3) + src1_offset);
int dst_index  = mad24(y, dst_step,  (x << 3) + dst_offset);
double src1_data = *((__global double *)((__global char *)src1 + src1_index));
double tmp = src1_data > 0 ? exp(p * log(src1_data)) : (src1_data == 0 ? 0 : exp(p * log(fabs(src1_data))));
*((__global double *)((__global char *)dst + dst_index)) = tmp;
}
}
#endif

