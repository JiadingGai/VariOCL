
#if defined (DOUBLE_SUPPORT)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
#endif
#define CV_PI   3.1415926535897932384626433832795
__kernel void arithm_polarToCart_mag_D5 (__global float *src1, int src1_step, int src1_offset,
__global float *src2, int src2_step, int src2_offset,
__global float *dst1, int dst1_step, int dst1_offset,
__global float *dst2, int dst2_step, int dst2_offset,
int rows, int cols, int angInDegree)
{
int x = get_global_id(0);
int y = get_global_id(1);
if (x < cols && y < rows)
{
int src1_index = mad24(y, src1_step, (x << 2) + src1_offset);
int src2_index = mad24(y, src2_step, (x << 2) + src2_offset);
int dst1_index = mad24(y, dst1_step, (x << 2) + dst1_offset);
int dst2_index = mad24(y, dst2_step, (x << 2) + dst2_offset);
float x = *((__global float *)((__global char *)src1 + src1_index));
float y = *((__global float *)((__global char *)src2 + src2_index));
float ascale = CV_PI/180.0;
float alpha  = angInDegree == 1 ? y * ascale : y;
float a = cos(alpha) * x;
float b = sin(alpha) * x;
*((__global float *)((__global char *)dst1 + dst1_index)) = a;
*((__global float *)((__global char *)dst2 + dst2_index)) = b;
}
}
#if defined (DOUBLE_SUPPORT)
__kernel void arithm_polarToCart_mag_D6 (__global double *src1, int src1_step, int src1_offset,
__global double *src2, int src2_step, int src2_offset,
__global double *dst1, int dst1_step, int dst1_offset,
__global double *dst2, int dst2_step, int dst2_offset,
int rows, int cols, int angInDegree)
{
int x = get_global_id(0);
int y = get_global_id(1);
if (x < cols && y < rows)
{
int src1_index = mad24(y, src1_step, (x << 3) + src1_offset);
int src2_index = mad24(y, src2_step, (x << 3) + src2_offset);
int dst1_index = mad24(y, dst1_step, (x << 3) + dst1_offset);
int dst2_index = mad24(y, dst2_step, (x << 3) + dst2_offset);
double x = *((__global double *)((__global char *)src1 + src1_index));
double y = *((__global double *)((__global char *)src2 + src2_index));
float ascale = CV_PI/180.0;
double alpha  = angInDegree == 1 ? y * ascale : y;
double a = cos(alpha) * x;
double b = sin(alpha) * x;
*((__global double *)((__global char *)dst1 + dst1_index)) = a;
*((__global double *)((__global char *)dst2 + dst2_index)) = b;
}
}
#endif
__kernel void arithm_polarToCart_D5 (__global float *src,  int src_step,  int src_offset,
__global float *dst1, int dst1_step, int dst1_offset,
__global float *dst2, int dst2_step, int dst2_offset,
int rows, int cols, int angInDegree)
{
int x = get_global_id(0);
int y = get_global_id(1);
if (x < cols && y < rows)
{
int src_index  = mad24(y, src_step,  (x << 2) + src_offset);
int dst1_index = mad24(y, dst1_step, (x << 2) + dst1_offset);
int dst2_index = mad24(y, dst2_step, (x << 2) + dst2_offset);
float y = *((__global float *)((__global char *)src + src_index));
float ascale = CV_PI/180.0;
float alpha  = angInDegree == 1 ? y * ascale : y;
float a = cos(alpha);
float b = sin(alpha);
*((__global float *)((__global char *)dst1 + dst1_index)) = a;
*((__global float *)((__global char *)dst2 + dst2_index)) = b;
}
}
#if defined (DOUBLE_SUPPORT)
__kernel void arithm_polarToCart_D6 (__global float *src,  int src_step,  int src_offset,
__global float *dst1, int dst1_step, int dst1_offset,
__global float *dst2, int dst2_step, int dst2_offset,
int rows, int cols, int angInDegree)
{
int x = get_global_id(0);
int y = get_global_id(1);
if (x < cols && y < rows)
{
int src_index  = mad24(y, src_step,  (x << 3) + src_offset);
int dst1_index = mad24(y, dst1_step, (x << 3) + dst1_offset);
int dst2_index = mad24(y, dst2_step, (x << 3) + dst2_offset);
double y = *((__global double *)((__global char *)src + src_index));
float ascale = CV_PI/180.0;
double alpha  = angInDegree == 1 ? y * ascale : y;
double a = cos(alpha);
double b = sin(alpha);
*((__global double *)((__global char *)dst1 + dst1_index)) = a;
*((__global double *)((__global char *)dst2 + dst2_index)) = b;
}
}
#endif

