
__kernel void BlendLinear_C1_D0(
__global uchar4 *dst,
__global uchar4 *img1,
__global uchar4 *img2,
__global float4 *weight1,
__global float4 *weight2,
int rows,
int cols,
int istep,
int wstep
)
{
int idx = get_global_id(0);
int idy = get_global_id(1);
if (idx << 2 < cols && idy < rows)
{
int pos = mad24(idy,istep >> 2,idx);
int wpos = mad24(idy,wstep >> 2,idx);
float4 w1 = weight1[wpos], w2 = weight2[wpos];
dst[pos] = convert_uchar4((convert_float4(img1[pos]) * w1 +
convert_float4(img2[pos]) * w2) / (w1 + w2 + 1e-5f));
}
}
__kernel void BlendLinear_C4_D0(
__global uchar4 *dst,
__global uchar4 *img1,
__global uchar4 *img2,
__global float *weight1,
__global float *weight2,
int rows,
int cols,
int istep,
int wstep
)
{
int idx = get_global_id(0);
int idy = get_global_id(1);
if (idx < cols && idy < rows)
{
int pos = mad24(idy,istep >> 2,idx);
int wpos = mad24(idy,wstep, idx);
float w1 = weight1[wpos];
float w2 = weight2[wpos];
dst[pos] = convert_uchar4((convert_float4(img1[pos]) * w1 +
convert_float4(img2[pos]) * w2) / (w1 + w2 + 1e-5f));
}
}
__kernel void BlendLinear_C1_D5(
__global float4 *dst,
__global float4 *img1,
__global float4 *img2,
__global float4 *weight1,
__global float4 *weight2,
int rows,
int cols,
int istep,
int wstep
)
{
int idx = get_global_id(0);
int idy = get_global_id(1);
if (idx << 2 < cols && idy < rows)
{
int pos = mad24(idy,istep >> 2,idx);
int wpos = mad24(idy,wstep >> 2,idx);
float4 w1 = weight1[wpos], w2 = weight2[wpos];
dst[pos] = (img1[pos] * w1 + img2[pos] * w2) / (w1 + w2 + 1e-5f);
}
}
__kernel void BlendLinear_C4_D5(
__global float4 *dst,
__global float4 *img1,
__global float4 *img2,
__global float *weight1,
__global float *weight2,
int rows,
int cols,
int istep,
int wstep
)
{
int idx = get_global_id(0);
int idy = get_global_id(1);
if (idx < cols && idy < rows)
{
int pos = mad24(idy,istep >> 2,idx);
int wpos = mad24(idy,wstep, idx);
float w1 = weight1[wpos];
float w2 = weight2[wpos];
dst[pos] = (img1[pos] * w1 + img2[pos] * w2) / (w1 + w2 + 1e-5f);
}
}

