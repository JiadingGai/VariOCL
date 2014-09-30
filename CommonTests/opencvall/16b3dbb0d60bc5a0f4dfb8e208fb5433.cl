
#if defined (DOUBLE_SUPPORT)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
#endif
#define INF_FLOAT -88.029694
#define INF_DOUBLE -709.0895657128241
__kernel void arithm_log_D5(int rows, int cols, int srcStep, int dstStep, int srcOffset, int dstOffset, __global float *src, __global float *dst)
{
int x = get_global_id(0);
int y = get_global_id(1);
if(x < cols && y < rows )
{
x = x << 2;
int srcIdx = mad24( y, srcStep, x + srcOffset);
int dstIdx = mad24( y, dstStep, x + dstOffset);
float src_data = *((__global float *)((__global char *)src + srcIdx));
float dst_data = (src_data == 0) ? INF_FLOAT : log(fabs(src_data));
*((__global float *)((__global char *)dst + dstIdx)) = dst_data;
}
}
#if defined (DOUBLE_SUPPORT)
__kernel void arithm_log_D6(int rows, int cols, int srcStep, int dstStep, int srcOffset, int dstOffset, __global double *src, __global double *dst)
{
int x = get_global_id(0);
int y = get_global_id(1);
if(x < cols && y < rows )
{
x = x << 3;
int srcIdx = mad24( y, srcStep, x + srcOffset);
int dstIdx = mad24( y, dstStep, x + dstOffset);
double src_data = *((__global double *)((__global char *)src + srcIdx));
double dst_data = (src_data == 0) ? INF_DOUBLE : log(fabs(src_data));
*((__global double *)((__global char *)dst + dstIdx)) = dst_data;
}
}
#endif

