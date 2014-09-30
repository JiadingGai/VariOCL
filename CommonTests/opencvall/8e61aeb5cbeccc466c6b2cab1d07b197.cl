
#pragma OPENCL EXTENSION cl_amd_printf : enable
#if defined (__ATI__)
#pragma OPENCL EXTENSION cl_amd_fp64:enable
#elif defined (__NVIDIA__)
#pragma OPENCL EXTENSION cl_khr_fp64:enable
#endif
__kernel void columnSum_C1_D5(__global float* src,__global float* dst,int srcCols,int srcRows,int srcStep,int dstStep)
{
const int x = get_global_id(0);
srcStep >>= 2;
dstStep >>= 2;
if (x < srcCols)
{
int srcIdx = x ;
int dstIdx = x ;
float sum = 0;
for (int y = 0; y < srcRows; ++y)
{
sum += src[srcIdx];
dst[dstIdx] = sum;
srcIdx += srcStep;
dstIdx += dstStep;
}
}
}

